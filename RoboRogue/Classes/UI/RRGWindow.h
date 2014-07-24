//
//  RRGWindow.h
//  RoboRogue
//
//  Created by 山本政徳 on 2014/05/03.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "CCSprite9Slice.h"

@class RRGAction;

@interface RRGWindow : CCSprite9Slice
@property (nonatomic, readonly) NSUInteger contentsCount;
@property (nonatomic, readonly) CGSize contentNodeSize;
@property (nonatomic, readonly) CGFloat sumContentsHeight;

+(instancetype)windowWithSize:(CGSize)size;
+(instancetype)windowWithContentSize:(CGSize)contentSize;
+(instancetype)windowWithContent:(CCNode*)content;

+(CGFloat)contentNodeHeightForHeight:(CGFloat)height;

-(void)addContent:(CCNode*)content;
-(void)addContentFor1Page:(CCNode*)content;
-(void)addMessage:(NSString*)message;
-(void)addMessageFor1Page:(NSString*)message;
-(void)addLine;
-(void)removeAllContents;
@end

@interface RRGClippingWindow : RRGWindow
@property (nonatomic, readonly) BOOL needScroll;

-(RRGAction*)actionScrollContentWithDuration:(CGFloat)duration;
-(RRGAction*)actionScrollContentWithVelocity:(CGFloat)velocity;
@end

@interface RRGScrollWindow : RRGClippingWindow
@property (nonatomic) CGPoint scrollPosition;
+(instancetype)windowWithSize:(CGSize)size
                      content:(CCNode*)content
                       button:(BOOL)button;
@end