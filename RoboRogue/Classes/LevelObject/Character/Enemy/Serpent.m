//
//  Serpent.m
//  RoboRogue
//
//  Created by 山本政徳 on 2014/04/09.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "Serpent.h"

@interface Serpent ()
@property (nonatomic) NSInteger poison;
@end

@implementation Serpent
-(instancetype)initWithLevel:(RRGLevel *)level
{
    self = [super initWithLevel:level];
    if (self) {
        self.stateSprite.position = ccp(.5, .9);
    }
    return self;
}
-(void)setDefaultAttributes
{
    [super setDefaultAttributes];
    self.poison = 1;
    self.isDragon = YES;
    [self setLevelNamesArray:@[@"Serpent",
                               @"Viper",
                               @"PurpleWorm"]];
}
-(void)afterAttackEffect:(RRGCharacter *)target
{
    [target setStatePoison:self.poison];
}
-(void)setStatePoison:(NSInteger)poison
{
    [self setStateChangeOffensivePower:poison];
}
@end

@implementation Viper
-(void)setDefaultAttributes
{
    [super setDefaultAttributes];
    self.poison = 2;
}
@end

@implementation PurpleWorm
-(void)setDefaultAttributes
{
    [super setDefaultAttributes];
    self.poison = 3;
}
@end