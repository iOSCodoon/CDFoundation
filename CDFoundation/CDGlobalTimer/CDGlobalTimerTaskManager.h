//
//  DGGlobalTimerTaskManager.h
//  DGGlobalTimer
//
//  Created by Jinxiao on 7/25/14.
//  Copyright (c) 2014 debugeek. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CDGlobalTimerTask;

@interface CDGlobalTimerTaskManager : NSObject

@property (readwrite, nonatomic, strong) NSMutableArray *tasks;

+ (instancetype)sharedInstance;

- (void)restoreAllTimerTasks;

- (void)addTimerTask:(CDGlobalTimerTask *)task;
- (void)removeTimerTask:(CDGlobalTimerTask *)task;

- (CDGlobalTimerTask *)timerTaskForKey:(NSString *)key;

@end
