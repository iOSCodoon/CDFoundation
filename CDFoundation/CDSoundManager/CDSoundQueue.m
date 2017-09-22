//
//  CDSoundQueue.m
//  CodoonSport
//
//  Created by Jinxiao on 1/31/16.
//  Copyright © 2016 Codoon. All rights reserved.
//

#import "CDSoundQueue.h"

#import <libkern/OSAtomic.h>

#import "CDDefer.h"

@import AVFoundation;
@import CoreTelephony;

@interface CDSoundQueue () <CDSoundTaskDelegate>
@property (readwrite, nonatomic, strong) NSMutableArray<CDSoundTask *> *tasks;
@property (readwrite, nonatomic, strong) CDSoundTask *task;
@property (readwrite, nonatomic, assign) dispatch_defer_t defer;
@property (readwrite, nonatomic, strong) NSHashTable <id<CDSoundQueueDelegate>> *delegates;
@property (readwrite, nonatomic, assign) BOOL interrupted;
@property (readwrite, nonatomic, strong) CTCallCenter *callCenter;
@end

@implementation CDSoundQueue

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
    
    _tasks = [[NSMutableArray alloc] init];
    
    _delegates = [[NSHashTable alloc] initWithOptions:NSPointerFunctionsWeakMemory capacity:0];
    
    _defer = dispatch_defer_create();
    
    __weak typeof(self) weakSelf = self;
    _callCenter = [[CTCallCenter alloc] init];
    _callCenter.callEventHandler = ^(CTCall* call) {
        [weakSelf callCenterDidChangeState];
    };
    
    return self;
}

- (void)callCenterDidChangeState {
    __block BOOL interrupted = NO;
    
    [_callCenter.currentCalls enumerateObjectsUsingBlock:^(CTCall * _Nonnull obj, BOOL * _Nonnull stop) {
        if([obj.callState isEqualToString:CTCallStateConnected] || [obj.callState isEqualToString:CTCallStateIncoming] || [obj.callState isEqualToString:CTCallStateDialing]) {
            interrupted = YES;
            *stop = YES;
        }
    }];
    
    _interrupted = interrupted;
    
    if(_interrupted) {
        [self drain];
    }
}

- (void)enqueueTask:(CDSoundTask *)task {
    if(_interrupted) {
        return;
    }
    
    __block BOOL enqueuable = YES;
    [_delegates.allObjects enumerateObjectsUsingBlock:^(id<CDSoundQueueDelegate>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if([obj respondsToSelector:@selector(soundQueue:shouldEnqueueTask:)]) {
            enqueuable &= [obj soundQueue:self shouldEnqueueTask:task];
        }
    }];
    
    if(!enqueuable) {
        return;
    }
    
    if(task.options&CDSoundTaskOptionQueued) {
        [_tasks addObject:task];
        
        [self processNextIfNeeded];
    } else {
        [_tasks insertObject:task atIndex:0];
        
        if(_task != nil) {
            [_task stopPlaying];
        } else {
            [self processNextIfNeeded];
        }
    }
}

- (void)drain {
    [_tasks removeAllObjects];
    
    if(_task != nil) {
        [_task stopPlaying];
    }
}

- (void)processNextIfNeeded {
    dispatch_defer(&_defer, ^{
        if(_task != nil) {
            return;
        }
        
        if(_tasks.count == 0) {
            return;
        }
        
        __block CDSoundTask *task = _tasks.firstObject;
        [_tasks enumerateObjectsUsingBlock:^(CDSoundTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if(obj.priority > task.priority) {
                task = obj;
            }
        }];
        
        if(task.options&CDSoundTaskOptionDrain) {
            [_tasks removeAllObjects];
        } else {
            [_tasks removeObject:task];
        }
        
        task.delegate = self;
        [task startPlaying];
        
        _task = task;
    });
}

#pragma mark - CDSoundTaskDelegate

- (void)soundTaskWillStartPlaying:(CDSoundTask *)task {
    [_delegates.allObjects enumerateObjectsUsingBlock:^(id<CDSoundQueueDelegate>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if([obj respondsToSelector:@selector(soundQueue:willStartTask:)])
        {
            [obj soundQueue:self willStartTask:task];
        }
    }];
}

- (void)soundTaskDidStartPlaying:(CDSoundTask *)task {
    [_delegates.allObjects enumerateObjectsUsingBlock:^(id<CDSoundQueueDelegate>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if([obj respondsToSelector:@selector(soundQueue:didStartTask:)]) {
            [obj soundQueue:self didStartTask:task];
        }
    }];
}

- (void)soundTaskWillStopPlaying:(CDSoundTask *)task {
    [_delegates.allObjects enumerateObjectsUsingBlock:^(id<CDSoundQueueDelegate>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if([obj respondsToSelector:@selector(soundQueue:willFinishTask:)]) {
            [obj soundQueue:self willFinishTask:task];
        }
    }];
}

- (void)soundTaskDidStopPlaying:(CDSoundTask *)task {
    _task = nil;
    
    [_delegates.allObjects enumerateObjectsUsingBlock:^(id<CDSoundQueueDelegate>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if([obj respondsToSelector:@selector(soundQueue:didFinishTask:)]) {
            [obj soundQueue:self didFinishTask:task];
        }
    }];
    
    [self processNextIfNeeded];
}

- (void)addDelegate:(id<CDSoundQueueDelegate>)delegate
{
    if([delegate conformsToProtocol:@protocol(CDSoundQueueDelegate)] && ![_delegates containsObject:delegate])
    {
        [_delegates addObject:delegate];
    }
}

- (void)removeDelegate:(id<CDSoundQueueDelegate>)delegate
{
    [_delegates removeObject:delegate];
}

@end

