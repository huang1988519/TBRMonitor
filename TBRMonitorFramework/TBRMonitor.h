//
//  TBRMonitor.h
//  TBRMonitor
//
//  Created by huanwh on 16/4/14.
//  Copyright © 2016年 Alibaba-inc. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 *  TBRMonitor 代理方法
 */
@protocol TBRMonitorDelegate <NSObject>
@required
/**
 *  TBRMonitorDelegate 必须实现次方法，以及时发现失败的URL
 *
 *  @param dic 失败的URL
 */
-(void)applicationRecieveBadUrl:(NSDictionary *)dic;
@optional
/**
 * TBRMonitorDelegate 可选方法。当需要监听电量变化时实现此方法
 *
 *  @param level 当前电量
 */
-(void)applicationElectricityChanged:(float)level;
/**
 * TBRMonitorDelegate 可选方法。当需要监听RAM变化时实现此方法。
 *
 *  @param usedSpace 已使用ram
 *  @param freeSpace 剩余ram
 *  @param cpuUsage  当前cpu性能消耗
 */
-(void)applicationMemoryUsed:(float)usedSpace free:(float)freeSpace cpu:(float)cpuUsage;
@end

/** API 暴漏接口

* 电量监听类 TBRElectricity
* URL 统计类 TBRURLGuard
* 内存和cpu监听类为同一个 TBRDeviceUsage
 */
@interface TBRMonitor : NSObject
/**
 *  不添加observer，启动 监听
 */
+(void)startMonotor;
/**
 *  添加observer 并 启动监听
 *
 *  @param delegate 监听者
 */
+(void)startMonotorWithDelegate:(id<TBRMonitorDelegate>)delegate;
@end


