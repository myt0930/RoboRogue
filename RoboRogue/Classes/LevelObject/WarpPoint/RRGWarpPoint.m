//
//  RRGWarpPoint.m
//  RoboRogue
//
//  Created by 山本政徳 on 2014/03/15.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "RRGWarpPoint.h"
#import "RRGCategories.h"
#import "RRGModalLayer.h"
#import "RRGGameScene.h"
#import "RRGPlayer.h"
#import "RRGFunctions.h"
#import "RRGAction.h"

#import "RRGLevel.h"
#import "RRGLevel+TurnSequence.h"
#import "RRGLevel+MapID.h"
#import "RRGLevel+AddObject.h"

@implementation RRGWarpPoint
-(instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        decodeObject(self.dungeonName);
        decodeInteger(self.floorNum);
    }
    return self;
}
-(void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    encodeObject(self.dungeonName);
    encodeInteger(self.floorNum);
}
-(void)warpAction
{}
-(void)pulledToDirection:(CGPoint)direction
                maxTiles:(NSUInteger)maxTiles
             byCharacter:(RRGCharacter*)character
{
    CGPoint start = self.tileCoord;
    CGPoint end = self.tileCoord;
    
    BOOL bounce = NO;
    BOOL inView = [self.level inView:end];
    
    for (NSInteger i = 0; i < maxTiles; i++) {
        end = ccpAdd(end, direction);
        if ([self.level inView:end]) {
            inView = YES;
        }
        if (![self.level groundAtTileCoord:end] ||
            [self.level objectAtTileCoord:end] ||
            [self.level characterAtTileCoord:end]){
            end = ccpSub(end, direction);
            bounce = YES;
            break;
        }
    }
    
    [self jumpActionFromStart:start
                          end:end
                    direction:direction
                       bounce:bounce
                       inView:inView];
    
    [self dropAtTileCoord:end];
}
-(void)blowbackToDirection:(CGPoint)direction
                  maxTiles:(NSUInteger)maxTiles
               byCharacter:(RRGCharacter*)character
{
    [self pulledToDirection:direction
                   maxTiles:maxTiles
                byCharacter:character];
}
@end

@implementation Down_Stairs
-(void)updateObjectSprite
{
    //CCLOG(@"%s", __PRETTY_FUNCTION__);
    NSMutableArray* seqArray = [NSMutableArray array];
    
    __weak Down_Stairs* weakSelf = self;
    [seqArray addObject:[CCActionCallBlock actionWithBlock:^{
        [weakSelf.objectSprite stopAllActions];
    }]];
    
    CCSpriteFrame* spriteFrame = [[CCSpriteFrameCache sharedSpriteFrameCache]
                                  spriteFrameByName:@"Down_Stairs/0001.png"];
    [seqArray addObject:[CCActionCallBlock actionWithBlock:^{
        [weakSelf.objectSprite setSpriteFrame:spriteFrame];
    }]];
    CCActionSequence* seq = [CCActionSequence actionWithArray:seqArray];
    [self.level addAction:[RRGAction actionWithTarget:self
                                               action:seq
                                             forSpawn:YES]];
}
-(void)warpAction
{
    RRGPlayer* player = self.level.player;
    __weak RRGWarpPoint* weakSelf = self;
    
    [self.level.modalLayer
     showModalLayerWithMessage:@"Are you sure you want to go to the next floor?"
     opt1Message:@"Yes"
     opt1Actions:@[[CCActionSoundEffect actionWithSoundFile:@"stairs.caf"],
                   [CCActionCallBlock actionWithBlock:^{
        [sharedGameScene goToDungeon:weakSelf.dungeonName
                            floorNum:weakSelf.floorNum
                              player:player
                     playerDirection:South];
    }]
                   ]
     opt2Message:@"No"
     opt2Actions:@[@(LevelStateNormal)]];
}
@end