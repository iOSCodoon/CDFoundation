//
//  CDWeakableReference.h
//  CodoonSport
//
//  Created by Jinxiao on 3/14/17.
//  Copyright © 2017 Codoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CDWeakableReference : NSObject

@property (readonly, weak) id object;

- (instancetype)initWithObject:(id)object;

@end
