//
//  TBRURLProtocol.m
//  Usage
//
//  Created by huanwh on 16/4/12.
//  Copyright © 2016年 huanwh. All rights reserved.
//

#import "TBRURLProtocol.h"
#import "TBREnvConfig.h"
#import "TBRURLCollectionManager.h"

static NSString * const TBRURLProtocolHandleKey = @"TBRURLProtocolHandleKey";


@interface TBRURLProtocol () <NSURLConnectionDataDelegate>
@property(strong) NSURLConnection * connection;
@property(strong) NSArray * hostsList;//需要监控的host 列表
@end

@implementation TBRURLProtocol


#pragma mark - NSURLProtocol
// override 是否打算处理对应的request
+(BOOL)canInitWithRequest:(NSURLRequest *)request {
    NSAssert(request, @"url 不能为空");
    //排重
    if ([NSURLProtocol propertyForKey:TBRURLProtocolHandleKey inRequest:request] || !request) {
        return NO;
    }
    
    NSString * scheme  = [[request URL] scheme];
    NSString * host   = [[request URL] host];
    
    //过滤非http https 的请求
    BOOL isHttpOrHttps = NO;
    if ([scheme caseInsensitiveCompare:@"http"] == NSOrderedSame) {
        isHttpOrHttps =  YES;
    }
    if ([scheme caseInsensitiveCompare:@"https"] == NSOrderedSame) {
        isHttpOrHttps =  YES;
    }
    if (isHttpOrHttps == NO) {
        TBRLog(@"忽略 （%@）",scheme);
        
        return NO;
    }
    
    //判断是否包含需要监听的host. if = nil 监听所有host.
    
    NSArray * allowHosts = [TBREnvConfig shareInstance].allowHosts;
    if (!allowHosts || allowHosts.count <=0) {
        return YES;
    }
    
    BOOL isAllowObserver = NO;
    for (NSString * allowhost in allowHosts) {
        if ([allowhost.uppercaseString isEqualToString:[host uppercaseString]]) {
            isAllowObserver = YES;
            break;
        }
    }

    return isAllowObserver;
}
//overide  抽象 请求。 可以二次修改后返回最新的请求
+(NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    NSAssert(request, @"传入request 不能为空 或者 格式错误");

    NSMutableURLRequest * mutableRequest = [request mutableCopy];
    if (mutableRequest == nil) {
        [TBRURLCollectionManager injectFailedRequestWithRequest:request failedError:[NSError errorWithDomain:@"com.alibaba-inc.read" code:-1000 userInfo:nil]];
    }
//    mutableRequest = [self redirectHostForRequest:mutableRequest];
    return mutableRequest;
}
-(void)startLoading {
    NSMutableURLRequest * request = [self.request mutableCopy];
    
    TBRLog(@"request -> %@",request.URL.absoluteString);
    [NSURLProtocol setProperty:@YES forKey:TBRURLProtocolHandleKey inRequest:request];
    self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
    
    [TBRURLCollectionManager startRequest:request];
}
-(void)stopLoading {
    [self.connection cancel];
}
#pragma mark -  NSURLConnectionDataDelegate
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    
    [TBRURLCollectionManager injectReponse:response request:connection.currentRequest];
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
//    TBRLog(@"%s",__FUNCTION__);
    [self.client URLProtocol:self didLoadData:data];
    
    [TBRURLCollectionManager injectRecieveDataWithRequest:connection.currentRequest recieveLenght:data.length];
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self.client URLProtocolDidFinishLoading:self];
    
    [TBRURLCollectionManager injectFinishRequestWithRequest:connection.currentRequest];
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self.client URLProtocol:self didFailWithError:error];
    
    [TBRURLCollectionManager injectFailedRequestWithRequest:connection.currentRequest  failedError:error];
}
#pragma mark -
//override 替换错误url到本地 html 网页
/*
+(NSMutableURLRequest *)redirectHostForRequest:(NSMutableURLRequest *)request {
    
    if ([request.URL host].length == 0) {
        return [self localErrorHtmlPath];
    }
    
    NSString * originUrlString  = [request.URL absoluteString];
    NSString * originHostString = [request.URL host];
    NSRange hostRange = [originUrlString rangeOfString:originHostString];
    if (hostRange.location ==  NSNotFound) {
        return [self localErrorHtmlPath];
    }
    
    return request;
}
 */
+(NSMutableURLRequest *)localErrorHtmlPath {
    NSString * errPath = [[NSBundle mainBundle] pathForResource:@"404" ofType:@"html"];
    if (!errPath) {
        return nil;
    }
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc] initWithURL:[NSURL fileURLWithPath:errPath]];
    
    return request;
}

@end
