//
//  RRGCharacter.h
//  RoboRogue
//
//  Created by 山本政徳 on 2014/02/25.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "RRGLevelObject.h"

extern NSString* const kStateConfusion;
extern NSString* const kStateAsleep;
extern NSString* const kStatePoison;
extern NSString* const kStateParalyzed;
extern NSString* const kStateNapping;
extern NSString* const kStateFacedown;
extern NSString* const kStateBlindness;
extern NSString* const kStateInvisible;
extern NSString* const kStateSeeInvisible;
extern NSString* const kStateReflectMagic;
extern NSString* const kStateInvincible;
extern NSString* const kStatePygmy;
extern NSString* const kStateDecoy;
extern NSString* const kStateMad;
extern NSString* const kStateCantMove;
extern NSString* const kStateSealed;
extern NSString* const kStateStealth;
extern NSString* const kStateBadControll;
extern NSString* const kStateSureHit;
extern NSString* const kStateDodging;
extern NSString* const kStatePenetration;
extern NSString* const kStateTamara;
extern NSString* const kStateRunOutOfBattery;
extern NSString* const kStatePinch;

@class RRGItem, RRGMagicBullet;

@interface RRGCharacter : RRGLevelObject <NSCoding>

//sprites
@property (nonatomic) CCSprite* stateSprite;
@property (nonatomic) CCSprite* shadowSprite;

//profile
@property (nonatomic) NSUInteger shadowSize;
@property (nonatomic) CGFloat defaultSpeed;
@property (nonatomic) NSInteger pAfterAttackEffect;
@property (nonatomic, copy) NSString* attackSound;
@property (nonatomic) BOOL attackAnimationAll;

@property (nonatomic) BOOL canFly;
@property (nonatomic) BOOL canSwim;
@property (nonatomic) BOOL canWalkInWall;
//family
@property (nonatomic) BOOL isTamara;
@property (nonatomic) BOOL isDragon;
@property (nonatomic) BOOL isUndead;
@property (nonatomic) BOOL isMage;
@property (nonatomic) BOOL isMetal;

@property (nonatomic, readonly) CGFloat speed;
@property (nonatomic, readonly) CGFloat speedFactor;

@property (nonatomic, readonly) CGRect viewRect;
@property (nonatomic, weak) RRGCharacter* targetCharacter;
/*
 * for save
 */
//attributes
@property (nonatomic) NSUInteger characterLevel;
@property (nonatomic) NSUInteger maxHP;
@property (nonatomic) NSUInteger HP;
@property (nonatomic) NSUInteger strength;
@property (nonatomic) NSUInteger defense;
@property (nonatomic) NSUInteger experience;
@property (nonatomic) CGFloat actionCount;
@property (nonatomic, weak) RRGRoom* prevRoom;
@property (nonatomic) NSInteger cantWalkForwardCount;
@property (nonatomic) BOOL wasAdjacentToTarget;
@property (nonatomic) CGPoint direction;
@property (nonatomic) CGPoint exitGateOut;
@property (nonatomic) NSInteger inSameRoomCount;
//state
@property (nonatomic) NSMutableDictionary* status;
/*
 * for save
 */

@property (nonatomic) BOOL isDead;

-(void)addAction;
-(void)actionNormal;
-(void)actionConfusion;
-(void)actionMad;

-(BOOL)useSkill;
-(BOOL)attack;
-(BOOL)walk;

-(NSInteger)offenseValue;
-(NSInteger)defenseValue;

-(NSInteger)damageToTarget:(RRGCharacter*)target
         withSwordStrength:(NSInteger)swordStrength;
-(NSInteger)damageToTarget:(RRGCharacter*)target;

-(BOOL)capturingCharacter:(RRGCharacter*)character;
-(RRGCharacter*)closestCharacter;

//action
-(void)willHitItem:(RRGItem*)item
         direction:(CGPoint)direction
       byCharacter:(RRGCharacter*)character;

-(void)updateStateSprite;

-(void)didEnterRoom:(RRGRoom*)room;
-(void)didLeaveRoom:(RRGRoom*)room;

//step on trap or item
-(void)stepOnItem;
-(void)stepOnTrap;

//attack
-(void)attackToDirection:(CGPoint)direction;
-(void)didAttackToCharacter:(RRGCharacter*)character;
-(void)afterAttackEffect:(RRGCharacter*)target;

//walk
-(void)walkToDirection:(CGPoint)direction;
-(void)walkTowardDirection:(CGPoint)direction;
-(void)walkTowardTileCoord:(CGPoint)tileCoord;
-(void)walkInPath;

-(void)changeDirection:(CGPoint)direction;

-(void)wakeUpFromNap;

//damage
-(void)dealtDamage:(NSInteger)damage
       byCharacter:(RRGCharacter*)character;
-(void)didBeDealtDamage:(NSInteger)damage
            byCharacter:(RRGCharacter*)character;
-(void)killedByCharacter:(RRGCharacter*)character;
-(void)killCharacter:(RRGCharacter*)character;

-(void)rotate:(NSInteger)times;

//change
-(void)changeHP:(NSInteger)changeHP
    byCharacter:(RRGCharacter*)character;
-(void)changeMaxHP:(NSInteger)changeMaxHP;
-(void)changeExperience:(NSInteger)changeExp;
-(void)changeCharacterLevel:(NSInteger)changeLevel;
-(void)changeExperienceAndCharacterLevel:(NSInteger)changeLevel;

//item
-(void)throwItem:(RRGItem*)item;

//direction
-(CGPoint)directionToTileCoord:(CGPoint)tileCoord;
-(CGPoint)directionToObject:(RRGLevelObject*)object;

-(CGPoint)randomDirectionToWalk;

//condition
-(BOOL)canStandAtTileCoord:(CGPoint)tileCoord;
-(BOOL)canWalkToDirection:(CGPoint)direction;
-(BOOL)canAttackToDirection:(CGPoint)direction;
-(BOOL)canAttackToCharacter:(RRGCharacter*)character;
-(BOOL)canHitMagicBulletToCharacter:(RRGCharacter*)character;

//state
-(void)statusDecrement;

-(BOOL)haveState:(NSString*)key;
-(void)setState:(NSString*)key;
-(void)removeState:(NSString*)key;
-(void)removeAllStatusWithSound:(BOOL)sound
                        message:(BOOL)message;
-(BOOL)haveState:(NSString*)key;

-(NSInteger)poisonVal;
-(void)poisonHPLoss;
-(void)setStatePoison:(NSInteger)poison;

-(void)setStateChangeSpeed:(NSInteger)changeSpeed
      changeOffensivePower:(NSInteger)changeOffensivePower
      changeDefensivePower:(NSInteger)changeDefensivePower;
-(void)setStateChangeSpeed:(NSInteger)changeSpeed;
-(void)setStateChangeOffensivePower:(NSInteger)changeOffensivePower;
-(void)setStateChangeDefensivePower:(NSInteger)changeDefensivePower;
-(void)changeSpeed:(CGFloat)multiplyingVal;//to overwrite for player
@end