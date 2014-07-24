//
//  RRGButtonLayer.m
//  RoboRogue
//
//  Created by 山本政徳 on 2014/05/06.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "RRGButtonLayer.h"
#import "cocos2d-ui.h"
#import "RRGLevel.h"
#import "RRGLevel+TurnSequence.h"
#import "RRGPlayer.h"
#import "RRGStaff.h"
#import "RRGFunctions.h"

static NSString* const kStaffEquipped = @"staffEquipped";
static NSString* const kNumberOfMagicBullets = @"numberOfMagicBullets";

@interface RRGButtonLayer ()
@property (nonatomic,weak) RRGLevel* level;
@property (nonatomic,weak,readonly) RRGPlayer* player;

@property (nonatomic) CCNode* buttonNodeExceptMapButton;

@property (nonatomic) CCButton* attackButton;
@property (nonatomic) CCButton* actionButton;
@property (nonatomic) CCButton* changeDirectionButton;
@property (nonatomic) CCButton* itemButton;

@property (nonatomic) CCLayoutBox* subWeaponButtonBox;
@property (nonatomic) CCButton* staffButton;

@property (nonatomic) CCButton* mapButton;
@end

@implementation RRGButtonLayer
-(RRGPlayer*)player
{
    return self.level.player;
}
+(instancetype)layerWithSize:(CGSize)size
                       level:(RRGLevel *)level
             displayMapLayer:(BOOL)displayMapLayer
{
    return [[self alloc] initWithSize:size
                                level:level
                      displayMapLayer:displayMapLayer];
}
-(instancetype)initWithSize:(CGSize)size
                      level:(RRGLevel*)level
            displayMapLayer:(BOOL)displayMapLayer
{
    self = [super init];
    if (self) {
        _contentSize = size;
        
        self.level = level;
        
        self.buttonNodeExceptMapButton = [CCNode node];
        self.buttonNodeExceptMapButton.contentSize = size;
        [self addChild:self.buttonNodeExceptMapButton];
        
        //attack button
        CCSpriteFrame* spriteFrameAttack = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"attackButton.png"];
        CCSpriteFrame* spriteFrameAttackPressed = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"attackButtonP.png"];
        self.attackButton = [CCButton buttonWithTitle:@"Attack"
                                          spriteFrame:spriteFrameAttack
                               highlightedSpriteFrame:spriteFrameAttackPressed
                                  disabledSpriteFrame:spriteFrameAttack];
        [self.attackButton setTarget:self
                            selector:@selector(attackButtonPressed)];
        self.attackButton.anchorPoint = ccp(1,0);
        self.attackButton.positionType = CCPositionTypeNormalized;
        self.attackButton.position = ccp(1,0);
        [self.buttonNodeExceptMapButton addChild:self.attackButton];
        
        //change direction
        CCSpriteFrame* spriteFrameChangeDirection = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"changeDirectionButton.png"];
        CCSpriteFrame* spriteFrameChangeDirectionPressed = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"changeDirectionButtonP.png"];
        self.changeDirectionButton = [CCButton buttonWithTitle:@""
                                                   spriteFrame:spriteFrameChangeDirection
                                        highlightedSpriteFrame:spriteFrameChangeDirectionPressed
                                           disabledSpriteFrame:spriteFrameChangeDirection];
        [self.changeDirectionButton setTarget:self
                                     selector:@selector(changeDirectionButtonPressed)];
        self.changeDirectionButton.anchorPoint = ccp(1,0);
        self.changeDirectionButton.position = ccp(self.contentSize.width,
                                                  self.attackButton.contentSize.height);
        [self.buttonNodeExceptMapButton addChild:self.changeDirectionButton];
        
        //item button
        CCSpriteFrame* spriteFrameItemButton = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"button.png"];
        CCSpriteFrame* spriteFrameItemButtonPressed = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"buttonP.png"];
        self.itemButton = [CCButton buttonWithTitle:@"Item"
                                        spriteFrame:spriteFrameItemButton
                             highlightedSpriteFrame:spriteFrameItemButtonPressed
                                disabledSpriteFrame:spriteFrameItemButton];
        //self.itemButton.color = [CCColor blackColor];
        [self.itemButton setTarget:self
                          selector:@selector(itemButtonPressed)];
        self.itemButton.anchorPoint = CGPointZero;
        self.itemButton.positionType = CCPositionTypeNormalized;
        self.itemButton.position = CGPointZero;
        [self.buttonNodeExceptMapButton addChild:self.itemButton];
        
        //subWeaponButtonBox
        self.subWeaponButtonBox = [[CCLayoutBox alloc] init];
        self.subWeaponButtonBox.direction = CCLayoutBoxDirectionVertical;
        self.subWeaponButtonBox.anchorPoint = ccp(1,0);
        self.subWeaponButtonBox.position = ccp(self.contentSize.width,
                                               self.attackButton.contentSize.height
                                               + self.changeDirectionButton.contentSize.height);
        [self.buttonNodeExceptMapButton addChild:self.subWeaponButtonBox];
        
        [self updateSubWeaponButtons];
        
        //map button
        if (displayMapLayer) {
            CCSpriteFrame* spriteFrameMapButton = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"button.png"];
            CCSpriteFrame* spriteFrameMapButtonPressed = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"buttonP.png"];
            self.mapButton = [CCButton buttonWithTitle:@"Map"
                                           spriteFrame:spriteFrameMapButton
                                highlightedSpriteFrame:spriteFrameMapButtonPressed
                                   disabledSpriteFrame:spriteFrameMapButton];
            [self.mapButton setTarget:self
                             selector:@selector(mapButtonPressed)];
            self.mapButton.anchorPoint = ccp(1,1);
            self.mapButton.positionType = CCPositionTypeNormalized;
            self.mapButton.position = ccp(1,1);
            [self addChild:self.mapButton];
        }
    }
    return self;
}
-(void)dealloc
{
    CCLOG(@"%s", __PRETTY_FUNCTION__);
}
-(void)updateSubWeaponButtons
{
    [self.subWeaponButtonBox removeAllChildrenWithCleanup:YES];
    
    RRGStaff* staff = self.player.staffEquipped;
    if (staff) {
        CCSpriteFrame* spriteFrameSubWeaponButton = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"staffButton.png"];
        CCSpriteFrame* spriteFrameSubWeaponButtonPressed = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"staffButtonP.png"];
        NSString* title = [NSString stringWithFormat:@"[%zd]",
                           staff.numberToDisplay];
        self.staffButton = [CCButton buttonWithTitle:title
                                         spriteFrame:spriteFrameSubWeaponButton
                              highlightedSpriteFrame:spriteFrameSubWeaponButtonPressed
                                 disabledSpriteFrame:spriteFrameSubWeaponButton];
        [self.staffButton setTarget:self
                           selector:@selector(staffButtonPressed)];
        [self.subWeaponButtonBox addChild:self.staffButton];
    }
}
-(void)setStaffButtonNumber:(NSInteger)numberToDisplay
{
    [self.staffButton.label setString:[NSString stringWithFormat:@"[%zd]"
                                       ,numberToDisplay]];
}
#pragma mark - button callback
-(void)attackButtonPressed
{
    switch (self.level.levelState) {
        case LevelStateNormal:
        case LevelStateChangeDirection:
        case LevelStateShowingItemWindow:
        {
            CGPoint direction = self.player.direction;
            if ([self.player haveState:kStateConfusion]) {
                direction = randomDirection();
            }
            [self.level updateLevelState:LevelStateTurnInProgress];
            [self.player attackToDirection:direction];
            [self.level turnStartPhase];
            break;
        }
        default:
            break;
    }
}
-(void)changeDirectionButtonPressed
{
    switch (self.level.levelState) {
        case LevelStateNormal:
        case LevelStateChangeDirection:
        case LevelStateShowingItemWindow:
        {
            LevelState newState = (self.level.levelState == LevelStateChangeDirection)?
        LevelStateNormal:LevelStateChangeDirection;
            [self.level updateLevelState:newState];
            break;
        }
        default:
            break;
    }
}
-(void)itemButtonPressed
{
    switch (self.level.levelState) {
        case LevelStateNormal:
        case LevelStateChangeDirection:
        case LevelStateShowingItemWindow:
        {
            LevelState newState = (self.level.levelState == LevelStateShowingItemWindow)?
        LevelStateNormal:LevelStateShowingItemWindow;
            [self.level updateLevelState:newState];
            break;
        }
        default:
            break;
    }
}
-(void)mapButtonPressed
{
    switch (self.level.levelState) {
        case LevelStateNormal:
        case LevelStateChangeDirection:
        case LevelStateShowingItemWindow:
        {
            [self.level updateLevelState:LevelStateNormal];
            MapLayerState newState = self.level.mapLayerState + 1;
            if (newState > MapLayerStateHideMap) {
                newState = MapLayerStateShowMap;
            }
            [self.level updateMapLayerState:newState];
            break;
        }
        default:
            break;
    }
}
-(void)staffButtonPressed
{
    switch (self.level.levelState) {
        case LevelStateNormal:
        case LevelStateChangeDirection:
        case LevelStateShowingItemWindow:
        {
            [self.level updateLevelState:LevelStateTurnInProgress];
            RRGStaff* staff = self.player.staffEquipped;
            [self.player waveStaff:staff];
            [self.level turnStartPhase];
            break;
        }
        default:
            break;
    }
}
#pragma mark - update state
-(void)updateLevelState:(NSUInteger)state
{
    switch (state) {
        case LevelStateShowingModalLayer:
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
-(void)updateMapLayerState:(NSUInteger)state
{
    switch (state) {
        case MapLayerStateShowOnlyMap:
        {
            self.buttonNodeExceptMapButton.visible = NO;
            break;
        }
        default:
        {
            self.buttonNodeExceptMapButton.visible = YES;
            break;
        }
    }
}
@end