//
//  DGGlobalTimerObserverManager.h
//  DGGlobalTimer
//
//  Created by Jinxiao on 7/25/14.
//  Copyright (c) 2014 debugeek. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CDGlobalTimerObserver;

@interface CDGlobalTimerObserverManager : NSObject

+ (instancetype)sharedInstance;

- (BOOL)addGlobalTimerObserver:(CDGlobalTimerObserver *)observer;
- (BOOL)removeGlobalTimerObserver:(CDGlobalTimerObserver *)observer;

- (CDGlobalTimerObserver *)observerForIdentifier:(NSString *)identifier;

- (void)dispatchInitialEventsForKey:(NSString *)key;
- (void)dispatchTriggerEventsForKey:(NSString *)key remains:(NSTimeInterval)remains;
- (void)dispatchCompletionEventsForKey:(NSString *)key;

@end
