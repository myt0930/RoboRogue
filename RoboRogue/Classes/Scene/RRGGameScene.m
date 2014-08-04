//
//  RRGGameScene.m
//  RoboRogue
//
//  Created by 山本政徳 on 2014/07/08.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "RRGGameScene.h"
#import "RRGSavedDataHandler.h"
#import "RRGProfileCache.h"
#import "RRGLevel.h"
#import "RRGPlayer.h"
#import "RRGAction.h"
#import "cocos2d-ui.h"
#import "RRGButtonBehavior.h"
#import "RRGFunctions.h"
#import "RRGGameOverOrGoalLayer.h"

static NSString* const kProfileFloorNum = @"floorNum";

static NSString* const kProfileDungeonName = @"dungeonName";
static NSString* const kProfileGoal = @"goal";
static NSString* const kProfileDisplayFloorNum = @"displayFloorNum";
static NSString* const kProfileDisplayMapLayer = @"displayMapLayer";
static NSString* const kProfileInitialItems = @"initialItems";

static NSString* const kInitialDungeonName = @"TestDungeon";

typedef NS_ENUM(NSUInteger, ZOrderInGameScene)
{
    ZOrderInGameSceneLevel = 0,
    ZOrderInGameSceneBlack,
    ZOrderInGameSceneGoalLayer,
};

@implementation RRGGameScene
+(instancetype)sharedInstance
{
    static RRGGameScene* sharedSingleton;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedSingleton = [[RRGGameScene alloc] initSharedInstance];
    });
    return sharedSingleton;
}
-(instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}
-(instancetype)initSharedInstance
{
    self = [super init];

    if (self) {
        _mapLayerQueue = dispatch_queue_create("info.mygames888.roborogue.mapLayer", NULL);
        _MessageWindowQueue = dispatch_queue_create("info.mygames888.roborogue.messageWindow", NULL);
        
        _level = sharedSavedDataHandler.level;
        if (_level == nil) {
            CCLOG(@"start with initial level");
            _dungeonProfile = [sharedProfileCache profileForKey:kInitialDungeonName];
            NSDictionary* levelProfile = [self levelProfileWithFloorNum:1];
            _level = [RRGLevel levelWithProfile:levelProfile player:nil];
        }
        [self addChild:_level z:ZOrderInGameSceneLevel];
        _level.userInteractionEnabled = YES;
    }
    return self;
}
-(void)dealloc
{
    CCLOG(@"%s", __PRETTY_FUNCTION__);
    
    dispatch_release(_mapLayerQueue);
    dispatch_release(_MessageWindowQueue);
}
#pragma mark - dungeon readonly properties
-(NSUInteger)goal
{
    return [_dungeonProfile[kProfileGoal] integerValue];
}
-(NSString*)dungeonName
{
    return _dungeonProfile[kProfileDungeonName];
}
-(BOOL)displayFloorNum
{
    return [_dungeonProfile[kProfileDisplayFloorNum] boolValue];
}
-(BOOL)displayMapLayer
{
    return [_dungeonProfile[kProfileDisplayMapLayer] boolValue];
}
-(NSArray*)initialItems
{
    return _dungeonProfile[kProfileInitialItems];
}

#pragma mark - levelProfile
-(NSDictionary*)levelProfileWithFloorNum:(NSUInteger)floorNum
{
    NSMutableDictionary* levelProfile = nil;
    
    for (NSUInteger i = floorNum; i >= 1; i--) {
        NSString* key = [NSString stringWithFormat:@"floor%tu", i];
        if (_dungeonProfile[key]) {
            levelProfile = [NSMutableDictionary dictionaryWithDictionary:_dungeonProfile[key]];
            break;
        }
    }
    
    NSAssert(levelProfile != nil, @"Can not find levelProfile");
    
    [levelProfile setObject:self.dungeonName forKey:kProfileDungeonName];
    [levelProfile setObject:@(floorNum) forKey:kProfileFloorNum];
    [levelProfile setObject:@(self.displayFloorNum) forKey:kProfileDisplayFloorNum];
    [levelProfile setObject:@(self.displayMapLayer) forKey:kProfileDisplayMapLayer];
    
    if (floorNum == 1 && self.initialItems) {
        [levelProfile setObject:self.initialItems forKey:kProfileInitialItems];
    }
    return levelProfile;
}
-(void)goToDungeon:(NSString*)dungeonName
          floorNum:(NSUInteger)floorNum
            player:(RRGPlayer*)player
   playerDirection:(CGPoint)playerDirection
{
    if (![dungeonName isEqualToString:self.dungeonName]) {
        _dungeonProfile = [sharedProfileCache profileForKey:dungeonName];
    }
    [self goToFloorNum:floorNum
                player:player
       playerDirection:playerDirection];
}
-(void)goToFloorNum:(NSUInteger)floorNum
             player:(RRGPlayer*)player
    playerDirection:(CGPoint)playerDirection
{
    CCLOG(@"\n\
          ******************************\n\
          dungeonName = %@\n\
          floorNum = %tu\n\
          ******************************",
          self.dungeonName,
          floorNum);
    
    _level.userInteractionEnabled = NO;
    
    NSMutableArray* seqArray = [NSMutableArray array];
    
    if (_black == nil) {
        [seqArray addObject:[self fadeIn]];
    }
        
    if (floorNum >= self.goal) {
        [seqArray addObject:[CCActionCallFunc actionWithTarget:self
                                                      selector:@selector(goToGoal)]];
    } else {
        [seqArray addObject:[CCActionCallBlock actionWithBlock:^{
            [self showNextLevelWithFloorNum:floorNum
                                     player:player
                            playerDirection:playerDirection];
        }]];
    }
    
    [self runAction:[CCActionSequence actionWithArray:seqArray]];
}
-(void)goToGoal
{
    RRGGoalLayer* goalLayer = [RRGGoalLayer layerWithLevel:_level];
    [self addChild:goalLayer z:ZOrderInGameSceneGoalLayer];
}
-(void)showNextLevelWithFloorNum:(NSUInteger)floorNum
                          player:(RRGPlayer*)player
                 playerDirection:(CGPoint)playerDirection;
{
    NSDictionary* levelProfile = [self levelProfileWithFloorNum:floorNum];
    
    player.direction = playerDirection;
    [_level removeFromParent];
    CCLOG(@"level removeFromParent");
    
    _level = [RRGLevel levelWithProfile:levelProfile player:player];
    [self addChild:_level z:ZOrderInGameSceneLevel];
    
    _level.userInteractionEnabled = YES;
    
    [self runAction:[self fadeOut]];
}
-(void)goToInitialDungeon
{
    [self goToDungeon:kInitialDungeonName
             floorNum:1
               player:nil
      playerDirection:South];
}
#pragma mark - save level
-(void)saveLevel
{
    if (_level.levelState == LevelStateTurnInProgress) {
        sharedSavedDataHandler.invalidShutDown = YES;
    } else {
        sharedSavedDataHandler.invalidShutDown = NO;
        sharedSavedDataHandler.level = _level;
    }
}
#pragma mark - fade in and out
-(RRGAction*)fadeIn
{
    CCLOG(@"%s", __PRETTY_FUNCTION__);
    _black = [CCNodeColor nodeWithColor:[CCColor colorWithRed:0
                                                        green:0
                                                         blue:0
                                                        alpha:0]];
    [self addChild:_black z:ZOrderInGameSceneBlack];
    
    return [RRGAction actionWithTarget:_black
                                action:[CCActionFadeIn actionWithDuration:1.0f]];
}
-(RRGAction*)fadeOut
{
    CCLOG(@"%s", __PRETTY_FUNCTION__);
    CCNodeColor* black = _black;
    _black = nil;
    CCActionSequence* seq = [CCActionSequence actions:
                             [CCActionFadeOut actionWithDuration:1.0f],
                             [CCActionRemove action],
                             nil];
    return [RRGAction actionWithTarget:black action:seq];
}
@end