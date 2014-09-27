//
//  QBaseDatabase.h
//  QBaseFramework
//
//  Created by andy on 9/20/14.
//  Copyright (c) 2014 streakq. All rights reserved.
//

#import "FMDatabaseQueue.h"

#define DEFAULE_DB_PATH @"/Users/andy/Desktop/data.db"
@interface QBaseDatabase : FMDatabaseQueue
DEFINE_SINGLETON_FOR_HEADER(QBaseDatabase)

@end
