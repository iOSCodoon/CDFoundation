//
//  DGGlobalTimerObserverManager.m
//  DGGlobalTimer
//
//  Created by Jinxiao on 7/25/14.
//  Copyright (c) 2014 debugeek. All rights reserved.
//

#import "CDGlobalTimerObserverManager.h"
#import "CDGlobalTimerObserver.h"
#import "CDGlobalTimerTask.h"
#import "CDGlobalTimerTaskManager.h"

@interface CDGlobalTimerObserverManager ()
@property (readwrite, nonatomic, strong) NSMutableDictionary <NSString *, NSMutableArray <CDGlobalTimerObserver *> *> *groups;
@end

@implementation CDGlobalTimerObserverManager

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
        _groups = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (CDGlobalTimerObserver *)observerForIdentifier:(NSString *)identifier
{
    __block CDGlobalTimerObserver *observer = nil;
    [_groups enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSMutableArray<CDGlobalTimerObserver *> * _Nonnull obj, BOOL * _Nonnull stop) {
        [obj enumerateObjectsUsingBlock:^(CDGlobalTimerObserver * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if([obj.identifier isEqualToString:identifier])
            {
                observer = obj;
                *stop = YES;
            }
        }];
    }];
    return observer;
}

- (BOOL)addGlobalTimerObserver:(CDGlobalTimerObserver *)observer
{
    if(!observer)
    {
        return NO;
    }
    
    NSMutableArray <CDGlobalTimerObserver *> *observers = [_groups objectForKey:observer.key];
    if(!observers)
    {
        observers = [[NSMutableArray alloc] init];
        [_groups setObject:observers forKey:observer.key];
    }
    
    __block BOOL exist = NO;
    [observers enumerateObjectsUsingBlock:^(CDGlobalTimerObserver * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if([obj.identifier isEqualToString:observer.identifier])
        {
            exist = YES;
            *stop = YES;
        }
    }];
    
    if(!exist)
    {
        [observers addObject:observer];
    }
    
    return !exist;
}

- (BOOL)removeGlobalTimerObserver:(CDGlobalTimerObserver *)observer
{
    if(!observer)
    {
        return NO;
    }
    
    NSMutableArray <CDGlobalTimerObserver *> *observers = [_groups objectForKey:observer.key];
    if(observers != nil)
    {
        NSMutableArray <CDGlobalTimerObserver *> *matches = [NSMutableArray array];
        [observers enumerateObjectsUsingBlock:^(CDGlobalTimerObserver * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if([obj.identifier isEqualToString:observer.identifier])
            {
                [matches addObject:obj];
            }
        }];
        [observers removeObjectsInArray:matches];
    }
    
    return YES;
}

- (void)dispatchInitialEventsForKey:(NSString *)key
{
    NSMutableArray <CDGlobalTimerObserver *> *observers = [_groups objectForKey:key];
    [observers enumerateObjectsUsingBlock:^(CDGlobalTimerObserver * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        !obj.initial ?: obj.initial();
    }];
}

- (void)dispatchTriggerEventsForKey:(NSString *)key remains:(NSTimeInterval)remains
{
    NSMutableArray <CDGlobalTimerObserver *> *observers = [_groups objectForKey:key];
    [observers enumerateObjectsUsingBlock:^(CDGlobalTimerObserver * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        !obj.trigger ?: obj.trigger(remains);
    }];
}

- (void)dispatchCompletionEventsForKey:(NSString *)key
{
    NSMutableArray <CDGlobalTimerObserver *> *observers = [_groups objectForKey:key];
    [observers enumerateObjectsUsingBlock:^(CDGlobalTimerObserver * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        !obj.completion ?: obj.completion();
    }];
}

@end
