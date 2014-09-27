/**
 *  版本更新组件
 *
 *  Created by andy on 14-7-7.
 *  Copyright (c) 2014年 andy. All rights reserved.
 */

#import <Foundation/Foundation.h>

// 提示间隔
#define REMIND_INTERVAL (20)

// 请求URL
#define URL_CHECK_VERSION @"http://192.168.10.136:3000"

/**
 *  更新完成回调Block
 *
 *  @param error  是否出错
 *  @param update 是否更新
 *  @param result 服务器返回数据
 */
typedef void(^UpdateAppCompletionBlock)(NSError *error, BOOL update, id result);

/// 版本更新类
@interface QBaseUpdate : NSObject <UIAlertViewDelegate>
{
    UIAlertView *_alertView;
}

/**
 *  是否打印运行状态 默认关闭
 *
 *  @param isLog 是否打开运行状态
 */
+ (void)logEnabled:(BOOL)isLog;

/**
 *  版本检测组件回调
 *
 *  @param resultBlock 请求回调
 */
+ (void)registUpdateHandle:(UpdateAppCompletionBlock)completionBlock;

/**
 *  开始版本检测
 */
+ (void)startCheck;

@end
