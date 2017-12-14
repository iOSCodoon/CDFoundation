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
@property (readwrite, nonatomic, strong) dispatch_queue_t queue;
@end

@interface CDSoundTask (Convenience)
- (BOOL)shouldActiveAudioSession;
@end


@implementation CDSoundTask

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    _player.delegate = nil;
    _player = nil;
}

- (instancetype)initWithData:(NSData *)data {
    self = [super init];

    _pending = YES;
    
    _volume = 1;

    _queue = dispatch_queue_create(nil, 0);

    _options = CDSoundTaskOptionQueued;
    
    _data = data;

    _player = [[AVAudioPlayer alloc] initWithData:_data error:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveWillStartPlayingNotification:) name:CDSoundTaskWillStartPlayingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveDidStopPlayingNotification:) name:CDSoundTaskDidStopPlayingNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveWillDeactiveAudioSessionNotification:) name:CDSoundTaskWillDeactiveAudioSessionNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveDidDeactiveAudioSessionNotification:) name:CDSoundTaskDidDeactiveAudioSessionNotification object:nil];
    
    return self;
}

- (void)didReceiveWillStartPlayingNotification:(NSNotification *)notification {
    CDSoundTask *task = notification.object;
    
    if(task == self) {
        return;
    }
    
    if(_options&CDSoundTaskOptionAmbient && [task shouldActiveAudioSession]) {
        _player.volume = MIN(0.2, _volume);
    }
}

- (void)didReceiveDidStopPlayingNotification:(NSNotification *)notification {
    CDSoundTask *task = notification.object;
    
    if(task == self) {
        return;
    }
    
    if(_options&CDSoundTaskOptionAmbient && [task shouldActiveAudioSession]) {
        _player.volume = _volume;
    }
}

- (void)didReceiveWillActiveAudioSessionNotification:(NSNotification *)notification {
    CDSoundTask *task = notification.object;
    
    if(task == self) {
        return;
    }
    
    if(_pending) {
        return;
    }
    
    [_player pause];
}

- (void)didReceiveDidActiveAudioSessionNotification:(NSNotification *)notification {
    CDSoundTask *task = notification.object;
    
    if(task == self) {
        return;
    }
    
    if(_pending) {
        return;
    }
    
    NSString *category = AVAudioSessionCategoryPlayback;
    AVAudioSessionCategoryOptions options = AVAudioSessionCategoryOptionMixWithOthers;
    [self preferredCategory:&category options:&options];
    
    [[AVAudioSession sharedInstance] setCategory:category withOptions:options error:nil];
    
    if([self shouldActiveAudioSession]) {
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
    }
    
    [_player play];
}

- (void)didReceiveWillDeactiveAudioSessionNotification:(NSNotification *)notification {
    CDSoundTask *task = notification.object;
    
    if(task == self) {
        return;
    }
    
    if(_pending) {
        return;
    }
    
    [_player pause];
}

- (void)didReceiveDidDeactiveAudioSessionNotification:(NSNotification *)notification {
    CDSoundTask *task = notification.object;
    
    if(task == self) {
        return;
    }
    
    if(_pending) {
        return;
    }
    
    NSString *category = AVAudioSessionCategoryPlayback;
    AVAudioSessionCategoryOptions options = AVAudioSessionCategoryOptionMixWithOthers;
    [self preferredCategory:&category options:&options];
    
    [[AVAudioSession sharedInstance] setCategory:category withOptions:options error:nil];
    
    if([self shouldActiveAudioSession]) {
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
    }
    
    [_player play];
}

- (void)preferredCategory:(NSString **)category options:(AVAudioSessionCategoryOptions *)options {
    if(_options&CDSoundTaskOptionMixWithOthers) {
        *options = AVAudioSessionCategoryOptionMixWithOthers;
        *category = AVAudioSessionCategoryPlayback;
    } else if(_options&CDSoundTaskOptionSolo) {
        *options = AVAudioSessionCategoryOptionDuckOthers;
        *category = AVAudioSessionCategorySoloAmbient;
    } else if(_options&CDSoundTaskOptionAmbient) {
        *options = AVAudioSessionCategoryOptionDuckOthers;
        *category = AVAudioSessionCategoryPlayback;
    } else if(_options&CDSoundTaskOptionSilent) {
        *options = AVAudioSessionCategoryOptionMixWithOthers;
        *category = AVAudioSessionCategoryPlayback;
    } else {
        *options = AVAudioSessionCategoryOptionDuckOthers;
        *category = AVAudioSessionCategoryPlayback;
    }
}

- (void)startPlaying
{
    dispatch_async(_queue, ^{
        if([_delegate respondsToSelector:@selector(soundTaskWillStartPlaying:)]) {
            [_delegate soundTaskWillStartPlaying:self];
        }

        [[NSNotificationCenter defaultCenter] postNotificationName:CDSoundTaskWillStartPlayingNotification object:self];
        
        NSString *category = AVAudioSessionCategoryPlayback;
        AVAudioSessionCategoryOptions options = AVAudioSessionCategoryOptionMixWithOthers;
        [self preferredCategory:&category options:&options];
        
        [[AVAudioSession sharedInstance] setCategory:category withOptions:options error:nil];
        
        if([self shouldActiveAudioSession]) {
            [[AVAudioSession sharedInstance] setActive:YES error:nil];
        }

        _player.volume = _volume;
        
        if(_options&CDSoundTaskOptionSilent) {
            _player.volume = 0;
        }
        
        _player.delegate = self;
        [_player prepareToPlay];
        [_player play];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:CDSoundTaskDidStartPlayingNotification object:self];
        
        if([_delegate respondsToSelector:@selector(soundTaskDidStartPlaying:)]) {
            [_delegate soundTaskDidStartPlaying:self];
        }
    });
}

- (void)stopPlaying {
    dispatch_async(_queue, ^{
        if([_delegate respondsToSelector:@selector(soundTaskWillStopPlaying:)]) {
            [_delegate soundTaskWillStopPlaying:self];
        }

        [[NSNotificationCenter defaultCenter] postNotificationName:CDSoundTaskWillStopPlayingNotification object:self];

        BOOL willDeactiveAudioSession = [self shouldActiveAudioSession] && [AVAudioSession sharedInstance].otherAudioPlaying;
        
        if(willDeactiveAudioSession) {
            [[NSNotificationCenter defaultCenter] postNotificationName:CDSoundTaskWillDeactiveAudioSessionNotification object:self];
            
            [[AVAudioSession sharedInstance] setActive:NO error:nil];
        }

        [_player stop];
        _player.delegate = nil;
        _player = nil;

        if(willDeactiveAudioSession) {
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionDuckOthers error:nil];
            [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
        }
        
        if(willDeactiveAudioSession) {
            [[NSNotificationCenter defaultCenter] postNotificationName:CDSoundTaskDidDeactiveAudioSessionNotification object:self];
        }

        [[NSNotificationCenter defaultCenter] postNotificationName:CDSoundTaskDidStopPlayingNotification object:self];
        
        if([NSThread isMainThread]) {
            !_completion ?: _completion();
        } else {
            dispatch_sync(dispatch_get_main_queue(), ^{
                !_completion ?: _completion();
            });
        }
        
        if([_delegate respondsToSelector:@selector(soundTaskDidStopPlaying:)]) {
            [_delegate soundTaskDidStopPlaying:self];
        }
    });
}

- (void)setVolume:(float)volume {
    [self willChangeValueForKey:@"volume"];
    
    _volume = volume;
    
    _player.volume = volume;
    
    [self didChangeValueForKey:@"volume"];
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [self stopPlaying];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError * __nullable)error {
    [self stopPlaying];
}

@end



NSString * const CDSoundTaskWillStartPlayingNotification = @"CDSoundTaskWillStartPlayingNotification";
NSString * const CDSoundTaskDidStartPlayingNotification = @"CDSoundTaskDidStartPlayingNotification";

NSString * const CDSoundTaskWillStopPlayingNotification = @"CDSoundTaskWillStopPlayingNotification";
NSString * const CDSoundTaskDidStopPlayingNotification = @"CDSoundTaskDidStopPlayingNotification";

NSString * const CDSoundTaskWillDeactiveAudioSessionNotification = @"CDSoundTaskWillDeactiveAudioSessionNotification";
NSString * const CDSoundTaskDidDeactiveAudioSessionNotification = @"CDSoundTaskDidDeactiveAudioSessionNotification";


@implementation CDSoundTask (Convenience)

- (BOOL)shouldActiveAudioSession {
    return (!(_options&CDSoundTaskOptionMixWithOthers) && !(_options&CDSoundTaskOptionSilent));
}

@end

