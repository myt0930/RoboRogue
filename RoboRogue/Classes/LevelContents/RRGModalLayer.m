//
//  RRGModalWindow.m
//  RoboRogue
//
//  Created by 山本政徳 on 2014/07/10.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "RRGModalLayer.h"
#import "RRGLevel.h"
#import "RRGWindow.h"
#import "RRGButton.h"
#import "RRGClippingNode.h"
#import "RRGActionCache.h"
#import "RRGAction.h"

static NSString* const kModalLayerLabelMove = @"modalLayerLabelMove";

static NSString* const kMessage = @"message";
static NSString* const kOpt1Message = @"opt1Message";
static NSString* const kOpt2Message = @"opt2Message";
static NSString* const kOpt1Actions = @"opt1Actions";
static NSString* const kOpt2Actions = @"opt2Actions";

//prefix
static NSString* const kLabelPrefix = @"Label:";
static NSString* const kGotoPrefix = @"Goto:";

@interface RRGModalLayer ()
@property (nonatomic, weak) RRGLevel* level;

@property (nonatomic) RRGClippingWindow* window;
@property (nonatomic) RRGWindow* optWindow;

@property (nonatomic) NSMutableArray* actionQueue;
@property (nonatomic) NSMutableDictionary* labelActions;
@end

@implementation RRGModalLayer
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
        self.level = level;
        
        _contentSize = viewSize;
        _visible = NO;
        
        //create window
        CGSize windowSize = CGSizeMake(viewSize.width, viewSize.height * .25f);
        _window = [RRGClippingWindow windowWithSize:windowSize];
        [self addChild:_window];
        
        _labelActions = [NSMutableDictionary dictionary];
    }
    return self;
}
-(void)dealloc
{
    CCLOG(@"%s", __PRETTY_FUNCTION__);
}
#pragma mark - show and hide
-(void)showModalLayerWithActions:(NSArray*)actions
{
    CCLOG(@"%s", __PRETTY_FUNCTION__);
    
    [self.level updateLevelState:LevelStateShowingModalLayer];
    
    _actionQueue = [actions mutableCopy];
    _visible = YES;
    [self runAction];
}
-(void)showModalLayerWithMessage:(NSString *)message
                     opt1Message:(NSString *)opt1Message
                     opt1Actions:(NSArray *)opt1Actions
                     opt2Message:(NSString *)opt2Message
                     opt2Actions:(NSArray *)opt2Actions
{
    CCLOG(@"%s", __PRETTY_FUNCTION__);
    
    NSArray* array = @[@{kMessage: message,
                         kOpt1Message: opt1Message,
                         kOpt1Actions: opt1Actions,
                         kOpt2Message: opt2Message,
                         kOpt2Actions: opt2Actions}];
    [self showModalLayerWithActions:array];
}
-(void)hide
{
    CCLOG(@"%s", __PRETTY_FUNCTION__);
    [_actionQueue removeAllObjects];
    [_window removeAllContents];
    _visible = NO;
}
-(void)runAction
{
    CCLOG(@"%s", __PRETTY_FUNCTION__);
    
    [_optWindow removeFromParentAndCleanup:YES];
    
    if ([_actionQueue count] == 0) {
        [self hide];
        return;
    }
    
    id action = _actionQueue[0];
    [_actionQueue removeObjectAtIndex:0];
    
    if ([action isKindOfClass:[NSString class]]) {
        NSString* message = (NSString*)action;
        if ([message hasPrefix:kLabelPrefix]) {
            // label
            CCLOG(@"label action");
            NSString* key = [message stringByReplacingOccurrencesOfString:kLabelPrefix
                                                               withString:@""];
            [_labelActions setObject:[_actionQueue copy]
                              forKey:key];
            [self runAction];
        } else if ([message hasPrefix:kGotoPrefix]) {
            // go to label
            CCLOG(@"go to label");
            NSString* key = [message stringByReplacingOccurrencesOfString:kGotoPrefix
                                                               withString:@""];
            NSArray* actions = _labelActions[key];
            NSAssert(actions != nil, @"Invalid label %@", key);
            _actionQueue = [actions mutableCopy];
            [self runAction];
        } else {
            // show message
            CCLOG(@"show message");
            __weak RRGModalLayer* weakSelf = self;
            CCActionSequence* seq = [CCActionSequence actions:
                                     [self actionShowMessage:message],
                                     [CCActionCallBlock actionWithBlock:^{
                weakSelf.userInteractionEnabled = YES;
            }],
                                     nil];
            [self runAction:seq];
        }
    } else if ([action isKindOfClass:[NSDictionary class]]) {
        CCLOG(@"show options");
        NSDictionary* dict = (NSDictionary*)action;
        NSString* message = dict[kMessage];
        NSString* opt1Message = dict[kOpt1Message];
        NSString* opt2Message = dict[kOpt2Message];
        NSArray* opt1Actions = dict[kOpt1Actions];
        NSArray* opt2Actions = dict[kOpt2Actions];
        
        CCLabelTTF* opt1Label = [CCLabelTTF labelWithString:opt1Message
                                                   fontName:@"Helvetica"
                                                   fontSize:17];
        CCLabelTTF* opt2Label = [CCLabelTTF labelWithString:opt2Message
                                                   fontName:@"Helvetica"
                                                   fontSize:17];
        CGFloat width = MAX(MAX(opt1Label.contentSize.width,
                                opt2Label.contentSize.width),
                            100);
        RRGButton* opt1Button = [RRGButton buttonWithWidth:width
                                                      icon:nil
                                                     title:opt1Message];
        RRGButton* opt2Button = [RRGButton buttonWithWidth:width
                                                      icon:nil
                                                     title:opt2Message];
        __weak RRGModalLayer* weakSelf = self;
        opt1Button.block = ^(id sender){
            weakSelf.actionQueue = [opt1Actions mutableCopy];
            [weakSelf runAction];
        };
        opt2Button.block = ^(id sender){
            weakSelf.actionQueue = [opt2Actions mutableCopy];
            [weakSelf runAction];
        };
        
        CCLayoutBox* layoutBox = [[CCLayoutBox alloc] init];
        layoutBox.direction = CCLayoutBoxDirectionVertical;
        [layoutBox addChild:opt2Button];
        [layoutBox addChild:opt1Button];
        
        _optWindow = [RRGWindow windowWithContent:layoutBox];
        _optWindow.anchorPoint = ccp(1,0);
        _optWindow.position = ccp(_window.contentSize.width,
                                  _window.contentSize.height);
        
        CCActionSequence* seq = [CCActionSequence actions:
                                 [self actionShowMessage:message],
                                 [CCActionCallBlock actionWithBlock:^{
            [weakSelf addChild:_optWindow];
        }],
                                 nil];
        [self runAction:seq];
    } else if ([action isKindOfClass:[CCActionFiniteTime class]]) {
        CCLOG(@"run CCAction %@", NSStringFromClass([action class]));
        //CCAction
        CCActionFiniteTime* ccAction = (CCActionFiniteTime*)action;
        CCActionSequence* seq = [CCActionSequence actions:
                                 ccAction,
                                 [CCActionCallFunc actionWithTarget:self
                                                           selector:@selector(runAction)],
                                 nil];
        [self runAction:seq];
    } else if ([action isKindOfClass:[NSNumber class]]) {
        CCLOG(@"hide");
        //hide
        NSNumber* number = (NSNumber*)action;
        LevelState levelState = [number integerValue];
        [self.level updateLevelState:levelState];
        [self runAction];
    }
}
-(CCActionFiniteTime*)actionShowMessage:(NSString*)message
{
    CCLOG(@"%s", __PRETTY_FUNCTION__);
    CCLOG(@"message = %@", message);
    
    [_window addMessageFor1Page:message];
    
    if (_window.contentsCount <= 1) {
        return [CCActionCallBlock actionWithBlock:^{}];
    } else {
        return [_window actionScrollContentWithDuration:.3f];
    }
}
#pragma mark - touch handler
-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    self.userInteractionEnabled = NO;
    [self runAction];
}
@end