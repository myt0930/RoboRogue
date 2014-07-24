//
//  RRGButtonBehavior.m
//  RoboRogue
//
//  Created by 山本政徳 on 2014/07/15.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "RRGButtonBehavior.h"

@implementation RRGButtonBehavior
+(instancetype)behaviorWithSize:(CGSize)size
{
    return [[self alloc] initWithSize:size];
}
-(instancetype)initWithSize:(CGSize)size
{
    self = [super init];
    if (self) {
        self.userInteractionEnabled = YES;
        self.contentSize = size;
    }
    return self;
}
-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (_actionOnce) self.userInteractionEnabled = NO;
    _block(self);
}
@end
