//
//  Warp.h
//  RoboRogue
//
//  Created by 山本政徳 on 2014/03/24.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "RRGTrap.h"

@interface TeleportationTrap : RRGTrap <NSCoding>
@end

@interface TeleportationTrapUnbreakable : TeleportationTrap <NSCoding>
@end