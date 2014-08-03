//
//  RRGButton.h
//  RoboRogue
//
//  Created by 山本政徳 on 2014/05/02.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "CCControl.h"

//@class CCSprite9Slice;
@class CCLabelTTF, CCSpriteFrame, CCNodeColor, CCSprite, RRGItem;

@interface RRGButton : CCControl
/*
{
    NSMutableDictionary* _backgroundSpriteFrames;
    NSMutableDictionary* _backgroundColors;
    NSMutableDictionary* _backgroundOpacities;
    NSMutableDictionary* _labelColors;
    NSMutableDictionary* _labelOpacities;
    float _originalScaleX;
    float _originalScaleY;
    
    float _originalHitAreaExpansion;
}*/

//@property (nonatomic,readonly) CCSprite9Slice* background;
@property (nonatomic) CCNodeColor* bg;
@property (nonatomic) CCSprite* icon;
@property (nonatomic/*,readonly*/) CCLabelTTF* label;
//@property (nonatomic,assign) BOOL zoomWhenHighlighted;
//@property (nonatomic,assign) float horizontalPadding;
//@property (nonatomic,assign) float verticalPadding;
//@property (nonatomic,strong) NSString* title;
@property (nonatomic,assign) BOOL togglesSelectedState;

/// -----------------------------------------------------------------------
/// @name Creating Buttons
/// -----------------------------------------------------------------------

+(instancetype)buttonWithWidth:(CGFloat)width
                          icon:(CCSprite*)icon
                         title:(NSString*)title
                    labelColor:(CCColor*)labelColor;

+(instancetype)buttonWithWidth:(CGFloat)width
                          icon:(CCSprite*)icon
                         title:(NSString*)title;

-(instancetype)initWithWidth:(CGFloat)width
                        icon:(CCSprite*)icon
                       title:(NSString*)title
                  labelColor:(CCColor*)labelColor;
@end

@interface RRGItemButton : RRGButton
+(instancetype)buttonWithItem:(RRGItem*)item
                        width:(CGFloat)width;
@end