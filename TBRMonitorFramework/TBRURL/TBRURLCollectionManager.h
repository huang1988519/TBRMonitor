//
//  TBRURLCollectionManager.h
//  负责整理用户请求 并 写入文件
//
//  @description
//  收到内存警告和app 进入后台时会刷新请求写入本地 Record.text 文件，并清空url 列表
//
//  Created by huanwh on 16/4/12.
//  Copyright © 2016年 huanwh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TBRURLCollectionManager : NSObject
{
    NSMutableDictionary * items;
    
}
@property(assign,readonly) float interval;//间隔

+(instancetype)shareInstance;

/**
 *  网络请求监控，写文件间隔
 *  如果 second <=0 会暂定掉自动保存，否则自动发送
 *
 *  @param second 写文件时间间隔
 */
+(void)setIntervalOfCheckRequests:(float)second;

/**
 *  请求开始
 *
 *  @param request 当前网络请求
 */
+(void)startRequest:(NSURLRequest *)request;
/**
 *  网路请求完成并 记录
 *
 *  @param request 当前网络请求
 */
+(void)injectFinishRequestWithRequest:(NSURLRequest *)request;
/**
 *  网络请求收到数据并统计长度
 *
 *  @param request 当前网络请求
 *  @param length  当前接收到数据的长度
 */
+(void)injectRecieveDataWithRequest:(NSURLRequest *)request recieveLenght:(double)length;
/**
 *  网络请求失败并 记录
 *
 *  @param request 当前网络请求
 *  @param error   网络失败Error
 */
+(void)injectFailedRequestWithRequest:(NSURLRequest *)request failedError:(NSError *)error;
/**
 *  发出的网络请求收到 回应 并 记录
 *
 *  @param response 当前网络请求收到的回应
 *  @param request  当前网络请求
 */
+(void)injectReponse:(NSURLResponse *)response request:(NSURLRequest *)request;
@end




@interface TBRURLNode : NSObject
@property(nonatomic, strong) NSString * key;
@property(nonatomic, strong) NSString * urlString;
@property(nonatomic, strong) NSString * httpMethed;// get and post
@property(nonatomic, strong) NSNumber * stateCode; // http response 状态码
@property(nonatomic, strong) NSString * stateCodeLocalDescription;//状态码本地描述
@property(nonatomic, strong) NSNumber * expectedContentLength;
@property(nonatomic, strong) NSString * state;
@property(nonatomic, strong) NSString * errorDescription;
@property(nonatomic, strong) NSNumber * recieveLength;
@property(nonatomic, strong) NSNumber * recieveResponse_at;
@property(nonatomic, strong) NSNumber * create_at;
@property(nonatomic, strong, readonly) NSNumber * update_at;

@end