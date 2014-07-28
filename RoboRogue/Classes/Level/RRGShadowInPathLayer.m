//
//  RRGShadowInPathLayer.m
//  RoboRogue
//
//  Created by 山本政徳 on 2014/07/24.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "RRGShadowInPathLayer.h"
#import "CCTiledMapLayer.h"

static NSString* const kFileName = @"shadowInPath.tmx";
static NSString* const kShadowLayer = @"shadowLayer";

@interface RRGShadowInPathLayer ()
@property (nonatomic) CCTiledMapLayer* shadowLayer;
@property (nonatomic) NSUInteger shadowGID;
@end

@implementation RRGShadowInPathLayer
+(instancetype)layer
{
    return [[self alloc] init];
}
-(instancetype)init
{
    self = [super initWithFile:kFileName];
    if (self) {
        _shadowLayer = [self layerNamed:kShadowLayer];
        _shadowLayer.opacity = .5f;
        _visible = NO;
        _shadowGID = [_shadowLayer tileGIDAt:CGPointZero];
    }
    return self;
}
#pragma mark - tileCoord and position
-(CGPoint)tileCoordForTilePoint:(CGPoint)tilePoint
{
    return ccp((NSInteger)(tilePoint.x / _tileSize.width),
               (NSInteger)((_mapSize.height * _tileSize.height - tilePoint.y) / _tileSize.height));
}
-(CGPoint)tilePointForTileCoord:(CGPoint)tileCoord
{
    return ccp(tileCoord.x * _tileSize.width,
               (_mapSize.height - tileCoord.y - 1) * _tileSize.height);
}
-(CGPoint)centerTilePointForTileCoord:(CGPoint)tileCoord
{
    return ccpAdd([self tilePointForTileCoord:tileCoord],
                  ccp(_tileSize.width / 2, _tileSize.height / 2));
}
-(BOOL)shadowAtWorldPosition:(CGPoint)worldPosition
{
    CGPoint tilePoint = [self convertToNodeSpace:worldPosition];
    CGPoint tileCoord = [self tileCoordForTilePoint:tilePoint];
    tileCoord = ccp(MAX(0, MIN(_mapSize.width - 1, tileCoord.x)),
                    MAX(0, MIN(_mapSize.height - 1, tileCoord.y)));
    return ([_shadowLayer tileGIDAt:tileCoord] == _shadowGID)?YES:NO;
}
@end