//
//  RRGLabelLayer.h
//  RoboRogue
//
//  Created by 山本政徳 on 2014/06/15.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "CCNode.h"

@class RRGLevel;

@interface RRGLabelLayer : CCNode
+(instancetype)layerWithSize:(CGSize)size
                       level:(RRGLevel*)level
                    floorNum:(NSUInteger)floorNum
             displayFloorNum:(BOOL)displayFloorNum;

-(void)updateLevelState:(NSUInteger)state;
//-(void)updateMapLayerState:(NSUInteger)state;

-(void)setPlayerHPString:(NSUInteger)HP;
-(void)setPlayerMaxHPString:(NSUInteger)maxHP;
-(void)setPlayerLevelString:(NSUInteger)level;
@end