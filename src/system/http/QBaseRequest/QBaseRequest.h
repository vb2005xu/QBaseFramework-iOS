//
//  QBaseRequest.h
//  QBaseFramework
//
//  Created by andy on 9/20/14.
//  Copyright (c) 2014 streakq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QBaseVendor.h"

typedef void (^QBaseRequestBody) (id<AFMultipartFormData> formData);
typedef void (^QBaseRequestComplete) ( id result, NSError *err);

@interface QBaseRequest : NSObject

/**
 *  GET请求
 *
 *  @param url           请求链接
 *  @param params        请求参数
 *  @param completeBlock 请求完成回调
 */
+ (void)GET:(NSString *)url
     params:(NSDictionary *)params
   complete:(QBaseRequestComplete)completeBlock;

/**
 *  POST请求
 *
 *  @param url           请求链接
 *  @param params        请求参数
 *  @param completeBlock 请求完成回调
 */
+ (void)POST:(NSString *)url
      params:(NSDictionary *)params
    complete:(QBaseRequestComplete)completeBlock;

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
        body:(QBaseRequestBody)bodyBlock
    complete:(QBaseRequestComplete)completeBlock;

@end
