//
//  BlowbackTrap.h
//  RoboRogue
//
//  Created by 山本政徳 on 2014/03/30.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "RRGTrap.h"

@interface BlowbackTrap : RRGTrap <NSCoding>
//attribute
@property (nonatomic) CGPoint direction;
-(instancetype)initWithDirection:(CGPoint)direction;
@end
