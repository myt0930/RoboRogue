//
//  RRGLevel.m
//  RoboRogue
//
//  Created by 山本政徳 on 2014/03/02.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "RRGLevel.h"
#import "RRGLevel+CreateTileLayers.h"
#import "RRGLevel+AddObject.h"
#import "RRGLevel+MapID.h"
#import "RRGLevel+TurnSequence.h"

#import "RRGCategories.h"
#import "RRGTiledMap.h"
#import "RRGPlayer.h"
#import "RRGLabelLayer.h"
#import "RRGButtonLayer.h"
#import "RRGMessageWindowLayer.h"
#import "RRGLevelMapLayer.h"
#import "RRGItemWindowLayer.h"
#import "RRGMap.h"
#import "RRGEnemy.h"
#import "RRGItem.h"
#import "RRGTrap.h"
#import "RRGFunctions.h"
#import "RRGModalLayer.h"
#import "RRGWarpPoint.h"
#import "RRGGameOverLayer.h"

static NSString* const kProfileTMXFileName = @"tmxFileName";
static NSString* const kProfileMapWidth = @"mapWidth";
static NSString* const kProfileMapHeight = @"mapHeight";
static NSString* const kProfileRandom = @"random";
static NSString* const kProfileShadow = @"shadow";
static NSString* const kProfileSpawnEnemy = @"spawnEnemy";

static NSString* const kProfileEnemyCount = @"enemyCount";
static NSString* const kProfileItemCount = @"itemCount";
static NSString* const kProfileTrapCount = @"trapCount";

static NSString* const kProfileEnemyNames = @"enemyNames";
static NSString* const kProfileItemNames = @"itemNames";
static NSString* const kProfileTrapNames = @"trapNames";

static NSString* const kProfileDungeonName = @"dungeonName";
static NSString* const kProfileFloorNum = @"floorNum";
static NSString* const kProfileDisplayFloorNum = @"displayFloorNum";
static NSString* const kProfileDisplayMapLayer = @"displayMapLayer";
static NSString* const kProfileInitialItems = @"initialItems";

static NSUInteger const MessageCapacity = 30;

@interface RRGLevel ()
-(NSMutableArray*)p_blankMapWithSize:(CGSize)size;
-(void)p_addTiledMap;
-(void)p_addLayers;
-(void)p_setUpLevelAtRandom;
-(void)p_setUpLevelNotRandom;
-(void)p_addYajirusi;
@end

@implementation RRGLevel
#pragma mark - NSCoding
-(instancetype)initWithCoder:(NSCoder *)coder
{
    self = [self init];
    if (self) {
        decodeObject(_profile);
        decodeCGSize(_mapSize);
        decodeBool(_random);
        decodeBool(_shadow);
        decodeBool(_spawnEnemy);
        
        decodeObject(_dungeonName);
        decodeInteger(_floorNum);
        decodeBool(_displayFloorNum);
        
        decodeInteger(_turnCount);
        
        decodeObject(_objectMap);
        decodeObject(_characterMap);
        
        decodeObject(_mapIDMap);
        decodeObject(_roomIDMap);
        decodeObject(_roomArray);
        
        decodeObject(_enemyNames);
        decodeObject(_itemNames);
        decodeObject(_trapNames);
        
        decodeObject(_player);
        
        [self p_addTiledMap];
        
        if (_random) {
            [self createTileLayers];
            if (_shadow) {
                [self createShadowLayers];
            }
        } else {
            //todo
        }
        
        // add objects
        NSUInteger mapWidth = _mapSize.width;
        NSUInteger mapHeight = _mapSize.height;
        for (NSUInteger x = 0; x < mapWidth; x++) {
            for (NSUInteger y = 0; y < mapHeight; y++) {
                RRGLevelObject* object = [self objectAtTileCoord:ccp(x,y)];
                if (object) {
                    [self addObject:object atTileCoord:ccp(x,y)];
                }
                RRGCharacter* character = [self characterAtTileCoord:ccp(x,y)];
                if (character) {
                    [self addCharacter:character atTileCoord:ccp(x,y)];
                }
            }
        }
        
        CCActionFollow* follow = [CCActionFollow actionWithTarget:_player];
        [_tiledMap runAction:follow];
        
        [self p_addLayers];
        
        [self updateLevelState:LevelStateNormal];
        [self updateMapLayerState:MapLayerStateShowMap];
    }
    return self;
}
-(void)encodeWithCoder:(NSCoder *)coder
{
    encodeObject(_profile);
    encodeCGSize(_mapSize);
    encodeBool(_random);
    encodeBool(_shadow);
    encodeBool(_spawnEnemy);
    
    encodeObject(_dungeonName);
    encodeInteger(_floorNum);
    encodeBool(_displayFloorNum);
    
    encodeInteger(_turnCount);
    
    encodeObject(_objectMap);
    encodeObject(_characterMap);
    
    encodeObject(_mapIDMap);
    encodeObject(_roomIDMap);
    encodeObject(_roomArray);
    
    encodeObject(_enemyNames);
    encodeObject(_itemNames);
    encodeObject(_trapNames);
    
    encodeObject(_player);
}
#pragma mark - constructer
+(instancetype)levelWithProfile:(NSDictionary*)profile
                         player:(RRGPlayer*)player
{
    return [[self alloc] initWithProfile:profile
                                  player:player];
}
#pragma mark - initializer
-(instancetype)init
{
    self = [super init];
    if (self) {
        CGSize viewSize = [[CCDirector sharedDirector] viewSize];
        _contentSize = viewSize;
        
        _seqArray = [NSMutableArray array];
        _spawnArray = [NSMutableArray array];
        _actionArray = [NSMutableArray array];
        _charactersForTurnSequence = [NSMutableArray array];
        
        _messageHistory = [NSMutableArray arrayWithCapacity:MessageCapacity];
    }
    return self;
}
-(instancetype)initWithProfile:(NSDictionary*)profile
                        player:(RRGPlayer*)player
{
    self = [self init];
    if (self) {
        self.profile = profile;
        
        NSUInteger mapWidth = [profile[kProfileMapWidth] integerValue];
        NSUInteger mapHeight = [profile[kProfileMapHeight] integerValue];
        _mapSize = CGSizeMake(mapWidth, mapHeight);
        
        _random = [profile[kProfileRandom] boolValue];
        _shadow = [profile[kProfileShadow] boolValue];
        _spawnEnemy = [profile[kProfileSpawnEnemy] boolValue];
        
        _dungeonName = [profile[kProfileDungeonName] copy];
        _floorNum = [profile[kProfileFloorNum] integerValue];
        _displayFloorNum = [profile[kProfileDisplayFloorNum] boolValue];
        
        _turnCount = 0;
        
        _objectMap = [self p_blankMapWithSize:_mapSize];
        _characterMap = [self p_blankMapWithSize:_mapSize];
        
        self.enemyNames = profile[kProfileEnemyNames];
        self.itemNames = profile[kProfileItemNames];
        self.trapNames = profile[kProfileTrapNames];
        
        _player = player;
        [_player clearAttributesForNewLevel:self];
        
        [self p_addTiledMap];
        
        if (_random) {
            [self p_setUpLevelAtRandom];
        } else {
            [self p_setUpLevelNotRandom];
        }
        
        //initial items
        if (profile[kProfileInitialItems]) {
            NSArray* initialItems = profile[kProfileInitialItems];
            for (NSString* name in initialItems) {
                RRGItem* item = [RRGItem levelObjectWithLevel:self
                                                         name:name
                                                     atRandom:NO];
                if ([self.player getItem:item] == NO) break;
            }
        }
        
        CCActionFollow* follow = [CCActionFollow actionWithTarget:_player];
        [_tiledMap runAction:follow];
        
        [self p_addLayers];
        
        [self updateLevelState:LevelStateNormal];
        [self updateMapLayerState:MapLayerStateShowMap];
    }
    return self;
}
-(void)dealloc
{
    CCLOG(@"%s", __PRETTY_FUNCTION__);
}
#pragma mark - update
-(void)update:(CCTime)delta
{
    if (_shadow && self.player) {
        CGPoint playerTileCoordForPos = [self.tiledMap tileCoordForTilePoint:self.player.position];
        NSInteger roomNum = ([self inRoomAtTileCoord:playerTileCoordForPos])?
        [self roomNumAtTileCoord:playerTileCoordForPos]:-1;
        
        CCNode* nextShadowLayer = (roomNum >= 0)?
        self.tiledMap.shadowLayers[roomNum]:_shadowInPath;
        
        if (nextShadowLayer != _currentShadowLayer) {
            _currentShadowLayer.visible = NO;
            _currentShadowLayer = nextShadowLayer;
            _currentShadowLayer.visible = YES;
        }
    }
}
#pragma mark - private methods
-(NSMutableArray*)p_blankMapWithSize:(CGSize)size
{
    NSUInteger mapWidth = size.width;
    NSUInteger mapHeight = size.height;
    
    NSMutableArray* map = [NSMutableArray arrayWithCapacity:mapWidth];
    
    for (NSUInteger x = 0; x < mapWidth; x++) {
        NSMutableArray* array = [NSMutableArray arrayWithCapacity:mapHeight];
        for (NSUInteger y = 0; y < mapHeight; y++) {
            [array addObject:[NSNull null]];
        }
        [map addObject:array];
    }
    
    return map;
}
-(void)p_addTiledMap
{
    _tiledMap = [RRGTiledMap tiledMapWithFile:_profile[kProfileTMXFileName]];
    [self addChild:_tiledMap z:ZOrderTiledMap];
    
    _objectLayer = [CCNode node];
    [_tiledMap addChild:_objectLayer z:ZOrderInTiledMapObjectLayer];
    
    _characterLayer = [CCNode node];
    [_tiledMap addChild:_characterLayer z:ZOrderInTiledMapCharacterLayer];
    
    if (_shadow) {
        _shadowInPath = [CCTiledMap tiledMapWithFile:@"shadowInPath.tmx"];
        _shadowInPath.anchorPoint = ccp(.5, .5f);
        CGSize viewSize = [[CCDirector sharedDirector] viewSize];
        _shadowInPath.position = ccp(viewSize.width * .5f, viewSize.height * .5f);
        [_shadowInPath layerNamed:@"shadowLayer"].opacity = .5f;
        _shadowInPath.visible = NO;
        [self addChild:_shadowInPath z:ZOrderShadowInPath];
    }
}
-(void)p_addLayers
{
    //labelLayer
    _labelLayer = [RRGLabelLayer layerWithSize:_contentSize
                                         level:self
                                      floorNum:_floorNum
                               displayFloorNum:_displayFloorNum];
    [self addChild:_labelLayer z:ZOrderLabelLayer];
    
    //buttonLayer
    BOOL displayMapLayer = [_profile[kProfileDisplayMapLayer] boolValue];
    _buttonLayer = [RRGButtonLayer layerWithSize:_contentSize
                                           level:self
                                 displayMapLayer:displayMapLayer];
    [self addChild:_buttonLayer z:ZOrderButtonLayer];
    
    //message window
    CGRect messageWindowRect = CGRectMake(50,
                                          0,
                                          _contentSize.width - 50 - 100,
                                          _contentSize.height / 4);
    _messageWindowLayer = [RRGMessageWindowLayer layerWithWindowRect:messageWindowRect];
    [self addChild:_messageWindowLayer z:ZOrderMessageWindow];
    
    //mapLayer
    if (displayMapLayer) {
        _mapLayer = [RRGLevelMapLayer layerWithMapSize:_mapSize
                                                 level:self];
        [self addChild:_mapLayer z:ZOrderMapLayer];
    }
    
    //modalLayer
    _modalLayer = [RRGModalLayer layerWithViewSize:_contentSize
                                             level:self];
    [self addChild:_modalLayer z:ZOrderModalLayer];
    
    //[self p_addDebugLabels];
}
-(void)p_setUpLevelAtRandom
{
    //create map at random
    RRGMap* map = [RRGMap mapWithProfile:_profile];
    _mapIDMap = map.mapIDMap;
    _roomIDMap = map.roomIDMap;
    _roomArray = map.roomArray;
    
    [self createTileLayers];
    if (_shadow) [self createShadowLayers];
    
    //add objects
    NSInteger shopRoomNum = -1;
    NSInteger monstersNestRoomNum = -1;
    
    //add player
    CGPoint playerTileCoord = [self
                               randomTileCoordForCharacterExceptRoomNums:@[@(shopRoomNum)]
                               offScreen:NO];
    CCLOG(@"playerTileCoord = %@", NSStringFromCGPoint(playerTileCoord));
    
    if (_player == nil) {
        _player = [RRGPlayer levelObjectWithLevel:self
                                             name:@"RRGPlayer"
                                         atRandom:NO];
    }
    [self addCharacter:_player atTileCoord:playerTileCoord];
    
    NSInteger playerRoomNum = _player.roomNum;
    
    //add stair
    CGPoint stairTileCoord = [self randomTileCoordForObjectExceptRoomNums:@[@(shopRoomNum),@(playerRoomNum)]
                                                                offScreen:NO];
    if (CGPointEqualToPoint(stairTileCoord, CGPointZero)) {
        stairTileCoord = [self randomTileCoordForObjectExceptRoomNums:nil
                                                            offScreen:NO];
    }
    DownStairs* downStairs = [DownStairs levelObjectWithLevel:self
                                                         name:@"DownStairs"
                                                     atRandom:NO];
    downStairs.dungeonName = _profile[@"dungeonName"];
    downStairs.floorNum = _floorNum + 1;//go to next floor
    [self addObject:downStairs atTileCoord:stairTileCoord];
    
    //add enemies
    NSInteger enemyCount = [_profile[kProfileEnemyCount] integerValue];
    for (NSInteger i = 0; i < enemyCount; i++) {
        CGPoint tileCoord = [self
                             randomTileCoordForCharacterExceptRoomNums:@[@(monstersNestRoomNum),
                                                                         @(shopRoomNum)]
                             offScreen:NO];
        RRGEnemy* enemy = [self randomEnemyAtRandom:YES];
        [self addCharacter:enemy atTileCoord:tileCoord];
    }
    
    //add items
    NSInteger itemCount = [_profile[kProfileItemCount] integerValue];
    for (NSInteger i = 0; i < itemCount; i++) {
        CGPoint tileCoord = [self
                             randomTileCoordForObjectExceptRoomNums:@[@(monstersNestRoomNum),
                                                                      @(shopRoomNum)]
                             offScreen:NO];
        RRGItem* item = [self randomItemAtRandom:YES];
        [self addObject:item atTileCoord:tileCoord];
    }
    
    //add traps
    NSInteger trapCount = [_profile[kProfileTrapCount] integerValue];
    for (NSInteger i = 0; i < trapCount; i++) {
        CGPoint tileCoord = [self
                             randomTileCoordForObjectExceptRoomNums:@[@(monstersNestRoomNum),
                                                                      @(shopRoomNum)]
                             offScreen:NO];
        RRGTrap* trap = [self randomTrapAtRandom:YES];
        [self addObject:trap atTileCoord:tileCoord];
    }
}
-(void)p_setUpLevelNotRandom
{
    CCLOG(@"%s", __PRETTY_FUNCTION__);
    //self.mapIDMap =
    //self.roomIDMap =
    //self.roomArray =
    
    //add characters
    CCTiledMapObjectGroup* characterLayerGroup = [_tiledMap objectGroupNamed:@"characterLayer"];
    for (NSDictionary* property in [characterLayerGroup objects]) {
        NSString* name = property[@"name"];
        NSInteger x = [property[@"x"] integerValue];
        NSInteger y = [property[@"y"] integerValue];
        BOOL random = [property[@"random"] boolValue];
        CGPoint tileCoord = [_tiledMap tileCoordForTilePoint:ccp(x,y)];
        if ([name isEqualToString:@"RRGPlayer"]) {
            if (_player == nil) {
                _player = [RRGPlayer levelObjectWithLevel:self
                                                     name:name
                                                 atRandom:NO];
            }
            [self addCharacter:_player atTileCoord:tileCoord];
        } else {
            RRGCharacter* character = [RRGCharacter levelObjectWithLevel:self
                                                                    name:name
                                                                atRandom:random];
            [self addCharacter:character atTileCoord:tileCoord];
        }
    }
    //add objects
    CCTiledMapObjectGroup* objectLayerGroup = [_tiledMap objectGroupNamed:@"objectLayer"];
    for (NSDictionary* property in [objectLayerGroup objects]) {
        NSString* name = property[@"name"];
        NSInteger x = [property[@"x"] integerValue];
        NSInteger y = [property[@"y"] integerValue];
        BOOL random = [property[@"random"] boolValue];
        CGPoint tileCoord = [_tiledMap tileCoordForTilePoint:ccp(x,y)];
        RRGLevelObject* object = [RRGLevelObject levelObjectWithLevel:self
                                                                 name:name
                                                             atRandom:random];
        [self addObject:object atTileCoord:tileCoord];
    }
}
-(void)p_addDebugLabels
{
    CCNode* debugLayer = [CCNode node];
    
    NSUInteger mapWidth = _mapSize.width;
    NSUInteger mapHeight = _mapSize.height;
    for (NSUInteger x = 0; x < mapWidth; x++) {
        for (NSUInteger y = 0; y < mapHeight; y++) {
            MapID mapID = [self mapIDAtTileCoord:ccp(x,y)];
            if (mapID == MapIDGround) {
                mapID = [self roomMapIDAtTileCoord:ccp(x,y)];
            }
            NSString* str = [NSString stringWithFormat:@"%zd\n(%zd,%zd)",
                             mapID,x,y];
            CCLabelBMFont* label = [CCLabelBMFont labelWithString:str
                                                          fntFile:@"debug.fnt"];
            label.anchorPoint = CGPointZero;
            label.position = [_tiledMap tilePointForTileCoord:ccp(x,y)];
            [debugLayer addChild:label];
        }
    }
    [_tiledMap addChild:debugLayer z:ZOrderInTiledMapDebugLabelLayer];
}
-(void)p_addYajirusi
{
    CCLOG(@"%s", __PRETTY_FUNCTION__);
    
    _yajirusi = [CCNode node];
    _yajirusi.contentSize = _contentSize;
    
    for (NSUInteger i = 0; i < 8; i++) {
        CCSprite* sprite = [CCSprite spriteWithImageNamed:@"yajirusi.png"];
        sprite.anchorPoint = ccp(.5f,-1.0f);
        sprite.positionType = CCPositionTypeNormalized;
        sprite.position = ccp(.5f,.5f);
        sprite.rotation = 45 * i;
        sprite.opacity = .7f;
        [_yajirusi addChild:sprite];
        
        CCActionSequence* seq = [CCActionSequence actions:
                                 [CCActionTween
                                  actionWithDuration:.5f
                                  key:@"opacity"
                                  from:.7f
                                  to:.3f],
                                 [CCActionTween
                                  actionWithDuration:.5f
                                  key:@"opacity"
                                  from:.3f
                                  to:.7f],
                                 nil];
        CCActionRepeatForever* repeat = [CCActionRepeatForever actionWithAction:seq];
        [sprite runAction:repeat];
    }
    [self addChild:self.yajirusi z:ZOrderYajirusi];
}
#pragma mark - state
NSString* stateString(LevelState state)
{
    switch (state) {
        case LevelStateNormal:
            return @"LevelStateNormal";
        case LevelStateChangeDirection:
            return @"LevelStateChangeDirection";
        case LevelStateShowingItemWindow:
            return @"LevelStateShowingItemWindow";
        case LevelStateShowingModalLayer:
            return @"LevelStateShowingModalLayer";
        case LevelStateTurnInProgress:
            return @"LevelStateTurnInProgress";
        case LevelStateGameOver:
            return @"LevelStateGameOver";
    }
}
-(void)updateLevelState:(LevelState)state
{
    CCLOG(@"%s", __PRETTY_FUNCTION__);
    CCLOG(@"levelState = %@", stateString(state));
    
    _levelState = state;
    
    //label layer
    [_labelLayer updateLevelState:state];
    
    //button layer
    [_buttonLayer updateLevelState:state];
    
    //item window layer
    [_itemWindowLayer removeFromParentAndCleanup:YES];
    if (state == LevelStateShowingItemWindow) {
        _itemWindowLayer = [RRGItemWindowLayer
                            layerWithSize:CGSizeMake(_contentSize.width,
                                                     _contentSize.height - 50)
                            level:self];
        [self addChild:_itemWindowLayer z:ZOrderItemWindowLayer];
    }
    
    //yajirusi
    [self.yajirusi removeFromParentAndCleanup:YES];
    if (state == LevelStateChangeDirection) {
        [self p_addYajirusi];
    }
    
    //message window
    if (state == LevelStateShowingItemWindow ||
        state == LevelStateShowingModalLayer ||
        state == LevelStateGameOver) {
        [self.messageWindowLayer hide];
    }
    
    //map layer
    if (state == LevelStateGameOver) {
        self.mapLayer.visible = NO;
    }
    
    //game over layer
    if (state == LevelStateGameOver) {
        CCLOG(@"game over");
        self.userInteractionEnabled = NO;
        RRGGameOverLayer* gameOver = [RRGGameOverLayer layerWithViewSize:_contentSize
                                                                   level:self];
        [self addChild:gameOver z:ZOrderGameOverLayer];
        CCLOG(@"added game over");
        [gameOver scrollWindow];
        CCLOG(@"scroll window");
    }
}
-(void)updateMapLayerState:(MapLayerState)state
{
    CCLOG(@"%s", __PRETTY_FUNCTION__);
    
    _mapLayerState = state;
    
    [self updateLevelState:LevelStateNormal];
    
    [_buttonLayer updateMapLayerState:state];
}
-(void)addMessage:(NSString *)message
{
    [_messageHistory addObject:message];
    while ([_messageHistory count] > MessageCapacity) {
        [_messageHistory removeObjectAtIndex:0];
    }
    
    __weak RRGLevel* weakSelf = self;
    [self addAction:[CCActionCallBlock actionWithBlock:^{
        [weakSelf.messageWindowLayer addMessage:message];
    }]];
}
-(CGRect)viewRect
{
    return CGRectMake(MAX(self.player.tileCoord.x - 6, 0),
                      MAX(self.player.tileCoord.y - 5, 0),
                      13,
                      11);
}
-(NSArray*)characters
{
    return _characterLayer.children;
}
-(BOOL)inView:(CGPoint)tileCoord
{
    return CGRectContainsPoint([self viewRect], tileCoord);
}
-(BOOL)validTimingForShutDown
{
    switch (_levelState) {
        case LevelStateNormal:
        case LevelStateChangeDirection:
        case LevelStateShowingItemWindow:
            return YES;
            break;
        case LevelStateShowingModalLayer:
        case LevelStateTurnInProgress:
        case LevelStateGameOver:
            return NO;
            break;
    }
}
#pragma mark - Touch Handler
-(CGPoint)playerDirectionTowardTouch
{
    CGPoint tilePoint = [_currentTouch locationInNode:_tiledMap];
    CGPoint tileCoord = [_tiledMap tileCoordForTilePoint:tilePoint];
    CGPoint v = ccpSub(tileCoord, _player.tileCoord);
    return unitVector(v);
}
-(void)walkPlayerTowardTouch
{
    CGPoint direction = [self playerDirectionTowardTouch];
    
    if ([_player haveState:kStateConfusion]) {
        direction = [_player randomDirectionToWalk];
        if (CGPointEqualToPoint(direction, CGPointZero)) {
            direction = randomDirection();
        }
    }
    
    if (!CGPointEqualToPoint(direction, CGPointZero)) {
        //CCLOG(@"%@", directionString(direction));
        if ([_player canWalkToDirection:direction]) {
            [self updateLevelState:LevelStateTurnInProgress];
            [self.player walkToDirection:direction];
            [self turnStartPhase];
        } else {
            // if cannot walk
            [self updateLevelState:LevelStateNormal];
            [self.player changeDirection:direction];
        }
    } else {
        CCLOG(@"direction is CGPointZero");
    }
}
-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    //CCLOG(@"%s", __PRETTY_FUNCTION__);
    if (self.mapLayerState == MapLayerStateShowOnlyMap) return;
    
    self.touching = YES;
    self.currentTouch = touch;
    
    switch (self.levelState) {
        case LevelStateNormal:
        {
            [self walkPlayerTowardTouch];
            break;
        }
        case LevelStateChangeDirection:
        {
            CGPoint direction = [self playerDirectionTowardTouch];
            
            if (!CGPointEqualToPoint(direction, CGPointZero)) {
                CCLOG(@"%@", directionString(direction));
                [self.player changeDirection:direction];
            }
            break;
        }
        case LevelStateGameOver:
        case LevelStateShowingItemWindow:
        case LevelStateShowingModalLayer:
        case LevelStateTurnInProgress:
        {
            break;
        }
    }
}
-(void)touchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    self.currentTouch = touch;
}
-(void)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    self.touching = NO;
}
-(void)touchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
    self.touching = NO;
}
@end