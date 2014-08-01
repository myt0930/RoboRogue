//
//  RRGShadowInPathLayer.h
//  RoboRogue
//
//  Created by 山本政徳 on 2014/07/24.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "CCTiledMap.h"

@interface RRGShadowInPathLayer : CCTiledMap
@property (nonatomic) BOOL playerHasLamplight;
+(instancetype)layerWithLamplight:(BOOL)lamplight;

-(CGPoint)tileCoordForTilePoint:(CGPoint)tilePoint;
-(CGPoint)tilePointForTileCoord:(CGPoint)tileCoord;
-(CGPoint)centerTilePointForTileCoord:(CGPoint)tileCoord;

-(BOOL)shadowAtWorldPosition:(CGPoint)worldPosition;
@end
