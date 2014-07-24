//
//  RRGPotion.h
//  RoboRogue
//
//  Created by 山本政徳 on 2014/03/24.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "RRGItem.h"

@interface RRGPotion : RRGItemUseOnce <NSCoding>
@end
@interface PotionOfHealingBase : RRGPotion <NSCoding>
@end
@interface PotionOfHealing : PotionOfHealingBase <NSCoding>
@end
@interface PotionOfExtraHealing : PotionOfHealingBase <NSCoding>
@end
@interface PotionOfFullHealing : PotionOfHealingBase <NSCoding>
@end
@interface HolyWater : RRGPotion <NSCoding>
@end
@interface PotionOfPoison : RRGPotion <NSCoding>
@end
@interface PotionOfConfusion : RRGPotion <NSCoding>
@end
@interface PotionOfSleeping : RRGPotion <NSCoding>
@end
@interface PotionOfParalysis : RRGPotion <NSCoding>
@end
@interface PotionOfSpeed : RRGPotion <NSCoding>
@end
@interface RottenPotion : RRGPotion <NSCoding>
@end