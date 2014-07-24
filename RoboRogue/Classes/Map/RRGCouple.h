//
//  RRGCouple.h
//  RoboRogue
//
//  Created by 山本政徳 on 2014/03/01.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, RRGCoupleVorH)
{
    RRGCoupleVertical,
    RRGCoupleHorizontal
};

@class RRGZone;

@interface RRGCouple : NSObject
@property (nonatomic) RRGCoupleVorH vorh;
@property (nonatomic) RRGZone* zone0;
@property (nonatomic) RRGZone* zone1;

+(instancetype)coupleWithVorH:(RRGCoupleVorH)vorh
                        Zone0:(RRGZone*)zone0
                        Zone1:(RRGZone*)zone1;
@end
