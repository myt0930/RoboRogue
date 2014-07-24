//
//  RRGLevel+CreateTileLayers.m
//  RoboRogue
//
//  Created by 山本政徳 on 2014/03/06.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "RRGLevel+CreateTileLayers.h"
#import "RRGLevel+MapID.h"

#import "RRGTiledMap.h"
#import "RRGFunctions.h"
#import "RRGRoom.h"
#import "RRGCategories.h"

@implementation RRGLevel (CreateTileLayers)

-(void)createTileLayers
{
#if DEBUG
    NSDate *start = [NSDate date];
#endif
    [self.tiledMap.wallLayer removeTileAt:CGPointZero];
    [self.tiledMap.lavaLayer removeTileAt:CGPointZero];
    [self.tiledMap.waterLayer removeTileAt:CGPointZero];
    [self.tiledMap.skyLayer removeTileAt:CGPointZero];
    
    NSInteger mapWidth = self.mapSize.width;
    NSInteger mapHeight = self.mapSize.height;
    
    for (NSInteger x = 0; x < mapWidth; x++) {
        for (NSInteger y = 0; y < mapHeight; y++) {
            MapID mapID = [self mapIDAtTileCoord:ccp(x,y)];
            if (mapID != MapIDGround) {
                [self setTile:mapID at:ccp(x,y)];
            }
        }
    }
    
#if DEBUG
    NSDate *end = [NSDate date];
    float diffSeconds = [end timeIntervalSinceDate:start];
    CCLOG(@"diffSeconds = %f", diffSeconds);
#endif
}
-(void)setTile:(MapID)mapID
            at:(CGPoint)tileCoord
{
    NSUInteger tileGID1;
    CCTiledMapLayer* tileLayer;
    
    switch (mapID) {
        case MapIDWall:
        case MapIDWallFragile:
        case MapIDWallUnbreakable:
            tileGID1 = self.tiledMap.wallGID1;
            tileLayer = self.tiledMap.wallLayer;
            break;
        case MapIDLava:
            tileGID1 = self.tiledMap.lavaGID1;
            tileLayer = self.tiledMap.lavaLayer;
            break;
        case MapIDWater:
            tileGID1 = self.tiledMap.waterGID1;
            tileLayer = self.tiledMap.waterLayer;
            break;
        case MapIDSky:
            tileGID1 = self.tiledMap.skyGID1;
            tileLayer = self.tiledMap.skyLayer;
            break;
        default:
            CCLOG(@"Invalid tileType : %zd", mapID);
            return;
    }
    
    [self setTile:mapID
         tileGID1:tileGID1
        tileLayer:tileLayer
               at:tileCoord];
}
BOOL sameTypeMapID(MapID mapID1, MapID mapID2)
{
    if (mapID1 == mapID2) {
        return YES;
    } else if (mapID1 <= MapIDWall && mapID2 <= MapIDWall) {
        return YES;
    }
    return NO;
}
-(void)setTile:(MapID)mapID
      tileGID1:(NSUInteger)tileGID1
     tileLayer:(CCTiledMapLayer*)tileLayer
            at:(CGPoint)tileCoord
{
    //CCLOG("%s", __PRETTY_FUNCTION__);
    
    NSUInteger (^tileGID)(NSUInteger) = ^(NSUInteger i){
        return tileGID1 + i - 1;
    };
    
    NSInteger mapWidth = self.mapSize.width;
    NSInteger mapHeight = self.mapSize.height;
    
    BOOL (^tileExistAt)(CGPoint) = ^(CGPoint tileCoord){
        if (tileCoord.x < 0
            || tileCoord.y < 0
            || mapWidth <= tileCoord.x
            || mapHeight <= tileCoord.y) {
            return YES;
        }
        return sameTypeMapID([self mapIDAtTileCoord:tileCoord], mapID);
    };
    
    void (^setTileSub)(NSUInteger, CGPoint) = ^(NSUInteger GID, CGPoint p){
        NSAssert(1 <= GID && GID <= 24, @"Invalid GID %lu", (unsigned long)GID);
        //[tileLayer appendTileForGID:(u_int32_t)tileGID(GID) at:p];
        [tileLayer setTileGID:(u_int32_t)tileGID(GID) at:p];
    };
    
    //upper left
    CGPoint upperLeft = ccpMult(tileCoord, 2);
    if (tileExistAt(northWest(tileCoord))
        && tileExistAt(north(tileCoord))
        && tileExistAt(west(tileCoord))) {
        setTileSub(19, upperLeft);
    } else if (!tileExistAt(northWest(tileCoord))
               && tileExistAt(north(tileCoord))
               && tileExistAt(west(tileCoord))) {
        setTileSub(3, upperLeft);
    } else if (!tileExistAt(north(tileCoord))
               && !tileExistAt(west(tileCoord))) {
        if (!tileExistAt(south(tileCoord))
            && !tileExistAt(east(tileCoord))) {
            setTileSub(1, upperLeft);
        } else {
            setTileSub(9, upperLeft);
        }
    } else if (!tileExistAt(north(tileCoord))
               && tileExistAt(west(tileCoord))) {
        setTileSub(11, upperLeft);
    } else if (tileExistAt(north(tileCoord))
               && !tileExistAt(west(tileCoord))) {
        setTileSub(17, upperLeft);
    }
    //upper right
    CGPoint upperRight = ccpAdd(upperLeft, ccp(1,0));
    if (tileExistAt(northEast(tileCoord))
        && tileExistAt(north(tileCoord))
        && tileExistAt(east(tileCoord))) {
        setTileSub(18, upperRight);
    } else if (!tileExistAt(northEast(tileCoord))
               && tileExistAt(north(tileCoord))
               && tileExistAt(east(tileCoord))) {
        setTileSub(4, upperRight);
    } else if (!tileExistAt(north(tileCoord))
               && !tileExistAt(east(tileCoord))) {
        if (!tileExistAt(south(tileCoord))
            && !tileExistAt(west(tileCoord))) {
            setTileSub(2, upperRight);
        } else {
            setTileSub(12, upperRight);
        }
    } else if (!tileExistAt(north(tileCoord))
               && tileExistAt(east(tileCoord))) {
        setTileSub(10, upperRight);
    } else if (tileExistAt(north(tileCoord))
               && !tileExistAt(east(tileCoord))) {
        setTileSub(20, upperRight);
    }
    //lower left
    CGPoint lowerLeft = ccpAdd(upperLeft, ccp(0,1));
    if (tileExistAt(southWest(tileCoord))
        && tileExistAt(south(tileCoord))
        && tileExistAt(west(tileCoord))) {
        setTileSub(15, lowerLeft);
    } else if (!tileExistAt(southWest(tileCoord))
               && tileExistAt(south(tileCoord))
               && tileExistAt(west(tileCoord))) {
        setTileSub(7, lowerLeft);
    } else if (!tileExistAt(south(tileCoord))
               && !tileExistAt(west(tileCoord))) {
        if (!tileExistAt(north(tileCoord))
            && !tileExistAt(east(tileCoord))) {
            setTileSub(5, lowerLeft);
        } else {
            setTileSub(21, lowerLeft);
        }
    } else if (!tileExistAt(south(tileCoord))
               && tileExistAt(west(tileCoord))) {
        setTileSub(23, lowerLeft);
    } else if (tileExistAt(south(tileCoord))
               && !tileExistAt(west(tileCoord))) {
        setTileSub(13, lowerLeft);
    }
    //lower right
    CGPoint lowerRight = ccpAdd(upperLeft, ccp(1,1));
    if (tileExistAt(southEast(tileCoord))
        && tileExistAt(south(tileCoord))
        && tileExistAt(east(tileCoord))) {
        setTileSub(14, lowerRight);
    } else if (!tileExistAt(southEast(tileCoord))
               && tileExistAt(south(tileCoord))
               && tileExistAt(east(tileCoord))) {
        setTileSub(8, lowerRight);
    } else if (!tileExistAt(south(tileCoord))
               && !tileExistAt(east(tileCoord))) {
        if (!tileExistAt(north(tileCoord))
            && !tileExistAt(west(tileCoord))) {
            setTileSub(6, lowerRight);
        } else {
            setTileSub(24, lowerRight);
        }
    } else if (!tileExistAt(south(tileCoord))
               && tileExistAt(east(tileCoord))) {
        setTileSub(22, lowerRight);
    } else if (tileExistAt(south(tileCoord))
               && !tileExistAt(east(tileCoord))) {
        setTileSub(16, lowerRight);
    }
}

-(void)createShadowLayers
{
    NSInteger roomCount = [self.roomArray count];
    for (NSInteger i = 0; i < roomCount; i++) {
        CCTiledMapLayer* shadowLayer = self.tiledMap.shadowLayers[i];
        shadowLayer.visible = NO;
        RRGRoom* room = self.roomArray[i];
        CGRect rect = room.roomRect;
        rect = CGRectMake(rect.origin.x - 1,
                          rect.origin.y - 1,
                          rect.size.width + 2,
                          rect.size.height + 2);
        CGRectForEach(rect)
        {
            [self removeShadowTileAt:ccp(x,y) shadowLayer:shadowLayer];
        }
        
        [self setShadowTilesAtUpperLeft:ccp(LX,LY)
                            shadowLayer:shadowLayer
                               tileGID1:self.tiledMap.shadowGID1];
        [self setShadowTilesAtUpperRight:ccp(HX,LY)
                             shadowLayer:shadowLayer
                                tileGID1:self.tiledMap.shadowGID1];
        [self setShadowTilesAtLowerLeft:ccp(LX,HY)
                            shadowLayer:shadowLayer
                               tileGID1:self.tiledMap.shadowGID1];
        [self setShadowTilesAtLowerRight:ccp(HX,HY)
                             shadowLayer:shadowLayer
                                tileGID1:self.tiledMap.shadowGID1];
    }
}
-(void)removeShadowTileAt:(CGPoint)tileCoord
              shadowLayer:(CCTiledMapLayer*)shadowLayer
{
    CGPoint upperLeft = ccpMult(tileCoord, 2);
    CGPoint upperRight = ccpAdd(upperLeft, ccp(1,0));
    CGPoint lowerLeft = ccpAdd(upperLeft, ccp(0,1));
    CGPoint lowerRight = ccpAdd(upperLeft, ccp(1,1));
    [shadowLayer removeTileAt:upperLeft];
    [shadowLayer removeTileAt:upperRight];
    [shadowLayer removeTileAt:lowerLeft];
    [shadowLayer removeTileAt:lowerRight];
}
-(void)setShadowTilesAtUpperLeft:(CGPoint)tileCoord
                     shadowLayer:(CCTiledMapLayer*)shadowLayer
                        tileGID1:(NSUInteger)tileGID1
{
    NSUInteger (^tileGID)(NSUInteger) = ^(NSUInteger i){
        return tileGID1 + i - 1;
    };
    CGPoint upperLeft = ccpMult(tileCoord, 2);
    CGPoint upperRight = ccpAdd(upperLeft, ccp(1,0));
    CGPoint lowerLeft = ccpAdd(upperLeft, ccp(0,1));
    //CGPoint lowerRight = ccpAdd(upperLeft, ccp(1,1));
    
    [shadowLayer setTileGID:(u_int32_t)tileGID(1) at:upperLeft];
    [shadowLayer setTileGID:(u_int32_t)tileGID(2) at:upperRight];
    [shadowLayer setTileGID:(u_int32_t)tileGID(5) at:lowerLeft];
}
-(void)setShadowTilesAtUpperRight:(CGPoint)tileCoord
                      shadowLayer:(CCTiledMapLayer*)shadowLayer
                         tileGID1:(NSUInteger)tileGID1
{
    NSUInteger (^tileGID)(NSUInteger) = ^(NSUInteger i){
        return tileGID1 + i - 1;
    };
    CGPoint upperLeft = ccpMult(tileCoord, 2);
    CGPoint upperRight = ccpAdd(upperLeft, ccp(1,0));
    //CGPoint lowerLeft = ccpAdd(upperLeft, ccp(0,1));
    CGPoint lowerRight = ccpAdd(upperLeft, ccp(1,1));
    
    [shadowLayer setTileGID:(u_int32_t)tileGID(3) at:upperLeft];
    [shadowLayer setTileGID:(u_int32_t)tileGID(4) at:upperRight];
    [shadowLayer setTileGID:(u_int32_t)tileGID(8) at:lowerRight];
}
-(void)setShadowTilesAtLowerLeft:(CGPoint)tileCoord
                     shadowLayer:(CCTiledMapLayer*)shadowLayer
                        tileGID1:(NSUInteger)tileGID1
{
    NSUInteger (^tileGID)(NSUInteger) = ^(NSUInteger i){
        return tileGID1 + i - 1;
    };
    CGPoint upperLeft = ccpMult(tileCoord, 2);
    //CGPoint upperRight = ccpAdd(upperLeft, ccp(1,0));
    CGPoint lowerLeft = ccpAdd(upperLeft, ccp(0,1));
    CGPoint lowerRight = ccpAdd(upperLeft, ccp(1,1));
    
    [shadowLayer setTileGID:(u_int32_t)tileGID(9) at:upperLeft];
    [shadowLayer setTileGID:(u_int32_t)tileGID(13) at:lowerLeft];
    [shadowLayer setTileGID:(u_int32_t)tileGID(14) at:lowerRight];
}
-(void)setShadowTilesAtLowerRight:(CGPoint)tileCoord
                      shadowLayer:(CCTiledMapLayer*)shadowLayer
                         tileGID1:(NSUInteger)tileGID1
{
    NSUInteger (^tileGID)(NSUInteger) = ^(NSUInteger i){
        return tileGID1 + i - 1;
    };
    CGPoint upperLeft = ccpMult(tileCoord, 2);
    CGPoint upperRight = ccpAdd(upperLeft, ccp(1,0));
    CGPoint lowerLeft = ccpAdd(upperLeft, ccp(0,1));
    CGPoint lowerRight = ccpAdd(upperLeft, ccp(1,1));
    
    [shadowLayer setTileGID:(u_int32_t)tileGID(12) at:upperRight];
    [shadowLayer setTileGID:(u_int32_t)tileGID(15) at:lowerLeft];
    [shadowLayer setTileGID:(u_int32_t)tileGID(16) at:lowerRight];
}
@end