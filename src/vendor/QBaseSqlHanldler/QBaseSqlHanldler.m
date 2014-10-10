//
//  NSMeapSqlHanldler.m
//  NSMeap
//
//  Created by 十九 on 13-8-12.
//  Copyright (c) 2013年 nationsky. All rights reserved.
//

#import "QBaseSqlHanldler.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import <objc/objc.h>

@implementation QBaseSqlHanldler
+(NSString *)createTableSql:(Class)myClass
{
    NSMutableString *sql=[[NSMutableString alloc] init];
    [sql appendFormat:@"create table %@(",[myClass description]];
    NSMutableArray *keys=[[NSMutableArray alloc] init];
    
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList(myClass, &outCount);        //反射出类的所有属性
    
    BOOL haveKey=NO;
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
		NSString *proty=[NSString stringWithFormat:@"%s",property_getAttributes(property)]; //字段的属性
        NSString *name=[NSString stringWithFormat:@"%s",property_getName(property)];        //字段的名称
        if ([name hasPrefix:@"_"]) {
            continue;
        }
        
		NSString *class_type=[proty substringToIndex:2];
        NSString *primary=@"";
        if ([name isEqualToString:@"qbase_id"]) {
            haveKey=YES;
            primary=@"PRIMARY KEY AUTOINCREMENT DEFAULT NULL";
        }
        if ([class_type isEqualToString:@"Tl"]) {														// long类型字段
            [keys addObject:[NSString stringWithFormat:@"%@ INTEGER %@",name,primary]];
			continue;
		}else if ([class_type isEqualToString:@"T@"]) {
			if ([proty length]>12 && [[proty substringToIndex:12] isEqualToString:@"T@\"NSString\""]) { // NSString 类型字段
                [keys addObject:[NSString stringWithFormat:@"%@ TEXT ",name]];
				continue;
			}
		}else if ([class_type isEqualToString:@"Ti"]) {													// long类型字段
			[keys addObject:[NSString stringWithFormat:@"%@ INTEGER ",name]];
			continue;
		}else if ([class_type isEqualToString:@"Td"]) {											        // double类型字段
			[keys addObject:[NSString stringWithFormat:@"%@ REAL ",name]];
			continue;
		}else if ([class_type isEqualToString:@"Tf"]) {											        // float类型字段
			[keys addObject:[NSString stringWithFormat:@"%@ REAL ",name]];
			continue;
		}else if ([class_type isEqualToString:@"Tc"]) {											        // BOOL类型字段
			[keys addObject:[NSString stringWithFormat:@"%@ INTEGER ",name]];
			continue;
		}else if ([class_type isEqualToString:@"TB"]) {											        // bool类型字段
			[keys addObject:[NSString stringWithFormat:@"%@ INTEGER ",name]];
			continue;
		}
    }
    if (haveKey) {
        [sql appendString:[keys componentsJoinedByString:@","]];
    }else {
        [sql appendFormat:@"qbase_id INTEGER PRIMARY KEY AUTOINCREMENT DEFAULT NULL, %@",[keys componentsJoinedByString:@","]];
    }
    
    free(properties);
    [sql appendString:@")"];
    [keys release];
    return [sql autorelease];
}
+(NSString *)dropTableSql:(Class)myClass
{
    NSMutableString *sql=[[NSMutableString alloc] init];
    [sql appendFormat:@"drop table %@",[myClass description]];
    return [sql autorelease];
}
+(NSString *)insertSql:(Class)myClass dictionary:(NSMutableDictionary *)dictionary
{
    NSMutableString *sql=[[NSMutableString alloc] init];
    [sql appendFormat:@"insert into %@(",[myClass description]];
    NSMutableArray *keys=[[NSMutableArray alloc] init];
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList(myClass, &outCount);        //反射出类的所有属性
    NSMutableArray *propertiesArray=[NSMutableArray array];
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        NSString *name=[NSString stringWithFormat:@"%s",property_getName(property)];        //字段的名称
        [propertiesArray addObject:name];
        if ([name hasPrefix:@"_"]) {
            continue;
        }
        if ([dictionary objectForKey:name]==nil || ![[dictionary allKeys] containsObject:name]) {
            continue;
        }
        
        if (![name hasPrefix:@"qbase_id"]) {
            [keys addObject:name];
        }
    }
    for (NSString *key in [dictionary allKeys]) {
        if (![propertiesArray containsObject:key]) {
            [dictionary removeObjectForKey:key];
        }
    }
    [sql appendString:[keys componentsJoinedByString:@","]];
    [sql appendString:@") VALUES ("];
    BOOL isFirst=YES;
    for (NSString *key in keys) {
        if (!isFirst) {
            [sql appendString:@","];
        }
        [sql appendFormat:@":%@",key];
        isFirst=NO;
    }
    
    [sql appendString:@")"];
    [keys release];
    free(properties);
    return [sql autorelease];
}

+(NSString *)updateSql:(Class)myClass dictionary:(NSMutableDictionary *)dictionary
{
    NSMutableString *sql=[[NSMutableString alloc] init];
    [sql appendFormat:@"update %@ set ",[myClass description]];
    NSMutableArray *keys=[[NSMutableArray alloc] init];
    
    NSString *idKey=nil;
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList(myClass, &outCount);        //反射出类的所有属性
    NSMutableArray *propertiesArray=[NSMutableArray array];
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        NSString *name=[NSString stringWithFormat:@"%s",property_getName(property)];        //字段的名称
        [propertiesArray addObject:name];
        if ([dictionary objectForKey:name]==nil || ![[dictionary allKeys] containsObject:name]) {
            continue;
        }
        if ([name hasPrefix:@"qbase_id"]) {
            idKey=[NSString stringWithFormat:@"%@",name];
            
        }
        [keys addObject:name];
    }
    
    for (NSString *key in [dictionary allKeys]) {
        if (![propertiesArray containsObject:key]&&![key isEqualToString:@"qbase_id"]) {
            [dictionary removeObjectForKey:key];
        }
    }
    
    BOOL isFirst=YES;
    for (NSString *key in keys) {
        if (!isFirst) {
            [sql appendString:@","];
        }
        [sql appendFormat:@"%@=:%@",key,key];
        isFirst=NO;
    }
    
    if (idKey!=nil) {
        [sql appendFormat:@" where %@=:%@",idKey,idKey];
    }else{
        //FIXME:可能要修改
        [sql appendFormat:@" where qbase_id=:qbase_id"];
    }
    [keys release];
    free(properties);
    return [sql autorelease];
}
+ (NSString *)queryCountSql:(Class)myClass conditions:(NSString *)conditions
{
    NSString *sql = [NSString stringWithFormat:@"select count(*) from %@",[myClass description]];
    if (conditions != nil){
        sql= [sql stringByAppendingFormat:@" where %@",conditions];
    }
    return sql;
}
+(NSString *)queryAllSql:(Class)myClass conditions:(NSString *)conditions order:(NSString *)order
{
    NSString *sql = [NSString stringWithFormat:@"select * from %@",[myClass description]];
    if (conditions != nil){
        sql= [sql stringByAppendingFormat:@" where %@",conditions];
    }
    if (order!=nil && [order length]>0) {
        sql=[sql stringByAppendingFormat:@" order by %@",order];
    }
    return sql;
}
+(NSString *)queryWithPageSql:(Class)myClass conditions:(NSString *)conditions pageNumber:(NSInteger)pageNumber pageSize:(NSInteger)pageSize order:(NSString *)order
{
    NSString *sql = [NSString stringWithFormat:@"select * from %@",[myClass description]];
    if (conditions != nil){
        sql= [sql stringByAppendingFormat:@" where %@",conditions];
    }
    if (order!=nil && [order length]>0) {
        sql=[sql stringByAppendingFormat:@" order by %@",order];
    }
    if (pageNumber>0) {
        int startNumber=(pageNumber-1)*pageSize;
        sql=[sql stringByAppendingFormat:@" Limit %d Offset %d",pageSize,startNumber];
    }
    else
    {
        sql=[sql stringByAppendingFormat:@" Limit %d Offset %d",pageSize,0];
    }
    return sql;
}
+(NSString *)queryWithPageSql:(Class)myClass conditions:(NSString *)conditions offSet:(NSInteger)offSet pageSize:(NSInteger)pageSize order:(NSString *)order
{
    NSString *sql = [NSString stringWithFormat:@"select * from %@",[myClass description]];
    if (conditions != nil){
        sql= [sql stringByAppendingFormat:@" where %@",conditions];
    }
    if (order!=nil && [order length]>0) {
        sql=[sql stringByAppendingFormat:@" order by %@",order];
    }
    sql=[sql stringByAppendingFormat:@" Limit %d Offset %d",pageSize,offSet];
    return sql;
}
+(NSString *)deleteSql:(Class)myClass conditions:(NSString *)conditions
{
    NSString *sql = [NSString stringWithFormat:@"delete from %@",[myClass description]];
    if (conditions != nil){
        sql=[sql stringByAppendingFormat:@" where %@",conditions];
    }
    return sql;
}
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
    return [returnValue autorelease];
    

}

@end
