//
//  RRGItem.m
//  RoboRogue
//
//  Created by 山本政徳 on 2014/03/24.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "RRGItem.h"
#import "RRGCategories.h"
#import "RRGAction.h"
#import "RRGFunctions.h"
#import "RRGCharacter.h"
#import "RRGSavedDataHandler.h"
#import "RRGTiledMap.h"
#import "RRGTrap.h"

#import "RRGLevel.h"
#import "RRGLevel+TurnSequence.h"
#import "RRGLevel+MapID.h"
#import "RRGLevel+AddObject.h"

static const NSInteger ProbabilityItemHit = 90;

@implementation RRGItem
#pragma mark - NSCoding
-(instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        decodeInteger(self.cursedOrBlessed);
        decodeBool(self.equipped);
    }
    return self;
}
-(void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    encodeInteger(self.cursedOrBlessed);
    encodeBool(self.equipped);
}
#pragma mark - attributes
-(void)setDefaultAttributes
{
    [super setDefaultAttributes];
    self.cursedOrBlessed = RRGItemNormal;
}
-(void)setRandomAttributes
{
    [super setRandomAttributes];
    if (calculateProbability(10)) {
        _cursedOrBlessed = RRGItemCursed;
    } else if (calculateProbability(10)) {
        _cursedOrBlessed = RRGItemBlessed;
    }
}
-(void)setAttributesForNameComponents:(NSArray*)components
{
    [super setAttributesForNameComponents:components];
    for (NSString* str in components) {
        if ([str isEqualToString:@"cursed"]) {
            _cursedOrBlessed = RRGItemCursed;
        } else if ([str isEqualToString:@"blessed"]) {
            _cursedOrBlessed = RRGItemBlessed;
        }
    }
}
-(NSString*)itemInfo
{
    return nil;
}
#pragma mark - overwrite action
-(void)updateObjectSprite
{
    //CCLOG(@"%s", __PRETTY_FUNCTION__);
    NSString* spriteName = [NSString stringWithFormat:@"%@/0001.png",
                            [self spriteFolderName]];
    CCSpriteFrame* spriteFrame = [[CCSpriteFrameCache sharedSpriteFrameCache]
                                  spriteFrameByName:spriteName];
    __weak CCSprite* weakObjectSprite = self.objectSprite;
    CCActionCallBlock* block = [CCActionCallBlock actionWithBlock:^{
        [weakObjectSprite setSpriteFrame:spriteFrame];
    }];
    [self.level addAction:[RRGAction actionWithTarget:self
                                               action:block
                                             forSpawn:YES]];
}
-(void)blowbackToDirection:(CGPoint)direction
                  maxTiles:(NSUInteger)maxTiles
               byCharacter:(RRGCharacter*)character
{
    CGPoint start = self.tileCoord;
    CGPoint end = self.tileCoord;
    
    BOOL inView = [self.level inView:end];
    BOOL bounce = NO;
    RRGCharacter* characterHit = NO;
    
    for (NSUInteger i = 0; i < maxTiles; i++) {
        end = ccpAdd(end, direction);
        if ([self.level inView:end]) {
            inView = YES;
        }
        if ([self.level wallAtTileCoord:end]){
            //hit with wall
            end = ccpSub(end, direction);
            bounce = YES;
            break;
        } else if ([self.level characterAtTileCoord:end]) {
            //hit with character
            characterHit = [self.level characterAtTileCoord:end];
            break;
        }
    }
    
    [self jumpActionFromStart:start
                          end:end
                    direction:direction
                       bounce:bounce
                       inView:inView];
    
    self.tileCoord = end;
    
    if (characterHit) {
        [characterHit willHitItem:self
                        direction:direction
                      byCharacter:character];
    } else {
        [self dropAtTileCoord:end];
    }
}
-(void)dropAtTileCoord:(CGPoint)tileCoord
{
    //trap action
    RRGTrap* trap = [self.level trapAtTileCoord:tileCoord];
    if (trap && trap.found) {
        RRGCharacter* character = [self.level characterAtTileCoord:tileCoord];
        [trap steppedOnBy:character message:NO];
    }
    [super dropAtTileCoord:tileCoord];
}
#pragma mark - action
-(void)useToCharacter:(RRGCharacter *)target
          byCharacter:(RRGCharacter *)user
{
    [target dealtDamage:1 byCharacter:user];
}
-(void)hitCharacter:(RRGCharacter *)target
          direction:(CGPoint)direction
           thrownBy:(RRGCharacter *)character
{
    if (calculateProbability(ProbabilityItemHit)) {
        [self.level addMessage:[NSString stringWithFormat:@"%@ hit %@.",
                                self.displayName,
                                target.displayName]];
        [self.level removeObject:self];
        [self useToCharacter:target byCharacter:character];
    } else {
        //miss
        [self.level addAction:[CCActionSoundEffect actionWithSoundFile:@"miss.caf"]];
        [self dropAtTileCoord:target.tileCoord];
    }
}
@end

@implementation RRGItemUseOnce
@end

@implementation RRGItemEquipment
-(void)equippedByPlayer:(RRGPlayer *)player
{}
-(void)unequippedByPlayer:(RRGPlayer *)player
{
    [self unequippedByPlayer:player soundAndMessage:YES];
}
-(void)unequippedByPlayer:(RRGPlayer *)player
          soundAndMessage:(BOOL)soundAndMessage
{}
@end

static NSString* const kProfileBaseValue = @"baseValue";
static NSString* const kProfileLimitToEnchant = @"limitToEnchant";

@implementation RRGSwordOrShield
#pragma mark - NSCoding
-(instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        decodeInteger(self.enchantment);
    }
    return self;
}
-(void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    encodeInteger(self.enchantment);
}
#pragma mark - attributes
-(void)setDefaultAttributes
{
    [super setDefaultAttributes];
    self.baseValue = [self.profile[kProfileBaseValue] integerValue];
    self.limitToEnchant = [self.profile[kProfileLimitToEnchant] integerValue];
}
-(void)setRandomAttributes
{
    [super setRandomAttributes];
    switch (self.cursedOrBlessed) {
        case RRGItemCursed:
        {
            _enchantment = -1;
            break;
        }
        case RRGItemNormal:
        {
            if (calculateProbability(50)) {
                _enchantment = +1;
            }
            break;
        }
        case RRGItemBlessed:
        {
            _enchantment = +2;
            break;
        }
    }
}
-(void)setAttributesForNameComponents:(NSArray *)components
{
    [super setAttributesForNameComponents:components];
    for (NSString* str in components) {
        if ([str hasPrefix:@"+"]) {
            NSString* numStr = [str stringByReplacingOccurrencesOfString:@"+"
                                                              withString:@""];
            _enchantment = [numStr integerValue];
        } else if ([str hasPrefix:@"-"]) {
            NSString* numStr = [str stringByReplacingOccurrencesOfString:@"-"
                                                              withString:@""];
            _enchantment = [numStr integerValue] * -1;
        }
    }
}
-(NSInteger)strength
{
    return self.baseValue + self.enchantment;
}
-(NSString*)displayName
{
    NSString* str;
    if (self.enchantment > 0) {
        str = [NSString stringWithFormat:@"%@+%zd",
               [super displayName],
               self.enchantment];
    } else if (self.enchantment < 0) {
        str = [NSString stringWithFormat:@"%@%zd",
               [super displayName],
               self.enchantment];
    } else {
        str = [super displayName];
    }
    return str;
}
-(NSString*)itemInfo
{
    return [NSString stringWithFormat:@"Str. : %zd",
            self.strength];
}
#pragma mark - action
-(void)useToCharacter:(RRGCharacter *)target
          byCharacter:(RRGCharacter *)user
{
    NSInteger strength = MAX(0, self.strength);
    
    switch (self.cursedOrBlessed) {
        case RRGItemCursed:
            strength = 0;
            break;
        case RRGItemBlessed:
            strength *= 2;
            break;
    }
    
    NSInteger damage = [user damageToTarget:target
                          withSwordStrength:strength];
    [target dealtDamage:damage byCharacter:user];
}
////
-(NSString*)description
{
    return [NSString stringWithFormat:@"%@ at %@", self.className, NSStringFromCGPoint(self.tileCoord)];
}
@end