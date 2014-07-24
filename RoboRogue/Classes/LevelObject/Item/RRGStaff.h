//
//  RRGStaff.h
//  RoboRogue
//
//  Created by 山本政徳 on 2014/05/05.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "RRGItem.h"

@interface RRGStaff : RRGItemEquipment <NSCoding>
/*
 * save
 */
@property (nonatomic) NSUInteger numberOfMagicBullets;
/*
 * save
 */

//profile
@property (nonatomic, copy) NSString* magicBulletName;
@property (nonatomic) NSArray* namesOfMagicBullets;
@property (nonatomic, readonly) NSInteger numberToDisplay;

-(instancetype)initWithLevel:(RRGLevel *)level
        numberOfMagicBullets:(NSInteger)numberOfMagicBullets;
-(void)wavedByCharacter:(RRGCharacter*)character;
@end

@interface StaffOfSloth : RRGStaff
@end

@interface StaffOfDeath : RRGStaff
@end

@interface StaffOfBlowback : RRGStaff
@end

@interface StaffOfSwitching : RRGStaff
@end

@interface StaffOfJumping : RRGStaff
@end

@interface StaffOfPulling : RRGStaff
@end

@interface StaffOfProgress : RRGStaff
@end

@interface StaffOfRegress : RRGStaff
@end

@interface StaffOfTamara : RRGStaff
@end

@interface StaffOfLich : RRGStaff
@end
@interface StaffOfDemilich : RRGStaff
@end
@interface StaffOfArchlich : RRGStaff
@end