//
//  RRGShield.m
//  RoboRogue
//
//  Created by 山本政徳 on 2014/04/16.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "RRGShield.h"
#import "RRGCategories.h"
#import "RRGPlayer.h"
#import "RRGFunctions.h"

#import "RRGLevel+TurnSequence.h"

@implementation RRGShield
-(void)setDefaultAttributes
{
    [super setDefaultAttributes];
    self.dispNumber = ItemDispNumberShield;
}
-(NSString*)spriteFolderName
{
    return @"Shield";
}
-(void)equippedByPlayer:(RRGPlayer *)player
{
    //CCLOG(@"%s", __PRETTY_FUNCTION__);
    [player.shieldEquipped unequippedByPlayer:player soundAndMessage:NO];
    
    if (player.shieldEquipped) return;
    
    [self.level addMessage:[NSString stringWithFormat:@"%@ equipped %@.",
                            player.displayName,
                            self.displayName]];
    
    if (self.cursedOrBlessed == RRGItemCursed) {
        //cursed
        [self.level addMessage:[NSString stringWithFormat:@"%@ was cursed.",
                                self.displayName]];
        [self.level addAction:[CCActionSoundEffect actionWithSoundFile:@"cursed.caf"]];
    } else {
        //not cursed
        [self.level addAction:[CCActionSoundEffect actionWithSoundFile:@"equip.caf"]];
    }
    
    self.equipped = YES;
    player.shieldEquipped = self;
    
    [player updateObjectSprite];
}
-(void)unequippedByPlayer:(RRGPlayer *)player
          soundAndMessage:(BOOL)soundAndMessage
{
    if (self.cursedOrBlessed == RRGItemCursed) {
        //cursed
        [self.level addAction:[CCActionSoundEffect actionWithSoundFile:@"cursed.caf"]];
        [self.level addMessage:[NSString
                                stringWithFormat:@"%@ could not unequip %@ because it was cursed.",
                                player.displayName,
                                self.displayName]];
    } else {
        // not cursed
        if (soundAndMessage) {
            [self.level addAction:[CCActionSoundEffect actionWithSoundFile:@"equip.caf"]];
            [self.level addMessage:[NSString stringWithFormat:@"%@ unequipped %@.",
                                    player.displayName,
                                    self.displayName]];
        }
        self.equipped = NO;
        player.shieldEquipped = nil;
        [player updateObjectSprite];
    }
}
-(void)didBeDealtDamage:(NSInteger)damage
            byCharacter:(RRGCharacter *)character
{}
@end

@implementation WoodenShield
@end

@implementation ShieldOfGlass
-(void)didBeDealtDamage:(NSInteger)damage
            byCharacter:(RRGCharacter *)character
{
    if (calculateProbability(10)) {
        self.cursedOrBlessed = RRGItemNormal;
        [self unequippedByPlayer:self.player
                 soundAndMessage:NO];
        [self.player.items removeObject:self];
        [self.level addAction:[CCActionSoundEffect actionWithSoundFile:@"breakGlass.caf"]];
        [self.level addMessage:[NSString stringWithFormat:@"%@ was broken.",
                                self.displayName]];
    }
}
@end

@implementation ShieldOfIron
@end