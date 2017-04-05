//
//  DGGlobalTimerTask.m
//  DGGlobalTimer
//
//  Created by Jinxiao on 7/25/14.
//  Copyright (c) 2014 debugeek. All rights reserved.
//

#import "CDGlobalTimerTask.h"
#import "CDGlobalTimerTaskManager.h"
#import "CDGlobalTimerObserverManager.h"

@interface CDGlobalTimerTask () <NSCoding>
@property (readwrite, nonatomic, strong) NSTimer *timer;
@end

@implementation CDGlobalTimerTask

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self)
    {
        self.key = [aDecoder decodeObjectForKey:@"key"];
        self.deadline = [aDecoder decodeObjectForKey:@"deadline"];
        self.interval = [aDecoder decodeDoubleForKey:@"interval"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.key forKey:@"key"];
    [aCoder encodeObject:self.deadline forKey:@"deadline"];
    [aCoder encodeDouble:self.interval forKey:@"interval"];
}

- (void)schedule
{
    [_timer invalidate];
    _timer = nil;
    
    NSTimeInterval remains = [_deadline timeIntervalSinceDate:[NSDate date]];
    
    if(remains <= 0)
    {
        [[CDGlobalTimerTaskManager sharedInstance] removeTimerTask:self];
        [[CDGlobalTimerObserverManager sharedInstance] dispatchCompletionEventsForKey:_key];
    }
    else
    {
        [[CDGlobalTimerTaskManager sharedInstance] addTimerTask:self];
        [[CDGlobalTimerObserverManager sharedInstance] dispatchInitialEventsForKey:_key];
        
        _timer = [NSTimer scheduledTimerWithTimeInterval:_interval target:self selector:@selector(timerDidFired) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
}

- (void)finish
{
    [_timer invalidate];
    _timer = nil;
    
    [[CDGlobalTimerTaskManager sharedInstance] removeTimerTask:self];
    [[CDGlobalTimerObserverManager sharedInstance] dispatchCompletionEventsForKey:_key];
}

- (void)cancel
{
    [_timer invalidate];
    _timer = nil;
    
    [[CDGlobalTimerTaskManager sharedInstance] removeTimerTask:self];
    [[CDGlobalTimerObserverManager sharedInstance] dispatchInitialEventsForKey:_key];
}

- (void)timerDidFired
{
    NSTimeInterval remains = [_deadline timeIntervalSinceDate:[NSDate date]];
    
    if(remains > 0)
    {
        [[CDGlobalTimerObserverManager sharedInstance] dispatchTriggerEventsForKey:_key remains:remains];
    }
    else
    {
        [self finish];
    }
}

@end