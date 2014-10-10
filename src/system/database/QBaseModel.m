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
    return [self executeUpdate:[QBaseSqlHanldler createTableSql:[self class]], nil];
}

/**
 *  删除表
 */
- (BOOL)dropTable
{
    return [self executeUpdate:[QBaseSqlHanldler dropTableSql:[self class]], nil];
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
    NSMutableDictionary *_dictionary = [NSMutableDictionary dictionaryWithDictionary:[QBaseSqlHanldler objectToDictionary:self]];
    NSString *sql = [QBaseSqlHanldler insertSql:[self class] dictionary:_dictionary];
    
    return [self executeUpdate:sql withParameterDictionary:_dictionary];
}

/**
 *  更新数据
 */
- (BOOL)updateTable
{
    NSMutableDictionary *_dictionary = [NSMutableDictionary dictionaryWithDictionary:[QBaseSqlHanldler objectToDictionary:self]];
    NSString *sql = [QBaseSqlHanldler updateSql:[self class] dictionary:_dictionary];
    
    return [self executeUpdate:sql withParameterDictionary:_dictionary];
}

/**
 *  移除数据
 */
- (BOOL)deleteFromTable
{
    [self inDatabase:^(FMDatabase *db) {
         NSString *sql = [QBaseSqlHanldler deleteSql:[self class]
                                          conditions:@""];
        [db executeUpdate:sql withArgumentsInArray:@[@(2)]];
     }];
    return YES;
}

/**
 *  查询数据 （所有数据）
 */
- (NSArray *)selectFromTable
{
    return [self transformResult:[self executeQuery:[QBaseSqlHanldler queryAllSql:[self class] conditions:nil order:nil]]];
}

/**
 *  查询数据 （条件查询）
 */
- (NSArray *)selectByConditions:(NSString*)conditions args:(NSArray*)args pageNumber:(NSInteger)pageNumber pageSize:(NSInteger)pageSize order:(NSString*)order
{
    return [self transformResult:[self executeQuery:[QBaseSqlHanldler queryWithPageSql:[self class] conditions:conditions pageNumber:pageNumber pageSize:pageSize order:order]]];
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


#pragma mark - SQL Helper

+ (NSDictionary *)objectToDictionary:(NSObject *)myObject
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
    
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"%@",@"qbase_id"]);        //判断是否有字段对应的get方法
    if ([myObject respondsToSelector:selector])
    {
        //        id str = [myObject performSelector:selector];          //调用get方法
        //        if (str != nil)
        //        {
        IMP myImp1 = [myObject methodForSelector:selector];
        long str = ((long (*) (id,SEL))myImp1)(myObject,selector);
        [returnValue setObject:[NSString stringWithFormat:@"%ld",str] forKey:@"qbase_id"];
        //        }
    }
    free(properties);
    return returnValue;
}

- (NSArray *)transformResult:(FMResultSet *)result
{
    
    NSMutableArray *array = [NSMutableArray array];
    
    while ([result next]) {
        NSObject *obj=[[[self class] alloc] init];
        NSDictionary *dictionary=[result resultDictionary];
        for (NSString *key in dictionary) {
            NSString *method=[NSString stringWithFormat:@"set%@%@",[[key substringToIndex:1] uppercaseString],[key substringFromIndex:1]];
            SEL selector = NSSelectorFromString([NSString stringWithFormat:@"%@:",method]);
            //判断该类中是否有对应的set方法
            if ([obj respondsToSelector:selector]) {
                @try {
                    id value=[dictionary objectForKey:key];
                    
                    NSString *type=[self getType:obj property:key];
                    
                    if ([type isEqualToString:@"string"]) {
                        
                        if (value==nil || [value isKindOfClass:[NSNull class]]) {
                            value=@"";
                        }
                        [obj performSelector:selector withObject:value];//调用set方法
                        
                    }else {
                        if (value==nil||[value isKindOfClass:[NSNull class]]) {
                            
                        }else{
                            SEL sel = NSSelectorFromString([NSString stringWithFormat:@"%@Value",type]);//判断该类中是否有对应的set方法
                            
                            if ([value respondsToSelector:sel]) {
                                if ([type isEqualToString:@"double"])
                                {
                                    
                                    IMP myImp = [obj methodForSelector:selector];
                                    myImp(obj,selector,[value doubleValue]);
                                    
                                }
                                else if ([type isEqualToString:@"float"])
                                {
                                    float sid=[value floatValue];
                                    NSMethodSignature *signature = [obj methodSignatureForSelector:selector];
                                    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
                                    
                                    [invocation setTarget:obj];
                                    [invocation setSelector:selector];
                                    [invocation setArgument:&sid atIndex:2];
                                    
                                    [invocation invoke];
                                    //
                                    //                                        IMP myImp = [obj methodForSelector:selector];
                                    //                                         myImp(obj,selector,[value floatValue]);
                                    //
                                    //                                        NSLog(@"%f",sid);
                                    //                                        IMP myImp1 = [obj methodForSelector:selector];
                                    //                                        myImp1(obj,selector,[NSNumber numberWithFloat:sid]);
                                }
                                else
                                {
                                    [obj performSelector:selector withObject:[value performSelector:sel withObject:nil]];
                                }//调用set方法
                            }else {
                                [obj performSelector:selector withObject:@""];//调用set方法
                            }
                            
                        }
                    }
                    
                }
                @catch (NSException * e) {
                    
                }
                @finally {
                    
                }
            }else {
                if (![method isEqualToString:@"setQbase_id"]) {
                    DEBUG_NSLOG(@"%@ no found" ,method);
                }
                
            }
        }
        
        if (obj)
        {
            [array addObject:obj];
        }
    }
    return array;
}

-(NSString*) getType:(NSObject*) bean property:(NSString*) field{
	objc_property_t property = class_getProperty([bean class], [field cStringUsingEncoding:NSUTF8StringEncoding]);
	NSString *proty=[NSString stringWithFormat:@"%s",property_getAttributes(property)]; //字段的属性
	NSString *name=[NSString stringWithFormat:@"%s",property_getName(property)];        //字段的名称
	
	if ([name isEqualToString:field]) {
		NSString *class_type=[proty substringToIndex:2];
		if ([class_type isEqualToString:@"Tl"]) {														// long类型字段
			return @"long";
		}else if ([class_type isEqualToString:@"T@"]) {
			if ([proty length]>12 && [[proty substringToIndex:12] isEqualToString:@"T@\"NSString\""]) { // NSString 类型字段
				return @"string";
			}
		}else if ([class_type isEqualToString:@"Ti"]) {														// long类型字段
			return @"int";
		}else if ([class_type isEqualToString:@"Tf"])
        {
            return @"float";
        }
        else if([class_type isEqualToString:@"Td"])
        {
            return @"double";
        }
        else if ([class_type isEqualToString:@"Tc"])
        {
            return  @"bool";
        }
        
	}
	
	return @"";
}

@end
