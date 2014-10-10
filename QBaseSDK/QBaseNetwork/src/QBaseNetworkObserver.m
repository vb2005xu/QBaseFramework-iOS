//
//  QBaseNetwork.m
//  QBaseNetwork
//
//  Created by andy on 9/27/14.
//  Copyright (c) 2014 streakq. All rights reserved.
//

#import "QBaseNetworkObserver.h"

@implementation QBaseNetworkObserver
DEFINE_SINGLETON_FOR_CLASS(QBaseNetworkObserver)

/**
 *  开始监听网络状态
 */
- (void)startNotifier
{
    _reach = [Reachability reachabilityWithHostname:@"www.baidu.com"];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    
    [_reach startNotifier];
}

/**
 *  网络状态发生改变，获取通知回调
 */
- (void)reachabilityChanged:(NSNotification *)note
{
    switch (_reach.currentReachabilityStatus) {
        case ReachableViaWiFi:
            _status = QBaseNetStatus_WiFi;
            break;
        case ReachableViaWWAN:
            _status = QBaseNetStatus_WWAN;
            break;
        case NotReachable:
            _status = QBaseNetStatus_None;
            break;
        default:
            break;
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:kQBaseNetStatusChangedNotification object:self];
}

/**
 *  帮助对象注册网络状态变化通知
 */
- (void)registNotification:(NSObject *)obj selector:(SEL)selector
{
    [[NSNotificationCenter defaultCenter] addObserver:obj
                                             selector:selector
                                                 name:kQBaseNetStatusChangedNotification
                                               object:nil];
}


@end
