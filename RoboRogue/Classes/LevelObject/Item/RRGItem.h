//
//  RRGItem.h
//  RoboRogue
//
//  Created by 山本政徳 on 2014/03/24.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "RRGNonCharacterObject.h"

typedef NS_ENUM(NSUInteger, RRGItemCursedOrBlessed)
{
    RRGItemCursed,
    RRGItemNormal,
    RRGItemBlessed,
};

typedef NS_ENUM(NSInteger, ItemDispNumber)
{
    ItemDispNumberSword,
    ItemDispNumberShield,
    ItemDispNumberAmulet,
    ItemDispNumberPotion,
    ItemDispNumberStaff,
    ItemDispNumberScroll,
};

@class RRGPlayer;

@interface RRGItem : RRGNonCharacterObject <NSCoding>
/*
 * save
 */
@property (nonatomic) NSInteger cursedOrBlessed;
@property (nonatomic) BOOL equipped;
/*
 * save
 */

//profile
@property (nonatomic) ItemDispNumber dispNumber;
@property (nonatomic, readonly) NSString* itemInfo;

-(void)useToCharacter:(RRGCharacter*)target
          byCharacter:(RRGCharacter*)user;
-(void)hitCharacter:(RRGCharacter*)target
          direction:(CGPoint)direction
           thrownBy:(RRGCharacter*)character;
@end

@interface RRGItemUseOnce : RRGItem <NSCoding>
@end

@interface RRGItemEquipment : RRGItem <NSCoding>
-(void)equippedByPlayer:(RRGPlayer*)player;
-(void)unequippedByPlayer:(RRGPlayer*)player
    soundAndMessage:(BOOL)soundAndMessage;
-(void)unequippedByPlayer:(RRGPlayer*)player;
@end

@interface RRGSwordOrShield : RRGItemEquipment <NSCoding>
/*
 * save
 */
@property (nonatomic) NSInteger enchantment;
/*
 * save
 */
//profile
@property (nonatomic) NSInteger baseValue;
@property (nonatomic) NSInteger limitToEnchant;

@property (nonatomic, readonly) NSInteger strength;
@end