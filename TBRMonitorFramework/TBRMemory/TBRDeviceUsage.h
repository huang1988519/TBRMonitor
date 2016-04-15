//
//  TBRMemory.h
//  Usage
//
//  Created by huanwh on 16/4/13.
//  Copyright © 2016年 huanwh. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^TBRDeviceInfoHandle)(float usage,float free,float cpuUsage);

@interface TBRDeviceUsage : NSObject {
    
}
+(instancetype)observeMemoryHandle:(TBRDeviceInfoHandle)observer;
@end
