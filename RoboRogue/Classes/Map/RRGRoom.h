//
//  RRGRoom.h
//  RoboRogue
//
//  Created by 山本政徳 on 2014/03/01.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, RRGRoomType)
{
    RRGRoomTypeNormal,
    RRGRoomTypeUnused,
    RRGRoomTypeMonstersNest,
    RRGRoomTypeShop,
};

@interface RRGRoom : NSObject <NSCoding>
@property (nonatomic) RRGRoomType roomType;
@property (nonatomic) CGRect roomRect;
@property (nonatomic) NSUInteger roomNum;

-(NSInteger)roomLX;
-(NSInteger)roomLY;
-(NSInteger)roomHX;
-(NSInteger)roomHY;
-(NSInteger)roomWidth;
-(NSInteger)roomHeight;

+(instancetype)roomWithRect:(CGRect)rect
                   roomType:(RRGRoomType)roomType;

-(void)addGateOut:(CGPoint)newGateOut
           gateIn:(CGPoint)newGateIn;
-(CGPoint)exitGateOutAtRandom:(CGPoint)entranceGateOut;
@end
