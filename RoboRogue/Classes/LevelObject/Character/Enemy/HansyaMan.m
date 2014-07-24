//
//  HansyaMan.m
//  RoboRogue
//
//  Created by 山本政徳 on 2014/05/08.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "HansyaMan.h"

@implementation HansyaMan
-(void)setDefaultAttributes
{
    [super setDefaultAttributes];
    self.isMetal = YES;
    [self setLevelNamesArray:@[@"HansyaMan",
                               @"MirrorMan",
                               @"MirrorKing"]];
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

@implementation MirrorMan
@end

@implementation MirrorKing
@end