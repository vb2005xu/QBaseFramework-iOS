//
//  QBaseModel.h
//  QBaseFramework
//
//  Created by andy on 9/20/14.
//  Copyright (c) 2014 streakq. All rights reserved.
//

#import "JSONModel.h"

@interface QBaseModel : JSONModel

/**
 *  增删改数据库操作
 */
- (BOOL)executeUpdate:(NSString *)sql, ...;

/**
 *  查找
 */
- (FMResultSet *)executeQuery:(NSString *)sql, ...;

@end
