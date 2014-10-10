//
//  QBaseModel.h
//  QBaseFramework
//
//  Created by andy on 9/20/14.
//  Copyright (c) 2014 streakq. All rights reserved.
//

#import "JSONModel.h"

@interface QBaseModel : JSONModel

- (BOOL)createTable;
- (BOOL)dropTable;
- (BOOL)checkTableIsExist;
- (BOOL)insertTable;
- (BOOL)updateTable;

@end
