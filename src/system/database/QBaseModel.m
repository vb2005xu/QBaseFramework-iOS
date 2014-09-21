//
//  QBaseModel.m
//  QBaseFramework
//
//  Created by andy on 9/20/14.
//  Copyright (c) 2014 streakq. All rights reserved.
//

#import "QBaseModel.h"
#import <objc/runtime.h>

@implementation QBaseModel

- (FMResultSet *)executeQuery:(NSString *)sql, ...
{
    va_list args;
    va_start(args, sql);
    
    __block FMResultSet *set = nil;
    [[QBaseDatabase sharedQBaseDatabase] inDatabase:^(FMDatabase *db) {
        set = [db executeQuery:sql, args];
    }];
    
    va_end(args);
    
    return set;
}
- (BOOL)executeUpdate:(NSString *)sql, ...
{
    va_list args;
    va_start(args, sql);

    __block BOOL success;
    [[QBaseDatabase sharedQBaseDatabase] inDatabase:^(FMDatabase *db) {
        success = [db executeUpdate:sql, args];
    }];
    
    va_end(args);

    return success;
}

/**
 *  获取所有属性名称
 */
- (NSArray *)property
{
    NSMutableArray *arr = [NSMutableArray array];
    
    u_int count;
    objc_property_t *properties=class_copyPropertyList([self class], &count);
    for (int i = 0; i < count ; i++)
    {
        const char* propertyName =property_getName(properties[i]);
        
        NSString *strName = [NSString stringWithCString:propertyName
                                               encoding:NSUTF8StringEncoding];
        [arr addObject:strName];
    }
    return arr;
}

/**
 *  获取所有属性的类型
 */
- (id)type:(NSString *)propertyName
{
    Ivar var = class_getInstanceVariable(object_getClass(self),"varTest1");
    const char* typeEncoding =ivar_getTypeEncoding(var);
    NSString *stringType =  [NSString stringWithCString:typeEncoding
                                               encoding:NSUTF8StringEncoding];
    
    return stringType;
}


@end
