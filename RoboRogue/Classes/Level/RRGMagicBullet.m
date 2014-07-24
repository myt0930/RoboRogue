//
//  RRGMagicBullet.m
//  RoboRogue
//
//  Created by 山本政徳 on 2014/05/05.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "RRGMagicBullet.h"
#import "RRGLevel.h"
#import "RRGLevel+AddObject.h"
#import "RRGLevel+MapID.h"
#import "RRGLevel+TurnSequence.h"
#import "RRGLevel+Particle.h"
#import "RRGCategories.h"
#import "RRGFunctions.h"
#import "RRGSavedDataHandler.h"
#import "RRGTiledMap.h"
#import "RRGAction.h"
#import "RRGCharacter.h"
#import "RRGPlayer.h"
#import "Tamara.h"
#import "RRGTrap.h"

@interface RRGMagicBullet ()
@property (nonatomic, weak) RRGLevel* level;
@property (nonatomic, readonly, weak) RRGTiledMap* tiledMap;
@property (nonatomic) BOOL collideWithObject;
-(instancetype)initWithLevel:(RRGLevel*)level
                       owner:(RRGCharacter*)owner;
-(void)magicActionCollidedWithWallWithEndTileCoord:(CGPoint)endTileCoord;
-(void)magicActionToCharacter:(RRGCharacter*)character;
@end

@implementation RRGMagicBullet
+(instancetype)magicBulletWithLevel:(RRGLevel *)level
                               name:(NSString *)name
                              owner:(RRGCharacter *)owner
{
    Class c = NSClassFromString(name);
    id obj = [[c alloc] initWithLevel:level
                                owner:owner];
    if (obj == nil) {
        CCLOG(@"Invalid name : %@", name);
    }
    return obj;
}
-(instancetype)initWithLevel:(RRGLevel*)level
                       owner:(RRGCharacter*)owner
{
    self = [super init];
    if (self) {
        self.level = level;
        _reflected = NO;
        _owner = owner;
        _collideWithObject = NO;
        
        CCParticleSystem* particle = [CCParticleSystem particleWithFile:@"MagicBullet.plist"];
        particle.position = CGPointZero;
        [self addChild:particle];
    }
    return self;
}
-(RRGTiledMap*)tiledMap
{
    return self.level.tiledMap;
}
-(void)shootToDirection:(CGPoint)direction
          fromTileCoord:(CGPoint)tileCoord
{
    self.direction = direction;
    RRGLevelObject* target = nil;
    BOOL collidedWithWall = NO;
    
    CGPoint endTileCoord = tileCoord;
    BOOL inView = [self.level inView:endTileCoord];
    
    while (YES) {
        endTileCoord = ccpAdd(endTileCoord, direction);
        if ([self.level inView:endTileCoord]) {
            inView = YES;
        }
        if ([self.level wallAtTileCoord:endTileCoord]) {
            endTileCoord = ccpSub(endTileCoord, direction);
            collidedWithWall = YES;
            break;
        } else if ([self.level characterAtTileCoord:endTileCoord]) {
            target = [self.level characterAtTileCoord:endTileCoord];
            break;
        } else if (self.collideWithObject
                   && [self.level objectAtTileCoord:endTileCoord]) {
            target = [self.level objectAtTileCoord:endTileCoord];
            break;
        }
    }
    
    [self.level addAction:[CCActionSoundEffect actionWithSoundFile:@"magicBullet.caf"]];
    
    if (inView) {
        CGFloat tiles = tileDistance(tileCoord, endTileCoord);
        if (collidedWithWall) {
            tiles += .5f;
        }
        CCActionMoveBy* move = [self.tiledMap
                                actionMoveByWithVelocity:VelocityMagicBullet
                                direction:self.direction
                                tiles:tiles];
        [self.level addAction:[RRGAction actionWithTarget:self
                                                   action:move]];
    }
    [self.level addAction:[RRGAction actionWithTarget:self
                                               action:[CCActionRemove action]]];
    if (collidedWithWall) {
        [self magicActionCollidedWithWallWithEndTileCoord:endTileCoord];
    } else if (target) {
        [target willHitByMagicBullet:self];
    }
}
-(void)magicActionCollidedWithWallWithEndTileCoord:(CGPoint)endTileCoord
{}
-(void)magicActionToObject:(RRGLevelObject*)object
{
    if ([object isKindOfClass:[RRGCharacter class]]) {
        [self magicActionToCharacter:(RRGCharacter*)object];
    }
}
-(void)magicActionToCharacter:(RRGCharacter*)character
{}
@end

#pragma mark - collide with Character

@implementation BulletOfSleeping
-(void)magicActionToCharacter:(RRGCharacter*)character
{
    [character setState:kStateAsleep];
}
@end

@implementation BulletOfConfusion
-(void)magicActionToCharacter:(RRGCharacter *)character
{
    [character setState:kStateConfusion];
}
@end

@implementation BulletOfParalysis
-(void)magicActionToCharacter:(RRGCharacter *)character
{
    [character setState:kStateParalyzed];
}
@end

@implementation BulletOfPygmy
-(void)magicActionToCharacter:(RRGCharacter *)character
{
    [character setState:kStatePygmy];
}
@end

@implementation BulletOfSloth
-(void)magicActionToCharacter:(RRGCharacter *)character
{
    [character setStateChangeSpeed:-1];
}
@end

@implementation BulletOfSloth2
-(void)magicActionToCharacter:(RRGCharacter *)character
{
    [character setStateChangeSpeed:-2];
}
@end

@implementation BulletOfDeath
-(void)magicActionToCharacter:(RRGCharacter *)character
{
    if (character.isUndead) {
        [character changeCharacterLevel:+1];
    } else {
        [character killedByCharacter:nil];
    }
}
@end

@implementation BulletOfPowerDown
-(void)magicActionToCharacter:(RRGCharacter *)character
{
    [character setStateChangeOffensivePower:-1];
}
@end

@implementation BulletOfPowerDownAndDefenseDown
-(void)magicActionToCharacter:(RRGCharacter *)character
{
    [character setStateChangeSpeed:0
              changeOffensivePower:-1
              changeDefensivePower:-1];
}
@end

@implementation BulletOfProgress
-(void)magicActionToCharacter:(RRGCharacter *)character
{
    [character changeCharacterLevel:+1];
}
@end

@implementation BulletOfRegress
-(void)magicActionToCharacter:(RRGCharacter *)character
{
    [character changeCharacterLevel:-1];
}
@end

@implementation BulletOfJumping
-(void)magicActionCollidedWithWallWithEndTileCoord:(CGPoint)endTileCoord
{
    [self.owner pulledToDirection:self.direction
                         maxTiles:99
                      byCharacter:self.owner];
}
-(void)magicActionToCharacter:(RRGCharacter *)character
{
    if (character == self.owner) return;
    
    [self.owner pulledToDirection:self.direction
                         maxTiles:99
                      byCharacter:self.owner];
}
@end

#pragma mark - collide with Object

@implementation RRGMagicBulletCollideWithObject
-(instancetype)initWithLevel:(RRGLevel *)level owner:(RRGCharacter *)owner
{
    self = [super initWithLevel:level owner:owner];
    if (self) {
        self.collideWithObject = YES;
    }
    return self;
}
@end

@implementation BulletOfTeleportation
-(void)magicActionToObject:(RRGLevelObject *)object
{
    [object warpToRandomTileCoord];
}
@end

@implementation BulletOfTamara
-(void)magicActionToObject:(RRGLevelObject *)object
{
    if ([object isKindOfClass:[RRGPlayer class]]) {
        RRGPlayer* player = (RRGPlayer*)object;
        [player setState:kStateTamara];
    } else if ([object isKindOfClass:[Tamara class]]) {
        Tamara* tamara = (Tamara*)object;
        [tamara changeCharacterLevel:+1];
    } else if ([object isKindOfClass:[RRGTrap class]] &&
               ((RRGTrap*)object).unbreakable) {
        return;
    } else {
        [object transFormInto:@"Tamara"];
    }
}
@end

@implementation BulletOfBlowback
-(void)magicActionToObject:(RRGLevelObject*)object
{
    [object blowbackToDirection:self.direction
                       maxTiles:10
                    byCharacter:self.owner];
}
@end

@implementation BulletOfPulling
-(void)magicActionToObject:(RRGLevelObject*)object
{
    if (object == self.owner) return;
    
    [object pulledToDirection:reverseDirection(self.direction)
                     maxTiles:99
                  byCharacter:self.owner];
}
@end

@implementation BulletOfSwitching
-(void)magicActionToObject:(RRGLevelObject*)object
{
    if (object == self.owner) return;
    
    CGPoint objectTileCoord = object.tileCoord;
    CGPoint ownerTileCoord = self.owner.tileCoord;
    
    self.owner.tileCoord = objectTileCoord;
    object.tileCoord = ownerTileCoord;
    
    [self.level addAction:[RRGAction
                           actionWithTarget:object
                           action:[self.tiledMap actionPlaceToTileCoord:ownerTileCoord]]];
    [self.level addAction:[RRGAction
                           actionWithTarget:self.owner
                           action:[self.tiledMap actionPlaceToTileCoord:objectTileCoord]]];
    [self.level addParticleWithName:kParticleSmoke
                        atTileCoord:objectTileCoord
                              sound:YES];
    [self.level addParticleWithName:kParticleSmoke
                        atTileCoord:ownerTileCoord
                              sound:YES];
    
    [self.owner dropAtTileCoord:objectTileCoord];
    [object dropAtTileCoord:ownerTileCoord];
}
@end