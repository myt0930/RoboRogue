//
//  RRGGameOverLayer.m
//  RoboRogue
//
//  Created by 山本政徳 on 2014/07/16.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "RRGGameOverLayer.h"
#import "RRGWindow.h"
#import "RRGPlayer.h"
#import "RRGGameScene.h"

#import "RRGLevel.h"

@interface RRGGameOverLayer ()
@property (nonatomic) RRGWindow* window;
@property (nonatomic, weak) RRGLevel* level;
@property (nonatomic, weak, readonly) RRGPlayer* player;
@end

@implementation RRGGameOverLayer
-(RRGPlayer*)player
{
    return self.level.player;
}
+(instancetype)layerWithViewSize:(CGSize)viewSize
                           level:(RRGLevel *)level
{
    return [[self alloc] initWithViewSize:viewSize
                                    level:level];
}
-(instancetype)initWithViewSize:(CGSize)viewSize
                          level:(RRGLevel*)level
{
    self = [super init];
    if (self) {
        _contentSize = viewSize;
        
        self.level = level;
        
        _window = [RRGWindow windowWithSize:viewSize];
        _window.position = ccp(0,viewSize.height * -1);
        [self addChild:_window];
        
        NSString* message = [NSString stringWithFormat:
                             @"%@ was destroyed",self.player.displayName];
        
        if (self.player.killer) {
            message = [message stringByAppendingString:
                       [NSString stringWithFormat:@" by %@",
                        self.player.killer.displayName]];
        }
        
        if (self.level.displayFloorNum) {
            NSString* floorNum;
            switch (self.level.floorNum) {
                case 1:
                    floorNum = @"1st";
                    break;
                case 2:
                    floorNum = @"2nd";
                    break;
                case 3:
                    floorNum = @"3rd";
                    break;
                default:
                    floorNum = [NSString stringWithFormat:@"%tuth",floorNum];
                    break;
            }
            message = [message stringByAppendingString:
                       [NSString stringWithFormat:@" in the %@ floor of %@.",
                        floorNum, self.level.dungeonName]];
        } else {
            message = [message stringByAppendingString:
                       [NSString stringWithFormat:@" in %@.",
                        self.level.dungeonName]];
        }
        [_window addMessage:message];
        
        [_window addLine];
        
        NSString* levelString = [NSString stringWithFormat:
                                 @"Lv.%tu Exp:%tu",
                                 self.player.characterLevel,
                                 self.player.experience];
        [_window addMessage:levelString];
    }
    return self;
}
-(void)dealloc
{
    CCLOG(@"%s", __PRETTY_FUNCTION__);
}
-(void)scrollWindow
{
    CCLOG(@"%s", __PRETTY_FUNCTION__);
    CCActionDelay* delay = [CCActionDelay actionWithDuration:1.0f];
    CCActionMoveBy* move = [CCActionMoveBy
                            actionWithDuration:1.0f
                            position:ccp(0,_window.contentSize.height)];
    __weak RRGGameOverLayer* weakSelf = self;
    CCActionCallBlock* block = [CCActionCallBlock actionWithBlock:^{
        weakSelf.userInteractionEnabled = YES;
    }];
    [_window runAction:[CCActionSequence actions:delay, move, block, nil]];
}
-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    self.userInteractionEnabled = NO;
    _window.visible = NO;
    [sharedGameScene goToInitialDungeon];
}
@end