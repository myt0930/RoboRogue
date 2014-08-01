//
//  RRGLabelLayer.m
//  RoboRogue
//
//  Created by 山本政徳 on 2014/06/15.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "RRGLabelLayer.h"
#import "RRGPlayer.h"
#import "RRGAction.h"

#import "RRGLevel.h"
#import "RRGLevel+TurnSequence.h"

@interface RRGLabelLayer ()
@property (nonatomic, weak) RRGLevel* level;
@property (nonatomic, weak, readonly) RRGPlayer* player;

@property (nonatomic) CCLabelBMFont* playerHPLabel;
@property (nonatomic) CCLabelBMFont* playerMaxHPLabel;
@property (nonatomic) CCLabelBMFont* playerLevelLabel;
@end

@implementation RRGLabelLayer
-(RRGPlayer*)player
{
    return self.level.player;
}
+(instancetype)layerWithSize:(CGSize)size
                       level:(RRGLevel *)level
                    floorNum:(NSUInteger)floorNum
             displayFloorNum:(BOOL)displayFloorNum
{
    return [[self alloc] initWithSize:size
                                level:level
                             floorNum:floorNum
                      displayFloorNum:displayFloorNum];
}
-(instancetype)initWithSize:(CGSize)size
                      level:(RRGLevel*)level
                   floorNum:(NSUInteger)floorNum
            displayFloorNum:(BOOL)displayFloorNum
{
    self = [super init];
    if (self) {
        _contentSize = size;
        
        self.level = level;
        
        //floorNum label
        if (displayFloorNum) {
            NSString* str = [NSString stringWithFormat:@"%tuF", floorNum];
            CCLabelBMFont* floorNumLabel = [CCLabelBMFont labelWithString:str
                                                                  fntFile:@"font.fnt"];
            floorNumLabel.anchorPoint = ccp(0,1);
            floorNumLabel.positionType = CCPositionTypeNormalized;
            floorNumLabel.position = ccp(0,1);
            [self addChild:floorNumLabel];
        }
        
        CCLabelBMFont* slashLabel = [CCLabelBMFont labelWithString:@"/"
                                                           fntFile:@"font.fnt"];
        slashLabel.anchorPoint = ccp(.5f,1.0f);
        slashLabel.positionType = CCPositionTypeNormalized;
        slashLabel.position = ccp(.5f,1.0f);
        [self addChild:slashLabel];
        
        //HP label
        _playerHPLabel = [CCLabelBMFont
                          labelWithString:[NSString stringWithFormat:@"%tu",self.player.HP]
                          fntFile:@"font.fnt"];
        _playerHPLabel.anchorPoint = ccp(1,1);
        _playerHPLabel.position = ccpAdd(slashLabel.positionInPoints, ccp(-10,0));
        [self addChild:_playerHPLabel];
        
        //maxHP label
        _playerMaxHPLabel = [CCLabelBMFont
                             labelWithString:[NSString stringWithFormat:@"%tu",self.player.maxHP]
                             fntFile:@"font.fnt"];
        _playerMaxHPLabel.anchorPoint = ccp(0,1);
        _playerMaxHPLabel.position = ccpAdd(slashLabel.positionInPoints, ccp(10,0));
        [self addChild:_playerMaxHPLabel];
        
        //level label
        _playerLevelLabel = [CCLabelBMFont
                             labelWithString:[NSString stringWithFormat:@"Lv.%tu",
                                              self.player.characterLevel]
                             fntFile:@"font.fnt"];
        _playerLevelLabel.anchorPoint = ccp(.5f, 1.0f);
        _playerLevelLabel.positionType = CCPositionTypeNormalized;
        _playerLevelLabel.position = ccp(.25f, 1.0f);
        [self addChild:_playerLevelLabel];
    }
    return self;
}
-(void)dealloc
{
    CCLOG(@"%s", __PRETTY_FUNCTION__);
}
-(void)setPlayerHPString:(NSUInteger)HP
{
    CCLOG(@"setPlayerHPString:%tu", HP);
    [self.playerHPLabel setString:[NSString stringWithFormat:@"%tu",HP]];
}
-(void)setPlayerMaxHPString:(NSUInteger)maxHP
{
    CCLOG(@"setPlayerMaxHPString:%tu", maxHP);
    [self.playerMaxHPLabel setString:[NSString stringWithFormat:@"%tu",maxHP]];
}
-(void)setPlayerLevelString:(NSUInteger)level
{
    CCLOG(@"setPlayerLevelString:%tu", level);
    [self.playerLevelLabel setString:[NSString stringWithFormat:@"Lv.%tu",level]];
}
#pragma mark - update state
-(void)updateLevelState:(NSUInteger)state
{
    switch (state) {
        case LevelStateGameOver:
        {
            _visible = NO;
            break;
        }
        default:
        {
            _visible = YES;
            break;
        }
    }
}
@end