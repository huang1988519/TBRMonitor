//
//  TBRElectricity.h
//  Usage
//
//  Created by huanwh on 16/4/11.
//  Copyright © 2016年 huanwh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^TBElectrictiyHandle)(float);

@interface TBRElectricity : NSObject
/**
 *  设置电量阈值
 *
 *  @param minLevel 电量阈值 ，默认 20%
 */
+(void)setMinElectricityLevel:(float)minLevel;
/**
 *  监听电量变化
 *
 *  @param electricityLevel 添加需要监听的回调
 *
 *  @return 返回当前电量管理类
 */
+(instancetype)electricityLevel:(TBElectrictiyHandle)electricityLevel;
@end

extern NSString * const TBDeviceBatteryStateDidChangeNotification;
