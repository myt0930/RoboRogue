//
//  RRGActionCache.h
//  RoboRogue
//
//  Created by 山本政徳 on 2014/06/14.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "cocos2d.h"

#define sharedActionCache [RRGActionCache sharedInstance]

@interface RRGActionCache : NSObject
+(RRGActionCache*)sharedInstance;
-(CCActionAnimate*)animateWithFormat:(NSString*)format
                          frameCount:(NSUInteger)frameCount
                               delay:(CGFloat)delay;
-(CCAction*)actionForKey:(NSString*)key;
-(void)setAction:(CCAction*)action
          forKey:(NSString*)key;
-(void)purge;
@end
