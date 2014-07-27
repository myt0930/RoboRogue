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

extern NSString* const kLevelObject;
extern NSString* const kTileCoord;

@class RRGLevel, RRGLevelObject;

@interface RRGLevelMapLayer : CCNode
+(instancetype)layerWithSize:(CGSize)size
                       level:(RRGLevel*)level;
-(void)setTilesInRect:(CGRect)rect;
@end

@interface RRGObjectOnMap : CCNode
@property (nonatomic, weak) RRGLevelMapLayer* mapLayer;
@property (nonatomic, weak) RRGLevelObject* levelObject;
@property (nonatomic, weak, readonly) RRGLevel* level;

@property (nonatomic) CGPoint tileCoord;

+(instancetype)objectWithMapLayer:(RRGLevelMapLayer*)mapLayer
                      levelObject:(RRGLevelObject*)levelObject;
-(instancetype)initWithMapLayer:(RRGLevelMapLayer*)mapLayer
                    levelObject:(RRGLevelObject*)levelObject;

-(void)getPostSetTileCoord:(NSNotification*)notification;
-(void)update;
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