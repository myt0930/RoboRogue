//
//  Mystikoi.m
//  RoboRogue
//
//  Created by 山本政徳 on 2014/05/23.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "Mystikoi.h"
#import "RRGFunctions.h"
#import "RRGCategories.h"
#import "RRGRoom.h"

#import "RRGLevel+AddObject.h"
#import "RRGLevel+TurnSequence.h"
#import "RRGLevel+Particle.h"

@implementation Mystikoi
-(void)setDefaultAttributes
{
    [super setDefaultAttributes];
    self.canFly = YES;
    [self setLevelNamesArray:@[@"Mystikoi",
                               @"SeaMystikoi",
                               @"PearlMystikoi"]];
}
-(BOOL)useSkill
{
    if ([self canUseSkill] && calculateProbability(50)) {
        [self useSkillToDirection:self.direction];
        return YES;
    }
    return NO;
}
-(CGRect)useSkillRect
{
    return CGRectMake(self.tileCoord.x - 1,
                      self.tileCoord.y - 1,
                      3,
                      3);
}
-(BOOL)canUseSkill
{
    CGRect useSkillRect = [self useSkillRect];
    CGRectForEach(useSkillRect)
    {
        RRGCharacter* character = [self.level characterAtTileCoord:ccp(x,y)];
        if (character && [character.status count] > 0) {
            return YES;
        }
    }
    return NO;
}
-(void)useSkillToDirection:(CGPoint)direction
{
    //CCLOG(@"%s", __PRETTY_FUNCTION__);
    CGRect useSkillRect = [self useSkillRect];
    CGRectForEach(useSkillRect)
    {
        RRGCharacter* character = [self.level characterAtTileCoord:ccp(x,y)];
        if (character && [character.status count] > 0) {
            //particle
            [self.level addParticleWithName:kParticleBless
                                atTileCoord:ccp(x,y)
                                      sound:YES];
            [character removeAllStatusWithSound:NO message:YES];
        }
    }
    [self rotate:1];
}
@end

@implementation SeaMystikoi
-(CGRect)useSkillRect
{
    return CGRectMake(self.tileCoord.x - 2,
                      self.tileCoord.y - 2,
                      5,
                      5);
}
@end

@implementation PearlMystikoi
-(CGRect)useSkillRect
{
    if ([self inRoom] && self.room) {
        return self.room.roomRect;
    } else {
        return CGRectMake(self.tileCoord.x - 3,
                          self.tileCoord.y - 3,
                          7,
                          7);
    }
}
@end