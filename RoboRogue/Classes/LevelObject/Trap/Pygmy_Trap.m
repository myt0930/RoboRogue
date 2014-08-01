//
//  Pygmy_Trap.m
//  RoboRogue
//
//  Created by 山本政徳 on 2014/05/22.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "Pygmy_Trap.h"
#import "RRGCharacter.h"

@implementation Pygmy_Trap
-(void)trapActionToCharacter:(RRGCharacter*)character
{
    [character setState:kStatePygmy];
}
@end
