//
//  DGGlobalTimerTask.h
//  DGGlobalTimer
//
//  Created by Jinxiao on 7/25/14.
//  Copyright (c) 2014 debugeek. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CDGlobalTimerTask : NSObject

@property (readwrite, nonatomic, strong) NSString *key;

@property (readwrite, nonatomic, assign) NSTimeInterval interval;

@property (readwrite, nonatomic, strong) NSDate *deadline;

- (void)schedule;

- (void)finish;

- (void)cancel;

@end
