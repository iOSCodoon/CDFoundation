//
//  CDDefer.m
//  CodoonSport
//
//  Created by Jinxiao on 2/1/16.
//  Copyright © 2016 Codoon. All rights reserved.
//

#import "CDDefer.h"

@interface CDDeferObject : NSObject
@property (readwrite, nonatomic, copy) dispatch_block_t block;
@end
@implementation CDDeferObject
- (void)dealloc
{
    !_block ?: _block();
    _block = nil;
}
@end

dispatch_defer_t dispatch_defer_create()
{
    return 0;
}

void dispatch_defer(dispatch_defer_t *defer, dispatch_block_t block)
{
    if(*defer == 0)
    {
        CDDeferObject *deferObject = CDDeferObject.new;
        
        SEL retainSEL = NSSelectorFromString(@"retain");
        SEL autoreleaseSEL = NSSelectorFromString(@"autorelease");
        
        IMP retainIMP = [deferObject methodForSelector:retainSEL];
        IMP autoreleaseIMP = [deferObject methodForSelector:autoreleaseSEL];
        
        void (*retain)(id, SEL) = (void *)retainIMP;
        void (*autorelease)(id, SEL) = (void *)autoreleaseIMP;
        
        if(retain != NULL && autorelease != NULL)
        {
            retain(deferObject, retainSEL);
            autorelease(deferObject, autoreleaseSEL);
        }
        
        deferObject.block = ^{
            !block ?: block();
            *defer = 0;
        };
        *defer = 1;
    }
}