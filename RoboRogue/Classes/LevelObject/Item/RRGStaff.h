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

@interface Staff_of_Sloth : RRGStaff
@end

@interface Staff_of_Death : RRGStaff
@end

@interface Staff_of_Blowback : RRGStaff
@end

@interface Staff_of_Switching : RRGStaff
@end

@interface Staff_of_Jumping : RRGStaff
@end

@interface Staff_of_Pulling : RRGStaff
@end

@interface Staff_of_Teleportation : RRGStaff
@end

@interface Staff_of_Progress : RRGStaff
@end

@interface Staff_of_Regress : RRGStaff
@end

@interface Staff_of_Tamara : RRGStaff
@end

@interface Staff_of_Lich : RRGStaff
@end
@interface Staff_of_Demilich : RRGStaff
@end
@interface Staff_of_Archlich : RRGStaff
@end