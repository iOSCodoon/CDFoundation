//
//  NSManagedObject+CDCoreData.h
//  CodoonSport
//
//  Created by Jinxiao on 5/29/15.
//  Copyright (c) 2015 Codoon. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (CDCoreData)

+ (void)performInBlock:(void (^)(NSManagedObjectContext *context))block;

+ (id)create;
+ (id)createInContext:(NSManagedObjectContext *)context;

- (void)delete;
+ (void)deleteAll;
+ (void)deleteAllInContext:(NSManagedObjectContext *)context;

+ (instancetype)find:(NSDictionary *)attributes;
+ (instancetype)find:(NSDictionary *)attributes inContext:(NSManagedObjectContext *)context;

+ (NSArray *)all;
+ (NSArray *)allWithOrder:(id)order;
+ (NSArray *)allInContext:(NSManagedObjectContext *)context;
+ (NSArray *)allInContext:(NSManagedObjectContext *)context order:(id)order;

+ (NSArray *)where:(id)condition;
+ (NSArray *)where:(id)condition order:(id)order;
+ (NSArray *)where:(id)condition limit:(NSNumber *)limit;
+ (NSArray *)where:(id)condition order:(id)order limit:(NSNumber *)limit;
+ (NSArray *)where:(id)condition inContext:(NSManagedObjectContext *)context;
+ (NSArray *)where:(id)condition inContext:(NSManagedObjectContext *)context order:(id)order;
+ (NSArray *)where:(id)condition inContext:(NSManagedObjectContext *)context limit:(NSNumber *)limit;
+ (NSArray *)where:(id)condition inContext:(NSManagedObjectContext *)context order:(id)order limit:(NSNumber *)limit;

+ (NSUInteger)count;
+ (NSUInteger)countWhere:(id)condition;
+ (NSUInteger)countInContext:(NSManagedObjectContext *)context;
+ (NSUInteger)countWhere:(id)condition inContext:(NSManagedObjectContext *)context;

@end
