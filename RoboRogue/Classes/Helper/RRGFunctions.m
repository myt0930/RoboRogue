//
//  RRGFunctions.m
//  RoboRogue
//
//  Created by 山本政徳 on 2014/02/25.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "RRGFunctions.h"

NSString* directionString(CGPoint direction)
{
    if (CGPointEqualToPoint(direction, North)) {
        return @"north";
    } else if (CGPointEqualToPoint(direction, NorthEast)) {
        return @"northeast";
    } else if (CGPointEqualToPoint(direction, East)) {
        return @"east";
    } else if (CGPointEqualToPoint(direction, SouthEast)) {
        return @"southeast";
    } else if (CGPointEqualToPoint(direction, South)) {
        return @"south";
    } else if (CGPointEqualToPoint(direction, SouthWest)) {
        return @"southwest";
    } else if (CGPointEqualToPoint(direction, West)) {
        return @"west";
    } else if (CGPointEqualToPoint(direction, NorthWest)) {
        return @"northwest";
    }
    return @"";
}

CGPoint unitVector(CGPoint v)
{
    int x = 0;
    int y = 0;
    
    if (v.x > 0) {
        x = 1;
    } else if (v.x < 0) {
        x = -1;
    }
    
    if (v.y > 0) {
        y = 1;
    } else if (v.y < 0) {
        y = -1;
    }
    
    return ccp(x, y);
}

CGPoint rotatedDirection(CGPoint direction, NSInteger rotation)
{
    if (rotation == 0) {
        return direction;
    } else if (rotation > 0) {
        //clockwise
        if (CGPointEqualToPoint(direction, North)) {
            return rotatedDirection(NorthEast, rotation - 1);
        } else if (CGPointEqualToPoint(direction, NorthEast)) {
            return rotatedDirection(East, rotation - 1);
        } else if (CGPointEqualToPoint(direction, East)) {
            return rotatedDirection(SouthEast, rotation - 1);
        } else if (CGPointEqualToPoint(direction, SouthEast)) {
            return rotatedDirection(South, rotation - 1);
        } else if (CGPointEqualToPoint(direction, South)) {
            return rotatedDirection(SouthWest, rotation - 1);
        } else if (CGPointEqualToPoint(direction, SouthWest)) {
            return rotatedDirection(West, rotation - 1);
        } else if (CGPointEqualToPoint(direction, West)) {
            return rotatedDirection(NorthWest, rotation - 1);
        } else if (CGPointEqualToPoint(direction, NorthWest)) {
            return rotatedDirection(North, rotation - 1);
        }
    } else /*if (rotation < 0)*/ {
        //counterclockwise
        if (CGPointEqualToPoint(direction, North)) {
            return rotatedDirection(NorthWest, rotation + 1);
        } else if (CGPointEqualToPoint(direction, NorthWest)) {
            return rotatedDirection(West, rotation + 1);
        } else if (CGPointEqualToPoint(direction, West)) {
            return rotatedDirection(SouthWest, rotation + 1);
        } else if (CGPointEqualToPoint(direction, SouthWest)) {
            return rotatedDirection(South, rotation + 1);
        } else if (CGPointEqualToPoint(direction, South)) {
            return rotatedDirection(SouthEast, rotation + 1);
        } else if (CGPointEqualToPoint(direction, SouthEast)) {
            return rotatedDirection(East, rotation + 1);
        } else if (CGPointEqualToPoint(direction, East)) {
            return rotatedDirection(NorthEast, rotation + 1);
        } else if (CGPointEqualToPoint(direction, NorthEast)) {
            return rotatedDirection(North, rotation + 1);
        }
    }
    return CGPointZero;
}

CGPoint reverseDirection(CGPoint direction)
{
    return ccpMult(direction, -1);
}
CGPoint randomDirection()
{
    NSInteger i = randomInteger(0, 7);
    return rotatedDirection(North, i);
}

NSInteger randomInteger(NSInteger a, NSInteger b)
{
    if (a == b) {
        return a;
    }
    NSInteger min = MIN(a, b);
    NSInteger max = MAX(a, b);
    if (min < 0) {
        return randomInteger(0, max - min) + min;
    }
    return (NSInteger)arc4random_uniform((u_int32_t)(max - min + 1)) + min;
}
NSInteger randomIntegerExcept(NSInteger a, NSInteger b, NSInteger except)
{
    NSInteger ret = randomInteger(a, b);
    if (ret == except) {
        if (++ret > b) {
            ret = a;
        }
    }
    return ret;
}

BOOL calculateProbability(NSUInteger probability)
{
    return (arc4random_uniform(100) < probability)?YES:NO;
}

CGPoint north(CGPoint tileCoord)
{
    return ccpAdd(tileCoord, North);
}
CGPoint northEast(CGPoint tileCoord)
{
    return ccpAdd(tileCoord, NorthEast);
}
CGPoint east(CGPoint tileCoord)
{
    return ccpAdd(tileCoord, East);
}
CGPoint southEast(CGPoint tileCoord)
{
    return ccpAdd(tileCoord, SouthEast);
}
CGPoint south(CGPoint tileCoord)
{
    return ccpAdd(tileCoord, South);
}
CGPoint southWest(CGPoint tileCoord)
{
    return ccpAdd(tileCoord, SouthWest);
}
CGPoint west(CGPoint tileCoord)
{
    return ccpAdd(tileCoord, West);
}
CGPoint northWest(CGPoint tileCoord)
{
    return ccpAdd(tileCoord, NorthWest);
}

NSUInteger tileDistance(CGPoint tileCoord1, CGPoint tileCoord2)
{
    return MAX(ABS(tileCoord1.x - tileCoord2.x), ABS(tileCoord1.y - tileCoord2.y));
}