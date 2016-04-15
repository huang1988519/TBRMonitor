//
//  TBRURLGuard.m
//  Usage
//
//  Created by huanwh on 16/4/13.
//  Copyright © 2016年 huanwh. All rights reserved.
//

#import "TBRURLGuard.h"
#import "UIKit/UIKit.h"

NSString * const TBRURLErrorStateChangedNotification = @"TBRURLErrorStateChangedNotification";
static NSString * TBRURLRecieveLenghtKey = @"TBRURLRecieveLenghtKey";

@implementation TBRURLGuard

+(instancetype)sharInstance {
    static TBRURLGuard * instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TBRURLGuard alloc] init];
    });
    return instance;
}
-(instancetype)init {
    self = [super init];
    if (self) {
        _errorUrlList = [NSMutableArray array];
        _countOfTotalRequest = 0;
        recieveLength = [[NSUserDefaults standardUserDefaults] doubleForKey:TBRURLRecieveLenghtKey];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(synchronous) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}
#pragma mark - Public

+(void)addErrorUrlDictionay:(NSDictionary *)dictionaryOfBadUrl {
    [[NSNotificationCenter defaultCenter] postNotificationName:TBRURLErrorStateChangedNotification object:dictionaryOfBadUrl];
    [[TBRURLGuard sharInstance] addErrorUrlNode:dictionaryOfBadUrl];
}
+(void)observerErrorUrlChange:(TBRURLChangeHandle)errorUrlChangeBlock {
    [[TBRURLGuard sharInstance] observerErrorUrlChange:errorUrlChangeBlock];
}
#pragma mark - 成功率
+(void)increaseTotalRequestCount {
    [[TBRURLGuard sharInstance] increaseCountOfTotalRequest];
}
+(NSInteger)countOfTotalRequest {
    return [[TBRURLGuard sharInstance] countOfTotalRequest];
}
#pragma mark - 流量
+(void)appendRecieveLength:(double)length {
    [[TBRURLGuard sharInstance] appendRecieveLength:length];
}
+(double)networkRecieveDataLenght {
    return [[TBRURLGuard sharInstance] networkRecieveDataLenght];
}
+(void)reset {
    [[NSUserDefaults standardUserDefaults] setDouble:0 forKey:TBRURLRecieveLenghtKey];
}
#pragma mark - 
-(void)increaseCountOfTotalRequest {
    _countOfTotalRequest++;
}
-(void)appendRecieveLength:(double)length  {
    recieveLength += length;
}
-(double)networkRecieveDataLenght {
    return recieveLength;
}
-(void)synchronous {
    [[NSUserDefaults standardUserDefaults] setDouble:recieveLength forKey:TBRURLRecieveLenghtKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (void)addErrorUrlNode:(NSDictionary *)badUrl {
    if (badUrl && ![_errorUrlList containsObject:badUrl]) {
        [_errorUrlList addObject:badUrl];
        
        if (_errorUrlChangeBlock) {
            NSMutableDictionary * appendParams = [NSMutableDictionary dictionaryWithDictionary:badUrl];
            
            NSDictionary * collectionDic = @{@"total":@(_countOfTotalRequest),
                                     @"error":@(_errorUrlList.count)};
            appendParams[@"Collection"] = collectionDic;
            
            _errorUrlChangeBlock(appendParams);
        }
    }
}
- (void)observerErrorUrlChange:(TBRURLChangeHandle)errorUrlChangeBlock {
    _errorUrlChangeBlock = errorUrlChangeBlock;
}
@end
