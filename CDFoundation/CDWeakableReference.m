//
//  CDWeakableReference.m
//  CodoonSport
//
//  Created by Jinxiao on 3/14/17.
//  Copyright © 2017 Codoon. All rights reserved.
//

#import "CDWeakableReference.h"

@interface CDWeakableReference ()
@property (readwrite, nonatomic, weak) id object;
@end

@implementation CDWeakableReference

- (instancetype)initWithObject:(id)object {
    self = [super init];

    _object = object;

    return self;
}

@end
