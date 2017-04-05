//
//  DGGlobalTimerManager.h
//  DGGlobalTimer
//
//  Created by Jinxiao on 7/24/14.
//  Copyright (c) 2014 debugeek. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CDGlobalTimerManager : NSObject

+ (instancetype)sharedInstance;

- (void)scheduleGlobalTimerForTaskKey:(NSString *)taskKey interval:(NSTimeInterval)interval duration:(NSTimeInterval)duration;

- (void)rescheduleGlobalTimerForTaskKey:(NSString *)taskKey interval:(NSTimeInterval)interval duration:(NSTimeInterval)duration;

- (void)removeGlobalTimerForTaskKey:(NSString *)taskKey;

- (void)observeGlobalTimerForIdentifier:(NSString *)identifier taskKey:(NSString *)taskKey initial:(void (^)())initial trigger:(void (^)(NSTimeInterval remains))trigger completion:(void (^)(void))completion;

@end
