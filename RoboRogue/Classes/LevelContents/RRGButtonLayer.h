//
//  RRGButtonLayer.h
//  RoboRogue
//
//  Created by 山本政徳 on 2014/05/06.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "CCNode.h"

@class RRGLevel;

@interface RRGButtonLayer : CCNode

+(instancetype)layerWithSize:(CGSize)size
                       level:(RRGLevel*)level
             displayMapLayer:(BOOL)displayMapLayer;
-(void)updateLevelState:(NSUInteger)state;
-(void)updateMapLayerState:(NSUInteger)state;

-(void)updateSubWeaponButtons;
-(void)setStaffButtonNumber:(NSInteger)numberToDisplay;
@end
