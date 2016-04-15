//
//  TBRMonitor.m
//  TBRMonitor
//
//  Created by huanwh on 16/4/14.
//  Copyright © 2016年 huanwh. All rights reserved.
//

#import "TBRMonitor.h"
#import "TBRElectricity.h"
#import "TBRDeviceUsage.h"
#import "TBRURLProtocol.h"
#import "TBRURLGuard.h"

@interface TBRMonitor () {
    TBRDeviceUsage * deviceObserver;
    TBRElectricity * electricityObserver;
}
@property(nonatomic, weak) id <TBRMonitorDelegate> delegate;
@end

@implementation TBRMonitor
+(instancetype)shareInstance {
    static TBRMonitor * monitor = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        monitor = [[TBRMonitor alloc] init];
    });
    return monitor;
}
-(instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}
-(void)setDelegate:(id<TBRMonitorDelegate>)delegate {
    if ([delegate respondsToSelector:@selector(applicationElectricityChanged:)]) {
        electricityObserver = [TBRElectricity electricityLevel:^(float level) {
            [delegate applicationElectricityChanged:level];
        }];
    }
    if ([delegate respondsToSelector:@selector(applicationMemoryUsed:free:)]) {
        deviceObserver = [TBRDeviceUsage observeMemoryHandle:^(float usage, float free) {
            [delegate applicationMemoryUsed:usage free:free];
        }];
    }
    
    [TBRURLGuard observerErrorUrlChange:^(NSDictionary * badUrl) {
        [delegate applicationRecieveBadUrl:badUrl];
    }];
}
#pragma mark - public api
+(void)startMonotor {
    [NSURLProtocol registerClass:[TBRURLProtocol class]];
}
+(void)startMonotorWithDelegate:(id<TBRMonitorDelegate>)delegate {
    [[self class] startMonotor];
    [TBRMonitor shareInstance].delegate = delegate;
}
@end