//
//  Rotating_Plate.m
//  RoboRogue
//
//  Created by 山本政徳 on 2014/03/27.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "Rotating_Plate.h"
#import "RRGCategories.h"
#import "RRGCharacter.h"

#import "RRGLevel+TurnSequence.h"

@implementation Rotating_Plate
-(void)trapActionToCharacter:(RRGCharacter *)character
{
    if ([self.level inView:self.tileCoord]) {
        [self.level addAction:[CCActionSoundEffect actionWithSoundFile:@"rotate.caf"]];
        [character rotate:2];
    }
    
    [character setState:kStateConfusion];
}
@end