//
//  NSMeapSqlHanldler.h
//  NSMeap
//
//  Created by 十九 on 13-8-12.
//  Copyright (c) 2013年 nationsky. All rights reserved.
//

#import <Foundation/Foundation.h>

/// 数据库语句处理类

@interface QBaseSqlHanldler : NSObject
/**
 *	@brief	创建表的sql语句
 *
 *	@param 	myClass
 *
 *	@return	sql语句
 */
+(NSString *)createTableSql:(Class)myClass;

/**
 *	@brief	删除表的sql语句
 *
 *	@param 	myClass
 *
 *	@return	sql语句
 */
+(NSString *)dropTableSql:(Class)myClass;


/**
 *	@brief	插入数据的sql语句
 *
 *	@param 	myClass
 *	@param 	dictionary 	数据
 *
 *	@return	sql语句
 */
+(NSString *)insertSql:(Class)myClass dictionary:(NSMutableDictionary *)dictionary;

/**
 *	@brief	更新数据的sql语句
 *
 *	@param 	myClass
 *	@param 	dictionary 	数据
 *
 *	@return	sql语句
 */
+(NSString *)updateSql:(Class)myClass dictionary:(NSMutableDictionary *)dictionary;

/**
 *	@brief	查询表数据条数
 *
 *	@param 	myClass 	类
 *	@param 	conditions 	条件 eg:@"name=?"
 *	@param 	args 	条件的值  eg:["张三"]
 *
 */
+ (NSString *)queryCountSql:(Class)myClass conditions:(NSString *)conditions;

/**
 *	@brief	查询数据的sql语句
 *
 *	@param 	myClass
 *	@param 	conditions 	条件
 *	@param 	order 	排序
 *
 *	@return	sql语句
 */
+(NSString *)queryAllSql:(Class)myClass conditions:(NSString *)conditions order:(NSString *)order;

/**
 *	@brief	分页查询
 *
 *	@param 	myClass
 *	@param 	conditions 	条件
 *	@param 	pageNumber 	页数
 *	@param 	pageSize 	记录数
 *	@param 	order 	排序
 *
 *	@return	sql语句
 */
+(NSString *)queryWithPageSql:(Class)myClass conditions:(NSString *)conditions pageNumber:(NSInteger)pageNumber pageSize:(NSInteger)pageSize order:(NSString *)order ;
/**
 *	@brief	分页查询
 *
 *	@param 	myClass
 *	@param 	conditions 	条件
 *	@param 	offSet      从哪条开始查
 *	@param 	pageSize 	记录数
 *	@param 	order 	排序
 *
 *	@return	sql语句
 */
+(NSString *)queryWithPageSql:(Class)myClass conditions:(NSString *)conditions offSet:(NSInteger)offSet pageSize:(NSInteger)pageSize order:(NSString *)order;
/**
 *	@brief	删除数据的sql语句
 *
 *	@param 	myClass
 *	@param 	conditions 	条件
 *
 *	@return	sql语句
 */
+(NSString *)deleteSql:(Class)myClass conditions:(NSString *)conditions;

/**
 *	@brief	对象转换成字典
 *
 *	@param 	myObject 	对象
 *
 *	@return	字典
 */
+(NSDictionary *)objectToDictionary:(NSObject *)myObject;
@end
