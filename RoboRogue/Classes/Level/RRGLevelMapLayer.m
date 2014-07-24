//
//  RRGLevelMapLayer.m
//  RoboRogue
//
//  Created by 山本政徳 on 2014/05/18.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "RRGLevelMapLayer.h"

@implementation RRGLevelMapLayer
+(instancetype)layerWithMapSize:(CGSize)mapSize
                          level:(RRGLevel *)level
{
    return [[self alloc] initWithMapSize:mapSize
                                   level:level];
}
-(instancetype)initWithMapSize:(CGSize)mapSize
                         level:(RRGLevel*)level
{
    self = [super init];
    if (self) {
        
    }
    return self;
}
@end