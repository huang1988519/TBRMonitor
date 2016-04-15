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
@property(nonatomic, copy) TBRDeviceInfoHandle observeHandle;
@property(nonatomic, assign) float interval;
@end

@implementation TBRDeviceUsage


static long prevMemUsage = 0;
static long curMemUsage = 0;
static long memUsageDiff = 0;
static long curFreeMem = 0;

static long cpuUsage = 0;

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
-(instancetype)initWithMemoryHandle:(TBRDeviceInfoHandle)handle {
    self = [self init];
    if (self) {
        _observeHandle = handle;
    }
    return self;
}
+(instancetype)observeMemoryHandle:(TBRDeviceInfoHandle)observer {
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
 *  获取cpu
 *
 *  @return cpu 使用率
 */
float cpu_usage()
{
    kern_return_t kr;
    task_info_data_t tinfo;
    mach_msg_type_number_t task_info_count;
    
    task_info_count = TASK_INFO_MAX;
    kr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)tinfo, &task_info_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    
    task_basic_info_t      basic_info;
    thread_array_t         thread_list;
    mach_msg_type_number_t thread_count;
    
    thread_info_data_t     thinfo;
    mach_msg_type_number_t thread_info_count;
    
    thread_basic_info_t basic_info_th;
    uint32_t stat_thread = 0; // Mach threads
    
    basic_info = (task_basic_info_t)tinfo;
    
    // get threads in the task
    kr = task_threads(mach_task_self(), &thread_list, &thread_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    if (thread_count > 0)
        stat_thread += thread_count;
    
    long tot_sec = 0;
    long tot_usec = 0;
    float tot_cpu = 0;
    int j;
    
    for (j = 0; j < thread_count; j++)
    {
        thread_info_count = THREAD_INFO_MAX;
        kr = thread_info(thread_list[j], THREAD_BASIC_INFO,
                         (thread_info_t)thinfo, &thread_info_count);
        if (kr != KERN_SUCCESS) {
            return -1;
        }
        
        basic_info_th = (thread_basic_info_t)thinfo;
        
        if (!(basic_info_th->flags & TH_FLAGS_IDLE)) {
            tot_sec = tot_sec + basic_info_th->user_time.seconds + basic_info_th->system_time.seconds;
            tot_usec = tot_usec + basic_info_th->user_time.microseconds + basic_info_th->system_time.microseconds;
            tot_cpu = tot_cpu + basic_info_th->cpu_usage / (float)TH_USAGE_SCALE * 100.0;
        }
        
    } // for each thread
    
    kr = vm_deallocate(mach_task_self(), (vm_offset_t)thread_list, thread_count * sizeof(thread_t));
    assert(kr == KERN_SUCCESS);
    
    
    return tot_cpu;
}

/**
 *  快照
 */
-(void) captureMemUsage {
    prevMemUsage = curMemUsage;
    curMemUsage = [self usedMemory];
    memUsageDiff = curMemUsage - prevMemUsage;
    curFreeMem = [self freeMemory];
    
    cpuUsage = cpu_usage();
}
-(void)observeMemoryChanged {
    //快照
    [self captureMemUsage];
    
    if (_observeHandle) {
        _observeHandle(curMemUsage/1024.0f,curFreeMem/1024.0f, cpuUsage);
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
