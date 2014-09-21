//
//  QBaseRequest.h
//  QBaseFramework
//
//  Created by andy on 9/20/14.
//  Copyright (c) 2014 streakq. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QBaseRequest;
typedef void (^QBaseRegistBlock) (QBaseRequest *request);
typedef void (^QBaseRequestBodyBlock) (id<AFMultipartFormData> formData);
typedef void (^QBaseRequestCompleteBlock) ( id result, NSError *err);

@interface QBaseRequest : AFHTTPRequestOperationManager

/**
 *  注册请求参数
 *
 *  @param registBlock 注册参数
 */
+ (void)registRequest:(QBaseRegistBlock)registBlock;

/**
 *  GET请求
 *
 *  @param url           请求链接
 *  @param params        请求参数
 *  @param completeBlock 请求完成回调
 */
+ (void)GET:(NSString *)url
     params:(NSDictionary *)params
   complete:(QBaseRequestCompleteBlock)completeBlock;

/**
 *  POST请求
 *
 *  @param url           请求链接
 *  @param params        请求参数
 *  @param completeBlock 请求完成回调
 */
+ (void)POST:(NSString *)url
      params:(NSDictionary *)params
    complete:(QBaseRequestCompleteBlock)completeBlock;

/**
 *  POST请求
 *
 *  @param url           请求链接
 *  @param params        请求参数
 *  @param bodyBlock     请求Body设置
 *  @param completeBlock 请求完成回调
 */
+ (void)POST:(NSString *)url
      params:(NSDictionary *)params
        body:(QBaseRequestBodyBlock)bodyBlock
    complete:(QBaseRequestCompleteBlock)completeBlock;

@end
