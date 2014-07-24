//
//  RRGLevel+Particle.m
//  RoboRogue
//
//  Created by 山本政徳 on 2014/06/24.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "RRGLevel+Particle.h"
#import "RRGLevel+TurnSequence.h"

#import "RRGCategories.h"
#import "RRGTiledMap.h"
#import "RRGMagicBullet.h"
#import "RRGItem.h"

NSString* const kParticleExplosion = @"Explosion";
NSString* const kParticlePoisonGas = @"PoisonGas";
NSString* const kParticleSleepingGas = @"SleepingGas";
NSString* const kParticleSmoke = @"Smoke";
NSString* const kParticleBless = @"Bless";

@implementation RRGLevel (Particle)
-(void)addParticleWithName:(NSString*)name
               atTileCoord:(CGPoint)tileCoord
                     sound:(BOOL)sound
{
    NSInteger zOrder = 0;
    
    //ZOrder
    if ([name isEqualToString:kParticleExplosion] ||
        [name isEqualToString:kParticlePoisonGas] ||
        [name isEqualToString:kParticleSleepingGas] ||
        [name isEqualToString:kParticleBless]) {
        zOrder = ZOrderInTiledMapParticleOverCharacter;
    } else if ([name isEqualToString:kParticleSmoke]) {
        zOrder = ZOrderInTiledMapParticleUnderCharacter;
    }
    // sound
    if (sound) {
        NSString* sound;
        if ([name isEqualToString:kParticleExplosion]) {
            sound = @"explosion.caf";
        } else if ([name isEqualToString:kParticlePoisonGas] ||
                   [name isEqualToString:kParticleSleepingGas]) {
            sound = @"gas.caf";
        } else if ([name isEqualToString:kParticleSmoke]) {
            sound = @"smoke.caf";
        } else if ([name isEqualToString:kParticleBless]) {
            sound = @"bless.caf";
        }
        [self addAction:[CCActionSoundEffect actionWithSoundFile:sound]];
    }
    
    name = [name stringByAppendingString:@".plist"];
    CCParticleSystem* particle = [CCParticleSystem particleWithFile:name];
    particle.position = [self.tiledMap centerTilePointForTileCoord:tileCoord];
    particle.autoRemoveOnFinish = YES;
    particle.zOrder = zOrder;
    
    __weak RRGLevel* weakSelf = self;
    [self addAction:[CCActionCallBlock actionWithBlock:^{
        [weakSelf.tiledMap addChild:particle];
    }]];
}
-(void)shootMagicBulletWithName:(NSString *)name
                  fromTileCoord:(CGPoint)tileCoord
                      direction:(CGPoint)direction
                    byCharacter:(RRGCharacter *)character
{
    RRGMagicBullet* bullet = [RRGMagicBullet magicBulletWithLevel:self
                                                             name:name
                                                            owner:character];
    bullet.position = [self.tiledMap centerTilePointForTileCoord:tileCoord];
    bullet.zOrder = ZOrderInTiledMapParticleUnderCharacter;
    
    __weak RRGLevel* weakSelf = self;
    [self addAction:[CCActionCallBlock actionWithBlock:^{
        [weakSelf.tiledMap addChild:bullet];
    }]];
    [bullet shootToDirection:direction fromTileCoord:tileCoord];
}
@end