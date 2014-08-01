//
//  RRGTiledMap+AddObject.h
//  RoboRogue
//
//  Created by 山本政徳 on 2014/06/22.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "RRGLevel.h"

@class RRGEnemy, RRGWarpPoint;

@interface RRGLevel (AddObject)

//object at tileCoord
-(RRGCharacter*)characterAtTileCoord:(CGPoint)tileCoord;
-(RRGLevelObject*)objectAtTileCoord:(CGPoint)tileCoord;
-(RRGLevelObject*)objectFoundAtTileCoord:(CGPoint)tileCoord;
-(RRGItem*)itemAtTileCoord:(CGPoint)tileCoord;
-(RRGTrap*)trapAtTileCoord:(CGPoint)tileCoord;
-(RRGWarpPoint*)warpPointAtTileCoord:(CGPoint)tileCoord;

//set tileCoord of object
-(void)setTileCoord:(CGPoint)tileCoord
           ofObject:(RRGLevelObject*)object;
-(void)setTileCoord:(CGPoint)tileCoord
        ofCharacter:(RRGCharacter*)character;

//add and remove level object
-(void)addCharacter:(RRGCharacter*)character
        atTileCoord:(CGPoint)tileCoord;
-(void)addObject:(RRGLevelObject*)object
     atTileCoord:(CGPoint)tileCoord;
-(void)removeCharacter:(RRGCharacter*)character;
-(void)removeObject:(RRGLevelObject*)object;

//random tileCoord
-(CGPoint)randomTileCoordForCharacterExceptRoomNums:(NSArray*)roomNums
                                          offScreen:(BOOL)offScreen;
-(CGPoint)randomTileCoordForObjectExceptRoomNums:(NSArray*)roomNums
                                       offScreen:(BOOL)offScreen;
//random object
-(RRGEnemy*)randomEnemyAtRandom:(BOOL)atRandom;
-(RRGItem*)randomItemAtRandom:(BOOL)atRandom;
-(RRGTrap*)randomTrapAtRandom:(BOOL)atRandom;

-(void)spawnEnemyInTurn;
@end
