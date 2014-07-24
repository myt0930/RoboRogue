//
//  RRGTliedMap.h
//  RoboRogue
//
//  Created by 山本政徳 on 2014/02/25.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "cocos2d.h"

//ZOrder
typedef NS_ENUM(NSUInteger, ZOrderInTiledMap)
{
    ZOrderInTiledMapGroundLayer,
    ZOrderInTiledMapWallLayer,
    ZOrderInTiledMapLavaLayer,
    ZOrderInTiledMapWaterLayer,
    ZOrderInTiledMapSkyLayer,
    ZOrderInTiledMapDebugLabelLayer,
    ZOrderInTiledMapObjectLayer,
    ZOrderInTiledMapParticleUnderCharacter,
    ZOrderInTiledMapCharacterLayer,
    ZOrderInTiledMapParticleOverCharacter,
    ZOrderInTiledMapShadowLayer,
};

@class RRGCharacter, RRGLevelObject, RRGLevel, RRGPlayer;

@interface RRGTiledMap : CCTiledMap

@property (nonatomic, readonly) CGSize gameMapSize;
@property (nonatomic, readonly) CGSize gameTileSize;

//layer
@property (nonatomic) CCTiledMapLayer* groundLayer;
@property (nonatomic) CCTiledMapLayer* wallLayer;
@property (nonatomic) CCTiledMapLayer* lavaLayer;
@property (nonatomic) CCTiledMapLayer* waterLayer;
@property (nonatomic) CCTiledMapLayer* skyLayer;
@property (nonatomic) NSMutableArray* shadowLayers;

//GID
@property (nonatomic) NSUInteger wallGID1;
@property (nonatomic) NSUInteger lavaGID1;
@property (nonatomic) NSUInteger waterGID1;
@property (nonatomic) NSUInteger skyGID1;
@property (nonatomic) NSUInteger shadowGID1;

//tileCoord and position
-(CGPoint)tileCoordForTilePoint:(CGPoint)tilePoint;
-(CGPoint)tilePointForTileCoord:(CGPoint)tileCoord;
-(CGPoint)centerTilePointForTileCoord:(CGPoint)tileCoord;

//action move and place
-(CCActionMoveBy*)actionMoveByWithDuration:(CGFloat)duration
                                 direction:(CGPoint)direction
                                     tiles:(CGFloat)tiles;
-(CCActionMoveBy*)actionMoveByWithDuration:(CGFloat)duration
                             fromTileCoord:(CGPoint)start
                               toTileCoord:(CGPoint)end;
-(CCActionMoveBy*)actionMoveByWithVelocity:(CGFloat)velocity
                                 direction:(CGPoint)direction
                                     tiles:(CGFloat)tiles;
-(CCActionMoveBy*)actionMoveByWithVelocity:(CGFloat)velocity
                             fromTileCoord:(CGPoint)start
                               toTileCoord:(CGPoint)end;
-(CCActionPlace*)actionPlaceToTileCoord:(CGPoint)tileCoord;
@end
