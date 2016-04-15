//
//  TBRMonitor.h
//  TBRMonitor
//
//  Created by huanwh on 16/4/14.
//  Copyright © 2016年 Alibaba-inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TBRMonitorDelegate <NSObject>
@required
-(void)applicationRecieveBadUrl:(NSDictionary *)dic;
@optional
-(void)applicationElectricityChanged:(float)level;
-(void)applicationMemoryUsed:(float)usedSpace free:(float)freeSpace;
@end


@interface TBRMonitor : NSObject
+(void)startMonotor;
+(void)startMonotorWithDelegate:(id<TBRMonitorDelegate>)delegate;
@end


