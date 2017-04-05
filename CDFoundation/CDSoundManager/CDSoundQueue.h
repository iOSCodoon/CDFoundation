//
//  CDSoundQueue.h
//  CodoonSport
//
//  Created by Jinxiao on 1/31/16.
//  Copyright © 2016 Codoon. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CDSoundTask.h"

@class CDSoundQueue;

@protocol CDSoundQueueDelegate <NSObject>
@optional
- (void)soundQueue:(CDSoundQueue *)soundQueue willStartTask:(CDSoundTask *)task;
- (void)soundQueue:(CDSoundQueue *)soundQueue didStartTask:(CDSoundTask *)task;
- (void)soundQueue:(CDSoundQueue *)soundQueue willFinishTask:(CDSoundTask *)task;
- (void)soundQueue:(CDSoundQueue *)soundQueue didFinishTask:(CDSoundTask *)task;
@end

@interface CDSoundQueue : NSObject

- (void)enqueueTask:(CDSoundTask *)task;

- (void)drain;

@property (readonly) NSMutableArray<CDSoundTask *> *tasks;

+ (instancetype)sharedInstance;

- (void)addDelegate:(id<CDSoundQueueDelegate>)delegate;
- (void)removeDelegate:(id<CDSoundQueueDelegate>)delegate;

@end
