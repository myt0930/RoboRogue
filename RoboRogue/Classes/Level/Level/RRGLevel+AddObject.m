//
//  RRGTiledMap+AddObject.m
//  RoboRogue
//
//  Created by 山本政徳 on 2014/06/22.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "RRGLevel+AddObject.h"
#import "RRGLevel+TurnSequence.h"
#import "RRGLevel+MapID.h"

#import "RRGFunctions.h"
#import "RRGRoom.h"
#import "RRGCategories.h"
#import "RRGLevelObject.h"
#import "RRGCharacter.h"
#import "RRGItem.h"
#import "RRGTrap.h"
#import "RRGTiledMap.h"
#import "RRGAction.h"
#import "RRGPlayer.h"
#import "RRGEnemy.h"
#import "RRGWarpPoint.h"

typedef NS_ENUM(NSUInteger, RRGRandomTileCoordTarget)
{
    RRGRandomTileCoordTargetCharacter,
    RRGRandomTileCoordTargetObject,
};

static NSString* const kCommon = @"Common";
static NSString* const kUncommon = @"Uncommon";
static NSString* const kRare = @"Rare";

@implementation RRGLevel (AddObject)
#pragma mark - object at tileCoord
-(RRGCharacter*)characterAtTileCoord:(CGPoint)tileCoord
{
    id obj = self.characterMap[(NSUInteger)tileCoord.x][(NSUInteger)tileCoord.y];
    if ([obj isKindOfClass:[RRGCharacter class]]) {
        RRGCharacter* character = (RRGCharacter*)obj;
        if (!character.isDead) {
            return character;
        }
    }
    return nil;
}
-(RRGLevelObject*)objectAtTileCoord:(CGPoint)tileCoord
{
    id obj = self.objectMap[(NSUInteger)tileCoord.x][(NSUInteger)tileCoord.y];
    if ([obj isKindOfClass:[RRGLevelObject class]]) {
        return (RRGLevelObject*)obj;
    }
    return nil;
}
-(RRGItem*)itemAtTileCoord:(CGPoint)tileCoord
{
    id obj = [self objectAtTileCoord:tileCoord];
    if ([obj isKindOfClass:[RRGItem class]]) {
        return (RRGItem*)obj;
    }
    return nil;
}
-(RRGTrap*)trapAtTileCoord:(CGPoint)tileCoord
{
    id obj = [self objectAtTileCoord:tileCoord];
    if ([obj isKindOfClass:[RRGTrap class]]) {
        RRGTrap* trap = (RRGTrap*)obj;
        if (!trap.isCorrupted) {
            return trap;
        }
    }
    return nil;
}
-(RRGWarpPoint*)warpPointAtTileCoord:(CGPoint)tileCoord
{
    id obj = [self objectAtTileCoord:tileCoord];
    if ([obj isKindOfClass:[RRGWarpPoint class]]) {
        return (RRGWarpPoint*)obj;
    }
    return nil;
}
#pragma mark - set tileCoord of object
-(void)setTileCoord:(CGPoint)tileCoord
        ofCharacter:(RRGCharacter*)character
{
    if ([self characterAtTileCoord:character.tileCoord] == character) {
        self.characterMap[(NSUInteger)character.tileCoord.x][(NSUInteger)character.tileCoord.y] = [NSNull null];
    }
    if ([self characterAtTileCoord:tileCoord]) {
        CCLOG(@"%@ already exists at %@.",
              character,
              NSStringFromCGPoint(tileCoord));
    } else {
        self.characterMap[(NSUInteger)tileCoord.x][(NSUInteger)tileCoord.y] = character;
    }
}
-(void)setTileCoord:(CGPoint)tileCoord
           ofObject:(RRGLevelObject*)object
{
    if ([self objectAtTileCoord:object.tileCoord] == object) {
        self.objectMap[(NSUInteger)object.tileCoord.x][(NSUInteger)object.tileCoord.y] = [NSNull null];
    }
    if ([self objectAtTileCoord:tileCoord]) {
        CCLOG(@"%@ already exists at %@.",
              object,
              NSStringFromCGPoint(tileCoord));
    } else {
        self.objectMap[(NSUInteger)tileCoord.x][(NSUInteger)tileCoord.y] = object;
    }
}
#pragma mark - add object
-(void)addCharacter:(RRGCharacter*)character
        atTileCoord:(CGPoint)tileCoord
{
    character.level = self;
    [character updateSprites];
    
    character.tileCoord = tileCoord;
    character.position = [self.tiledMap centerTilePointForTileCoord:tileCoord];
    
    __weak RRGLevel* weakSelf = self;
    [self addAction:[CCActionCallBlock actionWithBlock:^{
        [weakSelf.characterLayer addChild:character];
    }]];
    
    if (self.levelState == LevelStateTurnInProgress) {
        [self.charactersForTurnSequence addObject:character];
        character.actionCount--;
    }
}
-(void)addObject:(RRGLevelObject*)object
     atTileCoord:(CGPoint)tileCoord
{
    object.level = self;
    [object updateSprites];
    
    object.tileCoord = tileCoord;
    object.position = [self.tiledMap centerTilePointForTileCoord:tileCoord];
    
    __weak RRGLevel* weakSelf = self;
    [self addAction:[CCActionCallBlock actionWithBlock:^{
        [weakSelf.objectLayer addChild:object];
    }]];
}
#pragma mark - remove object
-(void)removeCharacter:(RRGCharacter*)character
{
    CGPoint tileCoord = character.tileCoord;
    if ([self characterAtTileCoord:tileCoord] == character) {
        self.characterMap[(NSUInteger)tileCoord.x][(NSUInteger)tileCoord.y] = [NSNull null];
    }
    [self addAction:[RRGAction actionWithTarget:character
                                         action:[CCActionRemove action]]];
}
-(void)removeObject:(RRGLevelObject*)object
{
    CGPoint tileCoord = object.tileCoord;
    if ([self objectAtTileCoord:tileCoord] == object) {
        self.objectMap[(NSUInteger)tileCoord.x][(NSUInteger)tileCoord.y] = [NSNull null];
    }
    [self addAction:[RRGAction actionWithTarget:object
                                         action:[CCActionRemove action]]];
}
#pragma mark - random tileCoord
-(CGPoint)randomTileCoordForCharacterExceptRoomNums:(NSArray*)roomNums
                                          offScreen:(BOOL)offScreen
{
    return [self randomTileCoordExceptRoomNums:roomNums
                                     offScreen:offScreen
                                        target:RRGRandomTileCoordTargetCharacter];
}
-(CGPoint)randomTileCoordForObjectExceptRoomNums:(NSArray*)roomNums
                                       offScreen:(BOOL)offScreen
{
    return [self randomTileCoordExceptRoomNums:roomNums
                                     offScreen:offScreen
                                        target:RRGRandomTileCoordTargetObject];
}
-(CGPoint)randomTileCoordExceptRoomNums:(NSArray*)roomNums
                              offScreen:(BOOL)offScreen
                                 target:(RRGRandomTileCoordTarget)target
{
    NSInteger rIndex = randomInteger(0, [self.roomArray count] - 1);
    NSInteger index = rIndex;
    while (YES) {
        CGPoint p = CGPointZero;
        if (roomNums == nil
            || ![roomNums containsObject:@(index)]) {
            //CCLOG(@"index = %zd", index);
            p = [self randomTileCoordInRoom:self.roomArray[index]
                                  offScreen:offScreen
                                     target:target];
        }
        if (!CGPointEqualToPoint(p, CGPointZero)) {
            return p;
        }
        if (++index >= [self.roomArray count]) {
            index = 0;
        }
        if (index == rIndex) {
            return CGPointZero;
        }
    }
}
-(CGPoint)randomTileCoordInRoom:(RRGRoom*)room
                      offScreen:(BOOL)offScreen
                         target:(RRGRandomTileCoordTarget)target
{
    if (room.roomType == RRGRoomTypeUnused) {
        return CGPointZero;
    }
    NSInteger rX = randomInteger(room.roomLX, room.roomHX);
    NSInteger rY = randomInteger(room.roomLY, room.roomHY);
    NSInteger x = rX;
    NSInteger y = rY;
    
    while (YES) {
        if ([self groundAtTileCoord:ccp(x,y)]
            && (!offScreen || ![self inView:ccp(x,y)])) {
            if (target == RRGRandomTileCoordTargetCharacter) {
                if ([self characterAtTileCoord:ccp(x,y)] == nil) {
                    return ccp(x,y);
                }
            } else if (target == RRGRandomTileCoordTargetObject) {
                if ([self roomMapIDAtTileCoord:ccp(x,y)] < 10//部屋の入り口でない条件
                    && [self objectAtTileCoord:ccp(x,y)] == nil) {
                    return ccp(x,y);
                }
            }
        }
        if (++x > room.roomHX) {
            x = room.roomLX;
            if (++y > room.roomHY) {
                y = room.roomLY;
            }
        }
        if (x == rX && y == rY) {
            return CGPointZero;
        }
    }
}
#pragma mark - random object
-(NSString*)nameAtRandom:(NSDictionary*)nameDict
{
    if (calculateProbability(60)) {
        return [nameDict[kCommon] objectAtRandom];
    } else if (calculateProbability(75)) {
        return [nameDict[kUncommon] objectAtRandom];
    } else {
        return [nameDict[kRare] objectAtRandom];
    }
}
-(RRGLevelObject*)randomLevelObject:(NSDictionary*)nameDict
                           atRandom:(BOOL)atRandom
{
    NSString* name = [self nameAtRandom:nameDict];
    RRGLevelObject* obj = [RRGLevelObject levelObjectWithLevel:self
                                                          name:name
                                                      atRandom:atRandom];
    if (obj == nil) {
        CCLOG(@"Invalid name : %@", name);
    }
    return obj;
}
-(RRGEnemy*)randomEnemyAtRandom:(BOOL)atRandom
{
    return (RRGEnemy*)[self randomLevelObject:self.enemyNames
                                     atRandom:atRandom];
}
-(RRGItem*)randomItemAtRandom:(BOOL)atRandom
{
    return (RRGItem*)[self randomLevelObject:self.itemNames
                                    atRandom:atRandom];
}
-(RRGTrap*)randomTrapAtRandom:(BOOL)atRandom
{
    return (RRGTrap*)[self randomLevelObject:self.trapNames
                                    atRandom:atRandom];
}
#pragma mark - spawn enemy in turn
-(void)spawnEnemyInTurn
{
    CGPoint tileCoord = [self randomTileCoordForCharacterExceptRoomNums:@[@(self.player.roomNum)]
                                                              offScreen:YES];
    RRGEnemy* enemy = [self randomEnemyAtRandom:YES];
    [self addCharacter:enemy atTileCoord:tileCoord];
}
@end