//
//  RRGMessageWindowLayer.h
//  RoboRogue
//
//  Created by 山本政徳 on 2014/03/23.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "CCNode.h"

@interface RRGMessageWindowLayer : CCNode

+(instancetype)layerWithWindowRect:(CGRect)windowRect;

-(void)addMessage:(NSString*)message;
-(void)hide;
@end
