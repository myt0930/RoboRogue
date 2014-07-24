//
//  SleepingGasTrap.m
//  RoboRogue
//
//  Created by 山本政徳 on 2014/03/30.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "SleepingGasTrap.h"
#import "RRGCharacter.h"

#import "RRGLevel+TurnSequence.h"
#import "RRGLevel+Particle.h"

@implementation SleepingGasTrap
-(void)trapActionToCharacter:(RRGCharacter *)character
{
    if ([self.level inView:self.tileCoord]) {
        [self.level addParticleWithName:kParticleSleepingGas
                            atTileCoord:self.tileCoord
                                  sound:YES];
        
        [self.level addAction:[CCActionDelay actionWithDuration:0.5f]];
    }
    
    [character setState:kStateAsleep];
}
@end
