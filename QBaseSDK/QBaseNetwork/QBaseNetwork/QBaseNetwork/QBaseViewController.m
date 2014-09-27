//
//  QBaseViewController.m
//  QBaseNetwork
//
//  Created by andy on 9/27/14.
//  Copyright (c) 2014 streakq. All rights reserved.
//

#import "QBaseViewController.h"

@interface QBaseViewController ()

@end

@implementation QBaseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[QBaseNetworkListener sharedQBaseNetworkListener] registNotification:self
                                                                 selector:@selector(reachabilityChanged:)];
}

- (void)reachabilityChanged:(NSNotification *)note
{
    NSLog(@"当前网络状态发生变化");
    switch ([QBaseNetworkListener sharedQBaseNetworkListener].status) {
        case QBaseNetStatus_None:
            NSLog(@"无网络");
            break;
        case QBaseNetStatus_WWAN:
            NSLog(@"WWAN");
            break;
        case QBaseNetStatus_WiFi:
            NSLog(@"Wifi");
            break;
        default:
            break;
    };
}

@end
