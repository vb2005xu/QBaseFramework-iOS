//
//  QBaseNetwork.h
//  QBaseNetwork
//
//  Created by andy on 9/27/14.
//  Copyright (c) 2014 streakq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"

/// 网络状态
typedef enum QBaseNetStatus {
    QBaseNetStatus_None,    // 无网络
    QBaseNetStatus_WiFi,    // WiFi
    QBaseNetStatus_WWAN     // 2G/3G
}QBaseNetStatus;

// 注册通知
#define kQBaseNetStatusChangedNotification @"kQBaseNetStatusChangedNotification"
@interface QBaseNetworkObserver : NSObject
{
    Reachability *_reach;
}
DEFINE_SINGLETON_FOR_HEADER(QBaseNetworkObserver)

/**
 *  当前网络状态
 */
@property (nonatomic, assign, readonly) QBaseNetStatus status;

/**
 *  开始监听网络状态
 */
- (void)startNotifier;

/**
 *  帮助对象注册网络状态变化通知
 */
- (void)registNotification:(NSObject *)obj selector:(SEL)selector;

@end
