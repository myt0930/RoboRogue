//
//  RRGButtonBehavior.h
//  RoboRogue
//
//  Created by 山本政徳 on 2014/07/15.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "CCNode.h"

@interface RRGButtonBehavior : CCNode
@property (nonatomic,copy) void(^block)(id sender);
@property (nonatomic) BOOL actionOnce;
+(instancetype)behaviorWithSize:(CGSize)size;
@end
