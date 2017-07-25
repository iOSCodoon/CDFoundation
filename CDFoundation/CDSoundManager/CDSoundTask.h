//
//  CDSoundTask.h
//  CDSoundManager
//
//  Created by Jinxiao on 1/31/16.
//  Copyright © 2016 codoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CDSoundTask;

typedef NS_ENUM(NSUInteger, CDSoundTaskOptions) {
    CDSoundTaskOptionImmediate = 0 << 0,
    CDSoundTaskOptionQueued = 1 << 0,
    CDSoundTaskOptionDrain = 1 << 2,
    
    CDSoundTaskOptionDuckOthers = 16 << 0,
    CDSoundTaskOptionMixWithOthers = 16 << 1,
    CDSoundTaskOptionSolo = 16 << 2
};

typedef NS_ENUM(NSUInteger, CDSoundTaskPriority) {
    CDSoundTaskPriorityLow = 0,
    CDSoundTaskPriorityMiddle = 500,
    CDSoundTaskPriorityHigh = 1000,
};

@protocol CDSoundTaskDelegate <NSObject>

@optional
- (void)soundTaskWillStartPlaying:(CDSoundTask *)task;
- (void)soundTaskDidStartPlaying:(CDSoundTask *)task;
- (void)soundTaskWillStopPlaying:(CDSoundTask *)task;
- (void)soundTaskDidStopPlaying:(CDSoundTask *)task;

@end

@interface CDSoundTask : NSObject

@property (readwrite, nonatomic, weak) id<CDSoundTaskDelegate> delegate;

@property (readwrite, nonatomic, assign) CDSoundTaskOptions options;

@property (readwrite, nonatomic, strong) NSData *data;

@property (readwrite, nonatomic, assign) CDSoundTaskPriority priority;

@property (readwrite, nonatomic, assign) float volume;

- (instancetype)initWithData:(NSData *)data;

- (void)startPlaying;
- (void)stopPlaying;

@property (readwrite, nonatomic, strong) void (^completion) ();

@property (readwrite, nonatomic, strong) id userInfo;

@end


extern NSString * const CDSoundTaskWillStartPlayingNotification;
extern NSString * const CDSoundTaskDidStartPlayingNotification;

extern NSString * const CDSoundTaskWillStopPlayingNotification;
extern NSString * const CDSoundTaskDidStopPlayingNotification;


extern NSString * const CDSoundTaskWillActiveAudioSessionNotification;
extern NSString * const CDSoundTaskDidActiveAudioSessionNotification;

extern NSString * const CDSoundTaskWillDeactiveAudioSessionNotification;
extern NSString * const CDSoundTaskDidDeactiveAudioSessionNotification;
