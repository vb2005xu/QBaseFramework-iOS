//
//  YYFMDatabasePool.m
//  YYFMDB
//
//  Created by August Mueller on 6/22/11.
//  Copyright 2011 Flying Meat Inc. All rights reserved.
//

#import "YYFMDatabasePool.h"
#import "YYFMDatabase.h"

@interface YYFMDatabasePool()

- (void)pushDatabaseBackInPool:(YYFMDatabase*)db;
- (YYFMDatabase*)db;

@end


@implementation YYFMDatabasePool
@synthesize path=_path;
@synthesize delegate=_delegate;
@synthesize maximumNumberOfDatabasesToCreate=_maximumNumberOfDatabasesToCreate;


+ (id)databasePoolWithPath:(NSString*)aPath {
    return YYFMDBReturnAutoreleased([[self alloc] initWithPath:aPath]);
}

- (id)initWithPath:(NSString*)aPath {
    
    self = [super init];
    
    if (self != nil) {
        _path               = [aPath copy];
        _lockQueue          = dispatch_queue_create([[NSString stringWithFormat:@"YYFMDB.%@", self] UTF8String], NULL);
        _databaseInPool     = YYFMDBReturnRetained([NSMutableArray array]);
        _databaseOutPool    = YYFMDBReturnRetained([NSMutableArray array]);
    }
    
    return self;
}

- (void)dealloc {
    
    _delegate = 0x00;
    YYFMDBRelease(_path);
    YYFMDBRelease(_databaseInPool);
    YYFMDBRelease(_databaseOutPool);
    
    if (_lockQueue) {
        YYFMDBDispatchQueueRelease(_lockQueue);
        _lockQueue = 0x00;
    }
#if ! __has_feature(objc_arc)
    [super dealloc];
#endif
}


- (void)executeLocked:(void (^)(void))aBlock {
    dispatch_sync(_lockQueue, aBlock);
}

- (void)pushDatabaseBackInPool:(YYFMDatabase*)db {
    
    if (!db) { // db can be null if we set an upper bound on the # of databases to create.
        return;
    }
    
    [self executeLocked:^() {
        
        if ([_databaseInPool containsObject:db]) {
            [[NSException exceptionWithName:@"Database already in pool" reason:@"The YYFMDatabase being put back into the pool is already present in the pool" userInfo:nil] raise];
        }
        
        [_databaseInPool addObject:db];
        [_databaseOutPool removeObject:db];
        
    }];
}

- (YYFMDatabase*)db {
    
    __block YYFMDatabase *db;
    
    [self executeLocked:^() {
        db = [_databaseInPool lastObject];
        
        if (db) {
            [_databaseOutPool addObject:db];
            [_databaseInPool removeLastObject];
        }
        else {
            
            if (_maximumNumberOfDatabasesToCreate) {
                NSUInteger currentCount = [_databaseOutPool count] + [_databaseInPool count];
                
                if (currentCount >= _maximumNumberOfDatabasesToCreate) {
                    NSLog(@"Maximum number of databases (%ld) has already been reached!", (long)currentCount);
                    return;
                }
            }
            
            db = [YYFMDatabase databaseWithPath:_path];
        }
        
        //This ensures that the db is opened before returning
        if ([db open]) {
            if ([_delegate respondsToSelector:@selector(databasePool:shouldAddDatabaseToPool:)] && ![_delegate databasePool:self shouldAddDatabaseToPool:db]) {
                [db close];
                db = 0x00;
            }
            else {
                //It should not get added in the pool twice if lastObject was found
                if (![_databaseOutPool containsObject:db]) {
                    [_databaseOutPool addObject:db];
                }
            }
        }
        else {
            NSLog(@"Could not open up the database at path %@", _path);
            db = 0x00;
        }
    }];
    
    return db;
}

- (NSUInteger)countOfCheckedInDatabases {
    
    __block NSUInteger count;
    
    [self executeLocked:^() {
        count = [_databaseInPool count];
    }];
    
    return count;
}

- (NSUInteger)countOfCheckedOutDatabases {
    
    __block NSUInteger count;
    
    [self executeLocked:^() {
        count = [_databaseOutPool count];
    }];
    
    return count;
}

- (NSUInteger)countOfOpenDatabases {
    __block NSUInteger count;
    
    [self executeLocked:^() {
        count = [_databaseOutPool count] + [_databaseInPool count];
    }];
    
    return count;
}

- (void)releaseAllDatabases {
    [self executeLocked:^() {
        [_databaseOutPool removeAllObjects];
        [_databaseInPool removeAllObjects];
    }];
}

- (void)inDatabase:(void (^)(YYFMDatabase *db))block {
    
    YYFMDatabase *db = [self db];
    
    block(db);
    
    [self pushDatabaseBackInPool:db];
}

- (void)beginTransaction:(BOOL)useDeferred withBlock:(void (^)(YYFMDatabase *db, BOOL *rollback))block {
    
    BOOL shouldRollback = NO;
    
    YYFMDatabase *db = [self db];
    
    if (useDeferred) {
        [db beginDeferredTransaction];
    }
    else {
        [db beginTransaction];
    }
    
    
    block(db, &shouldRollback);
    
    if (shouldRollback) {
        [db rollback];
    }
    else {
        [db commit];
    }
    
    [self pushDatabaseBackInPool:db];
}

- (void)inDeferredTransaction:(void (^)(YYFMDatabase *db, BOOL *rollback))block {
    [self beginTransaction:YES withBlock:block];
}

- (void)inTransaction:(void (^)(YYFMDatabase *db, BOOL *rollback))block {
    [self beginTransaction:NO withBlock:block];
}
#if SQLITE_VERSION_NUMBER >= 3007000
- (NSError*)inSavePoint:(void (^)(YYFMDatabase *db, BOOL *rollback))block {
    
    static unsigned long savePointIdx = 0;
    
    NSString *name = [NSString stringWithFormat:@"savePoint%ld", savePointIdx++];
    
    BOOL shouldRollback = NO;
    
    YYFMDatabase *db = [self db];
    
    NSError *err = 0x00;
    
    if (![db startSavePointWithName:name error:&err]) {
        [self pushDatabaseBackInPool:db];
        return err;
    }
    
    block(db, &shouldRollback);
    
    if (shouldRollback) {
        [db rollbackToSavePointWithName:name error:&err];
    }
    else {
        [db releaseSavePointWithName:name error:&err];
    }
    
    [self pushDatabaseBackInPool:db];
    
    return err;
}
#endif

@end
