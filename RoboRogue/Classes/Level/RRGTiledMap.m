//
//  RRGTliedMap.m
//  RoboRogue
//
//  Created by 山本政徳 on 2014/02/25.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "RRGTiledMap.h"

//layer name
static NSString* const kGroundLayer = @"groundLayer";
static NSString* const kWallLayer = @"wallLayer";
static NSString* const kLavaLayer = @"lavaLayer";
static NSString* const kWaterLayer = @"waterLayer";
static NSString* const kSkyLayer = @"skyLayer";

@implementation RRGTiledMap
-(instancetype)initWithFile:(NSString *)tmxFile
{
    self = [super initWithFile:tmxFile];
    if (self) {
        //layers
        _groundLayer = [self layerNamed:kGroundLayer];
        _wallLayer = [self layerNamed:kWallLayer];
        _lavaLayer = [self layerNamed:kLavaLayer];
        _waterLayer = [self layerNamed:kWaterLayer];
        _skyLayer = [self layerNamed:kSkyLayer];
        
        _groundLayer.zOrder = ZOrderInTiledMapGroundLayer;
        _wallLayer.zOrder = ZOrderInTiledMapWallLayer;
        _lavaLayer.zOrder = ZOrderInTiledMapLavaLayer;
        _waterLayer.zOrder = ZOrderInTiledMapWaterLayer;
        _skyLayer.zOrder = ZOrderInTiledMapSkyLayer;
        
        //shadow layer
        _shadowLayers = [NSMutableArray arrayWithCapacity:10];
        
        for (NSInteger i = 0; i < 10; i++) {
            CCTiledMapLayer* shadowLayer = [self layerNamed:[NSString stringWithFormat:@"shadowLayer%zd",i]];
            [_shadowLayers addObject:shadowLayer];
            shadowLayer.opacity = .5f;
            shadowLayer.visible = NO;
            shadowLayer.zOrder = ZOrderInTiledMapShadowLayer + i;
        }
        
        //GID
        _wallGID1 = [_wallLayer tileGIDAt:CGPointZero];
        _lavaGID1 = [_lavaLayer tileGIDAt:CGPointZero];
        _waterGID1 = [_waterLayer tileGIDAt:CGPointZero];
        _skyGID1 = [_skyLayer tileGIDAt:CGPointZero];
        _shadowGID1 = [_shadowLayers[0] tileGIDAt:CGPointZero] - 5;
    }
    return self;
}
-(void)dealloc
{
    CCLOG(@"%s", __PRETTY_FUNCTION__);
}
#pragma mark - gameMapSize and gameTileSize
-(CGSize)gameMapSize
{
    return CGSizeMake([super mapSize].width / 2, [super mapSize].height / 2);
}
-(CGSize)gameTileSize
{
    return CGSizeMake([super tileSize].width * 2, [super tileSize].height * 2);
}
#pragma mark - tileCoord and position
-(CGPoint)tileCoordForTilePoint:(CGPoint)tilePoint
{
    return ccp((NSInteger)(tilePoint.x / self.gameTileSize.width),
               (NSInteger)((self.gameMapSize.height * self.gameTileSize.height - tilePoint.y) / self.gameTileSize.height));
}
-(CGPoint)tilePointForTileCoord:(CGPoint)tileCoord
{
    return ccp(tileCoord.x * self.gameTileSize.width,
               (self.gameMapSize.height - tileCoord.y - 1) * self.gameTileSize.height);
}
-(CGPoint)centerTilePointForTileCoord:(CGPoint)tileCoord
{
    return ccpAdd([self tilePointForTileCoord:tileCoord],
                  ccp(self.gameTileSize.width / 2, self.gameTileSize.height / 2));
}
#pragma mark - action move and place
-(CCActionMoveBy*)actionMoveByWithDuration:(CGFloat)duration
                                 direction:(CGPoint)direction
                                     tiles:(CGFloat)tiles
{
    return [CCActionMoveBy
            actionWithDuration:duration
            position:ccp(direction.x * self.gameTileSize.width * tiles,
                         direction.y * self.gameTileSize.height * tiles * -1)];
}
-(CCActionMoveBy*)actionMoveByWithDuration:(CGFloat)duration
                             fromTileCoord:(CGPoint)start
                               toTileCoord:(CGPoint)end
{
    CGPoint position = ccpSub(end, start);
    position = ccp(position.x * self.gameTileSize.width,
                   position.y * self.gameTileSize.height * -1);
    return [CCActionMoveBy actionWithDuration:duration
                                     position:position];
}
-(CCActionMoveBy*)actionMoveByWithVelocity:(CGFloat)velocity
                                 direction:(CGPoint)direction
                                     tiles:(CGFloat)tiles
{
    CGFloat duration = velocity * tiles;
    return [self actionMoveByWithDuration:duration
                                direction:direction
                                    tiles:tiles];
}
-(CCActionMoveBy*)actionMoveByWithVelocity:(CGFloat)velocity
                             fromTileCoord:(CGPoint)start
                               toTileCoord:(CGPoint)end
{
    CGFloat tiles = MAX(ABS(end.x - start.x), ABS(end.y - start.y));
    CGFloat duration = velocity * tiles;
    return [self actionMoveByWithDuration:duration
                            fromTileCoord:start
                              toTileCoord:end];
}
-(CCActionPlace*)actionPlaceToTileCoord:(CGPoint)tileCoord
{
    return [CCActionPlace actionWithPosition:[self centerTilePointForTileCoord:tileCoord]];
}
@end