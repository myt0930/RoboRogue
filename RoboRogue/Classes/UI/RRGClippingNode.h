//
//  RRGClippingNode.h
//  RoboRogue
//
//  Created by 山本政徳 on 2014/05/21.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "cocos2d.h"

@interface RRGClippingNode : CCNode
@property (nonatomic) CGRect viewRect;
+(instancetype)nodeWithViewRect:(CGRect)viewRect
                    contentSize:(CGSize)contentSize;
@end
