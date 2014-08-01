//
//  RRGEnemy.m
//  RoboRogue
//
//  Created by 山本政徳 on 2014/02/26.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "RRGEnemy.h"
#import "RRGFunctions.h"
#import "RRGPlayer.h"
#import "RRGItem.h"
#import "RRGCategories.h"

#import "RRGLevel+AddObject.h"
#import "RRGLevel+TurnSequence.h"

static const NSInteger ProbabilityDropItem = 3;

static NSString* const kProfilePNapping = @"pNapping";
static NSString* const kProfilePDropItem = @"pDropItem";
static NSString* const kProfileItemNameToDrop = @"itemNameToDrop";
static NSString* const kProfileLevelNamesArray = @"levelNamesArray";

@implementation RRGEnemy
-(void)setDefaultAttributes
{
    [super setDefaultAttributes];
    self.pDropItem = (self.profile[kProfilePDropItem])?
    [self.profile[kProfilePDropItem] integerValue]:
    ProbabilityDropItem;
    self.itemNameToDrop = self.profile[kProfileItemNameToDrop];
}
-(void)setRandomAttributes
{
    [super setRandomAttributes];
    if (calculateProbability([self.profile[kProfilePNapping] integerValue])) {
        [self setState:kStateNapping];
    }
}
-(void)setLevelNamesArray:(NSArray *)array
{
    NSString* className = [self.className copy];
    __weak RRGEnemy* weakSelf = self;
    
    [array enumerateObjectsUsingBlock:^(NSString* obj, NSUInteger idx, BOOL* stop) {
        if ([obj isEqualToString:className]) {
            if (idx != 0) weakSelf.levelDropTo = array[idx - 1];
            if (idx != [array count] - 1) weakSelf.levelRaiseTo = array[idx + 1];
        }
    }];
}
-(NSString*)displayName
{
    return [self displayName:self.characterLevel];
}
-(NSString*)displayName:(NSUInteger)characterLevel
{
    if (characterLevel == 1) {
        return [super displayName];
    } else {
        return [NSString stringWithFormat:@"%@%tu",
                [super displayName],
                characterLevel];
    }
}
#pragma mark - action
-(void)killedByCharacter:(RRGCharacter *)character
{
    [super killedByCharacter:character];
    
    if (calculateProbability(self.pDropItem)) {
        RRGItem* item = (self.itemNameToDrop)?
        [RRGItem levelObjectWithLevel:self.level
                                 name:self.itemNameToDrop
                             atRandom:YES]:
        [self.level randomItemAtRandom:YES];
        
        [self.level addObject:item atTileCoord:self.tileCoord];
        [item dropAtTileCoord:self.tileCoord];
    }
}
-(void)killCharacter:(RRGCharacter *)character
{
    [self changeCharacterLevel:+1];
}
#pragma mark - experience and character level
-(void)changeCharacterLevel:(NSInteger)changeLevel
{
    if (changeLevel > 0 && self.levelRaiseTo) {
        [self.level addAction:[CCActionSoundEffect actionWithSoundFile:@"levelUpEnemy.caf"]];
        [self.level addMessage:[NSString stringWithFormat:@"%@ raised Level and became %@.",
                                self.displayName,
                                self.levelRaiseTo]];
        [self transFormInto:self.levelRaiseTo];
        return;
    } else if (changeLevel < 0 && self.levelDropTo) {
        [self.level addAction:[CCActionSoundEffect actionWithSoundFile:@"levelDown.caf"]];
        [self.level addMessage:[NSString stringWithFormat:@"%@ dropped Level and became %@.",
                                self.displayName,
                                self.levelDropTo]];
        [self transFormInto:self.levelDropTo];
        return;
    }
    
    NSUInteger oldLv = self.characterLevel;
    [super changeCharacterLevel:changeLevel];
    NSUInteger newLv = self.characterLevel;
    NSInteger change = newLv - oldLv;
    
    if (change == 0) return;
    
    [self.level addAction:[CCActionSoundEffect actionWithSoundFile:
                           (change > 0)?@"levelUpEnemy.caf":@"levelDown.caf"]];
    [self.level addMessage:[NSString stringWithFormat:@"%@ %@ Level and became %@.",
                            [self displayName:oldLv],
                            (change > 0)?@"raised":@"dropped",
                            [self displayName:newLv]]];
    [self transFormInto:self.className characterLevel:newLv];
}
-(void)changeExperienceAndCharacterLevel:(NSInteger)changeLevel
{
    [self changeCharacterLevel:changeLevel];
}
@end