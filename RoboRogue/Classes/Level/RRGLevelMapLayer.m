//
//  RRGLevelMapLayer.m
//  RoboRogue
//
//  Created by 山本政徳 on 2014/05/18.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "RRGLevelMapLayer.h"
#import "CCTiledMapLayer.h"
#import "RRGCategories.h"
#import "RRGPlayer.h"
#import "RRGEnemy.h"
#import "RRGItem.h"
#import "RRGTrap.h"
#import "RRGWarpPoint.h"

#import "RRGLevel.h"
#import "RRGLevel+MapID.h"

static NSString* const kTMXFileName = @"mapLayer.tmx";
static NSString* const kTileLayer = @"tileLayer";
static const NSUInteger tileSize = 8;

//notification key
NSString* const kAddObject = @"addObject";
NSString* const kSetTileCoord = @"setTileCoord";
NSString* const kRemove = @"remove";

NSString* const kLevelObject = @"levelObject";
NSString* const kTileCoord = @"tileCoord";

@interface RRGLevelMapLayer ()
@property (nonatomic, weak) RRGLevel* level;

@property (nonatomic) CCTiledMap* tiledMap;
@property (nonatomic) CCTiledMapLayer* tileLayer;
@property (nonatomic) CCNode* objectLayer;
@property (nonatomic) CCNode* characterLayer;

@property (nonatomic) NSUInteger tileGID1;

-(CGPoint)tilePointForTileCoord:(CGPoint)tileCoord;
-(BOOL)tileExistAtTileCoord:(CGPoint)tileCoord;;
@end

@implementation RRGLevelMapLayer
+(instancetype)layerWithSize:(CGSize)size
                       level:(RRGLevel *)level
{
    return [[self alloc] initWithSize:size
                                level:level];
}
-(instancetype)initWithSize:(CGSize)size
                      level:(RRGLevel *)level
{
    self = [super init];
    if (self) {
        _contentSize = size;
        self.level = level;
        
        _tiledMap = [CCTiledMap tiledMapWithFile:kTMXFileName];
        _tiledMap.position = ccp(0, _contentSize.height - 30 - _tiledMap.contentSize.height);
        [self addChild:_tiledMap];
        
        _tileLayer = [_tiledMap layerNamed:kTileLayer];
        _tileGID1 = [_tileLayer tileGIDAt:CGPointZero];
        
        [_tileLayer removeTileAt:CGPointZero];
        _tileLayer.opacity = .3f;
        
        _objectLayer = [CCNode node];
        [_tiledMap addChild:_objectLayer];
        _characterLayer = [CCNode node];
        [_tiledMap addChild:_characterLayer];
        
        NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self
               selector:@selector(getPostAddObject:)
                   name:@"addObject"
                 object:self.level];
    }
    return self;
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(CGPoint)tilePointForTileCoord:(CGPoint)tileCoord
{
    return ccp(tileCoord.x * tileSize,
               (_tiledMap.mapSize.height - tileCoord.y - 1) * tileSize);
}
-(void)setTilesInRect:(CGRect)rect
{
    CGRectForEach(rect)
    {
        if ([self.level groundAtTileCoord:ccp(x,y)]) {
            if ([self.level inRoomAtTileCoord:ccp(x,y)]) {
                //room
                [_tileLayer setTileGID:(u_int32_t)_tileGID1 at:ccp(x,y)];
            } else {
                //path
                [_tileLayer setTileGID:(u_int32_t)(_tileGID1 + 1) at:ccp(x,y)];
            }
        }
    }
}
-(BOOL)tileExistAtTileCoord:(CGPoint)tileCoord
{
    return ([_tileLayer tileGIDAt:tileCoord] != 0)?YES:NO;
}
-(void)getPostAddObject:(NSNotification*)notification
{
    CCLOG(@"%s", __PRETTY_FUNCTION__);
    
    RRGLevelObject* levelObject = notification.userInfo[kLevelObject];
    CGPoint tileCoord = [notification.userInfo[kTileCoord] CGPointValue];
    
    RRGObjectOnMap* mapObject;
    mapObject = [RRGObjectOnMap objectWithMapLayer:self
                                     levelObject:levelObject];
    mapObject.tileCoord = tileCoord;
    if ([levelObject isKindOfClass:[RRGCharacter class]]) {
        [_characterLayer addChild:mapObject];
    } else {
        [_objectLayer addChild:mapObject];
    }
}
@end

#pragma mark map object
@implementation RRGObjectOnMap
+(instancetype)objectWithMapLayer:(RRGLevelMapLayer*)mapLayer
                      levelObject:(RRGLevelObject*)levelObject
{
    Class c;
    if ([levelObject isKindOfClass:[RRGPlayer class]]) {
        c = [RRGPlayerOnMap class];
    } else if ([levelObject isKindOfClass:[RRGEnemy class]]) {
        c = [RRGEnemyOnMap class];
    } else if ([levelObject isKindOfClass:[RRGItem class]]) {
        c = [RRGItemOnMap class];
    } else if ([levelObject isKindOfClass:[DownStairs class]]) {
        c = [DownStairsOnMap class];
    } else if ([levelObject isKindOfClass:[RRGTrap class]]) {
        c = [RRGTrap class];
    }
    
    NSAssert(c != nil, @"Invalid levelObject : %@", levelObject);
    
    return [[c alloc] initWithMapLayer:mapLayer
                           levelObject:levelObject];
}
-(instancetype)initWithMapLayer:(RRGLevelMapLayer*)mapLayer
                    levelObject:(RRGLevelObject*)levelObject
{
    self = [super init];
    if (self) {
        _visible = NO;
        
        self.mapLayer = mapLayer;
        self.levelObject = levelObject;
        
        NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self
               selector:@selector(getPostSetTileCoord:)
                   name:kSetTileCoord
                 object:levelObject];
        [nc addObserver:self
               selector:@selector(getPostRemove:)
                   name:kRemove
                 object:levelObject];
    }
    return self;
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(RRGLevel*)level
{
    return self.mapLayer.level;
}
-(void)setTileCoord:(CGPoint)tileCoord
{
    _tileCoord = tileCoord;
    self.position = [_mapLayer tilePointForTileCoord:tileCoord];
    
    [self update];
}
-(void)getPostSetTileCoord:(NSNotification*)notification
{
    CCLOG(@"%s", __PRETTY_FUNCTION__);
    self.tileCoord = [notification.userInfo[kTileCoord] CGPointValue];
}
-(void)getPostRemove:(NSNotification*)notification
{
    [self removeFromParentAndCleanup:YES];
}
-(void)update
{}
@end

@implementation RRGPlayerOnMap
-(instancetype)initWithMapLayer:(RRGLevelMapLayer *)mapLayer
                    levelObject:(RRGLevelObject *)levelObject
{
    self = [super initWithMapLayer:mapLayer
                       levelObject:levelObject];
    if (self) {
        CCDrawNode* drawNode = [CCDrawNode node];
        [drawNode drawDot:ccp(tileSize * .5f, tileSize * .5f)
                   radius:tileSize * .5f
                    color:[CCColor whiteColor]];
        [self addChild:drawNode];
        
        _visible = YES;
    }
    return self;
}
-(void)update
{
    RRGPlayer* player = (RRGPlayer*)self.levelObject;
    CGRect rect = (self.level.shadow)?
    player.viewRect:self.level.viewRect;
    
    [self.mapLayer setTilesInRect:rect];
    
    [self.mapLayer.characterLayer.children
     enumerateObjectsWithOptions:NSEnumerationConcurrent
     usingBlock:^(RRGObjectOnMap* obj, NSUInteger idx, BOOL* stop){
         if (obj != self) {
             [obj update];
         }
     }];
    [self.mapLayer.objectLayer.children
     enumerateObjectsWithOptions:NSEnumerationConcurrent
     usingBlock:^(RRGObjectOnMap* obj, NSUInteger idx, BOOL* stop){
         [obj update];
     }];
}
@end

@implementation RRGEnemyOnMap
-(instancetype)initWithMapLayer:(RRGLevelMapLayer *)mapLayer
                    levelObject:(RRGLevelObject *)levelObject
{
    self = [super initWithMapLayer:mapLayer
                       levelObject:levelObject];
    if (self) {
        CCDrawNode* drawNode = [CCDrawNode node];
        [drawNode drawDot:ccp(tileSize * .5f, tileSize * .5f)
                   radius:tileSize * .5f
                    color:[CCColor redColor]];
        [self addChild:drawNode];
    }
    return self;
}
-(void)update
{
    _visible = self.levelObject.inPlayerViewForMapping;
}
@end

@implementation RRGItemOnMap
-(instancetype)initWithMapLayer:(RRGLevelMapLayer *)mapLayer
                    levelObject:(RRGLevelObject *)levelObject
{
    self = [super initWithMapLayer:mapLayer
                       levelObject:levelObject];
    if (self) {
        CCDrawNode* drawNode = [CCDrawNode node];
        [drawNode drawDot:ccp(tileSize * .5f, tileSize * .5f)
                   radius:tileSize * .5f
                    color:[CCColor cyanColor]];
        [self addChild:drawNode];
    }
    return self;
}
-(void)update
{
    _visible = [self.mapLayer tileExistAtTileCoord:self.tileCoord];
}
@end

@implementation RRGTrapOnMap
-(instancetype)initWithMapLayer:(RRGLevelMapLayer *)mapLayer
                    levelObject:(RRGLevelObject *)levelObject
{
    self = [super initWithMapLayer:mapLayer
                       levelObject:levelObject];
    if (self) {
        CCDrawNode* node1 = [CCDrawNode node];
        [node1 drawSegmentFrom:ccp(0,0)
                            to:ccp(tileSize - 1, tileSize - 1)
                        radius:.5f
                         color:[CCColor whiteColor]];
        [self addChild:node1];
        
        CCDrawNode* node2 = [CCDrawNode node];
        [node2 drawSegmentFrom:ccp(tileSize - 1, 0)
                            to:ccp(0, tileSize - 1)
                        radius:.5f
                         color:[CCColor whiteColor]];
        [self addChild:node2];
    }
    return self;
}
-(void)update
{
    RRGTrap* trap = (RRGTrap*)self.levelObject;
    _visible = [self.mapLayer tileExistAtTileCoord:self.tileCoord] && trap.found;
}
@end

@implementation DownStairsOnMap
-(instancetype)initWithMapLayer:(RRGLevelMapLayer *)mapLayer
                    levelObject:(RRGLevelObject *)levelObject
{
    self = [super initWithMapLayer:mapLayer
                       levelObject:levelObject];
    if (self) {
        CGPoint verts[] =
        {ccp(0,0),
            ccp(tileSize - 1,0),
            ccp(tileSize-1,tileSize-1),
            ccp(0,tileSize-1)};
        CCDrawNode* drawNode = [CCDrawNode node];
        [drawNode drawPolyWithVerts:verts
                              count:4
                          fillColor:nil
                        borderWidth:.5f
                        borderColor:[CCColor whiteColor]];
        [self addChild:drawNode];
    }
    return self;
}
-(void)update
{
    _visible = [self.mapLayer tileExistAtTileCoord:self.tileCoord];
}
@end