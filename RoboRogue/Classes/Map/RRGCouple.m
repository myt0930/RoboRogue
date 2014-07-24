//
//  RRGCouple.m
//  RoboRogue
//
//  Created by 山本政徳 on 2014/03/01.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "RRGCouple.h"

@implementation RRGCouple
+(instancetype)coupleWithVorH:(RRGCoupleVorH)vorh
                        Zone0:(RRGZone*)zone0
                        Zone1:(RRGZone*)zone1
{
    return [[self alloc] initWithVorH:vorh
                                        Zone0:zone0
                                        Zone1:zone1];
}
-(instancetype)initWithVorH:(RRGCoupleVorH)vorh
                      Zone0:(RRGZone*)zone0
                      Zone1:(RRGZone*)zone1
{
    self = [super init];
	if (self) {
        self.vorh = vorh;
        self.zone0 = zone0;
        self.zone1 = zone1;
    }
    return self;
}
@end
