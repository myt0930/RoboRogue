//
//  RRGFunctions.h
//  RoboRogue
//
//  Created by 山本政徳 on 2014/02/25.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "cocos2d.h"

//direction
#define North ccp(0,-1)
#define NorthEast ccp(1,-1)
#define East ccp(1,0)
#define SouthEast ccp(1,1)
#define South ccp(0,1)
#define SouthWest ccp(-1,1)
#define West ccp(-1,0)
#define NorthWest ccp(-1,-1)

NSString* directionString(CGPoint direction);
CGPoint unitVector(CGPoint v);
CGPoint rotatedDirection(CGPoint direction, NSInteger rotation);
CGPoint reverseDirection(CGPoint direction);
CGPoint randomDirection();

NSInteger randomInteger(NSInteger a, NSInteger b);
NSInteger randomIntegerExcept(NSInteger a, NSInteger b, NSInteger except);
BOOL calculateProbability(NSUInteger probability);

CGPoint north(CGPoint tileCoord);
CGPoint northEast(CGPoint tileCoord);
CGPoint east(CGPoint tileCoord);
CGPoint southEast(CGPoint tileCoord);
CGPoint south(CGPoint tileCoord);
CGPoint southWest(CGPoint tileCoord);
CGPoint west(CGPoint tileCoord);
CGPoint northWest(CGPoint tileCoord);

NSUInteger tileDistance(CGPoint tileCoord1, CGPoint tileCoord2);
