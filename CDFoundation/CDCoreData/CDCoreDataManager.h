//
//  CDCoreDataManager.h
//  CodoonSport
//
//  Created by Jinxiao on 5/29/15.
//  Copyright (c) 2015 Codoon. All rights reserved.
//

#import "CDCoreData.h"

@interface CDCoreDataManager : NSObject

@property (readwrite, nonatomic, strong) NSString *databaseName;
@property (readwrite, nonatomic, strong) NSString *modelName;

@property (readonly) NSManagedObjectContext *masterManagedObjectContext;
@property (readonly) NSManagedObjectContext *branchManagedObjectContext;

+ (instancetype)sharedInstance;

@end
