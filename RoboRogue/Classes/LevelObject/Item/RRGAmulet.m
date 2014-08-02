//
//  RRGAmulet.m
//  RoboRogue
//
//  Created by 山本政徳 on 2014/05/06.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "RRGAmulet.h"
#import "RRGPlayer.h"
#import "RRGCategories.h"
#import "RRGShadowInPathLayer.h"

#import "RRGLevel.h"
#import "RRGLevel+TurnSequence.h"

@interface RRGAmulet ()
-(void)didEquippedByPlayer:(RRGPlayer*)player;
-(void)didUnequippedByPlayer:(RRGPlayer*)player;
@end

@implementation RRGAmulet
-(void)setDefaultAttributes
{
    [super setDefaultAttributes];
    self.dispNumber = ItemDispNumberAmulet;
}
-(NSString*)spriteFolderName
{
    return @"Amulet";
}
-(void)equippedByPlayer:(RRGPlayer *)player
{
    //CCLOG(@"%s", __PRETTY_FUNCTION__);
    [player.amuletEquipped unequippedByPlayer:player soundAndMessage:NO];
    
    if (player.amuletEquipped) return;
    
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
    player.amuletEquipped = self;
    
    [self didEquippedByPlayer:player];
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
        player.amuletEquipped = nil;
        
        [self didUnequippedByPlayer:player];
    }
}
-(void)didEquippedByPlayer:(RRGPlayer*)player
{}
-(void)didUnequippedByPlayer:(RRGPlayer*)player
{}
@end

@implementation Amulet_of_Lamplight
@end

@implementation Amulet_of_Magic_Tunnel
@end

@implementation Amulet_of_Strength
@end