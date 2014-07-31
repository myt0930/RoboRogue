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
static NSString* const kShadowLayer1 = @"shadowLayer1";
static NSString* const kShadowLayer2 = @"shadowLayer2";

@interface RRGShadowInPathLayer ()
@property (nonatomic) CCTiledMapLayer* shadowLayer1;
@property (nonatomic) CCTiledMapLayer* shadowLayer2;
@property (nonatomic, readonly) CCTiledMapLayer* currentShadowLayer;
@property (nonatomic) NSUInteger shadowGID;
@end

@implementation RRGShadowInPathLayer
+(instancetype)layerWithLamplight:(BOOL)lamplight
{
    return [[self alloc] initWithLamplight:lamplight];
}
-(instancetype)initWithLamplight:(BOOL)lamplight
{
    self = [super initWithFile:kFileName];
    if (self) {
        _shadowLayer1 = [self layerNamed:kShadowLayer1];
        _shadowLayer1.opacity = .5f;
        _shadowLayer1.visible = NO;
        
        _shadowLayer2 = [self layerNamed:kShadowLayer2];
        _shadowLayer2.opacity = .5f;
        _shadowLayer2.visible = NO;
        
        self.playerHasLamplight = lamplight;
        
        _visible = NO;
        _shadowGID = [_shadowLayer1 tileGIDAt:CGPointZero];
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
    return ([self.currentShadowLayer tileGIDAt:tileCoord] == _shadowGID)?YES:NO;
}
-(void)setPlayerHasLamplight:(BOOL)playerHasLamplight
{
    _playerHasLamplight = playerHasLamplight;
    
    if (_playerHasLamplight) {
        _shadowLayer2.visible = YES;
        _shadowLayer1.visible = NO;
    } else {
        _shadowLayer1.visible = YES;
        _shadowLayer2.visible = NO;
    }
}
-(CCTiledMapLayer*)currentShadowLayer
{
    if (_playerHasLamplight) {
        return _shadowLayer2;
    } else {
        return _shadowLayer1;
    }
}
@end