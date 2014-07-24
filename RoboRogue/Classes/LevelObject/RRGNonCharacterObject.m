//
//  RRGNonCharacterObject.m
//  RoboRogue
//
//  Created by 山本政徳 on 2014/07/01.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "RRGNonCharacterObject.h"
#import "RRGCharacter.h"
#import "RRGAction.h"
#import "RRGSavedDataHandler.h"
#import "RRGTiledMap.h"
#import "RRGFunctions.h"

#import "RRGLevel+AddObject.h"
#import "RRGLevel+Particle.h"
#import "RRGLevel+TurnSequence.h"
#import "RRGLevel+MapID.h"

@implementation RRGNonCharacterObject
-(void)setTileCoord:(CGPoint)tileCoord
{
    CCLOG(@"%@ at %@",[self displayName],NSStringFromCGPoint(tileCoord));
    
    [self.level setTileCoord:tileCoord
                    ofObject:self];
    
    [super setTileCoord:tileCoord];
}
#pragma mark - overwrite action
-(void)warpToRandomTileCoord
{
    CGPoint tileCoord = [self.level randomTileCoordForObjectExceptRoomNums:nil
                                                                 offScreen:NO];
    [self warpToTileCoord:tileCoord];
}
-(void)pulledToDirection:(CGPoint)direction
                maxTiles:(NSUInteger)maxTiles
             byCharacter:(RRGCharacter*)character
{
    CGPoint start = self.tileCoord;
    CGPoint end = self.tileCoord;
    
    BOOL bounce = NO;
    BOOL inView = [self.level inView:end];
    
    for (NSInteger i = 0; i < maxTiles; i++) {
        end = ccpAdd(end, direction);
        if ([self.level inView:end]) {
            inView = YES;
        }
        if ([self.level wallAtTileCoord:end]){
            //hit with wall
            end = ccpSub(end, direction);
            bounce = YES;
            break;
        } else if ([self.level characterAtTileCoord:end]) {
            //hit with character
            end = ccpSub(end, direction);
            bounce = YES;
            break;
        }
    }
    
    [self jumpActionFromStart:start
                          end:end
                    direction:direction
                       bounce:bounce
                       inView:inView];
    
    [self dropAtTileCoord:end];
}
-(void)dropAtTileCoord:(CGPoint)tileCoord
{
    //CCLOG(@"%s", __PRETTY_FUNCTION__);
    self.tileCoord = tileCoord;
    
    CGPoint end = [self tileCoordForDrop:tileCoord];
    //CCLOG(@"%@", NSStringFromCGPoint(end));
    
    BOOL inView = [self.level inView:tileCoord] || [self.level inView:end];
    
    if (CGPointEqualToPoint(end, CGPointZero)) {
        if (inView) {
            [self.level addMessage:[NSString stringWithFormat:@"%@ disappeared.",
                                    self.displayName]];
        }
        [self.level removeObject:self];
    } else {
        if (!CGPointEqualToPoint(end, tileCoord)) {
            if (inView) {
                [self.level addAction:[RRGAction
                                       actionWithTarget:self
                                       action:[self.tiledMap
                                               actionMoveByWithVelocity:VelocityJump
                                               fromTileCoord:tileCoord
                                               toTileCoord:end]]];
            } else {
                [self.level addAction:[RRGAction
                                       actionWithTarget:self
                                       action:[self.tiledMap
                                               actionPlaceToTileCoord:end]]];
            }
            self.tileCoord = end;
        }
    }
}
-(CGPoint)tileCoordForDrop:(CGPoint)tileCoord
{
    //CCLOG(@"%s", __PRETTY_FUNCTION__);
    for (NSInteger i = 0; i <= 24; i++) {
        CGPoint ret = funcTileCoordForDrop(tileCoord, i);
        if ([self canDropAtTileCoord:ret]) {
            return ret;
        }
    }
    return CGPointZero;
}
-(BOOL)canDropAtTileCoord:(CGPoint)tileCoord
{
    return ([self.level groundAtTileCoord:tileCoord] &&
            ([self.level objectAtTileCoord:tileCoord] == nil ||
             [self.level objectAtTileCoord:tileCoord] == self))?YES:NO;
}
CGPoint funcTileCoordForDrop(CGPoint tileCoord, NSInteger i)
{
    CGPoint add;
    switch (i) {
        case 0:
            add = CGPointZero;
            break;
        case 1:
            add = South;
            break;
        case 2:
            add = East;
            break;
        case 3:
            add = North;
            break;
        case 4:
            add = West;
            break;
        case 5:
            add = SouthEast;
            break;
        case 6:
            add = NorthEast;
            break;
        case 7:
            add = NorthWest;
            break;
        case 8:
            add = SouthWest;
            break;
        case 9:
            add = ccp(0,2);
            break;
        case 10:
            add = ccp(2,0);
            break;
        case 11:
            add = ccp(0,-2);;
            break;
        case 12:
            add = ccp(-2,0);
            break;
        case 13:
            add = ccp(1,2);
            break;
        case 14:
            add = ccp(2,1);
            break;
        case 15:
            add = ccp(2,-1);
            break;
        case 16:
            add = ccp(1,-2);
            break;
        case 17:
            add = ccp(-1,-2);
            break;
        case 18:
            add = ccp(-2,-1);
            break;
        case 19:
            add = ccp(-2,1);
            break;
        case 20:
            add = ccp(-1,2);
            break;
        case 21:
            add = ccp(2,2);
            break;
        case 22:
            add = ccp(2,-2);
            break;
        case 23:
            add = ccp(-2,-2);
            break;
        case 24:
            add = ccp(-2,2);
            break;
    }
    return ccpAdd(tileCoord, add);
}

-(void)transFormInto:(NSString*)name
      characterLevel:(NSUInteger)characterLevel
{
    [self.level removeObject:self];
    
    //new character
    RRGCharacter* character = [RRGCharacter levelObjectWithLevel:self.level
                                                            name:name
                                                        atRandom:NO];
    character.characterLevel = characterLevel;
    [self.level addCharacter:character atTileCoord:self.tileCoord];
    
    [self.level addParticleWithName:kParticleSmoke
                        atTileCoord:self.tileCoord
                              sound:YES];
}
@end