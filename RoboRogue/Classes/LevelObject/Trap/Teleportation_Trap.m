//
//  Warp.m
//  RoboRogue
//
//  Created by 山本政徳 on 2014/03/24.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "Teleportation_Trap.h"
#import "RRGAction.h"
#import "RRGCharacter.h"

#import "RRGLevel+TurnSequence.h"

@implementation Teleportation_Trap
-(void)updateObjectSprite
{
    CCParticleSystem* particle = [CCParticleSystem particleWithFile:@"TeleportationParticle.plist"];
    particle.position = CGPointZero;
    
    __weak Teleportation_Trap* weakSelf = self;
    CCActionCallBlock* block = [CCActionCallBlock actionWithBlock:^{
        [weakSelf.objectSprite addChild:particle];
    }];
    
    [self.level addAction:[RRGAction actionWithTarget:self
                                               action:block
                                             forSpawn:YES]];
}
-(void)trapActionToCharacter:(RRGCharacter *)character
{
    [character warpToRandomTileCoord];
}
@end

@implementation Teleportation_Trap_Unbreakable
-(void)setDefaultAttributes
{
    [super setDefaultAttributes];
    self.found = YES;
    self.unbreakable = YES;
}
@end