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

#pragma mark -
#pragma mark - SQL Public Methods

/**
 *  创建表
 */
- (BOOL)createTable
{
    return [self executeUpdate:[NSMeapSqlHanldler createTableSql:[self class]],nil];
}

/**
 *  删除表
 */
- (BOOL)dropTable
{
    return [self executeUpdate:[NSMeapSqlHanldler dropTableSql:[self class]],nil];
}

/**
 *  判断表是否存在
 */
- (BOOL)checkTableIsExist
{
    __block BOOL retry = YES;
    __block BOOL exist = YES;
    
    [self inDatabase:^(FMDatabase *db)
     {
         NSString *className = NSStringFromClass([self class]);

         FMResultSet *rs = [db executeQuery:@"select count(*) as 'count' from sqlite_master where type ='table' and name = ?", className];
         while ([rs next])
         {
             // just print out what we've got in a number of formats.
             NSInteger count = [rs intForColumn:@"count"];
             
             if (0 == count)
             {
                 exist = NO;
             }
             else
             {
                 exist = YES;
             }
             retry = NO;
         }
     }];
    
    while (retry) {}
    return exist;
}

/**
 *  插入数据
 */
- (BOOL)insertTable
{
    NSMutableDictionary *_dictionary = [NSMutableDictionary dictionaryWithDictionary:[NSMeapSqlHanldler objectToDictionary:self]];
    NSString *sql = [NSMeapSqlHanldler insertSql:[self class] dictionary:_dictionary];
    
    return [self executeUpdate:sql withParameterDictionary:_dictionary];
}

/**
 *  更新数据
 */
- (BOOL)updateTable
{
    NSMutableDictionary *_dictionary = [NSMutableDictionary dictionaryWithDictionary:[NSMeapSqlHanldler objectToDictionary:self]];
    NSString *sql = [NSMeapSqlHanldler updateSql:[self class] dictionary:_dictionary];
    
    return [self executeUpdate:sql withParameterDictionary:_dictionary];
}




#pragma mark -
#pragma mark - SQL Handle Methods

/**
 *  通过线程池操作数据库
 */
- (void)inDatabase:(void (^)(FMDatabase *))block
{
    [[QBaseDatabase sharedQBaseDatabase] inDatabase:^(FMDatabase *db) {
        block(db);
    }];
}

/**
 *  SQL 查找数据库内容
 */
- (FMResultSet *)executeQuery:(NSString *)sql, ...
{
    va_list args;
    va_start(args, sql);
    
    __block FMResultSet *set = nil;
    [self inDatabase:^(FMDatabase *db) {
        set = [db executeQuery:sql, args];
    }];
    
    va_end(args);
    return set;
}

/**
 *  SQL 数据库基本操作
 */
- (BOOL)executeUpdate:(NSString *)sql, ...
{
    va_list args;
    va_start(args, sql);
    
    __block BOOL success;
    [self inDatabase:^(FMDatabase *db) {
        success = [db executeUpdate:sql];
    }];
    
    va_end(args);
    return success;
}

- (BOOL)executeUpdate:(NSString *)sql withParameterDictionary:(NSDictionary *)arguments
{
    __block BOOL success;
    
    [self inDatabase:^(FMDatabase *db) {
        success = [db executeUpdate:sql withParameterDictionary:arguments];
    }];
    
    return success;
}




#pragma mark ------------------------

+(NSDictionary *)objectToDictionary:(NSObject *)myObject
{
    
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([myObject class], &outCount);        //反射出类的所有属性
    NSMutableDictionary *returnValue=[[NSMutableDictionary alloc] init];
    
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        const char* propertyName = property_getName(property);
        NSString *proty=[NSString stringWithFormat:@"%s",property_getAttributes(property)];      //字段的属性
        NSString *name=[NSString stringWithFormat:@"%s",property_getName(property)];     //字段的名称
        SEL selector = NSSelectorFromString([NSString stringWithUTF8String:propertyName]);     //判断是否有字段对应的get方法
        
        if ([myObject  respondsToSelector:selector])
        {
            NSString *class_type=[proty substringToIndex:2];
            if ([class_type isEqualToString:@"Td"])
            {
                IMP myImp1 = [myObject methodForSelector:selector];
                double str = ((double (*) (id,SEL))myImp1)(myObject,selector);
                //                double str = objc_msgSend_fpret (myObject,selector);
                [returnValue setObject:[NSString stringWithFormat:@"%f",str] forKey:name];
            }
            else if ([class_type isEqualToString:@"Tf"])
            {
                IMP myImp1 = [myObject methodForSelector:selector];
                float str = ((float (*) (id,SEL))myImp1)(myObject,selector);
                //                float str = objc_msgSend_fpret (myObject,selector);
                [returnValue setObject:[NSString stringWithFormat:@"%f",str] forKey:name];
            }
            else if ([class_type isEqualToString:@"Tc"])
            {
                IMP myImp1 = [myObject methodForSelector:selector];
                BOOL str = ((BOOL (*) (id,SEL))myImp1)(myObject,selector);
                
                [returnValue setObject:[NSString stringWithFormat:@"%d",str] forKey:name];
            }
            else if ([class_type isEqualToString:@"Ti"])
            {
                IMP myImp1 = [myObject methodForSelector:selector];
                int str = ((int (*) (id,SEL))myImp1)(myObject,selector);
                
                [returnValue setObject:[NSString stringWithFormat:@"%d",str] forKey:name];
            }
            else
            {
                
                id str = [myObject performSelector:selector];//调用get方法
                if (str!=nil)
                {
                    
                    if ([class_type isEqualToString:@"Tl"]) {
                        // long类型字段
                        [returnValue setObject:[NSString stringWithFormat:@"%ld",(long)str] forKey:name];
                    }else if ([class_type isEqualToString:@"T@"]) {
                        if ([proty length]>12 && [[proty substringToIndex:12] isEqualToString:@"T@\"NSString\""])
                        {
                            // NSString 类型字段
                            [returnValue setObject:[NSString stringWithFormat:@"%@",str] forKey:name];
                        }
                    }
                    /*else if ([class_type isEqualToString:@"Ti"]) {
                     // int类型字段
                     [returnValue setObject:[NSString stringWithFormat:@"%d",(NSInteger)str]forKey:name];
                     
                     }*/
                    else if ([class_type isEqualToString:@"TB"]) {
                        // bool类型字段
                        [returnValue setObject:[NSString stringWithFormat:@"%d",(NSInteger)str] forKey:name];
                        continue;
                    }else {
                        DEBUG_NSLOG(@"不支持的字段类型!%@",class_type);
                    }
                }
            }
        }
    }
    
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"%@",@"meap_id"]);        //判断是否有字段对应的get方法
    if ([myObject respondsToSelector:selector])
    {
        //        id str = [myObject performSelector:selector];          //调用get方法
        //        if (str != nil)
        //        {
        IMP myImp1 = [myObject methodForSelector:selector];
        long str = ((long (*) (id,SEL))myImp1)(myObject,selector);
        [returnValue setObject:[NSString stringWithFormat:@"%ld",str] forKey:@"meap_id"];
        //        }
    }
    free(properties);
    return returnValue;
}




///**
// *  获取所有属性名称
// */
//- (NSArray *)property
//{
//    NSMutableArray *arr = [NSMutableArray array];
//    
//    u_int count;
//    objc_property_t *properties=class_copyPropertyList([self class], &count);
//    for (int i = 0; i < count ; i++)
//    {
//        const char* propertyName =property_getName(properties[i]);
//        
//        NSString *strName = [NSString stringWithCString:propertyName
//                                               encoding:NSUTF8StringEncoding];
//        [arr addObject:strName];
//    }
//    return arr;
//}
//
///**
// *  获取所有属性的类型
// */
//- (id)type:(NSString *)propertyName
//{
//    Ivar var = class_getInstanceVariable(object_getClass(self),"varTest1");
//    const char* typeEncoding =ivar_getTypeEncoding(var);
//    NSString *stringType =  [NSString stringWithCString:typeEncoding
//                                               encoding:NSUTF8StringEncoding];
//    
//    return stringType;
//}


@end
