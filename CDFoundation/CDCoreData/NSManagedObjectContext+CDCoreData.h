//
//  NSManagedObjectContext+CDCoreData.h
//  CodoonSport
//
//  Created by Jinxiao on 5/29/15.
//  Copyright (c) 2015 Codoon. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObjectContext (CDCoreData)

+ (NSManagedObjectContext *)threadObjectContext;

- (void)obtainPermanentIDsBeforeSaving;
- (void)mergeChangesFromContextAfterSaving:(NSManagedObjectContext *)context;

- (void)saveContext;

@end
