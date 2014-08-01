//
//  RRGWarpPoint.h
//  RoboRogue
//
//  Created by 山本政徳 on 2014/03/15.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "RRGTrap.h"

@interface RRGWarpPoint : RRGNonCharacterObject <NSCoding>
@property (nonatomic, copy) NSString* dungeonName;
@property (nonatomic) NSUInteger floorNum;
-(void)warpAction;
@end

@interface Down_Stairs : RRGWarpPoint <NSCoding>
@end
