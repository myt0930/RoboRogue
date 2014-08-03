//
//  RRGCharacter.m
//  RoboRogue
//
//  Created by 山本政徳 on 2014/02/25.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "RRGCharacter.h"
#import "RRGCategories.h"
#import "RRGAction.h"
#import "RRGFunctions.h"
#import "RRGLevel.h"
#import "RRGLevel+AddObject.h"
#import "RRGLevel+TurnSequence.h"
#import "RRGLevel+Particle.h"
#import "RRGLevel+MapID.h"

#import "RRGSavedDataHandler.h"
#import "RRGItem.h"
#import "RRGTiledMap.h"
#import "RRGRoom.h"
#import "RRGActionCache.h"
#import "RRGMagicBullet.h"
#import "RRGPlayer.h"
#import "RRGTrap.h"

static const NSInteger ProbabilityAttackHit = 95;

//profile
static NSString* const kProfileShadowSize = @"shadowSize";
static NSString* const kProfileMaxHP = @"maxHP";
static NSString* const kProfileStrength = @"strength";
static NSString* const kProfileDefense = @"defense";
static NSString* const kProfileExperience = @"experience";
static NSString* const kProfileDefaultSpeed = @"defaultSpeed";
static NSString* const kProfilePAfterAttackEffect = @"pAfterAttackEffect";
static NSString* const kProfileAttackSound = @"attackSound";
static NSString* const kProfileAttackAnimationAll = @"attackAnimationAll";
/*
static NSString* const kProfileCanFly = @"canFly";
static NSString* const kProfileCanSwim = @"canSwim";
static NSString* const kProfileCanWalkInWall = @"canWalkInWall";

static NSString* const kProfileIsTamara = @"isTamara";
static NSString* const kProfileIsDragon = @"isDragon";
static NSString* const kProfileIsUndead = @"isUndead";
static NSString* const kProfileIsMage = @"isMage";
static NSString* const kProfileIsMetal = @"isMetal";
*/
//status
static NSString* const kStateChangeSpeed = @"stateChangeSpeed";
static NSString* const kStateChangeOffensivePower = @"stateChangeOffensivePower";
static NSString* const kStateChangeDefensivePower = @"stateChangeDefensivePower";
static NSString* const kTurnCount = @"turnCount";
static NSString* const kValue = @"value";

NSString* const kStateConfusion = @"confusion";
NSString* const kStateAsleep = @"asleep";
NSString* const kStatePoison = @"poison";
NSString* const kStateParalyzed = @"paralyzed";
NSString* const kStateNapping = @"napping";
NSString* const kStateFacedown = @"facedown";
NSString* const kStateBlindness = @"blindness";
NSString* const kStateInvisible = @"invisible";
NSString* const kStateSeeInvisible = @"seeInvisible";
NSString* const kStateReflectMagic = @"reflectMagic";
NSString* const kStateInvincible = @"invincible";
NSString* const kStatePygmy = @"pygmy";
NSString* const kStateDecoy = @"decoy";
NSString* const kStateMad = @"mad";
NSString* const kStateCantMove = @"cantMove";
NSString* const kStateSealed = @"sealed";
NSString* const kStateStealth = @"stealth";
NSString* const kStateBadControll = @"badControll";
NSString* const kStateSureHit = @"sureHit";
NSString* const kStateDodging = @"dodging";
NSString* const kStatePenetration = @"penetration";
NSString* const kStateTamara = @"tamara";

NSString* const kStateRunOutOfBattery = @"runOutOfBattery";
NSString* const kStatePinch = @"pinch";

@implementation RRGCharacter
{
    CCClippingNode* _clippingNode;
}
#pragma mark NSCoding
-(instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        decodeInteger(_characterLevel);
        decodeInteger(_maxHP);
        decodeInteger(_HP);
        decodeInteger(_strength);
        decodeInteger(_defense);
        decodeInteger(_experience);
        decodeCGFloat(_actionCount);
        decodeObject(self.prevRoom);
        decodeInteger(_cantWalkForwardCount);
        decodeBool(_wasAdjacentToTarget);
        decodeCGPoint(_direction);
        decodeCGPoint(_exitGateOut);
        decodeInteger(_inSameRoomCount);
        
        decodeObject(_status);
        
        [self updateSprites];
    }
    return self;
}
-(void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    
    encodeInteger(_characterLevel);
    encodeInteger(_maxHP);
    encodeInteger(_HP);
    encodeInteger(_strength);
    encodeInteger(_defense);
    encodeInteger(_experience);
    encodeCGFloat(_actionCount);
    encodeObject(self.prevRoom);
    encodeInteger(_cantWalkForwardCount);
    encodeBool(_wasAdjacentToTarget);
    encodeCGPoint(_direction);
    encodeCGPoint(_exitGateOut);
    encodeInteger(_inSameRoomCount);
    
    encodeObject(_status);
}
-(instancetype)initWithLevel:(RRGLevel *)level
{
    self = [super initWithLevel:level];
    if (self) {
        NSString* shadowName = [NSString stringWithFormat:@"shadow%tu.png",
                                self.shadowSize];
        _shadowSprite = [CCSprite spriteWithImageNamed:shadowName];
        _shadowSprite.opacity = .5f;
        _shadowSprite.positionType = CCPositionTypeNormalized;
        _shadowSprite.position = ccp(.5,.5);
        [self.objectSprite addChild:_shadowSprite z:ZOrderInObjectShadow];
        
        _stateSprite = [CCSprite spriteWithImageNamed:@"toumei.png"];
        _stateSprite.positionType = CCPositionTypeNormalized;
        _stateSprite.position = ccp(.5,1);
        [self.objectSprite addChild:_stateSprite z:ZOrderInObjectState];
        
        _clippingNode = [CCClippingNode clippingNodeWithStencil:self.objectSprite];
        _clippingNode.position = CGPointZero;
        _clippingNode.alphaThreshold = 0.01f;
        [self addChild:_clippingNode];
    }
    return self;
}
#pragma mark - attribute
-(void)setDefaultAttributes
{
    //CCLOG(@"%s", __PRETTY_FUNCTION__);
    [super setDefaultAttributes];
    
    _shadowSize = [self.profile[kProfileShadowSize] integerValue];
    _defaultSpeed = [self.profile[kProfileDefaultSpeed] CGFloatValue];
    _pAfterAttackEffect = (self.profile[kProfilePAfterAttackEffect])?
    [self.profile[kProfilePAfterAttackEffect] integerValue]:0;
    self.attackSound = self.profile[kProfileAttackSound];
    _attackAnimationAll = [self.profile[kProfileAttackAnimationAll] boolValue];
    
    /*
    self.canFly = [self.profile[kProfileCanFly] boolValue];
    self.canSwim = [self.profile[kProfileCanSwim] boolValue];
    self.canWalkInWall = [self.profile[kProfileCanWalkInWall] boolValue];
    self.isTamara = [self.profile[kProfileIsTamara] boolValue];
    self.isDragon = [self.profile[kProfileIsDragon] boolValue];
    self.isUndead = [self.profile[kProfileIsUndead] boolValue];
    self.isMage = [self.profile[kProfileIsMage] boolValue];
    self.isMetal = [self.profile[kProfileIsMetal] boolValue];
    */
    
    //attributes
    _characterLevel = 1;
    _maxHP = [self.profile[kProfileMaxHP] integerValue];
    _HP = self.maxHP;
    _strength = [self.profile[kProfileStrength] integerValue];
    _defense = [self.profile[kProfileDefense] integerValue];
    _experience = [self.profile[kProfileExperience] integerValue];
    
    _direction = South;
    self.prevRoom = nil;
    _wasAdjacentToTarget = NO;
    _inSameRoomCount = 0;
    
    _status = [NSMutableDictionary dictionary];
}
-(void)setTileCoord:(CGPoint)tileCoord
{
    CCLOG(@"%@ at %@",[self displayName],NSStringFromCGPoint(tileCoord));
    
    [self.level setTileCoord:tileCoord
                 ofCharacter:self];
    
    if (CGPointEqualToPoint(self.tileCoord, tileCoord)) return;
    
    [super setTileCoord:tileCoord];
    
    RRGRoom* currentRoom = ([self inRoom])?[self room]:nil;
    
    if (self.prevRoom != nil
        && self.prevRoom != currentRoom) {
        [self didLeaveRoom:self.prevRoom];
    }
    if (currentRoom != nil
        && self.prevRoom != currentRoom) {
        [self didEnterRoom:currentRoom];
    }
    if (currentRoom != nil
        && self.prevRoom == currentRoom) {
        self.inSameRoomCount++;
    } else {
        self.inSameRoomCount = 0;
    }
    self.prevRoom = currentRoom;
}
-(void)setPosition:(CGPoint)position
{
    [super setPosition:position];
    NSInteger y = (NSInteger)position.y;
    self.zOrder = 3000 - y;
}
-(BOOL)hasLamplight
{
    return NO;
}
-(BOOL)magicTunnel
{
    return NO;
}
-(CGRect)viewRect
{
    if ([self inRoom]) {
        CGRect roomRect = self.room.roomRect;
        return CGRectMake(roomRect.origin.x - 1,
                          roomRect.origin.y - 1,
                          roomRect.size.width + 2,
                          roomRect.size.height + 2);
    } else {
        NSUInteger sightDistance = (self.hasLamplight)?2:1;
        return CGRectMake(self.tileCoord.x - sightDistance,
                          self.tileCoord.y - sightDistance,
                          1 + sightDistance * 2,
                          1 + sightDistance * 2);
    }
}
-(RRGCharacter*)closestCharacter
{
    //まず隣接するマスを探す
    for (NSUInteger i = 0; i < 8; i++) {
        CGPoint direction = rotatedDirection(South, i);
        CGPoint tileCoord = ccpAdd(self.tileCoord, direction);
        RRGCharacter* character = [self.level characterAtTileCoord:tileCoord];
        if (character) {
            return character;
        }
    }
    
    RRGCharacter* closestCharacter = nil;
    NSUInteger closestDistance = 99;
    
    CGRect viewRect = self.viewRect;
    CGRectForEach(viewRect)
    {
        RRGCharacter* character = [self.level characterAtTileCoord:ccp(x,y)];
        if (character && character != self) {
            NSUInteger distance = [self distanceBetweenObject:character];
            if (distance < closestDistance) {
                closestCharacter = character;
                closestDistance = distance;
            }
        }
    }
    return closestCharacter;
}
#pragma mark - condition
-(BOOL)canStandAtTileCoord:(CGPoint)tileCoord
{
    if ([self.level groundAtTileCoord:tileCoord] ||
        [self.level lavaAtTileCoord:tileCoord] ||
        ((self.canFly || self.canSwim) && [self.level waterAtTileCoord:tileCoord]) ||
        (self.canFly && [self.level skyAtTileCoord:tileCoord]) ||
        (self.canWalkInWall && [self.level walkableWallAtTileCoord:tileCoord])) {
        return YES;
    }
    return NO;
}
-(BOOL)canWalkToDirection:(CGPoint)direction
{
    if (![self canStandAtTileCoord:ccpAdd(self.tileCoord, direction)] ||
        [self.level characterAtTileCoord:ccpAdd(self.tileCoord, direction)] ||
        (!self.canWalkInWall
         && ([self.level wallAtTileCoord:ccpAdd(self.tileCoord, ccp(0,direction.y))]
             || [self.level wallAtTileCoord:ccpAdd(self.tileCoord, ccp(direction.x,0))]))) {
             return NO;
         }
    return YES;
}
-(BOOL)canAttackToDirection:(CGPoint)direction
{
    if (!self.canWalkInWall &&
        ([self.level wallAtTileCoord:ccpAdd(self.tileCoord, direction)]
         || [self.level wallAtTileCoord:ccpAdd(self.tileCoord, ccp(0,direction.y))]
         || [self.level wallAtTileCoord:ccpAdd(self.tileCoord, ccp(direction.x,0))])) {
            return NO;
        }
    return YES;
}
-(BOOL)canAttackToCharacter:(RRGCharacter*)character
{
    if (character &&
        [self distanceBetweenObject:character] == 1 &&
        [self canAttackToDirection:[self directionToObject:character]]) {
        return YES;
    }
    return NO;
}
-(BOOL)canHitMagicBulletToCharacter:(RRGCharacter *)character
{
    if (character &&
        [self onStraightLineWithObject:character]) {
        CGPoint direction = [self directionToObject:character];
        CGPoint tileCoord = self.tileCoord;
        while (YES) {
            tileCoord = ccpAdd(tileCoord, direction);
            if (CGPointEqualToPoint(tileCoord, character.tileCoord)) {
                return YES;
            } else if ([self.level characterAtTileCoord:tileCoord]
                       || [self.level wallAtTileCoord:tileCoord]) {
                return NO;
            }
        }
    }
    return NO;
}
-(BOOL)capturingCharacter:(RRGCharacter*)character
{
    //ターゲットを捕捉している
    /*
     if ([self distanceBetweenObject:character] == 1) {
     return YES;
     } else if ([self inRoom] &&
     self.roomNum == character.roomNum) {
     return YES;
     }
     return NO;
     */
    if (character == nil) return NO;
    
    return (CGRectContainsPoint(self.viewRect, character.tileCoord))?YES:NO;
}

#pragma mark - offense and defense value
-(NSInteger)offenseValue
{
    if ([self haveState:kStatePygmy]) {
        return 0;
    }
    return self.strength * self.characterLevel;
}
-(NSInteger)defenseValue
{
    if ([self haveState:kStatePygmy]) {
        return 0;
    }
    return (NSInteger)(self.defense / 2) + 10 * (self.characterLevel - 1);
}
-(NSInteger)damageToTarget:(RRGCharacter *)target
         withSwordStrength:(NSInteger)swordStrength
{
    CGFloat val = (self.offenseValue + swordStrength) * (arc4random_uniform(26) + 87) / 100.0f - target.defenseValue;
    val = MAX(val, 1);
    val = val * [self offensivePowerChangeRate] * [target defensivePowerChangeRate];
    val = MAX(val, 1);
    return (NSInteger)val;
}
-(NSInteger)damageToTarget:(RRGCharacter *)target
{
    return [self damageToTarget:target withSwordStrength:0];
}
-(CGFloat)offensivePowerChangeRate
{
    NSInteger offensiveFactor = [self offensiveFactor];
    switch (offensiveFactor) {
        case 0:
            return 1.0f;
            break;
        case -1:
            return 0.5f;
            break;
        case -2:
            return 0.4f;
            break;
        case -3:
            return 0.3f;
            break;
        case -4:
            return 0.2f;
            break;
        case -5:
            return 0.1f;
            break;
        case -6:
            return 0.05f;
            break;
        case -7:
            return 0.04f;
            break;
        case -8:
            return 0.03f;
            break;
        case -9:
            return 0.02f;
            break;
        case -10:
            return 0.01f;
            break;
        default:
            return 1.0f + (.5f * offensiveFactor);
            break;
    }
}
-(CGFloat)defensivePowerChangeRate
{
    NSInteger defensiveFactor = [self defensiveFactor];
    switch (defensiveFactor) {
        case 0:
            return 1.0f;
            break;
        case 1:
            return 0.5f;
            break;
        case 2:
            return 0.4f;
            break;
        case 3:
            return 0.3f;
            break;
        case 4:
            return 0.2f;
            break;
        case 5:
            return 0.1f;
            break;
        case 6:
            return 0.05f;
            break;
        case 7:
            return 0.04f;
            break;
        case 8:
            return 0.03f;
            break;
        case 9:
            return 0.02f;
            break;
        case 10:
            return 0.01f;
            break;
        default:
            return 1.0f - (.5f * defensiveFactor);
            break;
    }
}
#pragma mark - overwrite action
-(void)updateSprites
{
    //CCLOG(@"%s", __PRETTY_FUNCTION__);
    [self updateObjectSprite];
    [self updateStateSprite];
}
-(void)updateObjectSprite
{
    //CCLOG(@"%s", __PRETTY_FUNCTION__);
    __weak CCSprite* weakObjectSprite = self.objectSprite;
    
    NSMutableArray* seqArray = [NSMutableArray array];
    
    [seqArray addObject:[CCActionCallFunc actionWithTarget:self.objectSprite
                                                  selector:@selector(stopAllActions)]];
    //animation
    if ([self haveState:kStateAsleep]
        || [self haveState:kStateNapping]) {
        NSString* frameName = [NSString stringWithFormat:@"%@/asleep/0001.png",
                               [self spriteFolderName]];
        CCSpriteFrame* spriteFrame = [[CCSpriteFrameCache sharedSpriteFrameCache]
                                      spriteFrameByName:frameName];
        [seqArray addObject:[CCActionCallBlock actionWithBlock:^{
            [weakObjectSprite setSpriteFrame:spriteFrame];
        }]];
    } else if (![self haveState:kStateParalyzed]) {
        // set walking animation
        NSString* format = [NSString stringWithFormat:@"%@/walk/%@/%%04tu.png",
                            [self spriteFolderName],
                            directionString(self.direction)];
        NSUInteger frameCount = [self.profile[kProfileSprite][@"walk"] integerValue];
        
        CCActionAnimate* animate = [sharedActionCache
                                    animateWithFormat:format
                                    frameCount:frameCount
                                    delay:DelayAnimation / self.speed];
        
        CCActionRepeatForever* repeat = [CCActionRepeatForever actionWithAction:animate];
        
        [seqArray addObject:[CCActionCallBlock actionWithBlock:^{
            [weakObjectSprite runAction:repeat];
        }]];
    }
    
    //tint
    if ([self haveState:kStatePoison]) {
        CGFloat color = 1.0f - [self poisonVal] / 10.0f * 2.0f;
        color = MAX(color, 0);
        //CCLOG(@"color = %f", color);
        CCActionTintTo* tint = [CCActionTintTo
                                actionWithDuration:DelayAnimation * 3
                                color:[CCColor colorWithRed:color
                                                      green:0
                                                       blue:color]];
        CCActionTintTo* tintReverse = [CCActionTintTo
                                       actionWithDuration:DelayAnimation * 3
                                       color:[CCColor colorWithRed:color + .2f
                                                             green:0
                                                              blue:color + .2f]];
        CCActionSequence* tintSeq = [CCActionSequence actionWithArray:@[tint,tintReverse]];
        CCActionRepeatForever* repeat = [CCActionRepeatForever actionWithAction:tintSeq];
        
        [seqArray addObject:[CCActionCallBlock actionWithBlock:^{
            [weakObjectSprite runAction:repeat];
        }]];
    } else {
        [seqArray addObject:[CCActionCallBlock actionWithBlock:^{
            weakObjectSprite.color = [CCColor whiteColor];
        }]];
    }
    
    //scale
    CGFloat scale = ([self haveState:kStatePygmy])?.3f:1.0f;
    [seqArray addObject:[CCActionCallBlock actionWithBlock:^{
        weakObjectSprite.scale = scale;
    }]];
    
    CCActionSequence* seq = [CCActionSequence actionWithArray:seqArray];
    [self.level addAction:[RRGAction actionWithTarget:self
                                               action:seq
                                             forSpawn:YES]];
}
-(void)warpToRandomTileCoord
{
    CGPoint tileCoord = [self.level randomTileCoordForCharacterExceptRoomNums:nil
                                                                    offScreen:NO];
    [self warpToTileCoord:tileCoord];
}
-(void)pulledToDirection:(CGPoint)direction
                maxTiles:(NSUInteger)maxTiles
             byCharacter:(RRGCharacter *)character
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
        if (!self.canWalkInWall &&
            [self.level wallAtTileCoord:end]){
            //hit with wall
            end = ccpSub(end, direction);
            bounce = YES;
            break;
        } else if ([self.level unwalkableWallAtTileCoord:end]) {
            //hit with unwalkable wall
            end = ccpSub(end, direction);
            bounce = YES;
            break;
        } else if ([self.level characterAtTileCoord:end]) {
            //hit with character
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
               byCharacter:(RRGCharacter *)character
{
    CGPoint start = self.tileCoord;
    CGPoint end = self.tileCoord;
    
    BOOL inView = [self.level inView:end];
    BOOL bounce = NO;
    BOOL hitWithWall = NO;
    RRGCharacter* characterHit = NO;
    
    for (NSUInteger i = 0; i < maxTiles; i++) {
        end = ccpAdd(end, direction);
        if ([self.level inView:end]) {
            inView = YES;
        }
        if (!self.canWalkInWall &&
            [self.level wallAtTileCoord:end]){
            //hit with wall
            end = ccpSub(end, direction);
            bounce = YES;
            hitWithWall = YES;
            break;
        } else if ([self.level unwalkableWallAtTileCoord:end]) {
            //hit with unwalkable wall
            end = ccpSub(end, direction);
            bounce = YES;
            hitWithWall = YES;
            break;
        } else if ([self.level characterAtTileCoord:end]) {
            //hit with character
            characterHit = [self.level characterAtTileCoord:end];
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
    
    self.tileCoord = end;
    
    if (hitWithWall) {
        [self dealtDamage:5 byCharacter:character];
    } else if (characterHit) {
        [self dealtDamage:5 byCharacter:character];
        [characterHit dealtDamage:5 byCharacter:character];
    }
    
    if (!_isDead) {
        [self dropAtTileCoord:end];
    }
}
-(void)dropAtTileCoord:(CGPoint)tileCoord
{
    //CCLOG(@"%s", __PRETTY_FUNCTION__);
    self.tileCoord = tileCoord;
    
    [self stepOnItem];
    [self stepOnTrap];
    
    if (![self canStandAtTileCoord:tileCoord]) {
        [self warpToRandomTileCoord];
    }
}
-(void)transFormInto:(NSString*)name
      characterLevel:(NSUInteger)characterLevel
{
    //remove old
    self.isDead = YES;
    [self.level removeCharacter:self];
    
    //new character
    RRGCharacter* character = [RRGCharacter levelObjectWithLevel:self.level
                                                            name:name
                                                        atRandom:NO];
    character.characterLevel = characterLevel;
    character.direction = self.direction;
    [self.level addCharacter:character atTileCoord:self.tileCoord];
    [character updateObjectSprite];
    
    [self.level addParticleWithName:kParticleSmoke
                        atTileCoord:self.tileCoord
                              sound:YES];
}
-(void)willHitByMagicBullet:(RRGMagicBullet*)magicBullet
{
    [self wakeUpFromNap];
    
    if ([self haveState:kStateReflectMagic]) {
        [self reflectMagicBullet:magicBullet];
    } else {
        [magicBullet magicActionToObject:self];
    }
}
#pragma mark - will hit item
-(void)willHitItem:(RRGItem*)item
         direction:(CGPoint)direction
       byCharacter:(RRGCharacter *)character
{
    [self wakeUpFromNap];
    [item hitCharacter:self direction:direction thrownBy:character];
}
#pragma mark - update sprite
-(void)updateStateSprite
{
    __weak CCSprite* weakStateSprite = self.stateSprite;
    
    NSMutableArray* seqArray = [NSMutableArray array];
    
    [seqArray addObject:[CCActionCallFunc actionWithTarget:self.stateSprite
                                                  selector:@selector(stopAllActions)]];
    
    CCSpriteFrame* spriteFrame = [[CCSpriteFrameCache sharedSpriteFrameCache]
                                  spriteFrameByName:@"toumei.png"];
    
    [seqArray addObject:[CCActionCallBlock actionWithBlock:^{
        [weakStateSprite setSpriteFrame:spriteFrame];
    }]];
    
    NSMutableArray* animationArray = [NSMutableArray array];
    
    // confusion
    if ([self haveState:kStateConfusion]) {
        CCActionAnimate* animate = [sharedActionCache
                                    animateWithFormat:@"confusion/%04d.png"
                                    frameCount:3
                                    delay:DelayAnimation];
        [animationArray addObject:animate];
    }
    // asleep
    if ([self haveState:kStateAsleep]
        || [self haveState:kStateNapping]) {
        CCActionAnimate* animate = [sharedActionCache
                                    animateWithFormat:@"asleep/%04d.png"
                                    frameCount:4
                                    delay:DelayAnimation];
        [animationArray addObject:animate];
    }
    // poison
    if ([self haveState:kStatePoison]) {
        CCActionAnimate* animate = [sharedActionCache
                                    animateWithFormat:@"poison/%04d.png"
                                    frameCount:4
                                    delay:DelayAnimation];
        [animationArray addObject:animate];
    }
    // sloth
    if (self.status[kStateChangeSpeed]
        && [self.status[kStateChangeSpeed][kValue] CGFloatValue] < 1) {
        CCActionAnimate* animate = [sharedActionCache
                                    animateWithFormat:@"sloth/%04d.png"
                                    frameCount:4
                                    delay:DelayAnimation];
        [animationArray addObject:animate];
    }
    // offense
    if (self.status[kStateChangeOffensivePower]) {
        NSString* format = ([self offensiveFactor] > 0)?@"offenseUp/%04d.png":@"offenseDown/%04d.png";
        CCActionAnimate* animate = [sharedActionCache
                                    animateWithFormat:format
                                    frameCount:4
                                    delay:DelayAnimation];
        [animationArray addObject:animate];
    }
    // defense
    if (self.status[kStateChangeDefensivePower]) {
        NSString* format = ([self defensiveFactor] > 0)?@"defenseUp/%04d.png":@"defenseDown/%04d.png";
        CCActionAnimate* animate = [sharedActionCache
                                    animateWithFormat:format
                                    frameCount:4
                                    delay:DelayAnimation];
        [animationArray addObject:animate];
    }
    
    if ([animationArray count] > 0) {
        CCActionSequence* animationSeq = [CCActionSequence actionWithArray:animationArray];
        CCActionRepeatForever* repeat = [CCActionRepeatForever actionWithAction:animationSeq];
        [seqArray addObject:[CCActionCallBlock actionWithBlock:^{
            [weakStateSprite runAction:repeat];
        }]];
    }
    
    CCActionSequence* seq = [CCActionSequence actionWithArray:seqArray];
    [self.level addAction:[RRGAction actionWithTarget:self
                                               action:seq
                                             forSpawn:YES]];
}
#pragma mark - action
-(void)addAction
{
    if ([self haveState:kStateNapping]
        || [self haveState:kStateAsleep]
        || [self haveState:kStateParalyzed]) {
        // do nothing
    } else if ([self haveState:kStateConfusion]) {
        [self actionConfusion];
    } else if ([self haveState:kStateMad]) {
        [self actionMad];
    } else {
        [self actionNormal];
    }
    
    self.wasAdjacentToTarget = ([self distanceBetweenObject:self.targetCharacter] <= 1);
    
    if (!_isDead) {
        [self poisonHPLoss];
    }
    if (!_isDead) {
        [self statusDecrement];
    }
}
-(void)actionNormal
{
    self.targetCharacter = self.player;
    if ([self useSkill]) {
        return;
    } else if ([self attack]) {
        return;
    } else if ([self walk]) {
        return;
    }
}
-(void)actionConfusion
{
    CGPoint direction = randomDirection();
    if ([self canWalkToDirection:direction]) {
        [self walkToDirection:direction];
    } else if ([self canAttackToDirection:direction] &&
               [self.level characterAtTileCoord:ccpAdd(self.tileCoord, direction)]) {
        [self attackToDirection:direction];
    } else {
        [self changeDirection:direction];
    }
}
-(void)actionMad
{
    self.targetCharacter = [self closestCharacter];
    if ([self attack]) {
        return;
    } else if ([self walk]) {
        return;
    }
}
-(BOOL)useSkill
{
    return NO;
}
-(BOOL)attack
{
    if ([self canAttackToCharacter:self.targetCharacter]) {
        CGPoint direction = [self directionToObject:self.targetCharacter];
        [self attackToDirection:direction];
        return YES;
    }
    return NO;
}
-(BOOL)walk
{
    //３ターン以上前進していない
    if (self.cantWalkForwardCount > 3) {
        [self walkTowardDirection:reverseDirection(self.direction)];
        return YES;
    }
    //ターゲットを捕捉している
    if ([self capturingCharacter:self.targetCharacter]) {
        if ([self inRoom] &&
            [self.targetCharacter atGateOutOfRoom:self.room]) {
            self.exitGateOut = self.targetCharacter.tileCoord;
            CCLOG(@"exitGateOut = %@", NSStringFromCGPoint(self.exitGateOut));
        }
        [self walkTowardTileCoord:self.targetCharacter.tileCoord];
        return YES;
    }
    //前ターンにターゲットに隣接していた
    if (self.wasAdjacentToTarget && self.targetCharacter) {
        [self walkTowardTileCoord:self.targetCharacter.tileCoord];
        return YES;
    }
    //部屋内にいる
    if ([self inRoom]) {
        //CCLOG(@"in room");
        NSInteger MaxSameRoomCount = self.room.roomWidth + self.room.roomHeight;
        if (self.inSameRoomCount > MaxSameRoomCount) {
            self.inSameRoomCount = 0;
            self.exitGateOut = [self.room exitGateOutAtRandom:self.exitGateOut];
            CCLOG(@"Re-selected exitGateOut %@", NSStringFromCGPoint(self.exitGateOut));
        }
        if (CGPointEqualToPoint(self.exitGateOut, CGPointZero)) {
            [self walkTowardDirection:randomDirection()];
            return YES;
        } else {
            [self walkTowardTileCoord:self.exitGateOut];
            return YES;
        }
    } else {
        //CCLOG(@"in path");
        [self walkInPath];
        return YES;
    }
    return NO;
}

-(void)didEnterRoom:(RRGRoom*)room
{
    //CCLOG(@"%s", __PRETTY_FUNCTION__);
    CGPoint prevTileCoord = ccpSub(self.tileCoord, _direction);
    self.exitGateOut = [room exitGateOutAtRandom:prevTileCoord];
}
-(void)didLeaveRoom:(RRGRoom*)room
{
    //CCLOG(@"%s", __PRETTY_FUNCTION__);
}
#pragma mark - attack
-(void)attackToDirection:(CGPoint)direction
{
    //update direction
    [self changeDirection:direction];
    
    if ([self inView]) {
        [self.level addAction:[CCActionSoundEffect actionWithSoundFile:self.attackSound]];
        
        NSInteger frameCount = [self.profile[kProfileSprite][@"attack"] integerValue];
        CGFloat delay = (self.attackAnimationAll)?DurationAttack:DurationAttack * .5f;
        
        //animation
        NSString* format = [NSString stringWithFormat:@"%@/attack/%@/",
                            [self spriteFolderName],
                            directionString(self.direction)];
        format = [format stringByAppendingString:@"%04d.png"];
        //CCLOG(@"format = %@", format);
        CCActionAnimate* animate = [sharedActionCache
                                    animateWithFormat:format
                                    frameCount:frameCount
                                    delay:delay / frameCount];
        //CCLOG(@"animate.duration = %f", animate.duration);
        CCActionSequence* animationSeq = [CCActionSequence actions:
                                          [CCActionCallFunc
                                           actionWithTarget:self.objectSprite
                                           selector:@selector(stopAllActions)],
                                          animate,
                                          nil];
        
        //move
        CCActionMoveBy* move = [self.tiledMap
                                actionMoveByWithDuration:DurationAttack * .5f
                                direction:direction
                                tiles:.5f];
        CCActionMoveBy* move2 = [self.tiledMap
                                 actionMoveByWithDuration:DurationAttack * .5f
                                 direction:reverseDirection(direction)
                                 tiles:.5f];
        CCActionSequence* moveSeq = [CCActionSequence actions:move,move2,nil];
        
        CCActionSpawn* spawn = [CCActionSpawn actions:animationSeq,moveSeq,nil];
        [self.level addAction:[RRGAction actionWithTarget:self.objectSprite
                                                   action:spawn]];
        [self updateObjectSprite];
    }
    
    if ([self canAttackToDirection:direction]) {
        CGPoint targetTileCoord = ccpAdd(self.tileCoord, direction);
        RRGCharacter* target = [self.level characterAtTileCoord:targetTileCoord];
        if (target) {
            if (calculateProbability(ProbabilityAttackHit)) {
                NSInteger damage = [self damageToTarget:target];
                [target dealtDamage:damage byCharacter:self];
                
                if (!_isDead) {
                    [self didAttackToCharacter:target];
                }
            } else {
                //失敗
                [self.level addAction:[CCActionSoundEffect actionWithSoundFile:@"miss.caf"]];
                [self.level addMessage:[NSString stringWithFormat:@"%@'s attack missed.",
                                        self.displayName]];
            }
        }
    }
}
-(void)didAttackToCharacter:(RRGCharacter*)character
{
    if (!character.isDead &&
        calculateProbability(self.pAfterAttackEffect)) {
        [self afterAttackEffect:character];
    }
}
-(void)afterAttackEffect:(RRGCharacter *)target
{}
#pragma mark - damage
-(void)dealtDamage:(NSInteger)damage
       byCharacter:(RRGCharacter *)character
{
    [self.level addAction:[CCActionSoundEffect actionWithSoundFile:@"damage.caf"]];
    
    NSString* message = (character)?
    [NSString stringWithFormat:@"%@ dealt %zd damage to %@.",
     character.displayName,
     damage,
     self.displayName]:
    [NSString stringWithFormat:@"%zd damage was dealt to %@.",
     damage,
     self.displayName];
    
    [self.level addMessage:message];
    
    [self wakeUpFromNap];
    //blink
    CCActionBlink* blink = [CCActionBlink actionWithDuration:DurationBlink * 2
                                                      blinks:2];
    [self.level addAction:[RRGAction actionWithTarget:self.objectSprite
                                               action:blink]];
    
    [self changeHP:damage * -1 byCharacter:character];
    
    if (!_isDead) {
        [self didBeDealtDamage:damage byCharacter:character];
    }
}
-(void)didBeDealtDamage:(NSInteger)damage byCharacter:(RRGCharacter *)character
{}
-(void)killedByCharacter:(RRGCharacter*)character
{
    self.isDead = YES;
    
    [self.level addMessage:[NSString stringWithFormat:@"%@ died.",
                            [self displayName]]];
    
    CCActionBlink* blink = [CCActionBlink actionWithDuration:DurationBlink * 3
                                                      blinks:3];
    [self.level addAction:[RRGAction actionWithTarget:self.objectSprite
                                               action:blink]];
    
    [self.level removeCharacter:self];
    [character killCharacter:self];
}
-(void)killCharacter:(RRGCharacter*)character
{}
#pragma mark - change experience and level
static NSInteger const maxMaxHP = 500;
static NSInteger const maxExperience = 362208;
static NSInteger const maxCharacterLevel = 99;
-(void)changeHP:(NSInteger)changeHP
    byCharacter:(RRGCharacter *)character
{
    NSInteger newHP = self.HP + changeHP;
    newHP = MAX(0, MIN((NSInteger)self.maxHP, newHP));
    
    if (self.HP != newHP) {
        self.HP = newHP;
        if (self.HP == 0) {
            [self killedByCharacter:character];
        }
    }
}
-(void)changeMaxHP:(NSInteger)changeMaxHP
{
    NSInteger newMaxHP = self.maxHP + changeMaxHP;
    newMaxHP = MAX(0, MIN(maxMaxHP, newMaxHP));
    if (self.maxHP != newMaxHP) {
        self.maxHP = newMaxHP;
        [self changeHP:0 byCharacter:nil];
    }
}
-(void)changeExperience:(NSInteger)changeExp
{
    NSInteger newExp = self.experience + changeExp;
    newExp = MAX(0, MIN(maxExperience, newExp));
    if (self.experience != newExp) {
        self.experience = newExp;
    }
}
-(void)changeCharacterLevel:(NSInteger)changeLevel
{
    NSInteger newLv = self.characterLevel + changeLevel;
    newLv = MAX(1, MIN(maxCharacterLevel, newLv));
    if (self.characterLevel != newLv) {
        self.characterLevel = newLv;
    }
}
-(void)changeExperienceAndCharacterLevel:(NSInteger)characterLevel
{}
#pragma mark - walk
-(void)walkToDirection:(CGPoint)direction
{
    CGPoint targetTileCoord = ccpAdd(self.tileCoord, direction);
    
    BOOL inView = ([self.level inView:self.tileCoord]
                   || [self.level inView:targetTileCoord]);
    
    [self changeDirection:direction];
    
    if (inView) {
        [self.level addAction:[RRGAction
                               actionWithTarget:self
                               action:[self.tiledMap
                                       actionMoveByWithVelocity:VelocityWalk / self.speedFactor
                                       direction:direction
                                       tiles:1]
                               forSpawn:YES]];
    } else {
        [self.level addAction:[RRGAction
                               actionWithTarget:self
                               action:[self.tiledMap
                                       actionPlaceToTileCoord:targetTileCoord]
                               forSpawn:YES]];
    }
    
    self.tileCoord = targetTileCoord;
    
    [self stepOnItem];
    [self stepOnTrap];
}
-(void)walkTowardDirection:(CGPoint)direction
{
    CGPoint d = [self walkDirectionTowardDirection:direction];
    if (CGPointEqualToPoint(d, CGPointZero)) {
        self.cantWalkForwardCount++;
        return;
    }
    self.cantWalkForwardCount = 0;
    [self walkToDirection:d];
}
-(void)walkTowardTileCoord:(CGPoint)tileCoord
{
    CGPoint d = [self walkDirectionTowardTileCoord:tileCoord];
    if (CGPointEqualToPoint(d, CGPointZero)) {
        self.cantWalkForwardCount++;
        return;
    }
    self.cantWalkForwardCount = 0;
    [self walkToDirection:d];
}
-(void)walkInPath
{
    NSInteger arr[] = {-2,-1,0,1,2};
    NSInteger r, tmp;
    for (NSInteger i = 0; i < 4; i++) {
        r = randomInteger(i + 1, 4);
        tmp = arr[i];
        arr[i] = arr[r];
        arr[r] = tmp;
    }
    
    for (NSInteger j = 0; j < 5; j++) {
        if ([self canWalkToDirection:rotatedDirection(self.direction, arr[j])]) {
            self.cantWalkForwardCount = 0;
            [self walkToDirection:rotatedDirection(self.direction, arr[j])];
            return;
        }
    }
    self.cantWalkForwardCount++;
}
-(void)changeDirection:(CGPoint)direction
{
    if (!CGPointEqualToPoint(self.direction, direction)) {
        self.direction = direction;
        [self updateObjectSprite];
    }
}
-(void)wakeUpFromNap
{
    NSInteger removeCount = 0;
    if ([self haveState:kStateNapping]) {
        removeCount++;
        [self removeState:kStateNapping];
    }
    if ([self haveState:kStateParalyzed]) {
        removeCount++;
        [self removeState:kStateParalyzed];
    }
    /*
    if (removeCount > 0) {
        self.actionCount--;
    }*/
}
-(void)rotate:(NSUInteger)times
{
    CGFloat delay = DelayAnimation / 4;
    NSString* key = [NSString stringWithFormat:@"%@/rotate/%f",
                     [self spriteFolderName],
                     delay];
    
    CCActionAnimate* animate = (CCActionAnimate*)[sharedActionCache actionForKey:key];
    if (animate == nil) {
        NSMutableArray* array = [NSMutableArray array];
        CGPoint direction = South;
        do {
            NSString* name = [NSString stringWithFormat:@"%@/walk/%@/0001.png",
                              [self spriteFolderName],
                              directionString(direction)];
            [array addObject:name];
            direction = rotatedDirection(direction, 1);
        } while (!CGPointEqualToPoint(direction, South));
        
        animate = [CCActionAnimate animateWithSpriteFrameNames:array
                                                         delay:delay];
        [sharedActionCache setAction:[animate copy] forKey:key];
    }
    CCAction* repeat = [CCActionRepeat actionWithAction:animate times:times];
    CCActionSequence* animationSeq = [CCActionSequence actions:
                                      [CCActionCallFunc
                                       actionWithTarget:self.objectSprite
                                       selector:@selector(stopAllActions)],
                                      repeat,
                                      nil];
    [self.level addAction:[RRGAction actionWithTarget:self.objectSprite
                                               action:animationSeq]];
    [self updateObjectSprite];
}
#pragma mark - item action
-(void)throwItem:(RRGItem*)item
{
    [self.level addAction:[CCActionSoundEffect actionWithSoundFile:@"attack.caf"]];
    
    if ([self inView]) {
        //animation
        NSInteger frameCount = [self.profile[kProfileSprite][@"throw"] integerValue];
        CGFloat duration = DurationAttack * .5f;// / self.speedFactor;
        
        //animation
        NSString* format = [NSString stringWithFormat:@"%@/throw/%@/",
                            [self spriteFolderName],
                            directionString(self.direction)];
        format = [format stringByAppendingString:@"%04d.png"];
        //CCLOG(@"format = %@", format);
        CCActionAnimate* animate = [sharedActionCache
                                    animateWithFormat:format
                                    frameCount:frameCount
                                    delay:duration / frameCount];
        [self.level addAction:[CCActionCallFunc
                               actionWithTarget:self.objectSprite
                               selector:@selector(stopAllActions)]];
        [self.level addAction:[RRGAction actionWithTarget:self.objectSprite
                                                   action:animate]];
        [self updateObjectSprite];
    }
    
    NSInteger maxTiles = ([self haveState:kStatePygmy])?1:10;
    [self.level addObject:item atTileCoord:self.tileCoord];
    [item blowbackToDirection:self.direction
                     maxTiles:maxTiles
                  byCharacter:self];
}
#pragma mark - step on trap and item
-(void)stepOnItem
{}
-(void)stepOnTrap
{
    RRGTrap* trap = [self.level trapAtTileCoord:self.tileCoord];
    if (trap && trap.targetNPC && !self.canFly) {
        [trap steppedOnBy:self message:YES];
    }
}
#pragma mark - direction
-(CGPoint)directionToTileCoord:(CGPoint)tileCoord
{
    CGPoint delta = ccpSub(tileCoord, self.tileCoord);
    return unitVector(delta);
}
-(CGPoint)directionToObject:(RRGLevelObject*)object
{
    return [self directionToTileCoord:object.tileCoord];
}

-(CGPoint)walkDirectionTowardTileCoord:(CGPoint)tileCoord
{
    CGPoint deltaV = ccpSub(tileCoord, self.tileCoord);
    CGPoint direction = unitVector(deltaV);
    if ([self canWalkToDirection:direction]) {
        return direction;
    }
    //上下左右方向
    if (CGPointEqualToPoint(direction, North)
        || CGPointEqualToPoint(direction, East)
        || CGPointEqualToPoint(direction, South)
        || CGPointEqualToPoint(direction, West)) {
        return [self walkDirectionTowardDirection:direction];
    }
    //斜め方向
    if (abs(deltaV.y) >= abs(deltaV.x)) {
        //距離の長い方優先
        if ([self canWalkToDirection:ccp(0, direction.y)]) {
            return ccp(0, direction.y);
        } else if ([self canWalkToDirection:ccp(direction.x, 0)]) {
            return ccp(direction.x, 0);
        }
    } else {
        if ([self canWalkToDirection:ccp(direction.x, 0)]) {
            return ccp(direction.x, 0);
        } else if ([self canWalkToDirection:ccp(0, direction.y)]) {
            return ccp(0, direction.y);
        }
    }
    return [self walkDirectionTowardDirection:direction];
}
-(CGPoint)walkDirectionTowardDirection:(CGPoint)direction
{
    if ([self canWalkToDirection:direction]) {
        return direction;
    }
    
    NSInteger rotation = (randomInteger(0, 1) == 0)?1:-1;
    
    if ([self canWalkToDirection:rotatedDirection(direction, rotation)]) {
        return rotatedDirection(direction, rotation);
    } else if ([self canWalkToDirection:rotatedDirection(direction, rotation * -1)]) {
        return rotatedDirection(direction, rotation * -1);
    } else if ([self canWalkToDirection:rotatedDirection(direction, rotation * 2)]) {
        return rotatedDirection(direction, rotation * 2);
    } else if ([self canWalkToDirection:rotatedDirection(direction, rotation * -2)]) {
        return rotatedDirection(direction, rotation * -2);
    }
    
    return CGPointZero;
}
-(CGPoint)randomDirectionToWalk
{
    CGPoint direction = randomDirection();
    for (NSInteger i = 0; i < 8; i++) {
        if ([self canWalkToDirection:direction]) {
            return direction;
        }
        direction = rotatedDirection(direction, 1);
    }
    return CGPointZero;
}
#pragma mark - status
static const NSInteger kTurnCountConfusion = 12;
static const NSInteger kTurnCountAsleep = 10;
static const NSInteger kTurnCountNapping = 100;
static const NSInteger kTurnCountPygmy = 12;
static const NSInteger kTurnCountParalyzed = 100;

-(void)setState:(NSString*)key
{
    //CCLOG(@"%s", __PRETTY_FUNCTION__);
    if ([key isEqualToString:kStateConfusion]) {
        self.status[key] = @(kTurnCountConfusion);
        [self.level addMessage:[NSString stringWithFormat:@"%@ was confused.",
                                self.displayName]];
        [self.level addAction:[CCActionSoundEffect actionWithSoundFile:@"confusion.caf"]];
        self.direction = randomDirection();
    } else if ([key isEqualToString:kStateAsleep]) {
        self.status[key] = @(kTurnCountAsleep);
        [self.level addMessage:[NSString stringWithFormat:@"%@ fell asleep.",
                                self.displayName]];
        [self.level addAction:[CCActionSoundEffect actionWithSoundFile:@"sleep.caf"]];
    } else if ([key isEqualToString:kStateNapping]) {
        self.status[key] = @(kTurnCountNapping);
    } else if ([key isEqualToString:kStatePygmy]) {
        self.status[key] = @(kTurnCountPygmy);
        [self.level addMessage:[NSString stringWithFormat:@"%@ became small.",
                                self.displayName]];
        [self.level addParticleWithName:kParticleSmoke
                            atTileCoord:self.tileCoord
                                  sound:YES];
    } else if ([key isEqualToString:kStateParalyzed]) {
        self.status[key] = @(kTurnCountParalyzed);
        [self.level addMessage:[NSString stringWithFormat:@"%@ was paralyzed.",
                                self.displayName]];
        [self.level addAction:[CCActionSoundEffect actionWithSoundFile:@"paralyzed.caf"]];
    }
    [self updateSprites];
}
-(void)removeState:(NSString*)key
{
    if (![self haveState:key]) return;
    
    [self.status removeObjectForKey:key];
    
    // message
    if ([key isEqualToString:kStateChangeSpeed]) {
        [self.level addMessage:[NSString stringWithFormat:@"%@'s speed returned to normal.",
                                self.displayName]];
    } else if ([key isEqualToString:kStateChangeOffensivePower]) {
        [self.level addMessage:[NSString stringWithFormat:@"%@'s offensive power returned to normal.",
                                self.displayName]];
    } else if ([key isEqualToString:kStateChangeDefensivePower]) {
        [self.level addMessage:[NSString stringWithFormat:@"%@'s defensive power returned to normal.",
                                self.displayName]];
    } else if ([key isEqualToString:kStatePygmy]) {
        [self.level addParticleWithName:kParticleSmoke
                            atTileCoord:self.tileCoord
                                  sound:YES];
    }
    [self updateSprites];
}
-(void)removeAllStatusWithSound:(BOOL)sound
                        message:(BOOL)message
{
    [self.status removeAllObjects];
    
    if (sound) {
        [self.level addAction:[CCActionSoundEffect actionWithSoundFile:@"clearance.caf"]];
    }
    if (message) {
        [self.level addMessage:[NSString stringWithFormat:@"%@'s status returned to normal.",
                                self.displayName]];
    }
    [self updateSprites];
}
-(BOOL)haveState:(NSString *)key
{
    return (self.status[key] != nil)?YES:NO;
}
-(void)statusDecrement
{
    //CCLOG(@"%@'s status : %@",self.className,[self.status description]);
    NSArray* keys = self.status.allKeys;
    NSInteger keyCount = [keys count];
    
    if (keyCount == 0) return;
    
    for (NSInteger i = keyCount - 1; i >= 0; i--) {
        NSString* key = keys[i];
        id state = self.status[key];
        if ([state isKindOfClass:[NSNumber class]]) {
            NSInteger turnCount = [state integerValue];
            if (turnCount > 0) {
                turnCount--;
                if (turnCount == 0) {
                    [self removeState:key];
                } else {
                    self.status[key] = @(turnCount);
                }
            }
            //CCLOG(@"%@ : turnCount : %zd", key, turnCount);
        } else if ([state isKindOfClass:[NSDictionary class]]) {
            NSInteger turnCount = [state[kTurnCount] integerValue];
            if (turnCount > 0) {
                turnCount--;
                if (turnCount == 0) {
                    [self removeState:key];
                } else {
                    state[kTurnCount] = @(turnCount);
                }
            }
            //CCLOG(@"%@ : turnCount : %zd", key, turnCount);
        }
    }
}

static NSString* const kPoisonVal = @"poisonVal";
-(NSInteger)poisonVal
{
    if ([self haveState:kStatePoison]) {
        return [self.status[kStatePoison][kPoisonVal] integerValue];
    }
    return 0;
}
-(void)poisonHPLoss
{
    NSInteger poison = [self poisonVal];
    if (poison > 0) {
        [self changeHP:poison * -1 byCharacter:nil];
    }
}
static const NSInteger kTurnCountPoison = 20;
-(void)setStatePoison:(NSInteger)poison
{
    NSInteger poisonVal = self.poisonVal + poison;
    NSMutableDictionary* poisonState = [@{kPoisonVal: @(poisonVal),
                                          kTurnCount: @(kTurnCountPoison)} mutableCopy];
    self.status[kStatePoison] = poisonState;
    
    [self.level addMessage:[NSString stringWithFormat:@"%@ got poison.", self.displayName]];
    
    [self.level addAction:[CCActionSoundEffect actionWithSoundFile:@"poison.caf"]];
    
    [self updateSprites];
}
-(void)setStateChangeSpeed:(NSInteger)changeSpeed
      changeOffensivePower:(NSInteger)changeOffensivePower
      changeDefensivePower:(NSInteger)changeDefensivePower
{
    NSInteger val = 0;
    
    if (changeSpeed != 0) {
        [self changeSpeed:pow(2, changeSpeed)];
        val += changeSpeed;
        CCLOG(@"val = %zd", val);
    }
    if (changeOffensivePower != 0) {
        [self changeOffensiveOrDefensivePower:RRGOffensivePower
                                    changeVal:changeOffensivePower];
        val += changeOffensivePower;
    }
    if (changeDefensivePower != 0) {
        [self changeOffensiveOrDefensivePower:RRGDefensivePower
                                    changeVal:changeDefensivePower];
        val += changeDefensivePower;
    }
    //up or down animation
    if (val <= 0) {
        [self upOrDownEffect:RRGEffectDown];
    } else {
        [self upOrDownEffect:RRGEffectUp];
    }
}
-(void)setStateChangeSpeed:(NSInteger)changeSpeed
{
    return [self setStateChangeSpeed:changeSpeed
                changeOffensivePower:0
                changeDefensivePower:0];
}
-(void)setStateChangeOffensivePower:(NSInteger)changeOffensivePower
{
    return [self setStateChangeSpeed:0
                changeOffensivePower:changeOffensivePower
                changeDefensivePower:0];
}
-(void)setStateChangeDefensivePower:(NSInteger)changeDefensivePower
{
    return [self setStateChangeSpeed:0
                changeOffensivePower:0
                changeDefensivePower:changeDefensivePower];
}
#pragma mark - state effect
typedef NS_ENUM(NSInteger, RRGEffectUpOrDown)
{
    RRGEffectUp,
    RRGEffectDown,
};
-(void)upOrDownEffect:(RRGEffectUpOrDown)upOrDown
{
    NSString* path = @"upOrDownEffect/";
    NSString* upOrDownStr = (upOrDown == RRGEffectDown)?@"down":@"up";
    path = [path stringByAppendingString:upOrDownStr];
    CCSprite* sprite = [CCSprite spriteWithImageNamed:
                        [NSString stringWithFormat:@"%@.png",
                         path]];
    sprite.scale = self.objectSprite.contentSize.width / sprite.contentSize.width;
    //CCLOG(@"scale = %f", sprite.scale);
    sprite.opacity = .5f;
    sprite.anchorPoint = (upOrDown == RRGEffectDown)?ccp(.5f,.25f):ccp(.5f,.75f);
    sprite.position = CGPointZero;
    
    [self.level addAction:[CCActionSoundEffect actionWithSoundFile:
                           [NSString stringWithFormat:@"%@.caf",
                            upOrDownStr]]];
    
    __weak CCClippingNode* weakClippingNode = _clippingNode;
    [self.level addAction:[CCActionCallBlock
                           actionWithBlock:^{
                               [weakClippingNode addChild:sprite];
                           }]];
    
    CGFloat dY = sprite.contentSize.height *  .5f;
    if (upOrDown == RRGEffectDown) dY *= -1.0f;
    
    CCActionMoveBy* moveBy = [CCActionMoveBy
                              actionWithDuration:.5f
                              position:ccp(0,dY)];
    
    CCActionFadeTo* fadeOut = [CCActionFadeTo actionWithDuration:.5f
                                                         opacity:0];
    CCActionEaseIn* easeIn = [CCActionEaseIn actionWithAction:fadeOut rate:5];
    
    CCActionSpawn* spawn = [CCActionSpawn actionWithArray:@[moveBy,easeIn]];
    
    [self.level addAction:[RRGAction actionWithTarget:sprite
                                               action:spawn]];
    [self.level addAction:[RRGAction actionWithTarget:sprite
                                               action:[CCActionRemove action]]];
}
#pragma mark - change speed
-(CGFloat)speed
{
    if (self.status[kStateChangeSpeed]) {
        return [self.status[kStateChangeSpeed][kValue] CGFloatValue];
    }
    return self.defaultSpeed;
}
-(CGFloat)speedFactor
{
    CGFloat ret = self.speed / self.player.speed;
    ret = MAX(ret, 1);
    return ret;
}
static const NSInteger kTurnCountChangeSpeed = 20;
-(void)changeSpeed:(CGFloat)multiplyingVal
{
    CGFloat newSpeed = self.speed * multiplyingVal;
    //CCLOG(@"change speed to %f", newSpeed);
    
    NSString* message;
    if (multiplyingVal > 1) {
        //speed up
        if (newSpeed > 4) {
            newSpeed = 4;
            message = [NSString stringWithFormat:@"%@'s movement did not become faster anymore.",
                       self.displayName];
        } else {
            message = [NSString stringWithFormat:@"%@'s movement became faster.",
                       self.displayName];
        }
    } else {
        //speed down
        if (newSpeed < 0.25) {
            //CCLOG(@"newSpeed %f < 1/4", newSpeed);
            newSpeed = 0.25;
            message = [NSString stringWithFormat:@"%@'s movement did not become slower anymore.",
                       self.displayName];
        } else {
            //CCLOG(@"newSpeed %f >= 1/4", newSpeed);
            message = [NSString stringWithFormat:@"%@'s movement became slower.",
                       self.displayName];
        }
    }
    [self.level addMessage:message];
    
    if (newSpeed == self.defaultSpeed) {
        [self removeState:kStateChangeSpeed];
    } else {
        NSMutableDictionary* changeSpeed = [@{kValue: [NSNumber numberWithCGFloat:newSpeed],
                                              kTurnCount: @(kTurnCountChangeSpeed)} mutableCopy];
        self.status[kStateChangeSpeed] = changeSpeed;
    }
    [self updateSprites];
}
#pragma mark - change power or defense
-(NSInteger)offensiveFactor
{
    if (self.status[kStateChangeOffensivePower]) {
        return [self.status[kStateChangeOffensivePower][kValue] integerValue];
    }
    return 0;
}
-(NSInteger)defensiveFactor
{
    if (self.status[kStateChangeDefensivePower]) {
        return [self.status[kStateChangeDefensivePower][kValue] integerValue];
    }
    return 0;
}

typedef NS_ENUM(NSInteger, RRGOffensiveOrDefensivePower)
{
    RRGOffensivePower,
    RRGDefensivePower,
};
static const NSInteger kTurnCountChangeOffensiveOrDefensivePower = 20;
-(void)changeOffensiveOrDefensivePower:(RRGOffensiveOrDefensivePower)offensiveOrDefensive
                             changeVal:(NSInteger)changeVal
{
    NSInteger newFactor = (offensiveOrDefensive == RRGOffensivePower)?
    self.offensiveFactor + changeVal:
    self.defensiveFactor + changeVal;
    
    NSString* message;
    
    NSString* str = (offensiveOrDefensive == RRGOffensivePower)?
    @"offensive power":
    @"defensive power";
    
    if (changeVal > 0) {
        // up
        if (newFactor > 10) {
            newFactor = 10;
            message = [NSString stringWithFormat:@"%@'s %@ did not raise anymore.",
                       self.displayName,
                       str];
        } else {
            message = [NSString stringWithFormat:@"%@'s %@ raised.",
                       self.displayName,
                       str];
        }
    } else {
        // down
        if (newFactor < -10) {
            newFactor = -10;
            message = [NSString stringWithFormat:@"%@'s %@ did not fall anymore.",
                       self.displayName,
                       str];
        } else {
            message = [NSString stringWithFormat:@"%@'s %@ fell.",
                       self.displayName,
                       str];
        }
    }
    [self.level addMessage:message];
    
    NSString* key = (offensiveOrDefensive == RRGOffensivePower)?
    kStateChangeOffensivePower:
    kStateChangeDefensivePower;
    
    if (newFactor == 0) {
        [self removeState:key];
    } else {
        NSMutableDictionary* changePower = [@{kValue: [NSNumber numberWithInteger:newFactor],
                                              kTurnCount: @(kTurnCountChangeOffensiveOrDefensivePower)} mutableCopy];
        self.status[key] = changePower;
    }
    [self updateSprites];
}
@end