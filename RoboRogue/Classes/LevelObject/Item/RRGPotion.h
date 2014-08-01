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
@interface Potion_of_HealingBase : RRGPotion <NSCoding>
@end
@interface Potion_of_Healing : Potion_of_HealingBase <NSCoding>
@end
@interface Potion_of_Extra_Healing : Potion_of_HealingBase <NSCoding>
@end
@interface Potion_of_Full_Healing : Potion_of_HealingBase <NSCoding>
@end
@interface Holy_Water : RRGPotion <NSCoding>
@end
@interface Potion_of_Poison : RRGPotion <NSCoding>
@end
@interface Potion_of_Confusion : RRGPotion <NSCoding>
@end
@interface Potion_of_Sleeping : RRGPotion <NSCoding>
@end
@interface Potion_of_Paralysis : RRGPotion <NSCoding>
@end
@interface Potion_of_Speed : RRGPotion <NSCoding>
@end
@interface Rotten_Potion : RRGPotion <NSCoding>
@end