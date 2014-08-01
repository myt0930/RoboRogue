//
//  Hansya_Man.m
//  RoboRogue
//
//  Created by 山本政徳 on 2014/05/08.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "Hansya_Man.h"

@implementation Hansya_Man
-(void)setDefaultAttributes
{
    [super setDefaultAttributes];
    self.isMetal = YES;
    [self setLevelNamesArray:@[@"Hansya_Man",
                               @"Mirror_Man",
                               @"Mirror_King"]];
}
-(void)willHitByMagicBullet:(RRGMagicBullet *)magicBullet
{
    [self wakeUpFromNap];
    
    if ([self haveState:kStateSealed]) {
        [super willHitByMagicBullet:magicBullet];
    } else {
        [self reflectMagicBullet:magicBullet];
    }
}
@end

@implementation Mirror_Man
@end

@implementation Mirror_King
@end