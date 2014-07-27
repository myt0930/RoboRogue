//
//  RRGLevelObject.h
//  RoboRogue
//
//  Created by 山本政徳 on 2014/02/25.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "cocos2d.h"

extern NSString* const kProfileSprite;

typedef NS_ENUM(NSInteger, ZOrderInObject)
{
    ZOrderInObjectShadow = -1,
    ZOrderInObjectObject,
    ZOrderInObjectState
};

@class RRGLevel, RRGPlayer, RRGTiledMap, RRGRoom, RRGMagicBullet, RRGItem, RRGCharacter;

@interface RRGLevelObject : CCNode <NSCoding>

@property (nonatomic) CCSprite* objectSprite;

@property (nonatomic, readonly, weak) RRGTiledMap* tiledMap;
@property (nonatomic, readonly, weak) RRGPlayer* player;

@property (nonatomic, readonly) NSInteger roomNum;
@property (nonatomic, readonly, weak) RRGRoom* room;
@property (nonatomic, readonly) BOOL inRoom;
//profile
@property (nonatomic, readonly, weak) NSDictionary* profile;
@property (nonatomic, copy) NSString* displayName;
/*
 * for save
 */
@property (nonatomic, weak) RRGLevel* level;
@property (nonatomic) CGPoint tileCoord;
/*
 * for save
 */

@property (nonatomic, readonly) BOOL inView;
@property (nonatomic, readonly) BOOL inPlayerView;
@property (nonatomic, readonly) BOOL inPlayerViewForMapping;

+(instancetype)levelObjectWithLevel:(RRGLevel*)level
                               name:(NSString*)name
                           atRandom:(BOOL)atRandom;
//designated initializer
-(instancetype)initWithLevel:(RRGLevel*)level;

-(void)setDefaultAttributes;
-(void)setRandomAttributes;
-(NSString*)spriteFolderName;

-(BOOL)atGateOutOfRoom:(RRGRoom*)room;
-(BOOL)atGateInOfRoom:(RRGRoom*)room;

-(BOOL)onStraightLineWithObject:(RRGLevelObject *)object;
-(NSUInteger)distanceBetweenObject:(RRGLevelObject*)object;

//action
-(void)updateSprites;
-(void)updateObjectSprite;

-(void)warpToTileCoord:(CGPoint)tileCoord;
-(void)warpToRandomTileCoord;

-(void)jumpActionFromStart:(CGPoint)start
                       end:(CGPoint)end
                 direction:(CGPoint)direction
                    bounce:(BOOL)bounce
                    inView:(BOOL)inView;

-(void)pulledToDirection:(CGPoint)direction
                maxTiles:(NSUInteger)maxTiles
             byCharacter:(RRGCharacter*)character;
-(void)blowbackToDirection:(CGPoint)direction
                  maxTiles:(NSUInteger)maxTiles
               byCharacter:(RRGCharacter*)character;

-(void)dropAtTileCoord:(CGPoint)tileCoord;

-(void)transFormInto:(NSString*)name
      characterLevel:(NSUInteger)characterLevel;
-(void)transFormInto:(NSString *)name;

-(void)willHitByMagicBullet:(RRGMagicBullet*)magicBullet;
-(void)reflectMagicBullet:(RRGMagicBullet*)magicBullet;
@end