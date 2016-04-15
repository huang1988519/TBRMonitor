//
//  TBREnvConfig.m
//  Usage
//
//  Created by huanwh on 16/4/12.
//  Copyright © 2016年 huanwh. All rights reserved.
//

#import "TBREnvConfig.h"
NSString * const BundleIdentify = @"[TBR USAGE]";

@implementation TBREnvConfig

static TBREnvConfig * instance = nil;
+(instancetype)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TBREnvConfig alloc] init];
    });
    
    return instance;
}

-(instancetype)init {
    self = [super init];
    if (self) {
        _enableDebugInfo = true;
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self configAllowHosts];
        });
    }
    return self;
}
-(void)setHosts:(NSArray *)hosts {
    if (!hosts) {
        return;
    }
    _allowHosts = [NSMutableArray arrayWithArray:hosts];
}

#pragma mark -
-(void)configAllowHosts {
    @synchronized (self) {
        NSString * path = [[NSBundle mainBundle] pathForResource:@"Hosts" ofType:@"plist"];
        if (path == nil) {
            NSLog(@"查无配置host 文件");
            return ;
        }
        NSArray * hosts = [NSArray arrayWithContentsOfFile:path];
        if (!hosts) {
            NSLog(@"初始化 host 过滤表 为空");
            return;
        }
        if (![hosts isKindOfClass:[NSArray class]]) {
            NSLog(@"配置host格式错误，要求配置为NSArray -> %@",[hosts class]);
#ifdef DEBUG
            NSAssert(true, @"配置host格式错误，要求配置为NSArray");
#endif
            return;
        }
        TBRLog(@"%@",hosts);
        [self setHosts:hosts];
    }
}
@end
