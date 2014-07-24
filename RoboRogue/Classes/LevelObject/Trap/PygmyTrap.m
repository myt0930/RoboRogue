//
//  PygmyTrap.m
//  RoboRogue
//
//  Created by 山本政徳 on 2014/05/22.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "PygmyTrap.h"
#import "RRGCharacter.h"

@implementation PygmyTrap
-(void)trapActionToCharacter:(RRGCharacter*)character
{
    [character setState:kStatePygmy];
}
@end
