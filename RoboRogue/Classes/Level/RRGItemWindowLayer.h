//
//  RRGItemWindowLayer.h
//  RoboRogue
//
//  Created by 山本政徳 on 2014/04/03.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "cocos2d.h"

@class RRGLevel;

@interface RRGItemWindowLayer : CCNode

+(instancetype)layerWithSize:(CGSize)size
                       level:(RRGLevel*)level;
@end
