//
//  CDDefer.h
//  CodoonSport
//
//  Created by Jinxiao on 2/1/16.
//  Copyright © 2016 Codoon. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef long dispatch_defer_t;

extern dispatch_defer_t dispatch_defer_create(void);

extern void dispatch_defer(dispatch_defer_t *defer, dispatch_block_t block);
