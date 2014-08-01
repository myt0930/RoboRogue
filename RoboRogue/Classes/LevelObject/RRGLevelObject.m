//
//  RRGLevelObject.m
//  RoboRogue
//
//  Created by 山本政徳 on 2014/02/25.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "RRGLevelObject.h"
#import "RRGCategories.h"
#import "RRGProfileCache.h"
#import "RRGPlayer.h"
#import "RRGMagicBullet.h"
#import "RRGSavedDataHandler.h"
#import "RRGFunctions.h"
#import "RRGTiledMap.h"
#import "RRGAction.h"
#import "RRGItem.h"
#import "RRGLevelMapLayer.h"

#import "RRGLevel.h"
#import "RRGLevel+MapID.h"
#import "RRGLevel+TurnSequence.h"
#import "RRGLevel+AddObject.h"
#import "RRGLevel+Particle.h"

NSString* const kProfileSprite = @"sprite";
static NSString* const kProfileDisplayName = @"displayName";

static NSString* const kLevel = @"level";

@implementation RRGLevelObject
#pragma mark - NSCoding
-(instancetype)initWithCoder:(NSCoder *)coder
{
    RRGLevel* level = [coder decodeObjectForKey:kLevel];
    self = [self initWithLevel:level];
    if (self) {
        decodeCGPoint(_tileCoord);
    }
    return self;
}
-(void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.level forKey:kLevel];
    encodeCGPoint(_tileCoord);
}
#pragma mark - constructer and initializer
+(instancetype)levelObjectWithLevel:(RRGLevel *)level
                               name:(NSString *)name
                           atRandom:(BOOL)atRandom
{
    Class c = NSClassFromString(name);
    RRGLevelObject* obj = [[c alloc] initWithLevel:level];
    if (obj == nil) {
        CCLOG(@"Invalid name : %@", name);
    }
    if (atRandom) {
        [obj setRandomAttributes];
    }
    return obj;
}
-(instancetype)initWithLevel:(RRGLevel *)level
{
    self = [super init];
    if (self) {
        self.level = level;
        
        _objectSprite = [CCSprite spriteWithImageNamed:@"toumei.png"];
        [self addChild:_objectSprite z:ZOrderInObjectObject];
        
        [self setDefaultAttributes];
        //[self updateSprites];
    }
    return self;
}
#pragma mark - attributes
-(void)setDefaultAttributes
{
    self.displayName = (self.profile[kProfileDisplayName])?
    self.profile[kProfileDisplayName]:
    [self.className stringByReplacingOccurrencesOfString:@"_" withString:@" "];
}
-(void)setRandomAttributes
{}
-(NSDictionary*)profile
{
    return [sharedProfileCache profileForKey:[self className]];
}
-(void)setTileCoord:(CGPoint)tileCoord
{
    _tileCoord = tileCoord;
    
    NSNotification* notification = [NSNotification
                                    notificationWithName:kSetTileCoord
                                    object:self
                                    userInfo:@{kTileCoord: [NSValue valueWithCGPoint:tileCoord]}];
    RRGAction* action = [RRGAction
                         actionWithTarget:self
                         action:[CCActionCallBlock actionWithBlock:^{
        [[NSNotificationCenter defaultCenter] postNotification:notification];
        //CCLOG(@"%@ posted notification", self.className);
    }]
                         forSpawn:YES];
    [self.level addAction:action];
}

#pragma mark - reference
-(RRGTiledMap*)tiledMap
{
    return self.level.tiledMap;
}
-(RRGPlayer*)player
{
    return self.level.player;
}
#pragma mark - in view
-(BOOL)inView
{
    return [self.level inView:_tileCoord];
}
-(BOOL)inPlayerView
{
    return CGRectContainsPoint(self.player.playerViewRect, _tileCoord);
}
-(BOOL)inPlayerViewForMapping
{
    return CGRectContainsPoint(self.player.playerViewRectForMapping, _tileCoord);
}
#pragma mark - room and roomNum
-(NSInteger)roomNum
{
    return [self.level roomNumAtTileCoord:_tileCoord];
}
-(RRGRoom*)room
{
    return [self.level roomAtTileCoord:_tileCoord];
}
-(BOOL)inRoom
{
    return [self.level inRoomAtTileCoord:_tileCoord];
}
-(BOOL)atGateOutOfRoom:(RRGRoom *)room
{
    return [self.level gateOutOfRoom:room atTileCoord:_tileCoord];
}
-(BOOL)atGateInOfRoom:(RRGRoom *)room
{
    return [self.level gateInOfRoom:room atTileCoord:_tileCoord];
}
//
-(NSString*)spriteFolderName
{
    return self.className;
}
-(NSString*)description
{
    return _displayName;
}
#pragma mark - condition
-(BOOL)onStraightLineWithObject:(RRGLevelObject *)object
{
    if (object == nil) return NO;
    
    CGPoint vector = ccpSub(object.tileCoord, _tileCoord);
    return (vector.x == 0
            || vector.y == 0
            || ABS(vector.x) == ABS(vector.y))?YES:NO;
}
-(NSUInteger)distanceBetweenObject:(RRGLevelObject*)object
{
    if (object == nil) return 99;
    
    NSInteger dx = abs(_tileCoord.x - object.tileCoord.x);
    NSInteger dy = abs(_tileCoord.y - object.tileCoord.y);
    return MAX(dx, dy);
}

#pragma mark - action
-(void)updateSprites
{
    [self updateObjectSprite];
}
-(void)updateObjectSprite
{}
-(void)warpToTileCoord:(CGPoint)tileCoord
{
    BOOL inView = ([self inView] || [self.level inView:tileCoord]);
    
    [self.level addMessage:[NSString stringWithFormat:@"%@ warped.",
                            self.displayName]];
    
    [self.level addAction:[CCActionSoundEffect actionWithSoundFile:@"warp.caf"]];
    
    if (inView) {
        [self.level addAction:[RRGAction
                               actionWithTarget:self.objectSprite
                               action:[self.tiledMap
                                       actionMoveByWithVelocity:VelocityJump * .5f
                                       direction:North
                                       tiles:10]]];
    }
    
    //CCLOG(@"warp to %@", NSStringFromCGPoint(tileCoord));
    self.tileCoord = tileCoord;
    
    [self.level addAction:[RRGAction
                           actionWithTarget:self
                           action:[self.tiledMap
                                   actionPlaceToTileCoord:tileCoord]]];
    
    if (inView) {
        [self.level addAction:[RRGAction
                               actionWithTarget:self.objectSprite
                               action:[self.tiledMap
                                       actionMoveByWithVelocity:VelocityJump * .5f
                                       direction:South
                                       tiles:10]]];
    }
    [self dropAtTileCoord:tileCoord];
}
-(void)warpToRandomTileCoord
{}
-(void)jumpActionFromStart:(CGPoint)start
                       end:(CGPoint)end
                 direction:(CGPoint)direction
                    bounce:(BOOL)bounce
                    inView:(BOOL)inView
{
    if (inView) {
        NSMutableArray* moveSeqArray = [NSMutableArray array];
        [moveSeqArray addObject:[self.tiledMap
                                 actionMoveByWithVelocity:VelocityJump
                                 fromTileCoord:start
                                 toTileCoord:end]];
        if (bounce) {
            [moveSeqArray addObject:[self.tiledMap
                                     actionMoveByWithVelocity:VelocityJump
                                     direction:direction
                                     tiles:.5f]];
            [moveSeqArray addObject:[self.tiledMap
                                     actionMoveByWithVelocity:VelocityJump
                                     direction:reverseDirection(direction)
                                     tiles:.5f]];
        }
        CCActionSequence* moveSeq = [CCActionSequence actionWithArray:moveSeqArray];
        [self.level addAction:[RRGAction
                               actionWithTarget:self
                               action:moveSeq]];
    } else {
        [self.level addAction:[RRGAction
                               actionWithTarget:self
                               action:[self.tiledMap actionPlaceToTileCoord:end]]];
    }
}
-(void)pulledToDirection:(CGPoint)direction
                maxTiles:(NSUInteger)maxTiles
             byCharacter:(RRGCharacter *)character
{}
-(void)blowbackToDirection:(CGPoint)direction
                  maxTiles:(NSUInteger)maxTiles
               byCharacter:(RRGCharacter *)character
{}
#pragma mark - hit
-(void)dropAtTileCoord:(CGPoint)tileCoord
{}
-(void)transFormInto:(NSString *)name
      characterLevel:(NSUInteger)characterLevel
{}
-(void)transFormInto:(NSString *)name
{
    [self transFormInto:name characterLevel:1];
}
-(void)willHitByMagicBullet:(RRGMagicBullet*)magicBullet
{
    [magicBullet magicActionToObject:self];
}
-(void)reflectMagicBullet:(RRGMagicBullet*)magicBullet
{
    if (!magicBullet.reflected) {
        magicBullet.reflected = YES;
        [magicBullet shootToDirection:reverseDirection(magicBullet.direction)
                        fromTileCoord:self.tileCoord];
    }
}
#pragma mark - update
-(void)update:(CCTime)delta
{
    if (self.level.shadow) {
        _visible = ![self.level shadowAtTilePoint:_position];
    }
}
@end