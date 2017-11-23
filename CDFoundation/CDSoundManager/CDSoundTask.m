//
//  CDSoundTask.m
//  CDSoundManager
//
//  Created by Jinxiao on 1/31/16.
//  Copyright © 2016 codoon. All rights reserved.
//

#import "CDSoundTask.h"

@import AVFoundation;

@interface CDSoundTask () <AVAudioPlayerDelegate>
@property (readwrite, nonatomic, strong) AVAudioPlayer *player;
@property (readwrite, nonatomic, weak) AVAudioPlayer *weakPlayer;
@property (readwrite, nonatomic, strong) dispatch_queue_t queue;
@end

@implementation CDSoundTask

- (void)dealloc
{
    _player.delegate = nil;
    _player = nil;
}

- (instancetype)initWithData:(NSData *)data
{
    self = [super init];

    _volume = 1;

    _queue = dispatch_queue_create(nil, 0);

    _options = CDSoundTaskOptionQueued;
    
    _data = data;

    _player = [[AVAudioPlayer alloc] initWithData:_data error:nil];
    _weakPlayer = _player;

    return self;
}

- (void)startPlaying
{
    dispatch_async(_queue, ^{
        if([_delegate respondsToSelector:@selector(soundTaskWillStartPlaying:)])
        {
            [_delegate soundTaskWillStartPlaying:self];
        }

        if(!(_options&CDSoundTaskOptionMixWithOthers)) {
            [[NSNotificationCenter defaultCenter] postNotificationName:CDSoundTaskWillActiveAudioSessionNotification object:self];
        }

        NSString *category = AVAudioSessionCategoryPlayback;
        AVAudioSessionCategoryOptions options = AVAudioSessionCategoryOptionMixWithOthers;

        if(_options&CDSoundTaskOptionMixWithOthers) {
            options = AVAudioSessionCategoryOptionMixWithOthers;
            category = AVAudioSessionCategoryPlayback;
        } else if(_options&CDSoundTaskOptionSolo) {
            options = AVAudioSessionCategoryOptionDuckOthers;
            category = AVAudioSessionCategorySoloAmbient;
        } else if(_options&CDSoundTaskOptionAmbient) {
            options = AVAudioSessionCategoryOptionMixWithOthers;
            category = AVAudioSessionCategoryAmbient;
        } else {
            options = AVAudioSessionCategoryOptionDuckOthers;
            category = AVAudioSessionCategoryPlayback;
        }

        [[AVAudioSession sharedInstance] setCategory:category withOptions:options error:nil];

        if(!(_options&CDSoundTaskOptionMixWithOthers)) {
            [[AVAudioSession sharedInstance] setActive:YES error:nil];
        }

        _weakPlayer.volume = _volume;
        _weakPlayer.delegate = self;
        [_weakPlayer prepareToPlay];
        [_weakPlayer play];

        if(!(_options&CDSoundTaskOptionMixWithOthers)) {
            [[NSNotificationCenter defaultCenter] postNotificationName:CDSoundTaskDidActiveAudioSessionNotification object:self];
        }
        
        if([_delegate respondsToSelector:@selector(soundTaskDidStartPlaying:)])
        {
            [_delegate soundTaskDidStartPlaying:self];
        }
    });
}

- (void)stopPlaying
{
    dispatch_async(_queue, ^{
        if([_delegate respondsToSelector:@selector(soundTaskWillStopPlaying:)])
        {
            [_delegate soundTaskWillStopPlaying:self];
        }

        if(!(_options&CDSoundTaskOptionMixWithOthers)) {
            [[NSNotificationCenter defaultCenter] postNotificationName:CDSoundTaskWillDeactiveAudioSessionNotification object:self];
        }

        [_weakPlayer stop];
        _weakPlayer.delegate = nil;

        if(!(_options&CDSoundTaskOptionMixWithOthers)) {
            [[AVAudioSession sharedInstance] setActive:NO error:nil];

            [[NSNotificationCenter defaultCenter] postNotificationName:CDSoundTaskDidDeactiveAudioSessionNotification object:self];
        }

        if([NSThread isMainThread]) {
            !_completion ?: _completion();
        } else {
            dispatch_sync(dispatch_get_main_queue(), ^{
                !_completion ?: _completion();
            });
        }
        
        if([_delegate respondsToSelector:@selector(soundTaskDidStopPlaying:)])
        {
            [_delegate soundTaskDidStopPlaying:self];
        }
    });
}

- (void)setVolume:(float)volume {
    [self willChangeValueForKey:@"volume"];
    
    _volume = volume;
    
    _weakPlayer.volume = volume;
    
    [self didChangeValueForKey:@"volume"];
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self stopPlaying];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError * __nullable)error
{
    [self stopPlaying];
}

@end



NSString * const CDSoundTaskWillActiveAudioSessionNotification = @"CDSoundTaskWillActiveAudioSessionNotification";
NSString * const CDSoundTaskDidActiveAudioSessionNotification = @"CDSoundTaskDidActiveAudioSessionNotification";

NSString * const CDSoundTaskWillDeactiveAudioSessionNotification = @"CDSoundTaskWillDeactiveAudioSessionNotification";
NSString * const CDSoundTaskDidDeactiveAudioSessionNotification = @"CDSoundTaskDidDeactiveAudioSessionNotification";
