//
//  RRGMage.m
//  RoboRogue
//
//  Created by 山本政徳 on 2014/06/06.
//  Copyright 2014年 山本政徳. All rights reserved.
//

#import "RRGMage.h"
#import "RRGCategories.h"
#import "RRGStaff.h"
#import "RRGFunctions.h"
#import "RRGSavedDataHandler.h"
#import "RRGActionCache.h"
#import "RRGAction.h"

#import "RRGLevel+TurnSequence.h"
#import "RRGLevel+Particle.h"

@interface RRGMage ()
@property (nonatomic) RRGStaff* staff;
@end

@implementation RRGMage
#pragma mark - attribute
-(void)setDefaultAttributes
{
    [super setDefaultAttributes];
    
    NSString* staffName = [NSString stringWithFormat:@"StaffOf%@", [self className]];
    self.staff = [RRGStaff levelObjectWithLevel:self.level
                                           name:staffName
                                       atRandom:YES];
    
    self.itemNameToDrop = staffName;
    self.pDropItem = 10;
    
    self.isMage = YES;
}
#pragma mark - action
-(BOOL)useSkill
{
    if ([self canUseSkillToCharacter:self.targetCharacter] &&
        calculateProbability(50)) {
        CGPoint direction = [self directionToObject:self.targetCharacter];
        [self useSkillToDirection:direction];
        return YES;
    }
    return NO;
}
-(BOOL)canUseSkillToCharacter:(RRGCharacter*)character
{
    if ([self capturingCharacter:character] &&
        [self canHitMagicBulletToCharacter:character]) {
        return YES;
    }
    return NO;
}
-(void)useSkillToDirection:(CGPoint)direction
{
    [self changeDirection:direction];
    
    [self.level addAction:[CCActionSoundEffect actionWithSoundFile:@"waveStaff.caf"]];
    
    NSInteger frameCount = [self.profile[kProfileSprite][@"useskill"] integerValue];
    CGFloat duration = DurationAttack * .5f;
    
    //animation
    NSString* format = [NSString stringWithFormat:@"%@/useskill/%@/",
                        [self spriteFolderName],
                        directionString(direction)];
    format = [format stringByAppendingString:@"%04d.png"];
    //CCLOG(@"format = %@", format);
    CCActionAnimate* animate = [sharedActionCache
                                animateWithFormat:format
                                frameCount:frameCount
                                delay:duration / frameCount];
    //CCLOG(@"animate.duration = %f", animate.duration);
    [self.level addAction:[CCActionCallFunc
                           actionWithTarget:self.objectSprite
                           selector:@selector(stopAllActions)]];
    [self.level addAction:[RRGAction
                           actionWithTarget:self.objectSprite
                           action:animate]];
    [self updateObjectSprite];
    
    NSString* nameOfBullet = [self.staff.namesOfMagicBullets objectAtRandom];
    
    [self.level shootMagicBulletWithName:nameOfBullet
                           fromTileCoord:self.tileCoord
                               direction:self.direction
                             byCharacter:self];
}
@end

#pragma mark - Lich
@implementation Lich
-(void)setDefaultAttributes
{
    [super setDefaultAttributes];
    self.isUndead = YES;
    [self setLevelNamesArray:@[@"Lich",
                               @"Demilich",
                               @"Archlich"]];
}
@end
@implementation Demilich
@end
@implementation Archlich
@end