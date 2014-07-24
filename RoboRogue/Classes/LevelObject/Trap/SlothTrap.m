//
//  SlothTrap.m
//  RoboRogue
//
//  Created by 山本政徳 on 2014/04/07.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "SlothTrap.h"
#import "RRGCharacter.h"

@implementation SlothTrap
-(void)trapActionToCharacter:(RRGCharacter *)character
{
    [character setStateChangeSpeed:-1];
}
@end
