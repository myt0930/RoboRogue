//
//  RRGProfileCache.h
//  RoboRogue
//
//  Created by 山本政徳 on 2014/03/10.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//
#import "cocos2d.h"

#define sharedProfileCache [RRGProfileCache sharedInstance]

@interface RRGProfileCache : NSObject
+(RRGProfileCache*)sharedInstance;
-(NSDictionary*)profileForKey:(NSString*)key;
-(void)purge;
@end