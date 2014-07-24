//
//  RRGMagicBullet.h
//  RoboRogue
//
//  Created by 山本政徳 on 2014/05/05.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "cocos2d.h"

@class RRGLevelObject, RRGCharacter, RRGLevel;

@interface RRGMagicBullet : CCNode

@property (nonatomic) CGPoint direction;
@property (nonatomic) BOOL reflected;
@property (nonatomic,weak) RRGCharacter* owner;

+(instancetype)magicBulletWithLevel:(RRGLevel*)level
                               name:(NSString*)name
                              owner:(RRGCharacter*)owner;
-(void)shootToDirection:(CGPoint)direction
          fromTileCoord:(CGPoint)tileCoord;
-(void)magicActionToObject:(RRGLevelObject*)object;
@end

//collide with Character
@interface BulletOfSleeping : RRGMagicBullet
@end
@interface BulletOfConfusion : RRGMagicBullet
@end
@interface BulletOfParalysis : RRGMagicBullet
@end
@interface BulletOfPygmy : RRGMagicBullet
@end
@interface BulletOfSloth : RRGMagicBullet
@end
@interface BulletOfSloth2 : RRGMagicBullet
@end
@interface BulletOfDeath : RRGMagicBullet
@end
@interface BulletOfPowerDown : RRGMagicBullet
@end
@interface BulletOfPowerDownAndDefenseDown : RRGMagicBullet
@end
@interface BulletOfProgress : RRGMagicBullet
@end
@interface BulletOfRegress : RRGMagicBullet
@end
@interface BulletOfJumping : RRGMagicBullet
@end

//collide With Object
@interface RRGMagicBulletCollideWithObject : RRGMagicBullet
@end
@interface BulletOfTamara : RRGMagicBulletCollideWithObject
@end
@interface BulletOfTeleportation : RRGMagicBulletCollideWithObject
@end
@interface BulletOfBlowback : RRGMagicBulletCollideWithObject
@end
@interface BulletOfPulling : RRGMagicBulletCollideWithObject
@end
@interface BulletOfSwitching : RRGMagicBulletCollideWithObject
@end