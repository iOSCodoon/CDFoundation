//
//  NSManagedObjectContext+CDCoreData.m
//  CodoonSport
//
//  Created by Jinxiao on 5/29/15.
//  Copyright (c) 2015 Codoon. All rights reserved.
//

#import "NSManagedObjectContext+CDCoreData.h"
#import "CDCoreData.h"

@implementation NSManagedObjectContext (CDCoreData)

+ (NSManagedObjectContext *)threadObjectContext
{
    if([NSThread isMainThread])
    {
        return [CDCoreDataManager sharedInstance].branchManagedObjectContext;
    }
    else
    {
        NSString *threadKey = @"com.debugeek.DGCoreData.threadObjectContext";
        NSThread *thread = [NSThread currentThread];
        NSMutableDictionary *threadDictionary = thread.threadDictionary;
        
        NSManagedObjectContext *context = threadDictionary[threadKey];
        if(context == nil)
        {
            context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
            context.parentContext = [CDCoreDataManager sharedInstance].branchManagedObjectContext;
            [context obtainPermanentIDsBeforeSaving];
            threadDictionary[threadKey] = context;
        }
        return context;
    }
}

- (void)obtainPermanentIDsBeforeSaving
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(managedObjectContextWillSave:) name:NSManagedObjectContextWillSaveNotification object:self];
}

- (void)mergeChangesFromContextAfterSaving:(NSManagedObjectContext *)context
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(managedObjectContextDidSave:) name:NSManagedObjectContextDidSaveNotification object:context];
}

- (void)managedObjectContextWillSave:(NSNotification *)notification
{
    NSManagedObjectContext *context = notification.object;
    NSArray *insertedObjects = context.insertedObjects.allObjects;
    if(insertedObjects.count > 0)
    {
        [context obtainPermanentIDsForObjects:insertedObjects error:nil];
    }
}

- (void)managedObjectContextDidSave:(NSNotification *)notification
{
    if(![NSThread isMainThread])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self mergeChangesFromContextDidSaveNotification:notification];
        });
    }
    else
    {
        [self mergeChangesFromContextDidSaveNotification:notification];
    }
}

- (void)saveContext
{
    __block BOOL hasChanges = NO;
    
    if(self.concurrencyType == NSConfinementConcurrencyType)
    {
        hasChanges = self.hasChanges;
    }
    else
    {
        [self performBlockAndWait:^{
            hasChanges = self.hasChanges;
        }];
    }
    
    if(hasChanges)
    {
        [self performBlockAndWait:^{
            if([self save:nil] && self.parentContext != nil)
            {
                [self.parentContext saveContext];
            }
        }];
    }
}

@end
