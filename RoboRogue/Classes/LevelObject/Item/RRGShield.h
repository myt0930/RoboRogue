//
//  RRGShield.h
//  RoboRogue
//
//  Created by 山本政徳 on 2014/04/16.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "RRGItem.h"

@interface RRGShield : RRGSwordOrShield <NSCoding>
-(void)didBeDealtDamage:(NSInteger)damage
            byCharacter:(RRGCharacter*)character;
@end
@interface WoodenShield : RRGShield
@end
@interface ShieldOfGlass : RRGShield
@end
@interface ShieldOfIron : RRGShield <NSCoding>
@end
