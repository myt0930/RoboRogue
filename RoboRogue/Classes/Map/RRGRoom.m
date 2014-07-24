//
//  RRGRoom.m
//  RoboRogue
//
//  Created by 山本政徳 on 2014/03/01.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "RRGRoom.h"
#import "RRGFunctions.h"
#import "RRGCategories.h"

@implementation RRGRoom
{
    NSMutableArray* _gateOutArray;
    NSMutableArray* _gateInArray;
}
+(instancetype)roomWithRect:(CGRect)rect
                   roomType:(RRGRoomType)roomType;
{
    return [[self alloc] initWithRect:rect
                             roomType:roomType];
}
-(instancetype)initWithRect:(CGRect)rect
                   roomType:(RRGRoomType)roomType
{
    self = [super init];
	if (self) {
        _roomType = roomType;
        _roomRect = rect;
        _gateOutArray = [NSMutableArray array];
        _gateInArray = [NSMutableArray array];
        _roomNum = -1;
    }
    return self;
}
-(NSInteger)roomLX
{
    return _roomRect.origin.x;
}
-(NSInteger)roomLY
{
    return _roomRect.origin.y;
}
-(NSInteger)roomHX
{
    return [self roomLX] + [self roomWidth] - 1;
}
-(NSInteger)roomHY
{
    return [self roomLY] + [self roomHeight] - 1;
}
-(NSInteger)roomWidth
{
    return _roomRect.size.width;
}
-(NSInteger)roomHeight
{
    return _roomRect.size.height;
}

-(void)addGateOut:(CGPoint)newGateOut
           gateIn:(CGPoint)newGateIn
{
    if ([self haveGateOut:newGateOut]) {
        return;
    }
    [_gateOutArray addObject:[NSValue valueWithCGPoint:newGateOut]];
    [_gateInArray addObject:[NSValue valueWithCGPoint:newGateIn]];
}
-(BOOL)haveGateOut:(CGPoint)gateOut
{
    for (NSValue* val in _gateOutArray) {
        CGPoint gateExist = [val CGPointValue];
        if (CGPointEqualToPoint(gateExist, gateOut)) {
            return YES;
        }
    }
    return NO;
}
-(CGPoint)exitGateOutAtRandom:(CGPoint)entranceGateOut
{
    if ([_gateOutArray count] == 0) {
        return CGPointZero;
    } else if ([_gateOutArray count] == 1) {
        return [_gateOutArray[0] CGPointValue];
    }
    NSInteger index = randomInteger(0, [_gateOutArray count] - 1);
    if (CGPointEqualToPoint(entranceGateOut, [_gateOutArray[index] CGPointValue])) {
        if (++index >= [_gateOutArray count]) {
            index = 0;
        }
    }
    return [_gateOutArray[index] CGPointValue];
}

-(NSString*)description
{
    NSString* str = [NSString stringWithFormat:
                     @"roomNum: %tu LowerLeft: (%zd, %zd) UpperRight: (%zd, %zd)",
                     self.roomNum,
                     [self roomLX],
                     [self roomLY],
                     [self roomHX],
                     [self roomHY]];
    return str;
}

#pragma mark - NSCoding
-(void)encodeWithCoder:(NSCoder *)coder
{
    encodeInteger(_roomType);
    encodeCGRect(_roomRect);
    encodeInteger(_roomNum);
    encodeObject(_gateOutArray);
    encodeObject(_gateInArray);
}
-(instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self){
        decodeInteger(_roomType);
        decodeCGRect(_roomRect);
        decodeInteger(_roomNum);
        decodeObject(_gateOutArray);
        decodeObject(_gateInArray);
    }
    return self;
}
@end
