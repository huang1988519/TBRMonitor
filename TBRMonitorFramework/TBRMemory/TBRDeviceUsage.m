//
//  TBRMemory.m
//  Usage
//
//  Created by huanwh on 16/4/13.
//  Copyright © 2016年 huanwh. All rights reserved.
//

#import "TBRDeviceUsage.h"
#import <mach/mach.h>

@interface TBRDeviceUsage () {
    NSTimer * _timer;
}
@property(nonatomic, copy) TBRMemoryHandle observeHandle;
@property(nonatomic, assign) float interval;
@end

@implementation TBRDeviceUsage


static long prevMemUsage = 0;
static long curMemUsage = 0;
static long memUsageDiff = 0;
static long curFreeMem = 0;
-(instancetype)init {
    self = [super init];
    if (self) {
        _interval = 1.0;//一秒刷新一次
        _timer = [NSTimer scheduledTimerWithTimeInterval:_interval target:self selector:@selector(observeMemoryChanged) userInfo:nil repeats:true];
        [_timer fire];
    }
    return self;
}
-(void)dealloc {
    if (_timer && [_timer isValid]) {
        [_timer invalidate];
    }
    _timer = nil;
}
-(instancetype)initWithMemoryHandle:(TBRMemoryHandle)handle {
    self = [self init];
    if (self) {
        _observeHandle = handle;
    }
    return self;
}
+(instancetype)observeMemoryHandle:(TBRMemoryHandle)observer {
    return [[TBRDeviceUsage alloc] initWithMemoryHandle:observer];
}
#pragma mark - private
/**
 *  空闲内存
 *
 *  @return 空闲内存。 单位bytes
 */
-(vm_size_t) freeMemory {
    mach_port_t host_port = mach_host_self();
    mach_msg_type_number_t host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    vm_size_t pagesize;
    vm_statistics_data_t vm_stat;
    
    host_page_size(host_port, &pagesize);
    (void) host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size);
    return vm_stat.free_count * pagesize;
}
/**
 *  已使用内存
 *
 *  @return 已使用内存。 单位bytes
 */
-(vm_size_t) usedMemory {
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    kern_return_t kerr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)&info, &size);
    return (kerr == KERN_SUCCESS) ? info.resident_size : 0; // size in bytes
}

/**
 *  快照
 */
-(void) captureMemUsage {
    prevMemUsage = curMemUsage;
    curMemUsage = [self usedMemory];
    memUsageDiff = curMemUsage - prevMemUsage;
    curFreeMem = [self freeMemory];
}
-(void)observeMemoryChanged {
    [self captureMemUsage];
    if (_observeHandle) {
        _observeHandle(curMemUsage/1024.0f,curFreeMem/1024.0f);
    }
}
-(NSString*) captureMemUsageGetString{
    return [self captureMemUsageGetString: @"Memory used %7.1f (%+5.0f), free %7.1f kb"];
}

-(NSString*) captureMemUsageGetString:(NSString*) formatstring {
    [self captureMemUsage];
    return [NSString stringWithFormat:formatstring,curMemUsage/1000.0f, memUsageDiff/1000.0f, curFreeMem/1000.0f];
    
}
@end
