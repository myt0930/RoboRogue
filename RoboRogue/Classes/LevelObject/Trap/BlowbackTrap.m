//
//  BlowbackTrap.m
//  RoboRogue
//
//  Created by 山本政徳 on 2014/03/30.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "BlowbackTrap.h"
#import "RRGCategories.h"
#import "RRGFunctions.h"
#import "RRGAction.h"
#import "RRGCharacter.h"

#import "RRGLevel+TurnSequence.h"
#import "RRGLevel+AddObject.h"

@implementation BlowbackTrap
#pragma mark - NSCoding
-(instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        decodeCGPoint(self.direction);
        [self updateObjectSprite];
    }
    return self;
}
- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    encodeCGPoint(self.direction);
}

//designated initializer
-(instancetype)initWithDirection:(CGPoint)direction
{
    self = [super init];
    if (self) {
        _direction = direction;
        [self updateObjectSprite];
    }
    return self;
}
-(instancetype)init
{
    return [self initWithDirection:South];
}
-(void)setRandomAttributes
{
    [super setRandomAttributes];
    _direction = randomDirection();
    [self updateObjectSprite];
}
-(void)updateObjectSprite
{
    NSString* spriteName = [NSString stringWithFormat:@"%@/%@/0001.png",
                            [self spriteFolderName],
                            directionString(self.direction)];
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
-(void)trapActionToCharacter:(RRGCharacter*)character
{
    if (character == nil) return;
    
    [self.level addAction:[CCActionSoundEffect actionWithSoundFile:@"blowback.caf"]];
    
    [character blowbackToDirection:self.direction
                          maxTiles:10
                       byCharacter:nil];
}
@end