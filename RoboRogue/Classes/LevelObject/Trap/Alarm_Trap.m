//
//  Alarm_Trap.m
//  RoboRogue
//
//  Created by 山本政徳 on 2014/05/22.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "Alarm_Trap.h"
#import "RRGCategories.h"
#import "RRGActionCache.h"
#import "RRGSavedDataHandler.h"
#import "RRGAction.h"
#import "RRGPlayer.h"

#import "RRGLevel.h"
#import "RRGLevel+TurnSequence.h"

@implementation Alarm_Trap
-(void)trapActionToCharacter:(RRGCharacter*)character
{
    if ([self.level inView:self.tileCoord]) {
        [self.level addAction:[CCActionSoundEffect actionWithSoundFile:@"alarmClock.caf"]];
        
        CCSprite* sprite = [CCSprite spriteWithImageNamed:@"alarm0001.png"];
        CGSize viewSize = [CCDirector sharedDirector].viewSize;
        sprite.position = ccp(viewSize.width * .5f, viewSize.height * .5f + 100);
        
        __weak RRGLevel* weakLevel = self.level;
        [self.level addAction:[CCActionCallBlock actionWithBlock:^{
            [weakLevel addChild:sprite z:ZOrderTiledMap + 1];
        }]];
        
        CCActionAnimate* animate = [sharedActionCache
                                    animateWithFormat:@"alarm%04tu.png"
                                    frameCount:4
                                    delay:DelayAnimation];
        CCActionRepeat* repeat = [CCActionRepeat actionWithAction:animate
                                                            times:3];
        [self.level addAction:[RRGAction actionWithTarget:sprite
                                                   action:repeat]];
        [self.level addAction:[RRGAction actionWithTarget:sprite
                                                   action:[CCActionRemove action]]];
    }
    
    
    for (RRGCharacter* character in self.level.characters) {
        if (![character isKindOfClass:[RRGPlayer class]]) {
            [character removeAllStatusWithSound:NO message:NO];
        }
    }
    [self.level addMessage:@"All monsters woke up."];
}
@end