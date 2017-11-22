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
@property (readwrite, nonatomic, strong) dispatch_queue_t syncQueue;
@property (readwrite, nonatomic, assign) BOOL interrupted;
@property (readwrite, nonatomic, strong) CTCallCenter *callCenter;
@end

@implementation CDSoundQueue

+ (instancetype)sharedInstance {
    static id instance;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = self.new;
    });
    return instance;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init {
    self = [super init];
    
    _tasks = [[NSMutableArray alloc] init];
    
    _delegates = [[NSHashTable alloc] initWithOptions:NSPointerFunctionsWeakMemory capacity:0];
    
    _syncQueue = dispatch_queue_create(nil, DISPATCH_QUEUE_SERIAL);
    
    _defer = dispatch_defer_create();
    
    __weak typeof(self) weakSelf = self;
    _callCenter = [[CTCallCenter alloc] init];
    _callCenter.callEventHandler = ^(CTCall* call) {
        [weakSelf callCenterDidChangeState];
    };
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveRouteChangeNotification:) name:AVAudioSessionRouteChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMediaServicesWereLostNotification:) name:AVAudioSessionMediaServicesWereLostNotification object:nil];
    
    return self;
}

- (void)didReceiveRouteChangeNotification:(NSNotification *)notification {
    NSInteger reason = [[notification.userInfo objectForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    if(reason != AVAudioSessionRouteChangeReasonOldDeviceUnavailable && reason != AVAudioSessionRouteChangeReasonNewDeviceAvailable) {
        [self drain];
    }
}

- (void)didReceiveMediaServicesWereLostNotification:(NSNotification *)notification {
    [self drain];
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
    
    if(task.data == nil) {
        return;
    }
    
    __block BOOL enqueuable = YES;
    dispatch_sync(_syncQueue, ^{
        for(id<CDSoundQueueDelegate> delegate in _delegates) {
            if([delegate respondsToSelector:@selector(soundQueue:shouldEnqueueTask:)]) {
                enqueuable &= [delegate soundQueue:self shouldEnqueueTask:task];
            }
        }
    });
    
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
    dispatch_sync(_syncQueue, ^{
        for(id<CDSoundQueueDelegate> delegate in _delegates) {
            if([delegate respondsToSelector:@selector(soundQueue:willStartTask:)]) {
                [delegate soundQueue:self willStartTask:task];
            }
        }
    });
}

- (void)soundTaskDidStartPlaying:(CDSoundTask *)task {
    dispatch_sync(_syncQueue, ^{
        for(id<CDSoundQueueDelegate> delegate in _delegates) {
            if([delegate respondsToSelector:@selector(soundQueue:didStartTask:)]) {
                [delegate soundQueue:self didStartTask:task];
            }
        }
    });
}

- (void)soundTaskWillStopPlaying:(CDSoundTask *)task {
    dispatch_sync(_syncQueue, ^{
        for(id<CDSoundQueueDelegate> delegate in _delegates) {
            if([delegate respondsToSelector:@selector(soundQueue:willFinishTask:)]) {
                [delegate soundQueue:self willFinishTask:task];
            }
        }
    });
}

- (void)soundTaskDidStopPlaying:(CDSoundTask *)task {
    _task = nil;
    
    dispatch_sync(_syncQueue, ^{
        for(id<CDSoundQueueDelegate> delegate in _delegates) {
            if([delegate respondsToSelector:@selector(soundQueue:didFinishTask:)]) {
                [delegate soundQueue:self didFinishTask:task];
            }
        }
    });
    
    [self processNextIfNeeded];
}

- (void)addDelegate:(id<CDSoundQueueDelegate>)delegate {
    dispatch_sync(_syncQueue, ^{
        if([delegate conformsToProtocol:@protocol(CDSoundQueueDelegate)] && ![_delegates containsObject:delegate]) {
            [_delegates addObject:delegate];
        }
    });
}

- (void)removeDelegate:(id<CDSoundQueueDelegate>)delegate {
    dispatch_sync(_syncQueue, ^{
        [_delegates removeObject:delegate];
    });
}

@end

