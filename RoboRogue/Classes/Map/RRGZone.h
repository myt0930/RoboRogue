//
//  RRGZone.h
//  RoboRogue
//
//  Created by 山本政徳 on 2014/03/01.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RRGRoom;

@interface RRGZone : NSObject
@property (nonatomic) CGRect zoneRect;
@property (nonatomic) RRGRoom* room;
@property (nonatomic) BOOL cantSplitV;
@property (nonatomic) BOOL cantSplitH;
@property (nonatomic, readonly) NSInteger zoneLX;
@property (nonatomic, readonly) NSInteger zoneLY;
@property (nonatomic, readonly) NSInteger zoneHX;
@property (nonatomic, readonly) NSInteger zoneHY;
@property (nonatomic, readonly) NSInteger zoneWidth;
@property (nonatomic, readonly) NSInteger zoneHeight;

+(instancetype)zoneWithRect:(CGRect)rect;
@end