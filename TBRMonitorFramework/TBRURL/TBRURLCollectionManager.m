//
//  TBRURLCollectionManager.m
//  Usage
//
//  Created by huanwh on 16/4/12.
//  Copyright © 2016年 huanwh. All rights reserved.
//

#import "TBRURLCollectionManager.h"
#import "TBR_NSString+md5.h"
#import <UIKit/UIKit.h>
#import "TBR_NSObject+Property.h"
#import "TBREnvConfig.h"
#import "TBRURLGuard.h"

@interface TBRURLCollectionManager ()
{
    NSFileHandle * fileWriteHandle;
    NSTimer * _timer;

}
@end
@implementation TBRURLCollectionManager

+(instancetype)shareInstance {
    static TBRURLCollectionManager * manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[TBRURLCollectionManager alloc] init];
    });
    return manager;
}
-(instancetype)init {
    self = [super init];
    if (self) {
        _interval = 10.0;
        
        items = [NSMutableDictionary dictionary];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recieveMemeryWarmming) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    return self;
}

-(void)dealloc {
    if (_timer && [_timer isValid]) {
        [_timer invalidate];
        _timer = nil;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark - class methed
+(void)startRequest:(NSURLRequest *)request {
    [[TBRURLCollectionManager shareInstance] startRequest:request];
}
+(void)setIntervalOfCheckRequests:(float)second{
    [[TBRURLCollectionManager shareInstance] setSortTimeInterval:second];
}
+(void)injectFinishRequestWithRequest:(NSURLRequest *)request {
    [[TBRURLCollectionManager shareInstance] injectFinishRequestWithRequest:request];
}
+(void)injectFailedRequestWithRequest:(NSURLRequest *)request failedError:(NSError *)error  {
    [[TBRURLCollectionManager shareInstance] injectFailedRequestWithRequest:request failedError:error];
}
+(void)injectReponse:(NSURLResponse *)response request:(NSURLRequest *)request {
    [[TBRURLCollectionManager shareInstance] injectReponse:response request:request];
}
+(void)injectRecieveDataWithRequest:(NSURLRequest *)request recieveLenght:(double)length {
    [[TBRURLCollectionManager shareInstance] injectRecieveDataWithRequest:request recieveLenght:length];
}
#pragma mark -  private
- (void)startRequest:(NSURLRequest *)request {
    [TBRURLGuard increaseTotalRequestCount];
    
    [self nodeForRequest:request];
}
- (void)setSortTimeInterval:(float)interval {
    _interval = interval;
    if (_interval <= 0) {
        TBRLog(@"关闭 自动保存失败网络请求");
        if (_timer && [_timer isValid]) {
            [_timer invalidate];
            _timer = nil;
        }
        return ;
    }
    _timer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(recieveMemeryWarmming) userInfo:nil repeats:true];
    [_timer fire];
}

-(void)injectFinishRequestWithRequest:(NSURLRequest *)request {
    TBRURLNode * node = [self nodeForRequest:request];
    node.state = @"finish";
}
- (void)injectFailedRequestWithRequest:(NSURLRequest *)request failedError:(NSError *)error {
    TBRURLNode * node = [self nodeForRequest:request];
    node.state = @"failed";
    node.errorDescription = error.localizedDescription;
    
    //收集请求失败的请求
    [TBRURLGuard addErrorUrlDictionay:node.dictionay];
}
- (void)injectReponse:(NSURLResponse *)response request:(NSURLRequest *)request {
    TBRURLNode * node = [self nodeForRequest:request];
    if ([response isMemberOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse *)response;
        node.stateCode = @(httpResponse.statusCode);
        node.stateCodeLocalDescription = [NSHTTPURLResponse localizedStringForStatusCode:httpResponse.statusCode];
    }
    node.expectedContentLength = @(response.expectedContentLength);
    node.recieveResponse_at = @([[NSDate date] timeIntervalSince1970]);
}
- (void)injectRecieveDataWithRequest:(NSURLRequest *)request recieveLenght:(double)length {
    TBRURLNode * node = [self nodeForRequest:request];
    node.recieveLength = [NSNumber numberWithDouble:[node.recieveLength doubleValue] + length];
}
#pragma mark -
+(NSString *)keyForRequest:(NSURLRequest *)request {
    if (!request) {
        int random = arc4random();
        return [NSString stringWithFormat:@"%d",random].md5;
    }
    NSString * absolueString = request.URL.absoluteString;
    NSString * key  = absolueString.md5;
    if (!key) {
        int random = arc4random();
        key = [NSString stringWithFormat:@"%d",random].md5;
    }
    return key;
}
-(TBRURLNode *)nodeForRequest:(NSURLRequest *)request {
    NSString * key = [[self class] keyForRequest:request];
    TBRURLNode * node = items[key];
    if (!node) {
        node = [[TBRURLNode alloc] init];
        node.key = key;
        node.urlString = [request.URL absoluteString];
        if (node.urlString) {
            node.urlString = [request.URL relativeString];
        }
        node.httpMethed = [request HTTPMethod];
        node.create_at = @([[NSDate date] timeIntervalSince1970]);
        items[key] = node;
    }
    return node;
}

-(void)recieveMemeryWarmming {
    if (items.count > 0) {
        [self recordToFile];
    }
    [items removeAllObjects];
    TBRLog(@"收到内存警告，清楚网络记录缓存");
}
-(void)recordToFile {
    if (items.count <= 0) {
        return;
    }
    
    NSMutableString * content = [NSMutableString string];
    
    for (NSString * key in items.allKeys) {
        TBRURLNode * node = items[key];
        //收集没有收到响应的请求
        if (node.recieveResponse_at == 0) {
            [TBRURLGuard addErrorUrlDictionay:node.dictionay];
        }
        NSString * nodeJson = node.jsonString;
        [content appendFormat:@"%@\n",nodeJson];
    }
    
    NSFileHandle *handle = [self fileHandle];
    [handle writeData:[content dataUsingEncoding:NSUTF8StringEncoding]];
    [handle closeFile];
}

//如果是发布环境，隐藏日志文件
-(NSString *)pathForRecord {
#ifdef  DEBUG
    NSString * path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Record.txt"];
#else
    NSString * path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/.Record.txt"];
#endif
    
    BOOL isDir = NO;
    NSFileManager * fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:path isDirectory:&isDir] && !isDir) {
       BOOL sucess = [fileManager createFileAtPath:path contents:[@"" dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
        if (!sucess) {
            TBRLog(@"创建文件 .record.txt  失败");
#ifdef DEBUG
            NSAssert(sucess, @"创建文件 .record.txt  失败");
#endif
        }
    }
    TBRLog(@"path=%@",path);
    return path;
}
-(NSFileHandle *)fileHandle {
    if (!fileWriteHandle) {
        fileWriteHandle = [NSFileHandle fileHandleForUpdatingAtPath:[self pathForRecord]];
    }
    [fileWriteHandle seekToEndOfFile];
    
    return fileWriteHandle;
}
@end



@implementation TBRURLNode
-(instancetype)init {
    self = [super init];
    if (self) {
        _key = @"000000000";
        _urlString = @"";
        _httpMethed = @"";
        _stateCode = @0;
        _stateCodeLocalDescription = @"";
        _expectedContentLength = @(0);
        _state = @"init";
        _errorDescription = @"";
        _recieveResponse_at = 0;
        _create_at = 0;
        _update_at = 0;
    }
    return self;
}
-(void)setCreate_at:(NSNumber *)create_at {
    _create_at = @10;
    _create_at = create_at;
    _update_at = create_at;
}
-(void)setState:(NSString *)state {
    _state = state;
    _update_at = @([[NSDate date] timeIntervalSince1970]);
}
@end