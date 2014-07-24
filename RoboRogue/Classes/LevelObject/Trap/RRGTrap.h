//
//  RRGTrap.h
//  RoboRogue
//
//  Created by 山本政徳 on 2014/03/07.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "RRGNonCharacterObject.h"

@class RRGCharacter;

@interface RRGTrap : RRGNonCharacterObject <NSCoding>
/*
 * save
 */
@property (nonatomic) BOOL found;
@property (nonatomic) BOOL unbreakable;
@property (nonatomic) BOOL isCorrupted;
/*
 * save
 */

//profile
@property (nonatomic) BOOL targetPlayer;
@property (nonatomic) BOOL targetNPC;
@property (nonatomic) BOOL actionOnce;

-(void)steppedOnBy:(RRGCharacter*)character
           message:(BOOL)message;
-(void)trapActionToCharacter:(RRGCharacter*)character;
-(void)corrupt;

@end