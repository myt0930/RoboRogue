//
//  RRGLevel+TurnSequence.m
//  RoboRogue
//
//  Created by 山本政徳 on 2014/06/30.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "RRGLevel+TurnSequence.h"
#import "RRGLevel+AddObject.h"

#import "RRGAction.h"
#import "RRGPlayer.h"
#import "RRGGameScene.h"
#import "RRGModalLayer.h"
#import "RRGWarpPoint.h"

@implementation RRGLevel (TurnSequence)
#pragma mark - add action
-(void)addAction:(CCAction*)action
{
    if (action == nil) return;
    
    if (self.levelState == LevelStateTurnInProgress) {
        if ([action isKindOfClass:[RRGAction class]] &&
            ((RRGAction*)action).forSpawn) {
            // action for spawn
            RRGAction* lastAction = [self.seqArray lastObject];
            if (lastAction.forcedTarget != ((RRGAction*)action).forcedTarget) {
                [self createSequence];
            }
            [self.seqArray addObject:action];
        } else {
            // action not for spawn
            [self createSequence];
            [self createSpawn];
            [self.actionArray addObject:action];
        }
    } else {
        [self runAction:action];
    }
}
-(void)createSequence
{
    if ([self.seqArray count] > 0) {
        CCActionSequence* seq = [CCActionSequence actionWithArray:self.seqArray];
        [self.spawnArray addObject:seq];
        [self.seqArray removeAllObjects];
    }
}
-(void)createSpawn
{
    if ([self.spawnArray count] > 0) {
        CCActionSpawn* spawn = [CCActionSpawn actionWithArray:self.spawnArray];
        [self.actionArray addObject:spawn];
        [self.spawnArray removeAllObjects];
    }
}
#pragma mark - turn sequence
-(void)turnStartPhase
{
    CCLOG(@"%s", __PRETTY_FUNCTION__);
    [self.charactersForTurnSequence addObjectsFromArray:self.characterLayer.children];
    [self playerActionPhase];
}
-(void)playerActionPhase
{
    [self.player addAction];
    [self addActionPhase];
}
-(void)addActionPhase
{
    if ([self.charactersForTurnSequence count] > 0 && !self.player.isDead) {
        RRGCharacter* character = self.charactersForTurnSequence[0];
        if (character != self.player) {
            //CCLOG(@"player speed = %f", self.player.speed);
            character.actionCount += character.speed / self.player.speed;
            /*CCLOG(@"%@.speed = %f, player.speed = %f, actionCount = %f",
                  character, character.speed, self.player.speed, character.actionCount);*/
            while (!character.isDead &&
                   !self.player.isDead &&
                   character.actionCount >= 1) {
                character.actionCount--;
                [character addAction];
            }
        }
        CCLOG(@"charatersForTurnSequence removeObjectAtIndex:0");
        [self.charactersForTurnSequence removeObjectAtIndex:0];
        [self addActionPhase];
    } else {
        // no characters to action
        [self createSequence];
        [self createSpawn];
        [self runActionPhase];
    }
}
-(void)runActionPhase
{
    [self.actionArray addObject:[CCActionCallFunc
                                 actionWithTarget:self
                                 selector:@selector(turnEndPhase)]];
    CCActionSequence* seq = [CCActionSequence actionWithArray:self.actionArray];
    [self.actionArray removeAllObjects];
    [self runAction:seq];
}
-(void)turnEndPhase
{
    CCLOG(@"%s", __PRETTY_FUNCTION__);
    self.turnCount++;
    
    //game over
    if (self.player.isDead) {
        [self updateLevelState:LevelStateGameOver];
        return;
    }
    
    //spawn enemy
    if (self.spawnEnemy && self.turnCount % 20 == 0) {
        [self spawnEnemyInTurn];
    }
    
    //連続行動
    if ([self.player haveState:kStateAsleep] ||
        [self.player haveState:kStateParalyzed] ||
        [self.player haveState:kStateMad]) {
        [self turnStartPhase];
        return;
    } else {
        //warp
        RRGWarpPoint* warpPoint = [self warpPointAtTileCoord:self.player.tileCoord];
        if (warpPoint) {
            [warpPoint warpAction];
            return;
        }
    }
    
    if (self.touching) {
        [self walkPlayerTowardTouch];
        return;
    }
    
    [self updateLevelState:LevelStateNormal];
}
@end