//
//  RRGMessageWindowLayer.m
//  RoboRogue
//
//  Created by 山本政徳 on 2014/03/23.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "RRGMessageWindowLayer.h"
#import "RRGWindow.h"
#import "RRGAction.h"
#import "RRGGameScene.h"

@interface RRGMessageWindowLayer ()
@property (nonatomic) RRGClippingWindow* window;

@property (nonatomic) CGFloat duration1;
@property (nonatomic) CGFloat showingTime;
@end

@implementation RRGMessageWindowLayer
+(instancetype)layerWithWindowRect:(CGRect)windowRect
{
    return [[self alloc] initWithWindowRect:windowRect];
}
-(instancetype)initWithWindowRect:(CGRect)windowRect
{
    self = [super init];
    if (self) {
        _contentSize = [[CCDirector sharedDirector] viewSize];
        
        _window = [RRGClippingWindow windowWithSize:windowRect.size];
        _window.position = windowRect.origin;
        _window.visible = NO;
        [self addChild:_window];
        
        _showingTime = 0;
    }
    return self;
}
-(void)dealloc
{
    CCLOG(@"%s", __PRETTY_FUNCTION__);
}

-(void)addMessage:(NSString*)message
{
    CCLOG(@"%@", message);
    dispatch_async(sharedGameScene.MessageWindowQueue, ^{
        _showingTime = 0;
        [_window addMessage:message];
        
        if (_window.visible == NO) {
            _window.visible = YES;
            [self showMessages];
        }
    });
}
-(void)showMessages
{
    _duration1 = 1.0f / (_window.contentsCount + 1);
    CGFloat duration = _duration1 * .4f;
    _showingTime += duration;
    
    if (_showingTime > 4.0f &&
        _window.needScroll == NO) {
        [self hide];
        return;
    }
    
    CCActionDelay* delay = [CCActionDelay actionWithDuration:duration];
    
    SEL next = (_window.needScroll)?
    @selector(scrollMessages):@selector(showMessages);
    CCActionCallFunc* callFunc = [CCActionCallFunc actionWithTarget:self
                                                           selector:next];
    [self runAction:[CCActionSequence actions:delay, callFunc, nil]];
}
-(void)scrollMessages
{
    _showingTime = 0;
    
    [self runAction:[CCActionSequence actions:
                     [_window actionScrollContentWithDuration:_duration1 * .3f],
                     [CCActionCallFunc actionWithTarget:self
                                               selector:@selector(showMessages)],
                     nil]];
}

-(void)hide
{
    dispatch_async(sharedGameScene.MessageWindowQueue, ^{
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self stopAllActions];
        });
        _showingTime = 0;
        [_window removeAllContents];
        _window.visible = NO;
    });
}
@end