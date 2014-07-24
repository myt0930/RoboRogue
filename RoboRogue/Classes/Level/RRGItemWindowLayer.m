//
//  RRGItemWindow.m
//  RoboRogue
//
//  Created by 山本政徳 on 2014/04/03.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "RRGItemWindowLayer.h"
#import "cocos2d-ui.h"
#import "RRGWindow.h"
#import "RRGButton.h"
#import "RRGItem.h"
#import "RRGPlayer.h"
#import "RRGCategories.h"
#import "RRGStaff.h"
#import "RRGPotion.h"
#import "RRGScroll.h"
#import "RRGSword.h"
#import "RRGShield.h"
#import "RRGAmulet.h"

#import "RRGLevel.h"
#import "RRGLevel+AddObject.h"
#import "RRGLevel+TurnSequence.h"

static const NSUInteger ItemButtonWidth = 200;
static const NSUInteger ItemWindowWidth = 280;

@interface RRGItemWindowLayer ()
@property (nonatomic, weak) RRGLevel* level;
@property (nonatomic, weak, readonly) RRGPlayer* player;

@property (nonatomic) CCButton* sortButton;

@property (nonatomic) RRGWindow* itemWindow;
@property (nonatomic) RRGWindow* commandWindow;
@property (nonatomic) RRGWindow* infoWindow;

@property (nonatomic) RRGButton* selectedButton;
@property (nonatomic) RRGItem* selectedItem;

@property (nonatomic) CGPoint itemWindowScrollPosition;
@end

@implementation RRGItemWindowLayer
-(RRGPlayer*)player
{
    return self.level.player;
}
+(instancetype)layerWithSize:(CGSize)size
                       level:(RRGLevel *)level
{
    return [[self alloc] initWithSize:size
                                level:level];
}
-(instancetype)initWithSize:(CGSize)size
                      level:(RRGLevel*)level
{
    self = [super init];
    if (self) {
        _contentSize = size;
        self.level = level;
        
        //sort button
        CCSpriteFrame* frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"button.png"];
        CCSpriteFrame* frameP = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"buttonP.png"];
        _sortButton = [CCButton buttonWithTitle:@"Sort"
                                    spriteFrame:frame
                         highlightedSpriteFrame:frameP
                            disabledSpriteFrame:frame];
        [_sortButton setTarget:self
                      selector:@selector(sortButtonPressed)];
        _sortButton.anchorPoint = ccp(0,1);
        _sortButton.positionType = CCPositionTypeNormalized;
        _sortButton.position = ccp(0,1);
        
        __weak RRGItemWindowLayer* weakSelf = self;
        _sortButton.block = ^(id sender){
            [[OALSimpleAudio sharedInstance] playEffect:@"sort.caf"];
            [weakSelf.player sortItems];
            weakSelf.selectedItem = nil;
            weakSelf.selectedButton = nil;
            if ([weakSelf.itemWindow isKindOfClass:[RRGScrollWindow class]]) {
                ((RRGScrollWindow*)weakSelf.itemWindow).scrollPosition = CGPointZero;
            }
            [weakSelf update];
        };
        [self addChild:_sortButton];
        
        _itemWindowScrollPosition = CGPointZero;
        
        [self update];
    }
    return self;
}
-(void)dealloc
{
    CCLOG(@"%s", __PRETTY_FUNCTION__);
}
#pragma mark - update
-(void)update
{
    if ([_itemWindow isKindOfClass:[RRGScrollWindow class]]) {
        _itemWindowScrollPosition = ((RRGScrollWindow*)_itemWindow).scrollPosition;
    }
    [self updateItemWindow];
    [self updateCommandWindow];
}
-(void)updateItemWindow
{
    CCLOG(@"%s", __PRETTY_FUNCTION__);
    
    CCLayoutBox* layoutBox = [[CCLayoutBox alloc] init];
    layoutBox.direction = CCLayoutBoxDirectionVertical;
    
    NSArray* items = [self.player.items reverseArray];
    
    for (RRGItem* item in items) {
        RRGButton* button = [self itemButtonForItem:item];
        button.togglesSelectedState = YES;
        if (_selectedItem == item) {
            CCLOG(@"selectedItem is this");
            _selectedButton = button;
            _selectedButton.selected = YES;
        }
        __weak RRGItemWindowLayer* weakSelf = self;
        button.block = ^(id sender){
            weakSelf.selectedButton.selected = NO;
            weakSelf.selectedButton = sender;
            weakSelf.selectedButton.selected = YES;
            weakSelf.selectedItem = item;
            [weakSelf updateCommandWindow];
        };
        [layoutBox addChild:button];
    }
    
    if (layoutBox.contentSize.height > [RRGWindow contentNodeHeightForHeight:_contentSize.height]) {
        //scroll window
        [_itemWindow removeFromParentAndCleanup:YES];
        _itemWindow = [RRGScrollWindow
                       windowWithSize:CGSizeMake(ItemWindowWidth, _contentSize.height)
                       content:layoutBox
                       button:YES];
        _itemWindow.anchorPoint = CGPointZero;
        _itemWindow.position = ccp(_sortButton.contentSize.width, 0);
        ((RRGScrollWindow*)_itemWindow).scrollPosition = _itemWindowScrollPosition;
        [self addChild:_itemWindow];
    } else {
        //normal window
        [_itemWindow removeFromParentAndCleanup:YES];
        _itemWindow = [RRGWindow
                       windowWithSize:CGSizeMake(ItemWindowWidth, _contentSize.height)];
        _itemWindow.anchorPoint = CGPointZero;
        _itemWindow.position = ccp(_sortButton.contentSize.width, 0);
        [self addChild:_itemWindow];
        [_itemWindow addContent:layoutBox];
    }
}
-(void)updateCommandWindow
{
    CCLOG(@"%s", __PRETTY_FUNCTION__);
    [_commandWindow removeFromParentAndCleanup:YES];
    [_infoWindow removeFromParentAndCleanup:YES];
    
    if (_selectedItem == nil) return;
    
    CCLayoutBox* layoutBox = [[CCLayoutBox alloc] init];
    layoutBox.direction = CCLayoutBoxDirectionVertical;
    
    //description
    [layoutBox addChild:[self descriptionButton:_selectedItem]];
    
    //put or swap
    id obj = [self.level objectAtTileCoord:self.player.tileCoord];
    if (obj) {
        if ([obj isKindOfClass:[RRGItem class]]) {
            [layoutBox addChild:[self swapButton:_selectedItem]];
        }
    } else {
        [layoutBox addChild:[self putButton:_selectedItem]];
    }
    
    //throw
    [layoutBox addChild:[self throwButton:_selectedItem]];
    
    //equip or unequip
    if ([_selectedItem isKindOfClass:[RRGItemEquipment class]]) {
        RRGItemEquipment* equipment = (RRGItemEquipment*)_selectedItem;
        if (equipment.equipped) {
            [layoutBox addChild:[self unequipButton:equipment]];
        } else {
            [layoutBox addChild:[self equipButton:equipment]];
        }
    }
    
    //use
    if ([_selectedItem isKindOfClass:[RRGItemUseOnce class]]) {
        [layoutBox addChild:[self useButton:(RRGItemUseOnce*)_selectedItem]];
    }
    
    //subweapon
    //wave
    if ([_selectedItem isKindOfClass:[RRGStaff class]]) {
        [layoutBox addChild:[self waveButton:(RRGStaff*)_selectedItem]];
    }
    
    _commandWindow = [RRGWindow windowWithContent:layoutBox];
    _commandWindow.anchorPoint = ccp(0,1);
    _commandWindow.position = ccp(_itemWindow.position.x + _itemWindow.contentSize.width,
                                  _contentSize.height);
    [self addChild:_commandWindow];
    
    if (_selectedItem.itemInfo) {
        CCLabelTTF* label = [CCLabelTTF labelWithString:_selectedItem.itemInfo
                                               fontName:@"Helvetica"
                                               fontSize:17];
        label.dimensions = CGSizeMake(100, 0);
        _infoWindow = [RRGWindow windowWithContent:label];
        _infoWindow.anchorPoint = CGPointZero;
        _infoWindow.position = ccp(_itemWindow.position.x + _itemWindow.contentSize.width,
                                   0);
        [self addChild:_infoWindow];
    }
}
#pragma mark - button
-(RRGButton*)itemButtonForItem:(RRGItem*)item
{
    CCSprite* icon = [CCSprite spriteWithImageNamed:
                      [NSString stringWithFormat:@"%@/icon.png",
                       [item spriteFolderName]]];
    
    BOOL equipped = NO;
    if ([item isKindOfClass:[RRGItemEquipment class]] &&
        ((RRGItemEquipment*)item).equipped) {
        equipped = YES;
    }
    RRGButton* button = [RRGButton buttonWithWidth:ItemButtonWidth
                                              icon:icon
                                             title:item.displayName
                                        labelColor:[CCColor whiteColor]];
    button.equipped = equipped;
    return button;
}
-(RRGButton*)menuButtonWithTitle:(NSString*)title
{
    RRGButton* button = [RRGButton buttonWithWidth:100
                                            icon:nil
                                           title:title];
    return button;
}
-(RRGButton*)useButton:(RRGItemUseOnce*)item
{
    NSString* labelString;
    if ([item isKindOfClass:[RRGPotion class]]) {
        labelString = @"Drink";
    } else if ([item isKindOfClass:[RRGScroll class]]) {
        labelString = @"Read";
    }
    RRGButton* button = [self menuButtonWithTitle:labelString];
    
    __weak RRGItemWindowLayer* weakSelf = self;
    button.block = ^(id sender){
        [weakSelf.level updateLevelState:LevelStateTurnInProgress];
        [weakSelf.player useItem:item];
        [weakSelf.level turnStartPhase];
    };
    return button;
}
-(RRGButton*)waveButton:(RRGStaff*)staff
{
    RRGButton* button = [self menuButtonWithTitle:@"Wave"];
    
    __weak RRGItemWindowLayer* weakSelf = self;
    button.block = ^(id sender){
        [weakSelf.level updateLevelState:LevelStateTurnInProgress];
        [weakSelf.player waveStaff:staff];
        [weakSelf.level turnStartPhase];
    };
    return button;
}
-(RRGButton*)equipButton:(RRGItemEquipment*)item
{
    __weak RRGItemWindowLayer* weakSelf = self;
    
    RRGButton* button = [self menuButtonWithTitle:@"Equip"];
    if ([item isKindOfClass:[RRGSword class]] ||
        [item isKindOfClass:[RRGShield class]] ||
        [item isKindOfClass:[RRGAmulet class]]) {
        
        button.block = ^(id sender){
            [weakSelf.level updateLevelState:LevelStateTurnInProgress];
            [weakSelf.player equipItem:item];
            [weakSelf.level turnStartPhase];
        };
    } else {
        button.block = ^(id sender){
            [weakSelf.player equipItem:item];
            [weakSelf update];
        };
    }
    return button;
}
-(RRGButton*)unequipButton:(RRGItemEquipment*)item
{
    __weak RRGItemWindowLayer* weakSelf = self;
    
    RRGButton* button = [self menuButtonWithTitle:@"Unequip"];
    if ([item isKindOfClass:[RRGSword class]] ||
        [item isKindOfClass:[RRGShield class]] ||
        [item isKindOfClass:[RRGAmulet class]]) {
        button.block = ^(id sender){
            [weakSelf.level updateLevelState:LevelStateTurnInProgress];
            [weakSelf.player unequipItem:item];
            [weakSelf.level turnStartPhase];
        };
    }else {
        button.block = ^(id sender){
            [weakSelf.player unequipItem:item];
            [weakSelf update];
        };
    }
    return button;
}
-(RRGButton*)throwButton:(RRGItem*)item
{
    RRGButton* button = [self menuButtonWithTitle:@"Throw"];
    __weak RRGItemWindowLayer* weakSelf = self;
    button.block = ^(id sender){
        [weakSelf.level updateLevelState:LevelStateTurnInProgress];
        [weakSelf.player throwItem:item];
        [weakSelf.level turnStartPhase];
    };
    return button;
}
-(RRGButton*)putButton:(RRGItem*)item
{
    RRGButton* button = [self menuButtonWithTitle:@"Put"];
    __weak RRGItemWindowLayer* weakSelf = self;
    button.block = ^(id sender){
        [weakSelf.level updateLevelState:LevelStateTurnInProgress];
        [weakSelf.player putOnItem:item];
        [weakSelf.level turnStartPhase];
    };
    return button;
}
-(RRGButton*)swapButton:(RRGItem*)item
{
    RRGButton* button = [self menuButtonWithTitle:@"Swap"];
    __weak RRGItemWindowLayer* weakSelf = self;
    button.block = ^(id sender){
        [weakSelf.level updateLevelState:LevelStateTurnInProgress];
        [weakSelf.player swapItem:item];
        [weakSelf.level turnStartPhase];
    };
    return button;
}
-(RRGButton*)descriptionButton:(RRGItem*)item
{
    RRGButton* button = [self menuButtonWithTitle:@"Description"];
    /*
    __weak RRGItemWindowLayer* weakSelf = self;
    button.block = ^(id sender){
        [self.player addAction:[self.player throwItem:item]];
        self.level.levelState = LevelStateTurnInProgress;
        [self.level updateState];
    };*/
    return button;
}
/*
#pragma mark - button callback
-(void)sortButtonPressed
{
    [[OALSimpleAudio sharedInstance] playEffect:@"sort.caf"];
    [self.player sortItems];
    _selectedItem = nil;
    _selectedButton = nil;
    if ([_itemWindow isKindOfClass:[RRGScrollWindow class]]) {
        ((RRGScrollWindow*)_itemWindow).scrollPosition = CGPointZero;
    }
    [self update];
}*/
@end