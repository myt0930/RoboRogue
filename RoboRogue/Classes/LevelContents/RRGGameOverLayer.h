//
//  RRGGameOverLayer.h
//  RoboRogue
//
//  Created by 山本政徳 on 2014/07/16.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "CCNode.h"

@class RRGLevel;

@interface RRGGameOverLayer : CCNode
+(instancetype)layerWithViewSize:(CGSize)viewSize
                           level:(RRGLevel*)level;
-(void)scrollWindow;
@end
