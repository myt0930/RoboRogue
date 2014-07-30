//
//  RRGLevelMapLayer.h
//  RoboRogue
//
//  Created by 山本政徳 on 2014/05/18.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "CCNode.h"

extern NSString* const kAddObject;
extern NSString* const kSetTileCoord;
extern NSString* const kRemove;
extern NSString* const kFound;

extern NSString* const kLevelObject;
extern NSString* const kTileCoord;

@class RRGLevel, RRGLevelObject;

@interface RRGLevelMapLayer : CCNode <NSCoding>
+(instancetype)layerWithSize:(CGSize)size
                       level:(RRGLevel*)level;
@end

@interface RRGObjectOnMap : CCNode
@property (nonatomic) CGPoint tileCoord;

+(instancetype)objectWithMapLayer:(RRGLevelMapLayer*)mapLayer
                      levelObject:(RRGLevelObject*)levelObject;
@end

@interface RRGPlayerOnMap : RRGObjectOnMap
@end

@interface RRGEnemyOnMap : RRGObjectOnMap
@end

@interface RRGItemOnMap : RRGObjectOnMap
@end

@interface RRGTrapOnMap : RRGObjectOnMap
@end

@interface DownStairsOnMap : RRGObjectOnMap
@end