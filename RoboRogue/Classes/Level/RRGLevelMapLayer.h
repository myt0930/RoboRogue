//
//  RRGLevelMapLayer.h
//  RoboRogue
//
//  Created by 山本政徳 on 2014/05/18.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "cocos2d.h"

@class RRGLevel;

@interface RRGLevelMapLayer : CCNode
+(instancetype)layerWithMapSize:(CGSize)mapSize
                          level:(RRGLevel*)level;
@end