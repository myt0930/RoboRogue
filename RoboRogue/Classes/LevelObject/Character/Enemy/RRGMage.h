//
//  RRGMage.h
//  RoboRogue
//
//  Created by 山本政徳 on 2014/06/06.
//  Copyright 2014年 山本政徳. All rights reserved.
//

#import "RRGEnemy.h"

@class RRGStaff;

@interface RRGMage : RRGEnemy <NSCoding>
@end

//Lich
@interface Lich : RRGMage <NSCoding>
@end
@interface Demilich : Lich <NSCoding>
@end
@interface Archlich : Lich <NSCoding>
@end