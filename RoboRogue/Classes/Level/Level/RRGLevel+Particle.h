//
//  RRGLevel+Particle.h
//  RoboRogue
//
//  Created by 山本政徳 on 2014/06/24.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "RRGLevel.h"

extern NSString* const kParticleExplosion;
extern NSString* const kParticlePoisonGas;
extern NSString* const kParticleSleepingGas;
extern NSString* const kParticleSmoke;
extern NSString* const kParticleBless;

@interface RRGLevel (Particle)
-(void)addParticleWithName:(NSString*)name
               atTileCoord:(CGPoint)tileCoord
                     sound:(BOOL)sound;
-(void)shootMagicBulletWithName:(NSString *)name
                  fromTileCoord:(CGPoint)tileCoord
                      direction:(CGPoint)direction
                    byCharacter:(RRGCharacter *)character;
@end
