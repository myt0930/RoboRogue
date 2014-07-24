//
//  SummoningTrap.m
//  RoboRogue
//
//  Created by 山本政徳 on 2014/04/23.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "SummoningTrap.h"
#import "RRGCategories.h"
#import "RRGFunctions.h"
#import "RRGEnemy.h"

#import "RRGLevel+AddObject.h"
#import "RRGLevel+MapID.h"
#import "RRGLevel+Particle.h"

@implementation SummoningTrap
-(void)trapActionToCharacter:(RRGCharacter *)character
{
    NSMutableArray* intArray = [@[@0,@1,@2,@3,@4,@5,@6,@7] mutableCopy];
    
    NSInteger summonCount = 0;
    
    while (summonCount < 4) {
        if ([intArray count] == 0) {
            break;
        }
        NSNumber* val = [intArray objectAtRandom];
        [intArray removeObject:val];
        NSInteger rotation = [val integerValue];
        CGPoint direction = rotatedDirection(South, rotation);
        CGPoint tileCoord = ccpAdd(self.tileCoord, direction);
        
        if ([self.level groundAtTileCoord:tileCoord] &&
            [self.level characterAtTileCoord:tileCoord] == nil) {
            RRGEnemy* enemy = [self.level randomEnemyAtRandom:NO];
            [self.level addCharacter:enemy atTileCoord:tileCoord];
            
            [self.level addParticleWithName:kParticleSmoke
                                atTileCoord:tileCoord
                                      sound:YES];
            summonCount++;
        }
    }
}
@end