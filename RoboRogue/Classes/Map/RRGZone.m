//
//  RRGZone.m
//  RoboRogue
//
//  Created by 山本政徳 on 2014/03/01.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "RRGZone.h"

@implementation RRGZone
+(instancetype)zoneWithRect:(CGRect)rect
{
    return [[self alloc] initWithRect:rect];
}
-(instancetype)initWithRect:(CGRect)rect
{
    self = [super init];
	if (self) {
        self.zoneRect = rect;
        self.cantSplitV = NO;
        self.cantSplitH = NO;
    }
    return self;
}
-(NSInteger)zoneLX
{
    return self.zoneRect.origin.x;
}
-(NSInteger)zoneLY
{
    return self.zoneRect.origin.y;
}
-(NSInteger)zoneHX
{
    return self.zoneLX + self.zoneWidth - 1;
}
-(NSInteger)zoneHY
{
    return self.zoneLY + self.zoneHeight - 1;
}
-(NSInteger)zoneWidth
{
    return self.zoneRect.size.width;
}
-(NSInteger)zoneHeight
{
    return self.zoneRect.size.height;
}
-(NSString*)description
{
    NSString* str = [NSString stringWithFormat:
                     @"LowerLeft: (%zd, %zd) UpperRight: (%zd, %zd) width = %zd height = %zd",
                     self.zoneLX,
                     self.zoneLY,
                     self.zoneHX,
                     self.zoneHY,
                     self.zoneWidth,
                     self.zoneHeight];
    return str;
}
@end
