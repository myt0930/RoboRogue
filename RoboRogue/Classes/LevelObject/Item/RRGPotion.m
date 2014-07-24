//
//  RRGPotion.m
//  RoboRogue
//
//  Created by 山本政徳 on 2014/03/24.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "RRGPotion.h"
#import "RRGCategories.h"
#import "RRGCharacter.h"

#import "RRGLevel+TurnSequence.h"

static NSString* const kProfileHealingPoints = @"healingPoints";
static NSString* const kProfileRaisingMaxHPPoints = @"raisingMaxHPPoints";

@implementation RRGPotion
-(void)setDefaultAttributes
{
    [super setDefaultAttributes];
    self.dispNumber = ItemDispNumberPotion;
}
-(NSString*)spriteFolderName
{
    return @"Potion";
}
@end

@interface PotionOfHealingBase ()
//profile
@property (nonatomic) NSUInteger healingPoints;
@property (nonatomic) NSUInteger raisingMaxHPPoints;
@end
@implementation PotionOfHealingBase
-(void)setDefaultAttributes
{
    [super setDefaultAttributes];
    self.healingPoints = [self.profile[kProfileHealingPoints] integerValue];
    self.raisingMaxHPPoints = [self.profile[kProfileRaisingMaxHPPoints] integerValue];
}
-(NSString*)itemInfo
{
    return [NSString stringWithFormat:@"HP +%tu",
            self.healingPoints];
}
-(void)useToCharacter:(RRGCharacter *)target
          byCharacter:(RRGCharacter *)user
{
    //CCLOG(@"%s", __PRETTY_FUNCTION__);
    [self.level addAction:[CCActionSoundEffect actionWithSoundFile:@"healing.caf"]];
    
    if (target.HP == target.maxHP) {
        [self.level addMessage:
         [NSString stringWithFormat:@"%@'s Max HP raised by %tu %@.",
          target.displayName,
          self.raisingMaxHPPoints,
          (self.raisingMaxHPPoints == 1)?@"point":@"points"]];
        target.maxHP += self.raisingMaxHPPoints;
        target.HP += self.raisingMaxHPPoints;
    } else {
        [self.level addMessage:
         [NSString stringWithFormat:@"%@'s HP raised by %tu points.",
          target.displayName,
          self.healingPoints]];
        target.HP += self.healingPoints;
    }
}
@end

@implementation PotionOfHealing
@end

@implementation PotionOfExtraHealing
@end

@implementation PotionOfFullHealing
@end

@implementation HolyWater
-(void)useToCharacter:(RRGCharacter *)target
          byCharacter:(RRGCharacter *)user
{
    if (target.isUndead) {
        [target dealtDamage:100 byCharacter:user];
    } else {
        [target removeAllStatusWithSound:YES message:YES];
    }
}
@end

@implementation PotionOfPoison
-(void)useToCharacter:(RRGCharacter *)target
          byCharacter:(RRGCharacter *)user
{
    NSInteger poison = (self.cursedOrBlessed == RRGItemBlessed)?2:1;
    [target setStatePoison:poison];
}
@end

@implementation PotionOfConfusion
-(void)useToCharacter:(RRGCharacter *)target
          byCharacter:(RRGCharacter *)user
{
    [target setState:kStateConfusion];
}
@end

@implementation PotionOfSleeping
-(void)useToCharacter:(RRGCharacter *)target
          byCharacter:(RRGCharacter *)user
{
    [target setState:kStateAsleep];
}
@end

@implementation PotionOfParalysis
-(void)useToCharacter:(RRGCharacter *)target
          byCharacter:(RRGCharacter *)user
{
    [target setState:kStateParalyzed];
}
@end

@implementation PotionOfSpeed
-(void)useToCharacter:(RRGCharacter *)target
          byCharacter:(RRGCharacter *)user
{
    CGFloat changeSpeed = (self.cursedOrBlessed == RRGItemBlessed)?2:1;
    [target setStateChangeSpeed:changeSpeed];
}
@end

@implementation RottenPotion
-(void)useToCharacter:(RRGCharacter *)target
          byCharacter:(RRGCharacter *)user
{
    NSInteger val = (self.cursedOrBlessed == RRGItemBlessed)?-2:-1;
    [target setStateChangeSpeed:val
           changeOffensivePower:val
           changeDefensivePower:val];
}
@end