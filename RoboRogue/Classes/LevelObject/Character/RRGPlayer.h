//
//  Player.h
//  RoboRogue
//
//  Created by 山本政徳 on 2014/02/25.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "RRGCharacter.h"

extern NSString* const kChangePlayerHP;
extern NSString* const kChangePlayerMaxHP;
extern NSString* const kChangePlayerLevel;

@class RRGItem, RRGStaff, RRGSword, RRGShield, RRGRing, RRGItemEquipment, RRGItemUseOnce,
RRGLabelLayer;

@interface RRGPlayer : RRGCharacter <NSCoding>

/*
 * for save
 */
@property (nonatomic) NSMutableArray* items;
@property (nonatomic) RRGSword* swordEquipped;
@property (nonatomic) RRGShield* shieldEquipped;
@property (nonatomic) RRGStaff* staffEquipped;
/*
 * for save
 */
@property (nonatomic, readonly, weak) RRGLabelLayer* labelLayer;
@property (nonatomic, readonly) CGRect playerViewRect;
@property (nonatomic, readonly) CGRect playerViewRectForMapping;

@property (nonatomic, weak) RRGCharacter* killer;

-(BOOL)getItem:(RRGItem*)item;
-(void)useItem:(RRGItemUseOnce*)item;
-(void)waveStaff:(RRGStaff*)staff;
-(void)equipItem:(RRGItemEquipment*)item;
-(void)unequipItem:(RRGItemEquipment*)item;
-(void)throwItem:(RRGItem*)item;
-(void)putOnItem:(RRGItem*)item;
-(void)swapItem:(RRGItem*)item;

//clear attributes
-(void)clearAttributesForNewLevel:(RRGLevel*)level;

-(void)sortItems;
@end
