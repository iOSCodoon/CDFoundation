//
//  DGGlobalTimerTaskManager.m
//  DGGlobalTimer
//
//  Created by Jinxiao on 7/25/14.
//  Copyright (c) 2014 debugeek. All rights reserved.
//

#import "CDGlobalTimerTaskManager.h"
#import "CDGlobalTimerTask.h"

@implementation CDGlobalTimerTaskManager

+ (instancetype)sharedInstance
{
    static id instance;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = self.new;
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if(self)
    {
        self.tasks = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)restoreAllTimerTasks
{
    [self.tasks makeObjectsPerformSelector:@selector(cancel)];
    [self.tasks removeAllObjects];
    [self.tasks addObjectsFromArray:[self cachedTasks]];
    [self.tasks makeObjectsPerformSelector:@selector(schedule)];
}

- (NSString *)tasksCachePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"com.debugeek.DGGlobalTimer"];
    BOOL isDirectory = NO;
    BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory];
    if(!exist || !isDirectory)
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return [path stringByAppendingPathComponent:@"task"];
}

- (void)cacheTasks:(NSArray *)tasks
{
    return;
    
//    [NSKeyedArchiver archiveRootObject:tasks toFile:[self tasksCachePath]];
}

- (NSMutableArray *)cachedTasks
{
    return [@[] mutableCopy];
//    NSMutableArray *tasks = [NSKeyedUnarchiver unarchiveObjectWithFile:[self tasksCachePath]];
//    if(!tasks)
//    {
//        tasks = [[NSMutableArray alloc] init];
//    }
//    return tasks;
}

- (void)addTimerTask:(CDGlobalTimerTask *)task
{
    __block BOOL exist = NO;
    [_tasks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if([((CDGlobalTimerTask *)obj).key isEqualToString:task.key])
        {
            exist = YES;
            *stop = YES;
        }
    }];
    
    if(!exist)
    {
        [_tasks addObject:task];
        [self cacheTasks:_tasks];
    }
}

- (CDGlobalTimerTask *)timerTaskForKey:(NSString *)key
{
    __block CDGlobalTimerTask *task = nil;
    [_tasks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if([((CDGlobalTimerTask *)obj).key isEqualToString:key])
        {
            task = obj;
            *stop = YES;
        }
    }];
    
    return task;
}

- (void)removeTimerTask:(CDGlobalTimerTask *)task
{
    if([_tasks containsObject:task])
    {
        [_tasks removeObject:task];
    }
    else
    {
        [_tasks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if([((CDGlobalTimerTask *)obj).key isEqualToString:task.key])
            {
                [_tasks removeObjectAtIndex:idx];
            }
        }];
    }
    
    [self cacheTasks:_tasks];
}

@end
