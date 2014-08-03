//
//  RRGButton.m
//  RoboRogue
//
//  Created by 山本政徳 on 2014/05/02.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "RRGButton.h"
#import "CCControlSubclass.h"
#import "RRGItem.h"

#import "cocos2d.h"
#import <objc/runtime.h>

#define kCCFatFingerExpansion 70

@implementation RRGButton
{
    NSInteger _height;
    NSInteger _fontSize;
}

+(instancetype)buttonWithWidth:(CGFloat)width
                          icon:(CCSprite*)icon
                         title:(NSString*)title
                    labelColor:(CCColor*)labelColor
{
    return [[self alloc] initWithWidth:width
                                  icon:icon
                                 title:title
                            labelColor:labelColor];
}

+(instancetype)buttonWithWidth:(CGFloat)width
                          icon:(CCSprite*)icon
                         title:(NSString*)title
{
    return [[self alloc] initWithWidth:width
                                  icon:icon
                                 title:title
                            labelColor:nil];
}

-(instancetype)initWithWidth:(CGFloat)width
                        icon:(CCSprite*)icon
                       title:(NSString*)title
                  labelColor:(CCColor*)labelColor
{
    self = [super init];
    if (!self) return NULL;
    
    _height = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)?30:40;
    _fontSize = 17;//(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)?17:20;
    
    self.contentSize = CGSizeMake(width, _height);
    self.preferredSize = self.contentSize;
    self.anchorPoint = ccp(0,.5f);
    
    if (!title) title = @"";
    if (!labelColor) labelColor = [CCColor whiteColor];
    
    // Setup background image
    self.bg = [CCNodeColor nodeWithColor:[CCColor whiteColor]];
    self.bg.contentSize = self.contentSize;
    self.bg.opacity = 0;
    [self addChild:self.bg z:0];
    
    // Setup icon
    if (icon) {
        self.icon = icon;
        self.icon.anchorPoint = ccp(0,.5f);
        self.icon.positionType = CCPositionTypeNormalized;
        self.icon.position = ccp(0,.5f);
        [self addChild:self.icon z:1];
    }
    
    // Setup label
    self.label = [CCLabelTTF labelWithString:title
                                    fontName:@"Helvetica"
                                    fontSize:_fontSize];
    self.label.color = labelColor;
    //_label.adjustsFontSizeToFit = YES;
    //_label.horizontalAlignment = CCTextAlignmentCenter;
    //_label.verticalAlignment = CCVerticalTextAlignmentCenter;
    if (icon) {
        self.label.anchorPoint = ccp(0,.5f);
        self.label.position = ccp(icon.contentSize.height,
                                  _height * .5f);
    } else {
        self.label.anchorPoint = CGPointZero;
        CGFloat padding = (_height - self.label.contentSize.height) * .5f;
        self.label.position = ccp(padding, padding);
    }
    [self addChild:self.label z:1];
    
    [self needsLayout];
    [self stateChanged];
    
    return self;
}
/*
- (void) layout
{
    _label.dimensions = CGSizeZero;
    CGSize originalLabelSize = _label.contentSize;
    CGSize paddedLabelSize = originalLabelSize;
    paddedLabelSize.width += _horizontalPadding * 2;
    paddedLabelSize.height += _verticalPadding * 2;
    
    BOOL shrunkSize = NO;
    CGSize size = [self convertContentSizeToPoints: self.preferredSize type:self.contentSizeType];
    
    CGSize maxSize = [self convertContentSizeToPoints:self.maxSize type:self.contentSizeType];
    
    if (size.width < paddedLabelSize.width) size.width = paddedLabelSize.width;
    if (size.height < paddedLabelSize.height) size.height = paddedLabelSize.height;
    
    if (maxSize.width > 0 && maxSize.width < size.width)
    {
        size.width = maxSize.width;
        shrunkSize = YES;
    }
    if (maxSize.height > 0 && maxSize.height < size.height)
    {
        size.height = maxSize.height;
        shrunkSize = YES;
    }
    
    if (shrunkSize)
    {
        CGSize labelSize = CGSizeMake(clampf(size.width - _horizontalPadding * 2, 0, originalLabelSize.width),
                                      clampf(size.height - _verticalPadding * 2, 0, originalLabelSize.height));
        _label.dimensions = labelSize;
    }
    
    _background.contentSize = size;
    _background.anchorPoint = ccp(0.5f,0.5f);
    _background.positionType = CCPositionTypeNormalized;
    _background.position = ccp(0.5f,0.5f);
    
    _label.positionType = CCPositionTypeNormalized;
    _label.position = ccp(0.5f, 0.5f);
    
    self.contentSize = [self convertContentSizeFromPoints: size type:self.contentSizeType];
    
    [super layout];
}*/
#ifdef __CC_PLATFORM_IOS

- (void) touchEntered:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (!self.enabled)
    {
        return;
    }
    /*
    if (self.claimsUserInteraction)
    {
        [super setHitAreaExpansion:_originalHitAreaExpansion + kCCFatFingerExpansion];
    }*/
    self.highlighted = YES;
}

- (void) touchExited:(UITouch *)touch withEvent:(UIEvent *)event
{
    self.highlighted = NO;
}

- (void) touchUpInside:(UITouch *)touch withEvent:(UIEvent *)event
{
    //[super setHitAreaExpansion:_originalHitAreaExpansion];
    
    if (self.enabled)
    {
        [self triggerAction];
    }
    
    self.highlighted = NO;
}

- (void) touchUpOutside:(UITouch *)touch withEvent:(UIEvent *)event
{
    //[super setHitAreaExpansion:_originalHitAreaExpansion];
    self.highlighted = NO;
}

#elif __CC_PLATFORM_MAC

- (void) mouseDownEntered:(NSEvent *)event
{
    if (!self.enabled)
    {
        return;
    }
    self.highlighted = YES;
}

- (void) mouseDownExited:(NSEvent *)event
{
    self.highlighted = NO;
}

- (void) mouseUpInside:(NSEvent *)event
{
    if (self.enabled)
    {
        [self triggerAction];
    }
    self.highlighted = NO;
}

- (void) mouseUpOutside:(NSEvent *)event
{
    self.highlighted = NO;
}

#endif

- (void) triggerAction
{
    // Handle toggle buttons
    if (self.togglesSelectedState)
    {
        self.selected = !self.selected;
    }
    
    [super triggerAction];
}

- (void) updatePropertiesForState:(CCControlState)state
{
    /*
    // Update background
    _background.color = [self backgroundColorForState:state];
    _background.opacity = [self backgroundOpacityForState:state];
    
    CCSpriteFrame* spriteFrame = [self backgroundSpriteFrameForState:state];
    if (!spriteFrame) spriteFrame = [self backgroundSpriteFrameForState:CCControlStateNormal];
    _background.spriteFrame = spriteFrame;
    
    // Update label
    _label.color = [self labelColorForState:state];
    _label.opacity = [self labelOpacityForState:state];
    */
    
    if (state == CCControlStateNormal) {
        self.bg.opacity = (self.selected)?.5f:0;
        self.icon.opacity = 1;
        self.label.opacity = 1;
    } else if (state == CCControlStateHighlighted) {
        self.bg.opacity = .5f;
        self.icon.opacity = 1;
        self.label.opacity = 1;
    } else if (state == CCControlStateDisabled) {
        self.bg.opacity = 0;
        self.icon.opacity = .5f;
        self.label.opacity = .5f;
    } else if (state == CCControlStateSelected) {
        self.bg.opacity = .5f;
        self.icon.opacity = 1;
        self.label.opacity = 1;
    }
    
    [self needsLayout];
}

- (void) stateChanged
{
    if (self.enabled)
    {
        // Button is enabled
        if (self.highlighted)
        {
            [self updatePropertiesForState:CCControlStateHighlighted];
            /*
            if (_zoomWhenHighlighted)
            {
                [_label runAction:[CCActionScaleTo actionWithDuration:0.1 scaleX:_originalScaleX*1.2 scaleY:_originalScaleY*1.2]];
                [_background runAction:[CCActionScaleTo actionWithDuration:0.1 scaleX:_originalScaleX*1.2 scaleY:_originalScaleY*1.2]];
            }
             */
        }
        else
        {
            if (self.selected)
            {
                [self updatePropertiesForState:CCControlStateSelected];
            }
            else
            {
                [self updatePropertiesForState:CCControlStateNormal];
            }
            
            [_label stopAllActions];
            /*
            if (_zoomWhenHighlighted)
            {
                _label.scaleX = _originalScaleX;
                _label.scaleY = _originalScaleY;
                
                _background.scaleX = _originalScaleX;
                _background.scaleY = _originalScaleY;
            }*/
        }
    }
    else
    {
        // Button is disabled
        [self updatePropertiesForState:CCControlStateDisabled];
    }
}

#pragma mark Properties
/*
- (void) setHitAreaExpansion:(float)hitAreaExpansion
{
    _originalHitAreaExpansion = hitAreaExpansion;
    [super hitAreaExpansion];
}

- (float) hitAreaExpansion
{
    return _originalHitAreaExpansion;
}

- (void)setColor:(CCColor *)color {
    [self setLabelColor:color forState:CCControlStateNormal];
}

- (void) setLabelColor:(CCColor*)color forState:(CCControlState)state
{
    [_labelColors setObject:color forKey:[NSNumber numberWithInt:state]];
    [self stateChanged];
}

- (CCColor*) labelColorForState:(CCControlState)state
{
    CCColor* color = [_labelColors objectForKey:[NSNumber numberWithInt:state]];
    if (!color) color = [CCColor whiteColor];
    return color;
}

- (void) setLabelOpacity:(CGFloat)opacity forState:(CCControlState)state
{
    [_labelOpacities setObject:[NSNumber numberWithFloat:opacity] forKey:[NSNumber numberWithInt:state]];
    [self stateChanged];
}

- (CGFloat) labelOpacityForState:(CCControlState)state
{
    NSNumber* val = [_labelOpacities objectForKey:[NSNumber numberWithInt:state]];
    if (!val) return 1;
    return [val floatValue];
}

- (void) setBackgroundColor:(CCColor*)color forState:(CCControlState)state
{
    [_backgroundColors setObject:color forKey:[NSNumber numberWithInt:state]];
    [self stateChanged];
}

- (CCColor*) backgroundColorForState:(CCControlState)state
{
    CCColor* color = [_backgroundColors objectForKey:[NSNumber numberWithInt:state]];
    if (!color) color = [CCColor whiteColor];
    return color;
}

- (void) setBackgroundOpacity:(CGFloat)opacity forState:(CCControlState)state
{
    [_backgroundOpacities setObject:[NSNumber numberWithFloat:opacity] forKey:[NSNumber numberWithInt:state]];
    [self stateChanged];
}

- (CGFloat) backgroundOpacityForState:(CCControlState)state
{
    NSNumber* val = [_backgroundOpacities objectForKey:[NSNumber numberWithInt:state]];
    if (!val) return 1;
    return [val floatValue];
}

- (void) setBackgroundSpriteFrame:(CCSpriteFrame*)spriteFrame forState:(CCControlState)state
{
    if (spriteFrame)
    {
        [_backgroundSpriteFrames setObject:spriteFrame forKey:[NSNumber numberWithInt:state]];
    }
    else
    {
        [_backgroundSpriteFrames removeObjectForKey:[NSNumber numberWithInt:state]];
    }
    [self stateChanged];
}

- (CCSpriteFrame*) backgroundSpriteFrameForState:(CCControlState)state
{
    return [_backgroundSpriteFrames objectForKey:[NSNumber numberWithInt:state]];
}

- (void) setTitle:(NSString *)title
{
    _label.string = title;
    [self needsLayout];
}

- (NSString*) title
{
    return _label.string;
}

- (void) setHorizontalPadding:(float)horizontalPadding
{
    _horizontalPadding = horizontalPadding;
    [self needsLayout];
}

- (void) setVerticalPadding:(float)verticalPadding
{
    _verticalPadding = verticalPadding;
    [self needsLayout];
}

- (NSArray*) keysForwardedToLabel
{
    return [NSArray arrayWithObjects:
            @"fontName",
            @"fontSize",
            @"opacity",
            @"color",
            @"fontColor",
            @"outlineColor",
            @"outlineWidth",
            @"shadowColor",
            @"shadowBlurRadius",
            @"shadowOffset",
            @"shadowOffsetType",
            nil];
}

- (void) setValue:(id)value forKey:(NSString *)key
{
    if ([[self keysForwardedToLabel] containsObject:key])
    {
        [_label setValue:value forKey:key];
        [self needsLayout];
        return;
    }
    [super setValue:value forKey:key];
}

- (id) valueForKey:(NSString *)key
{
    if ([[self keysForwardedToLabel] containsObject:key])
    {
        return [_label valueForKey:key];
    }
    return [super valueForKey:key];
}

- (void) setValue:(id)value forKey:(NSString *)key state:(CCControlState)state
{
    if ([key isEqualToString:@"labelOpacity"])
    {
        [self setLabelOpacity:[value floatValue] forState:state];
    }
    else if ([key isEqualToString:@"labelColor"])
    {
        [self setLabelColor:value forState:state];
    }
    else if ([key isEqualToString:@"backgroundOpacity"])
    {
        [self setBackgroundOpacity:[value floatValue] forState:state];
    }
    else if ([key isEqualToString:@"backgroundColor"])
    {
        [self setBackgroundColor:value forState:state];
    }
    else if ([key isEqualToString:@"backgroundSpriteFrame"])
    {
        [self setBackgroundSpriteFrame:value forState:state];
    }
}

- (id) valueForKey:(NSString *)key state:(CCControlState)state
{
    if ([key isEqualToString:@"labelOpacity"])
    {
        return [NSNumber numberWithFloat:[self labelOpacityForState:state]];
    }
    else if ([key isEqualToString:@"labelColor"])
    {
        return [self labelColorForState:state];
    }
    else if ([key isEqualToString:@"backgroundOpacity"])
    {
        return [NSNumber numberWithFloat:[self backgroundOpacityForState:state]];
    }
    else if ([key isEqualToString:@"backgroundColor"])
    {
        return [self backgroundColorForState:state];
    }
    else if ([key isEqualToString:@"backgroundSpriteFrame"])
    {
        return [self backgroundSpriteFrameForState:state];
    }
    
    return NULL;
}
*/
@end

@interface RRGItemButton ()
@property (nonatomic) BOOL equipped;
@property (nonatomic) RRGItemCursedOrBlessed cursedOrBlessed;
@property (nonatomic) CCLabelTTF* labelE;
@property (nonatomic) CCSprite* cursedOrBlessedSprite;
@end

@implementation RRGItemButton
+(instancetype)buttonWithItem:(RRGItem *)item
                        width:(CGFloat)width
{
    return [[self alloc] initWithItem:item width:width];
}
-(instancetype)initWithItem:(RRGItem*)item
                      width:(CGFloat)width
{
    NSAssert(item != nil, @"item is nil");
    
    CCSprite* icon = [CCSprite spriteWithImageNamed:
                      [NSString stringWithFormat:@"%@/icon.png",
                       [item spriteFolderName]]];
    
    self = [super initWithWidth:width
                           icon:icon
                          title:item.displayName
                     labelColor:[CCColor whiteColor]];
    if (self) {
        if ([item isKindOfClass:[RRGItemEquipment class]]) {
            RRGItemEquipment* equipment = (RRGItemEquipment*)item;
            if (equipment.equipped) {
                self.equipped = YES;
            }
        }
        self.cursedOrBlessed = item.cursedOrBlessed;
    }
    return self;
}
-(void)setEquipped:(BOOL)equipped
{
    _equipped = equipped;
    [_labelE removeFromParent];
    if (equipped) {
        _labelE = [CCLabelTTF labelWithString:@"E"
                                     fontName:@"Helvetica"
                                     fontSize:10];
        _labelE.anchorPoint = ccp(0,1);
        _labelE.positionType = CCPositionTypeNormalized;
        _labelE.position = ccp(0,1);
        [self.icon addChild:_labelE];
    }
}
-(void)setCursedOrBlessed:(RRGItemCursedOrBlessed)cursedOrBlessed
{
    _cursedOrBlessed = cursedOrBlessed;
    [_cursedOrBlessedSprite removeFromParent];
    switch (cursedOrBlessed) {
        case RRGItemCursed:
        {
            _cursedOrBlessedSprite = [CCSprite spriteWithImageNamed:@"cursed.png"];
            _cursedOrBlessedSprite.anchorPoint = ccp(0,0);
            _cursedOrBlessedSprite.positionType = CCPositionTypeNormalized;
            _cursedOrBlessedSprite.position = ccp(0,0);
            [self.icon addChild:_cursedOrBlessedSprite];
            break;
        }
        default:
            break;
    }
}
@end