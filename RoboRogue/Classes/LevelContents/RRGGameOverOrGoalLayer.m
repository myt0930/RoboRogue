//
//  RRGGameOverLayer.m
//  RoboRogue
//
//  Created by 山本政徳 on 2014/07/16.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "RRGGameOverOrGoalLayer.h"
#import "RRGWindow.h"
#import "RRGPlayer.h"
#import "RRGGameScene.h"
#import "RRGCategories.h"
#import "RRGSword.h"
#import "RRGShield.h"
#import "RRGAmulet.h"

#import "RRGLevel.h"

static NSString* const kHelvetica = @"Helvetica";
static CGFloat const fontSize = 17;

@interface RRGGameOverOrGoalLayer ()
@property (nonatomic) RRGWindow* window;
@property (nonatomic, weak) RRGLevel* level;
@property (nonatomic, readonly) RRGPlayer* player;

-(instancetype)initWithLevel:(RRGLevel*)level;
-(void)addLevelLabel;
-(void)didFinishScrollWindow;
@end

@implementation RRGGameOverOrGoalLayer
+(instancetype)layerWithLevel:(RRGLevel*)level
{
    return [[self alloc] initWithLevel:level];
}
-(instancetype)initWithLevel:(RRGLevel*)level
{
    self = [super init];
    if (self) {
        CGSize viewSize = [CCDirector sharedDirector].viewSize;
        _contentSize = viewSize;
        
        _window = [RRGWindow windowWithSize:viewSize];
        _window.position = ccp(0,viewSize.height * -1);
        [self addChild:_window];
        
        self.level = level;
    }
    return self;
}
-(void)dealloc
{
    CCLOG(@"%s", __PRETTY_FUNCTION__);
}
-(void)addLevelLabel
{
    [_window addLine];
    
    NSString* levelString = [NSString stringWithFormat:
                             @"Lv.%tu Exp:%tu",
                             self.player.characterLevel,
                             self.player.experience];
    [_window addMessage:levelString];
    
    [self addEquipmentLabelWithEquipment:self.player.swordEquipped
                              folderName:@"Sword"];
    [self addEquipmentLabelWithEquipment:self.player.shieldEquipped
                              folderName:@"Shield"];
    if (self.player.amuletEquipped) {
        [self addEquipmentLabelWithEquipment:self.player.amuletEquipped
                                  folderName:@"Amulet"];
    }
}
-(void)addEquipmentLabelWithEquipment:(RRGItemEquipment*)equipment
                           folderName:(NSString*)folderName
{
    CCNode* box = [CCNode node];
    box.contentSize = CGSizeMake(100, 30);
    CCSprite* icon = [CCSprite spriteWithImageNamed:
                      [NSString stringWithFormat:@"%@/icon.png",folderName]];
    icon.position = ccp(15,15);
    [box addChild:icon];
    NSString* str = @"none";
    if (equipment) {
        str = equipment.displayName;
    }
    CCLabelTTF* label = [CCLabelTTF labelWithString:str
                                           fontName:kHelvetica
                                           fontSize:fontSize];
    label.anchorPoint = ccp(0,.5f);
    label.position = ccp(30,15);
    [box addChild:label];
    [_window addContent:box];
}
-(void)onEnterTransitionDidFinish
{
    [super onEnterTransitionDidFinish];
    [self scrollWindow];
}
-(void)scrollWindow
{
    //CCLOG(@"%s", __PRETTY_FUNCTION__);
    CCActionDelay* delay = [CCActionDelay actionWithDuration:1.0f];
    CCActionMoveBy* move = [CCActionMoveBy
                            actionWithDuration:1.0f
                            position:ccp(0,_window.contentSize.height)];
    __weak RRGGameOverOrGoalLayer* weakSelf = self;
    CCActionCallBlock* block = [CCActionCallBlock actionWithBlock:^{
        [weakSelf didFinishScrollWindow];
        weakSelf.userInteractionEnabled = YES;
    }];
    [_window runAction:[CCActionSequence actions:delay, move, block, nil]];
}
-(void)didFinishScrollWindow
{}
-(RRGPlayer*)player
{
    return self.level.player;
}
@end

#pragma mark - GameOverLayer

@implementation RRGGameOverLayer
-(instancetype)initWithLevel:(RRGLevel *)level
{
    self = [super initWithLevel:level];
    if (self) {
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
                    floorNum = [NSString stringWithFormat:@"%tuth",self.level.floorNum];
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
        [self.window addMessage:message];
        
        [self addLevelLabel];
    }
    return self;
}
-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    self.userInteractionEnabled = NO;
    self.window.visible = NO;
    [sharedGameScene goToInitialDungeon];
}
@end

#pragma mark - Goal Layer

@implementation RRGGoalLayer
-(instancetype)initWithLevel:(RRGLevel *)level
{
    self = [super initWithLevel:level];
    if (self) {
        NSString* message = [NSString stringWithFormat:
                             @"%@ arrived at the goal of %@.",
                             self.player.displayName,
                             self.level.dungeonName];
        [self.window addMessage:message];
        
        [self addLevelLabel];
    }
    return self;
}
-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    [self removeFromParent];
    [sharedGameScene goToInitialDungeon];
}
-(void)didFinishScrollWindow
{
    [[OALSimpleAudio sharedInstance] playEffect:@"levelUp.caf"];
}
@end