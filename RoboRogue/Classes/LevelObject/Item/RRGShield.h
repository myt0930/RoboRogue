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
@interface Wooden_Shield : RRGShield
@end
@interface Shield_of_Glass : RRGShield
@end
@interface Shield_of_Iron : RRGShield <NSCoding>
@end
