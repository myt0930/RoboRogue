//
//  RRGLevel.h
//  RoboRogue
//
//  Created by 山本政徳 on 2014/03/02.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "cocos2d.h"

//LevelState
typedef NS_ENUM(NSUInteger, LevelState)
{
    LevelStateNormal,
    LevelStateChangeDirection,
    LevelStateShowingItemWindow,
    LevelStateShowingModalLayer,
    LevelStateTurnInProgress,
    LevelStateGameOver
};

NSString* stateString(LevelState state);

//MapLayerState
typedef NS_ENUM(NSUInteger, MapLayerState)
{
    MapLayerStateShowMap,
    MapLayerStateShowOnlyMap,
    MapLayerStateHideMap
};

//ZOrder
typedef NS_ENUM(NSUInteger, ZOrder)
{
    ZOrderTiledMap,
    ZOrderShadowInPath,
    ZOrderLabelLayer,
    ZOrderButtonLayer,
    ZOrderYajirusi,
    ZOrderMessageWindow,
    ZOrderMapLayer,
    ZOrderItemWindowLayer,
    ZOrderModalLayer,
    ZOrderGameOverLayer
};

@class RRGTiledMap, RRGAction, RRGPlayer, RRGRoom, RRGLevelObject, RRGCharacter, RRGItem, RRGTrap, RRGLabelLayer, RRGButtonLayer, RRGMessageWindowLayer, RRGLevelMapLayer, RRGItemWindowLayer, RRGModalLayer, RRGShadowInPathLayer;

@interface RRGLevel : CCNode <NSCoding>
/*
 *save
 */
@property (nonatomic, copy) NSDictionary* profile;
@property (nonatomic) CGSize mapSize;
@property (nonatomic) BOOL random;
@property (nonatomic) BOOL shadow;
@property (nonatomic) BOOL spawnEnemy;

@property (nonatomic, copy) NSString* dungeonName;
@property (nonatomic) NSUInteger floorNum;
@property (nonatomic) BOOL displayFloorNum;
@property (nonatomic) BOOL displayMapLayer;

@property (nonatomic) NSUInteger turnCount;

//object map
@property (nonatomic) NSMutableArray* characterMap;
@property (nonatomic) NSMutableArray* objectMap;

//map model
@property (nonatomic) NSMutableArray* mapIDMap;
@property (nonatomic) NSMutableArray* roomIDMap;
@property (nonatomic) NSMutableArray* roomArray;

//names
@property (nonatomic, copy) NSDictionary* enemyNames;
@property (nonatomic, copy) NSDictionary* itemNames;
@property (nonatomic, copy) NSDictionary* trapNames;

@property (nonatomic) RRGPlayer* player;
/*
 *save
 */

//layers
@property (nonatomic) CCNode* objectLayer;
@property (nonatomic) CCNode* characterLayer;
@property (nonatomic, weak) CCNode* currentShadowLayer;

@property (nonatomic) RRGTiledMap* tiledMap;
@property (nonatomic) RRGShadowInPathLayer* shadowInPathLayer;

@property (nonatomic) RRGLabelLayer* labelLayer;
@property (nonatomic) RRGButtonLayer* buttonLayer;
@property (nonatomic) CCNode* yajirusi;
@property (nonatomic) RRGMessageWindowLayer* messageWindowLayer;
@property (nonatomic) RRGLevelMapLayer* mapLayer;
@property (nonatomic) RRGItemWindowLayer* itemWindowLayer;
@property (nonatomic) RRGModalLayer* modalLayer;

@property (nonatomic) NSMutableArray* seqArray;
@property (nonatomic) NSMutableArray* spawnArray;
@property (nonatomic) NSMutableArray* actionArray;
@property (nonatomic) NSMutableArray* charactersForTurnSequence;

@property (nonatomic) NSMutableArray* messageHistory;

@property (nonatomic) BOOL touching;
@property (nonatomic) UITouch* currentTouch;

@property (nonatomic) LevelState levelState;
@property (nonatomic) MapLayerState mapLayerState;

@property (nonatomic, readonly) CGRect viewRect;
@property (nonatomic, readonly, weak) NSArray* characters;

@property (nonatomic, readonly) BOOL validTimingForShutDown;

+(instancetype)levelWithProfile:(NSDictionary*)profile
                         player:(RRGPlayer*)player;

-(void)updateLevelState:(LevelState)state;
-(void)updateMapLayerState:(MapLayerState)state;

-(void)addMessage:(NSString*)message;
-(BOOL)inView:(CGPoint)tileCoord;
-(void)walkPlayerTowardTouch;
@end