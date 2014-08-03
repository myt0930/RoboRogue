//
//  RRGTrap.m
//  RoboRogue
//
//  Created by 山本政徳 on 2014/03/07.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "RRGTrap.h"
#import "RRGCategories.h"
#import "RRGAction.h"
#import "RRGActionCache.h"
#import "RRGSavedDataHandler.h"
#import "RRGCharacter.h"
#import "RRGFunctions.h"
#import "RRGTiledMap.h"
#import "RRGLevelMapLayer.h"

#import "RRGLevel+TurnSequence.h"
#import "RRGLevel+Particle.h"
#import "RRGLevel+AddObject.h"
#import "RRGLevel+MapID.h"

static const NSInteger ProbabilityTrapCorrupt = 20;

static NSString* const kProfileTargetPlayer = @"targetPlayer";
static NSString* const kProfileTargetNPC = @"targetNPC";
static NSString* const kProfileActionOnce = @"actionOnce";

@implementation RRGTrap
#pragma mark - NSCoding
-(instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        decodeBool(self.found);
        decodeBool(self.unbreakable);
        decodeBool(self.isCorrupted);
    }
    return self;
}
-(void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    encodeBool(self.found);
    encodeBool(self.unbreakable);
    encodeBool(self.isCorrupted);
}
-(void)setDefaultAttributes
{
    [super setDefaultAttributes];
    self.targetPlayer = [self.profile[kProfileTargetPlayer] boolValue];
    self.targetNPC = [self.profile[kProfileTargetNPC] boolValue];
    self.actionOnce = [self.profile[kProfileActionOnce] boolValue];
    
    //attribute
    self.found = NO;
    self.isCorrupted = NO;
}
-(void)setFound:(BOOL)found
{
    _found = found;
    
    NSNotification* notification = [NSNotification
                                    notificationWithName:kFound
                                    object:self
                                    userInfo:nil];
    
    __weak RRGTrap* weakSelf = self;
    
    [self.level addAction:[CCActionCallBlock actionWithBlock:^{
        //CCLOG(@"%@ is found", weakSelf);
        weakSelf.objectSprite.visible = found;
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }]];
}
#pragma mark - overwrite action
-(void)updateObjectSprite
{
    //CCLOG(@"%s", __PRETTY_FUNCTION__);
    NSMutableArray* seqArray = [NSMutableArray array];
    
    __weak RRGTrap* weakSelf = self;
    [seqArray addObject:[CCActionCallBlock actionWithBlock:^{
        [weakSelf.objectSprite stopAllActions];
    }]];
    
    NSUInteger frameCount = [self.profile[kProfileSprite] integerValue];
    if (frameCount == 1) {
        NSString* spriteName = [NSString stringWithFormat:@"%@/0001.png",
                                [self spriteFolderName]];
        //CCLOG(@"spriteName = %@", spriteName);
        CCSpriteFrame* spriteFrame = [[CCSpriteFrameCache sharedSpriteFrameCache]
                                      spriteFrameByName:spriteName];
        [seqArray addObject:[CCActionCallBlock actionWithBlock:^{
            [weakSelf.objectSprite setSpriteFrame:spriteFrame];
        }]];
    } else {
        NSString* format = [NSString stringWithFormat:@"%@/%%04tu.png",
                            [self spriteFolderName]];
        
        CCActionAnimate* animate = [sharedActionCache
                                    animateWithFormat:format
                                    frameCount:frameCount
                                    delay:DelayAnimation];
        CCActionRepeatForever* repeat = [CCActionRepeatForever actionWithAction:animate];
        [seqArray addObject:[CCActionCallBlock actionWithBlock:^{
            [weakSelf.objectSprite runAction:repeat];
        }]];
    }
    CCActionSequence* seq = [CCActionSequence actionWithArray:seqArray];
    [self.level addAction:[RRGAction actionWithTarget:self
                                               action:seq
                                             forSpawn:YES]];
}
-(void)pulledToDirection:(CGPoint)direction
                maxTiles:(NSUInteger)maxTiles
             byCharacter:(RRGCharacter*)character
{
    if (!self.unbreakable) {
        [super pulledToDirection:direction
                        maxTiles:maxTiles
                     byCharacter:character];
        return;
    }
    
    //if unbreakable
    
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
    if (self.unbreakable) {
        [self pulledToDirection:direction
                       maxTiles:maxTiles
                    byCharacter:character];
        return;
    }
    
    //if breakable
    CGPoint start = self.tileCoord;
    CGPoint end = self.tileCoord;
    
    BOOL inView = [self.level inView:end];
    BOOL bounce = NO;
    BOOL hit = NO;
    
    for (NSUInteger i = 0; i < maxTiles; i++) {
        end = ccpAdd(end, direction);
        if ([self.level inView:end]) {
            inView = YES;
        }
        if ([self.level wallAtTileCoord:end]){
            //hit with wall
            end = ccpSub(end, direction);
            bounce = YES;
            hit = YES;
            break;
        } else if ([self.level characterAtTileCoord:end]) {
            //hit with character
            hit = YES;
            break;
        }
    }
    
    [self jumpActionFromStart:start
                          end:end
                    direction:direction
                       bounce:bounce
                       inView:inView];
    
    self.tileCoord = end;
    
    if (hit) {
        RRGCharacter* targetCharacter = [self.level characterAtTileCoord:end];
        [self steppedOnBy:targetCharacter message:NO];
    }
    if (!_isCorrupted) {
        [self dropAtTileCoord:end];
    }
}
#pragma mark - action
-(void)steppedOnBy:(RRGCharacter *)character
           message:(BOOL)message
{
    self.found = YES;
    
    if (message && character) {
        [self.level addMessage:[NSString stringWithFormat:@"%@ stepped on %@.",
                                character.displayName,
                                self.displayName]];
    }
    
    if (!_unbreakable &&
        (_actionOnce || calculateProbability(ProbabilityTrapCorrupt))) {
        _isCorrupted = YES;
    }
    
    [self trapActionToCharacter:character];
    
    if (_isCorrupted) {
        [self corrupt];
    }
}
-(void)trapActionToCharacter:(RRGCharacter*)character
{}
-(void)corrupt
{
    [self.level addAction:[CCActionDelay actionWithDuration:.5f]];
    
    [self.level addParticleWithName:kParticleSmoke
                        atTileCoord:self.tileCoord
                              sound:NO];
    [self.level removeObject:self];
}
@end