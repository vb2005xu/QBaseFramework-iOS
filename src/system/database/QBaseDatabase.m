//
//  QBaseDatabase.m
//  QBaseFramework
//
//  Created by andy on 9/20/14.
//  Copyright (c) 2014 streakq. All rights reserved.
//

#import "QBaseDatabase.h"

@implementation QBaseDatabase
+ (QBaseDatabase *)sharedQBaseDatabase
{
    static QBaseDatabase *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] databaseQueueWithPath:DB_PATH];
    });
    return instance; \
    return nil;
}


@end
