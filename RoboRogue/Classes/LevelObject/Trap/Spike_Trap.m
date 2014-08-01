//
//  Spike_Trap.m
//  RoboRogue
//
//  Created by 山本政徳 on 2014/03/30.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "Spike_Trap.h"
#import "RRGCharacter.h"

@implementation Spike_Trap
-(void)trapActionToCharacter:(RRGCharacter *)character
{
    [character dealtDamage:10 byCharacter:nil];
}
@end
