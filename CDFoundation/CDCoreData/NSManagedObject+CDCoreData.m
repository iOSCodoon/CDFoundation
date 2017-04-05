//
//  NSManagedObject+CDCoreData.m
//  CodoonSport
//
//  Created by Jinxiao on 5/29/15.
//  Copyright (c) 2015 Codoon. All rights reserved.
//

#import "NSManagedObject+CDCoreData.h"
#import "CDCoreData.h"

@implementation NSManagedObject (CDCoreData)

+ (NSString *)entityName
{
    return NSStringFromClass(self);
}

+ (void)performInBlock:(void (^)(NSManagedObjectContext *))block
{
    NSManagedObjectContext *context = [NSManagedObjectContext threadObjectContext];
    block(context);
}

+ (id)create
{
    return [self createInContext:[NSManagedObjectContext threadObjectContext]];
}

+ (id)createInContext:(NSManagedObjectContext *)context
{
    return [NSEntityDescription insertNewObjectForEntityForName:[self entityName] inManagedObjectContext:context];
}

- (void)delete
{
    [self.managedObjectContext deleteObject:self];
}

+ (void)deleteAll
{
    [self deleteAllInContext:[NSManagedObjectContext threadObjectContext]];
}

+ (void)deleteAllInContext:(NSManagedObjectContext *)context
{
    [[self allInContext:context] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj delete];
    }];
}

+ (NSArray *)all
{
    return [self allInContext:[NSManagedObjectContext threadObjectContext]];
}

+ (NSArray *)allWithOrder:(id)order
{
    return [self allInContext:[NSManagedObjectContext threadObjectContext] order:order];
}

+ (NSArray *)allInContext:(NSManagedObjectContext *)context
{
    return [self allInContext:context order:nil];
}

+ (NSArray *)allInContext:(NSManagedObjectContext *)context order:(id)order
{
    return [self fetchWithCondition:nil inContext:context withOrder:order fetchLimit:nil];
}

+ (instancetype)find:(NSDictionary *)attributes
{
    return [self find:attributes inContext:[NSManagedObjectContext threadObjectContext]];
}

+ (instancetype)find:(NSDictionary *)attributes inContext:(NSManagedObjectContext *)context
{
    return [self where:attributes inContext:context limit:@1].firstObject;
}

+ (NSArray *)where:(id)condition
{
    return [self where:condition inContext:[NSManagedObjectContext threadObjectContext]];
}

+ (NSArray *)where:(id)condition order:(id)order
{
    return [self where:condition inContext:[NSManagedObjectContext threadObjectContext] order:order];
}

+ (NSArray *)where:(id)condition limit:(NSNumber *)limit
{
    return [self where:condition inContext:[NSManagedObjectContext threadObjectContext] limit:limit];
}

+ (NSArray *)where:(id)condition order:(id)order limit:(NSNumber *)limit
{
    return [self where:condition inContext:[NSManagedObjectContext threadObjectContext] order:order limit:limit];
}

+ (NSArray *)where:(id)condition inContext:(NSManagedObjectContext *)context
{
    return [self where:condition inContext:context order:nil limit:nil];
}

+ (NSArray *)where:(id)condition inContext:(NSManagedObjectContext *)context order:(id)order
{
    return [self where:condition inContext:context order:order limit:nil];
}

+ (NSArray *)where:(id)condition inContext:(NSManagedObjectContext *)context limit:(NSNumber *)limit
{
    return [self where:condition inContext:context order:nil limit:limit];
}

+ (NSArray *)where:(id)condition inContext:(NSManagedObjectContext *)context order:(id)order limit:(NSNumber *)limit
{
    return [self fetchWithCondition:condition inContext:context withOrder:order fetchLimit:limit];
}

+ (NSUInteger)count
{
    return [self countInContext:[NSManagedObjectContext threadObjectContext]];
}

+ (NSUInteger)countWhere:(id)condition
{
    return [self countWhere:condition inContext:[NSManagedObjectContext threadObjectContext]];
}

+ (NSUInteger)countInContext:(NSManagedObjectContext *)context
{
    return [self countForFetchWithPredicate:nil inContext:context];
}

+ (NSUInteger)countWhere:(id)condition inContext:(NSManagedObjectContext *)context
{
    NSPredicate *predicate = [self predicateFromObject:condition];
    
    return [self countForFetchWithPredicate:predicate inContext:context];
}

+ (NSPredicate *)predicateFromDictionary:(NSDictionary *)dictionary
{
    NSMutableArray *subpredicates = [NSMutableArray array];
    
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", key, obj];
        if(predicate)
        {
            [subpredicates addObject:predicate];
        }
    }];
    
    return [NSCompoundPredicate andPredicateWithSubpredicates:subpredicates];
}

+ (NSPredicate *)predicateFromObject:(id)condition
{
    if([condition isKindOfClass:[NSPredicate class]])
    {
        return condition;
    }
    else if([condition isKindOfClass:[NSString class]])
    {
        return [NSPredicate predicateWithFormat:condition];
    }
    else if([condition isKindOfClass:[NSDictionary class]])
    {
        return [self predicateFromDictionary:condition];
    }
    return nil;
}

+ (NSSortDescriptor *)sortDescriptorFromDictionary:(NSDictionary *)dictionary
{
    BOOL isAscending = ![[dictionary.allValues.firstObject uppercaseString] isEqualToString:@"DESC"];
    return [NSSortDescriptor sortDescriptorWithKey:dictionary.allKeys.firstObject ascending:isAscending];
}

+ (NSSortDescriptor *)sortDescriptorFromObject:(id)order
{
    if([order isKindOfClass:[NSSortDescriptor class]])
    {
        return order;
    }
    else if([order isKindOfClass:[NSString class]])
    {
        return [NSSortDescriptor sortDescriptorWithKey:order ascending:YES];
    }
    else if([order isKindOfClass:[NSDictionary class]])
    {
        return [self sortDescriptorFromDictionary:order];
    }
    return nil;
}

+ (NSArray *)sortDescriptorsFromObject:(id)order
{
    if([order isKindOfClass:[NSArray class]])
    {
        NSMutableArray *descriptors = [NSMutableArray array];
        
        [order enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSSortDescriptor *descriptor = [self sortDescriptorFromObject:obj];
            if(descriptor)
            {
                [descriptors addObject:descriptor];
            }
        }];
        
        return descriptors;
    }
    else
    {
        return @[[self sortDescriptorFromObject:order]];
    }
}

+ (NSFetchRequest *)createFetchRequestInContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [NSFetchRequest new];
    NSEntityDescription *entity = [NSEntityDescription entityForName:[self entityName] inManagedObjectContext:context];
    [request setEntity:entity];
    return request;
}

+ (NSArray *)fetchWithCondition:(id)condition inContext:(NSManagedObjectContext *)context withOrder:(id)order fetchLimit:(NSNumber *)fetchLimit
{
    NSFetchRequest *request = [self createFetchRequestInContext:context];
    
    if(condition)
    {
        [request setPredicate:[self predicateFromObject:condition]];
    }
    if(order)
    {
        [request setSortDescriptors:[self sortDescriptorsFromObject:order]];
    }
    if(fetchLimit)
    {
        [request setFetchLimit:[fetchLimit integerValue]];
    }
    return [context executeFetchRequest:request error:nil];
}

+ (NSUInteger)countForFetchWithPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [self createFetchRequestInContext:context];
    [request setPredicate:predicate];
    return [context countForFetchRequest:request error:nil];
}

@end
