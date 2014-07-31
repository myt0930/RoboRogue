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

//#import "RRGProfileCache.h"
//#import "RRGActionCache.h"

static NSString* const kProfileDungeonName = @"dungeonName";
static NSString* const kProfileFloorNum = @"floorNum";

static NSString* const kProfileDisplayFloorNum = @"displayFloorNum";
static NSString* const kProfileDisplayMapLayer = @"displayMapLayer";
static NSString* const kProfileInitialItems = @"initialItems";

static NSString* const kInitialDungeonName = @"Dungeon1";

typedef NS_ENUM(NSUInteger, ZOrderInGameScene)
{
    ZOrderInGameSceneLevel = 0,
    ZOrderInGameSceneBlack,
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
-(instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}
-(instancetype)initSharedInstance
{
    self = [super init];

    if (self) {
        self.level = sharedSavedDataHandler.level;
        if (self.level == nil) {
            CCLOG(@"start with initial level");
            NSDictionary* levelProfile = [self levelProfileWithDungeonName:kInitialDungeonName floorNum:1];
            self.level = [RRGLevel levelWithProfile:levelProfile player:nil];
        }
        [self addChild:self.level z:ZOrderInGameSceneLevel];
        self.level.userInteractionEnabled = YES;
    }
    return self;
}
-(NSDictionary*)levelProfileWithDungeonName:(NSString*)dungeonName
                                   floorNum:(NSUInteger)floorNum
{
    NSDictionary* dungeonProfile = [sharedProfileCache profileForKey:dungeonName];
    
    NSMutableDictionary* levelProfile = nil;
    
    for (NSUInteger i = floorNum; i >= 1; i--) {
        NSString* key = [NSString stringWithFormat:@"floor%tu", i];
        if (dungeonProfile[key]) {
            levelProfile = [NSMutableDictionary dictionaryWithDictionary:dungeonProfile[key]];
            break;
        }
    }
    
    NSAssert(levelProfile != nil, @"Can not find levelProfile");
    
    [levelProfile setObject:dungeonName forKey:kProfileDungeonName];
    [levelProfile setObject:@(floorNum) forKey:kProfileFloorNum];
    BOOL displayFloorNum = [dungeonProfile[kProfileDisplayFloorNum] boolValue];
    [levelProfile setObject:@(displayFloorNum) forKey:kProfileDisplayFloorNum];
    BOOL displayMapLayer = [dungeonProfile[kProfileDisplayMapLayer] boolValue];
    [levelProfile setObject:@(displayMapLayer) forKey:kProfileDisplayMapLayer];
    
    if (floorNum == 1 && dungeonProfile[kProfileInitialItems]) {
        [levelProfile setObject:dungeonProfile[kProfileInitialItems]
                         forKey:kProfileInitialItems];
    }
    
    return levelProfile;
}
-(void)saveLevel
{
    if (self.level.levelState == LevelStateTurnInProgress) {
        sharedSavedDataHandler.invalidShutDown = YES;
    } else {
        sharedSavedDataHandler.invalidShutDown = NO;
        sharedSavedDataHandler.level = self.level;
    }
}
-(void)goToDungeon:(NSString*)dungeonName
          floorNum:(NSUInteger)floorNum
            player:(RRGPlayer*)player
   playerDirection:(CGPoint)playerDirection
{
    CCLOG(@"******************************\n\
          dungeonName = %@\n\
          floorNum = %tu\n\
          ******************************",
          dungeonName,
          floorNum);
    
    self.level.userInteractionEnabled = NO;
    player.direction = playerDirection;
    NSDictionary* levelProfile = [self levelProfileWithDungeonName:dungeonName
                                                          floorNum:floorNum];
    
    CCNodeColor* black = [CCNodeColor nodeWithColor:[CCColor colorWithRed:0
                                                                    green:0
                                                                     blue:0
                                                                    alpha:0]];
    [self addChild:black z:ZOrderInGameSceneBlack];
    
    CCActionFadeIn* fadeIn = [CCActionFadeIn actionWithDuration:1.0f];
    
    __weak RRGGameScene* weakSelf = self;
    CCActionCallBlock* block = [CCActionCallBlock actionWithBlock:^{
        [weakSelf.level removeFromParentAndCleanup:YES];
        CCLOG(@"will create new level");
        RRGLevel* newLevel = [RRGLevel levelWithProfile:levelProfile player:player];
        CCLOG(@"did create new level");
        [weakSelf addChild:newLevel z:ZOrderInGameSceneLevel];
        newLevel.userInteractionEnabled = YES;
        weakSelf.level = newLevel;
    }];
    CCActionFadeOut* fadeOut = [CCActionFadeOut actionWithDuration:1.0f];
    CCActionRemove* remove = [CCActionRemove action];
    
    CCActionSequence* seq = [CCActionSequence actions:
                             fadeIn,
                             block,
                             fadeOut,
                             remove,
                             nil];
    CCLOG(@"before run action");
    [black runAction:seq];
}
-(void)goToInitialDungeon
{
    //[sharedProfileCache purge];
    //[sharedActionCache purge];
    
    [self goToDungeon:kInitialDungeonName
             floorNum:1
               player:nil
      playerDirection:South];
}
@end