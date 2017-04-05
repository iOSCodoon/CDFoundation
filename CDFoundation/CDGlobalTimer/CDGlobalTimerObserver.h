//
//  DGGlobalTimerObserver.h
//  DGGlobalTimer
//
//  Created by Jinxiao on 7/25/14.
//  Copyright (c) 2014 debugeek. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CDGlobalTimerObserver : NSObject

@property (readwrite, nonatomic, strong) NSString *identifier;

@property (readwrite, nonatomic, strong) NSString *key;

@property (readwrite, nonatomic, strong) void (^initial) (void);

@property (readwrite, nonatomic, strong) void (^trigger) (NSTimeInterval remains);

@property (readwrite, nonatomic, strong) void (^completion) (void);

@end
