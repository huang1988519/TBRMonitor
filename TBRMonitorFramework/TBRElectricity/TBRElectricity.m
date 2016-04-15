//
//  TBRElectricity.m
//  Usage
//
//  Created by huanwh on 16/4/11.
//  Copyright © 2016年 huanwh. All rights reserved.
//

#import "TBRElectricity.h"
#import "TBREnvConfig.h"

NSString * const TBDeviceBatteryStateDidChangeNotification = @"TBDeviceBatteryStateDidChangeNotification";

@interface TBRElectricity ()
@property(copy, nonatomic) TBElectrictiyHandle electricityBlock;
@end


@implementation TBRElectricity
- (instancetype)init
{
    self = [super init];
    
    if (self) {
    }
    
    return self;
}
+(instancetype)shareInstance {
    static TBRElectricity * instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [TBRElectricity new];
    });
    
    return instance;
}

#pragma mark -  public
+(void)setMinElectricityLevel:(float)minLevel {
    [[TBREnvConfig shareInstance] setMinBatteryLevel:minLevel];
}
+(instancetype)electricityLevel:(TBElectrictiyHandle)electricityLevel{
    TBRElectricity * newObserver = [TBRElectricity new];
    
    [newObserver setElectricityBlock:electricityLevel];
    
    return newObserver;
}
#pragma mark - private
-(void)setMinElectricityLevel:(float)minLevel {
    float minLevelOfElectricity = [[TBREnvConfig shareInstance] minBatteryLevel];
    
    if (minLevel >100) {
        minLevelOfElectricity = 100;
    }else if (minLevel <0) {
        minLevelOfElectricity = 0;
    }else {
        minLevelOfElectricity =  minLevel;
    }
    TBRLog(@"设置最小电量 %f 时发送通知",minLevelOfElectricity);
    [[TBREnvConfig shareInstance] setMinBatteryLevel:minLevelOfElectricity];
}
-(void)electricityLevel:(TBElectrictiyHandle)electricityLevel {
    _electricityBlock = electricityLevel;
    
    //add notificition to observe battery change value;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceBatteryLevelDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(observeElectricityChanged) name:UIDeviceBatteryLevelDidChangeNotification object:nil];
}
-(void)observeElectricityChanged {
    if (_electricityBlock) {
        float level = [self electricity];
        TBRLog([NSString stringWithFormat:@"当前电量 %f ",level]);
        _electricityBlock(level);
    }
}
-(float)electricity {
    UIDevice * device = [UIDevice currentDevice];
    
    device.batteryMonitoringEnabled = true;
    float batteryLevel = device.batteryLevel;
    
    return batteryLevel*100;
}
-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
