//
//  DGGlobalTimerManager.m
//  DGGlobalTimer
//
//  Created by Jinxiao on 7/24/14.
//  Copyright (c) 2014 debugeek. All rights reserved.
//

#import "CDGlobalTimerManager.h"
#import "CDGlobalTimerTask.h"
#import "CDGlobalTimerTaskManager.h"
#import "CDGlobalTimerObserverManager.h"
#import "CDGlobalTimerObserver.h"

@implementation CDGlobalTimerManager

//+ (void)load
//{
//    [[CDGlobalTimerTaskManager sharedInstance] restoreAllTimerTasks];
//}

+ (instancetype)sharedInstance
{
    static id instance;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = self.new;
    });
    return instance;
}

- (void)rescheduleGlobalTimerForTaskKey:(NSString *)taskKey interval:(NSTimeInterval)interval duration:(NSTimeInterval)duration
{
    [self removeGlobalTimerForTaskKey:taskKey];
    
    [self scheduleGlobalTimerForTaskKey:taskKey interval:interval duration:duration];
}

- (void)scheduleGlobalTimerForTaskKey:(NSString *)taskKey interval:(NSTimeInterval)interval duration:(NSTimeInterval)duration
{
    CDGlobalTimerTask *task = [[CDGlobalTimerTaskManager sharedInstance] timerTaskForKey:taskKey];
    if(task == nil)
    {
        task = [[CDGlobalTimerTask alloc] init];
        task.key = taskKey;
        task.interval = interval;
        task.deadline = [[NSDate date] dateByAddingTimeInterval:duration];
        [task schedule];
    }
}

- (void)removeGlobalTimerForTaskKey:(NSString *)taskKey
{
    CDGlobalTimerTask *task = [[CDGlobalTimerTaskManager sharedInstance] timerTaskForKey:taskKey];
    if(task != nil)
    {
        [task cancel];
    }
}

- (void)observeGlobalTimerForIdentifier:(NSString *)identifier taskKey:(NSString *)taskKey initial:(void (^)())initial trigger:(void (^)(NSTimeInterval))trigger completion:(void (^)(void))completion
{
    CDGlobalTimerObserver *observer = [[CDGlobalTimerObserverManager sharedInstance] observerForIdentifier:identifier];
    if(observer)
    {
        [[CDGlobalTimerObserverManager sharedInstance] removeGlobalTimerObserver:observer];
    }
    
    observer = [[CDGlobalTimerObserver alloc] init];
    observer.key = taskKey;
    observer.identifier = identifier;
    observer.initial = initial;
    observer.trigger = trigger;
    observer.completion = completion;
    [[CDGlobalTimerObserverManager sharedInstance] addGlobalTimerObserver:observer];
}

@end
