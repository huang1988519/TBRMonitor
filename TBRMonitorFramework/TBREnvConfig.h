//
//  TBREnvConfig.h
//  Usage
//
//  Created by huanwh on 16/4/12.
//  Copyright © 2016年 huanwh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TBREnvConfig : NSObject {
}

#pragma mark -  电量
@property (assign) float minBatteryLevel;//默认为20%，低于这个值通知注册通知的对象
@property (assign) BOOL  enableDebugInfo;//是否打开debug 开关。打开后，会显示debug信息

#pragma mark - URL
@property (copy,readonly) NSMutableArray * allowHosts;//设定需要监控的host 列表

+(instancetype)shareInstance;
@end


extern NSString * const BundleIdentify;



#ifdef TBR_DEBUG
#define TBRLog(FORMAT, ...) fprintf(stderr,"\n\n||===========================\n||\n||  [TBR USAGE]\n||  %s\n||\n||===========================\n", [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define TBRLog(...)
#endif
