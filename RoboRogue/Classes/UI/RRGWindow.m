//
//  RRGWindow.m
//  RoboRogue
//
//  Created by 山本政徳 on 2014/05/03.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "RRGWindow.h"
#import "RRGClippingNode.h"
#import "RRGAction.h"
#import "CCScrollView.h"
#import "CCButton.h"

static const NSUInteger RRGWindowMarginAroundContentBox = 20;
static const NSUInteger MinSize = 60;

static CGFloat const fontSize = 17;

@interface RRGWindow ()
@property (nonatomic) CCNode* parentNode;
@property (nonatomic) CCNode* contentNode;
@property (nonatomic) NSMutableArray* contents;
@property (nonatomic) CGFloat nextContentYPos;
@property (nonatomic) CGFloat initialNextContentYPos;

-(void)addContent:(CCNode *)content
    contentHeight:(CGFloat)contentHeight;
@end

@implementation RRGWindow
+(CGFloat)contentNodeHeightForHeight:(CGFloat)height
{
    return height - RRGWindowMarginAroundContentBox * 2;
}
#pragma mark - constructer
+(instancetype)windowWithSize:(CGSize)size
{
    return [[self alloc] initWithSize:size];
}
+(instancetype)windowWithContentSize:(CGSize)contentSize
{
    return [[self alloc] initWithContentSize:contentSize];
}
+(instancetype)windowWithContent:(CCNode*)content
{
    RRGWindow* window = [self windowWithContentSize:content.contentSize];
    [window addContent:content];
    return window;
}
#pragma mark - initializer
//designated initializer
-(instancetype)initWithSize:(CGSize)size
{
    CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"window.png"];
	self = [super initWithTexture:frame.texture rect:frame.rect rotated:NO];
    if (self) {
        _anchorPoint = CGPointZero;
        self.spriteFrame = frame;
        self.margin = .3f;
        _contentSize = CGSizeMake(MAX(size.width, MinSize),
                                  MAX(size.height, MinSize));
        
        CGSize contentSize = CGSizeMake(size.width - RRGWindowMarginAroundContentBox * 2,
                                        size.height - RRGWindowMarginAroundContentBox * 2);
        
        //parent node
        _parentNode = [CCNode node];
        _parentNode.contentSize = contentSize;
        _parentNode.position = ccp(RRGWindowMarginAroundContentBox,
                                   RRGWindowMarginAroundContentBox);
        [self addChild:_parentNode];
        
        //content node
        _contentNode = [CCNode node];
        _contentNode.contentSize = contentSize;
        _contentNode.position = CGPointZero;
        [_parentNode addChild:_contentNode];
        
        _contents = [NSMutableArray array];
        
        _nextContentYPos = _initialNextContentYPos = contentSize.height;
    }
	return self;
}
-(instancetype)initWithContentSize:(CGSize)contentSize
{
    CGSize size = CGSizeMake(contentSize.width + RRGWindowMarginAroundContentBox * 2,
                             contentSize.height + RRGWindowMarginAroundContentBox * 2);
    self = [self initWithSize:size];
    return self;
}
#pragma mark - add contents
-(void)addContent:(CCNode *)content
    contentHeight:(CGFloat)contentHeight
{
    //CCLOG(@"%s", __PRETTY_FUNCTION__);
    content.anchorPoint = ccp(0,1);
    content.position = ccp(0, _nextContentYPos);
    _nextContentYPos -= contentHeight;
    [_contentNode addChild:content];
    
    [_contents addObject:content];
}
-(void)addContentFor1Page:(CCNode*)content
{
    [self addContent:content contentHeight:self.contentNodeSize.height];
}
-(void)addContent:(CCNode*)content
{
    [self addContent:content contentHeight:content.contentSize.height];
}
-(void)addMessage:(NSString*)message
{
    CCLabelTTF* label = [CCLabelTTF labelWithString:message
                                           fontName:@"Helvetica"
                                           fontSize:fontSize];
    label.dimensions = CGSizeMake(_contentNode.contentSize.width, 0);
    [self addContent:label];
}
-(void)addMessageFor1Page:(NSString *)message
{
    CCLabelTTF* label = [CCLabelTTF labelWithString:message
                                           fontName:@"Helvetica"
                                           fontSize:fontSize];
    label.dimensions = CGSizeMake(_contentNode.contentSize.width, 0);
    [self addContentFor1Page:label];
}
-(void)addLine
{
    CCDrawNode* drawNode = [CCDrawNode node];
    CGFloat height = 20;
    drawNode.contentSize = CGSizeMake(_contentNode.contentSize.width, height);
    [drawNode drawSegmentFrom:ccp(0,height * .5f)
                           to:ccp(drawNode.contentSize.width, height * .5f)
                       radius:1
                        color:[CCColor whiteColor]];
    [self addContent:drawNode];
}
-(void)removeAllContents
{
    [self stopAllActions];
    [_contentNode removeAllChildrenWithCleanup:YES];
    [_contents removeAllObjects];
    _nextContentYPos = _initialNextContentYPos;
}
#pragma mark - attributes
-(NSUInteger)contentsCount
{
    return [_contents count];
}
-(CGSize)contentNodeSize
{
    return _contentNode.contentSize;
}
-(CGFloat)sumContentsHeight
{
    CGFloat ret = 0;
    for (CCNode* node in self.contents) {
        ret += node.contentSize.height;
    }
    return ret;
}
@end

#pragma mark - RRGClippingWindow
@interface RRGClippingWindow ()
@property (nonatomic) RRGClippingNode* clippingNode;
@property (nonatomic, readonly) CGFloat scrollDY;
@end

@implementation RRGClippingWindow
-(instancetype)initWithSize:(CGSize)size
{
    self = [super initWithSize:size];
    if (self) {
        CGSize contentSize = self.contentNodeSize;
        
        [self.contentNode removeFromParent];
        
        _clippingNode = [RRGClippingNode
                         nodeWithViewRect:CGRectMake(0,
                                                     0,
                                                     contentSize.width,
                                                     contentSize.height)
                         contentSize:contentSize];
        _clippingNode.position = CGPointZero;
        [self.parentNode addChild:_clippingNode];
        
        //content node
        [_clippingNode addChild:self.contentNode];
    }
    return self;
}
-(CGFloat)scrollDY
{
    CCNode* firstContent = [self.contents firstObject];
    
    if ([self.contents count] > 2) {
        CCNode* secondContent = self.contents[1];
        return firstContent.position.y - secondContent.position.y;
    } else {
        return firstContent.contentSize.height;
    }
}
#pragma mark - scroll action
-(RRGAction*)actionScrollContentWithDuration:(CGFloat)duration
{
    if ([self.contents count] == 0) {
        CCLOG(@"no contents");
        return nil;
    }
    
    NSMutableArray* seqArray = [NSMutableArray array];
    
    CCNode* firstContent = [self.contents firstObject];
    
    CCActionMoveBy* move = [CCActionMoveBy actionWithDuration:duration
                                                     position:ccp(0,self.scrollDY)];
    [seqArray addObject:move];
    [seqArray addObject:[RRGAction actionWithTarget:firstContent
                                             action:[CCActionRemove action]]];
    [self.contents removeObjectAtIndex:0];
    
    CCActionSequence* seq = [CCActionSequence actionWithArray:seqArray];
    
    return [RRGAction actionWithTarget:self.contentNode
                                action:seq];
}
-(RRGAction*)actionScrollContentWithVelocity:(CGFloat)velocity
{
    CGFloat duration = velocity * self.scrollDY;
    return [self actionScrollContentWithDuration:duration];
}
-(void)removeAllContents
{
    [super removeAllContents];
    self.contentNode.position = CGPointZero;
}
-(BOOL)needScroll
{
    if (self.contentsCount <= 1) {
        return NO;
    }
    if (self.contentsCount <= 3 &&
        self.sumContentsHeight <= self.contentNodeSize.height) {
        return NO;
    }
    return YES;
}
@end

#pragma mark - RRGScrollWindow
@interface RRGScrollWindow ()
@property (nonatomic) BOOL button;
@property (nonatomic) CCScrollView* scrollView;
@property (nonatomic) CCButton* upButton;
@property (nonatomic) CCButton* downButton;
@end

@implementation RRGScrollWindow
+(instancetype)windowWithSize:(CGSize)size
                      content:(CCNode *)content
                       button:(BOOL)button
{
    return [[self alloc] initWithSize:size
                              content:content
                               button:button];
}
-(instancetype)initWithSize:(CGSize)size
                    content:(CCNode*)content
                     button:(BOOL)button
{
    self = [super initWithSize:size];
    if (self) {
        _button = button;
        
        _scrollView = [[CCScrollView alloc] initWithContentNode:content];
        _scrollView.anchorPoint = ccp(0,1);
        _scrollView.positionType = CCPositionTypeNormalized;
        _scrollView.position = ccp(0,1);
        _scrollView.horizontalScrollEnabled = NO;
        _scrollView.verticalScrollEnabled = YES;
        _scrollView.bounces = YES;
        _scrollView.anchorPoint = ccp(0,1);
        _scrollView.positionType = CCPositionTypeNormalized;
        _scrollView.position = ccp(0,1);
        [self.contentNode addChild:_scrollView];
        
        if (_button) {
            CCSpriteFrame* upFrame = [[CCSpriteFrameCache sharedSpriteFrameCache]
                                      spriteFrameByName:@"upButton.png"];
            _upButton = [CCButton buttonWithTitle:nil
                                      spriteFrame:upFrame];
            [_upButton setBackgroundOpacity:0.5f forState:CCControlStateNormal];
            [_upButton setBackgroundOpacity:1 forState:CCControlStateHighlighted];
            _upButton.anchorPoint = ccp(1,1);
            _upButton.positionType = CCPositionTypeNormalized;
            _upButton.position = ccp(1,1);
            CGFloat deltaY = self.contentNodeSize.height;
            __weak CCScrollView* weakScrollView = _scrollView;
            _upButton.block = ^(id sender){
                CGPoint newPos = ccp(weakScrollView.scrollPosition.x,
                                     weakScrollView.scrollPosition.y - deltaY);
                [weakScrollView setScrollPosition:newPos animated:YES];
            };
            _upButton.visible = NO;
            [self.clippingNode addChild:_upButton];
            
            CCSpriteFrame* downFrame = [[CCSpriteFrameCache sharedSpriteFrameCache]
                                        spriteFrameByName:@"downButton.png"];
            _downButton = [CCButton buttonWithTitle:nil
                                        spriteFrame:downFrame];
            [_downButton setBackgroundOpacity:0.5f forState:CCControlStateNormal];
            [_downButton setBackgroundOpacity:1 forState:CCControlStateHighlighted];
            _downButton.anchorPoint = ccp(1,0);
            _downButton.positionType = CCPositionTypeNormalized;
            _downButton.position = ccp(1,0);
            _downButton.block = ^(id sender){
                CGPoint newPos = ccp(weakScrollView.scrollPosition.x,
                                     weakScrollView.scrollPosition.y + deltaY);
                [weakScrollView setScrollPosition:newPos animated:YES];
            };
            _downButton.visible = NO;
            [self.clippingNode addChild:_downButton];
        }
    }
    return self;
}
-(void)update:(CCTime)delta
{
    if (_button) {
        if (_scrollView.scrollPosition.y == _scrollView.minScrollY) {
            _upButton.visible = NO;
        } else {
            _upButton.visible = YES;
        }
        if (_scrollView.scrollPosition.y == _scrollView.maxScrollY) {
            _downButton.visible = NO;
        } else {
            _downButton.visible = YES;
        }
    }
}
-(void)addContent:(CCNode *)content
    contentHeight:(CGFloat)contentHeight
{
    CCLOG(@"You cannot add content to RRGScrollWindow after construction.");
}
-(CGPoint)scrollPosition
{
    return _scrollView.scrollPosition;
}
-(void)setScrollPosition:(CGPoint)scrollPosition
{
    _scrollView.scrollPosition = scrollPosition;
}
@end