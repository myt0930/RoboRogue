//
//  RRGAmulet.h
//  RoboRogue
//
//  Created by 山本政徳 on 2014/05/06.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "RRGItem.h"

@interface RRGAmulet : RRGItemEquipment <NSCoding>
@end

@interface AmuletOfLamplight : RRGAmulet <NSCoding>
@end

@interface AmuletOfMagicTunnel : RRGAmulet <NSCoding>
@end