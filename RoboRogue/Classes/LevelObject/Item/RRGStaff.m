//
//  RRGStaff.m
//  RoboRogue
//
//  Created by 山本政徳 on 2014/05/05.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "RRGStaff.h"
#import "RRGCategories.h"
#import "RRGFunctions.h"
#import "RRGPlayer.h"
#import "RRGMagicBullet.h"
#import "RRGButtonLayer.h"

#import "RRGLevel+TurnSequence.h"
#import "RRGLevel+Particle.h"

static NSString* const kProfileMagicBulletName = @"magicBulletName";
static NSString* const kProfileNamesOfMagicBullets = @"namesOfMagicBullets";

@implementation RRGStaff
#pragma mark - NSCoding
-(instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        decodeInteger(self.numberOfMagicBullets);
    }
    return self;
}
-(void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    encodeInteger(self.numberOfMagicBullets);
}
#pragma mark - initializer
//designated initializer
-(instancetype)initWithLevel:(RRGLevel *)level
        numberOfMagicBullets:(NSInteger)numberOfMagicBullets
{
    self = [super initWithLevel:level];
    if (self) {
        _numberOfMagicBullets = numberOfMagicBullets;
    }
    return self;
}
-(instancetype)initWithLevel:(RRGLevel *)level
{
    return [self initWithLevel:level numberOfMagicBullets:5];
}
#pragma mark - attributes
-(void)setDefaultAttributes
{
    [super setDefaultAttributes];
    self.dispNumber = ItemDispNumberStaff;
    if (self.profile[kProfileMagicBulletName]) {
        self.magicBulletName = self.profile[kProfileMagicBulletName];
    }
    if (self.profile[kProfileNamesOfMagicBullets]) {
        self.namesOfMagicBullets = self.profile[kProfileNamesOfMagicBullets];
    }
}
-(void)setRandomAttributes
{
    [super setRandomAttributes];
    self.numberOfMagicBullets = randomInteger(3, 6);
}
-(NSString*)magicBulletName
{
    if (_namesOfMagicBullets) {
        return [_namesOfMagicBullets objectAtRandom];
    } else {
        return _magicBulletName;
    }
}
-(NSString*)spriteFolderName
{
    return @"Staff";
}
-(NSString*)displayName
{
    return  [NSString stringWithFormat:@"%@[%tu]",
             [super displayName],
             self.numberOfMagicBullets];
}
-(NSInteger)numberToDisplay
{
    return self.numberOfMagicBullets;
}
#pragma mark - equip or unequip
-(void)equippedByPlayer:(RRGPlayer *)player
{
    CCLOG(@"%s", __PRETTY_FUNCTION__);
    [player.staffEquipped unequippedByPlayer:player soundAndMessage:NO];
    
    [self.level addAction:[CCActionSoundEffect actionWithSoundFile:@"equip.caf"]];
    
    self.equipped = YES;
    CCLOG(@"player = %@, player.staffEquipped = %@", player, player.staffEquipped);
    player.staffEquipped = self;
}
-(void)unequippedByPlayer:(RRGPlayer *)player
          soundAndMessage:(BOOL)soundAndMessage
{
    if (soundAndMessage) {
        [self.level addAction:[CCActionSoundEffect actionWithSoundFile:@"equip.caf"]];
    }
    self.equipped = NO;
    player.staffEquipped = nil;
}
#pragma mark - action
-(void)wavedByCharacter:(RRGCharacter*)character
{
    if (self.numberOfMagicBullets > 0) {
        self.numberOfMagicBullets--;
        if (self.player.staffEquipped == self) {
            [self.level.buttonLayer setStaffButtonNumber:self.numberToDisplay];
        }
        [self.level shootMagicBulletWithName:self.magicBulletName
                               fromTileCoord:character.tileCoord
                                   direction:character.direction
                                 byCharacter:character];
    } else {
        //nothing happened.
        [self.level addMessage:@"Nothing happened."];
    }
}
-(void)useToCharacter:(RRGCharacter *)target
          byCharacter:(RRGCharacter *)user
{
    RRGMagicBullet* bullet = [RRGMagicBullet magicBulletWithLevel:self.level
                                                             name:self.magicBulletName
                                                            owner:user];
    bullet.direction = user.direction;
    
    [bullet magicActionToObject:target];
}
@end

@implementation Staff_of_Sloth
@end

@implementation Staff_of_Death
-(instancetype)initWithLevel:(RRGLevel *)level
{
    return [super initWithLevel:level numberOfMagicBullets:0];
}
-(void)setRandomAttributes
{
    [super setRandomAttributes];
    self.numberOfMagicBullets = 0;
}
@end

@implementation Staff_of_Blowback
@end

@implementation Staff_of_Switching
@end

@implementation Staff_of_Jumping
@end

@implementation Staff_of_Pulling
@end

@implementation Staff_of_Teleportation
@end

@implementation Staff_of_Progress
@end

@implementation Staff_of_Regress
@end

@implementation Staff_of_Tamara
@end

@implementation Staff_of_Lich
@end
@implementation Staff_of_Demilich
@end
@implementation Staff_of_Archlich
@end