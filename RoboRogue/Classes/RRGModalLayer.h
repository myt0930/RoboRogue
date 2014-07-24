//
//  RRGModalWindow.h
//  RoboRogue
//
//  Created by 山本政徳 on 2014/07/10.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "CCNode.h"

@class RRGLevel;

@interface RRGModalLayer : CCNode
+(instancetype)layerWithViewSize:(CGSize)viewSize
                           level:(RRGLevel*)level;
-(void)showModalLayerWithActions:(NSArray*)actions;
-(void)showModalLayerWithMessage:(NSString*)message
                     opt1Message:(NSString*)opt1Message
                     opt1Actions:(NSArray*)opt1Actions
                     opt2Message:(NSString*)opt2Message
                     opt2Actions:(NSArray*)opt2Actions;
@end
