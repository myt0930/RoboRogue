//
//  RRGMap.m
//  RoboRogue
//
//  Created by 山本政徳 on 2014/03/01.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "RRGMap.h"
#import "RRGZone.h"
#import "RRGRoom.h"
#import "RRGCouple.h"
#import "RRGLevel.h"
#import "RRGFunctions.h"
#import "RRGLevel+MapID.h"

static const NSInteger MinRoomSize = 4;
static const NSInteger MarginBetweenZoneRoom = 2;
static const NSInteger MinZoneSize = 8;
static const NSInteger MarginAroundMap = 5;

static NSString* const kProfileMapWidth = @"mapWidth";
static NSString* const kProfileMapHeight = @"mapHeight";
static NSString* const kProfileBaseMapID = @"baseMapID";
static NSString* const kProfileWater = @"water";
static NSString* const kProfileLava = @"lava";
static NSString* const kProfileMoreLine = @"moreLine";
static NSString* const kProfilePMaze = @"pMaze";
static NSString* const kProfilePOneRoom = @"pOneRoom";

static const NSUInteger MaxRoomNum = 10;

@implementation RRGMap
{
    CGSize _mapSize;
    NSInteger _baseMapID;
}
+(instancetype)mapWithProfile:(NSDictionary*)profile
{
    return [[self alloc] initWithProfile:profile];
}
-(instancetype)initWithProfile:(NSDictionary*)profile;
{
    self = [super init];
    if (self) {
        NSUInteger w = [profile[kProfileMapWidth] integerValue];
        NSUInteger h = [profile[kProfileMapHeight] integerValue];
        _mapSize = CGSizeMake(w, h);
        
        _baseMapID = [profile[kProfileBaseMapID] integerValue];
        
        _zoneArray = [NSMutableArray array];
        _roomArray = [NSMutableArray array];
        _coupleArray = [NSMutableArray array];
        
        // initialize mapIDMap and roomMap
        //CCLOG(@"mapWidth = %zd mapHeight = %zd", mapWidth, mapHeight);
        //CCLOG(@"MarginBetweenZoneRoom = %zd", MarginBetweenZoneRoom);
        //CCLOG(@"MinZoneSize = %zd", MinZoneSize);
        
        _mapIDMap = [NSMutableArray arrayWithCapacity:_mapSize.width];
        for (NSInteger x = 0; x < _mapSize.width; x++) {
            NSMutableArray* array = [NSMutableArray arrayWithCapacity:_mapSize.height];
            for (NSInteger y = 0; y < _mapSize.height; y++) {
                if (x < MarginAroundMap
                    || y < MarginAroundMap
                    || x >= _mapSize.width - MarginAroundMap
                    || y >= _mapSize.height - MarginAroundMap) {
                    [array addObject:@(MapIDWallUnbreakable)];
                } else {
                    [array addObject:@(_baseMapID)];
                }
            }
            [_mapIDMap addObject:array];
        }
        
        _roomIDMap = [NSMutableArray arrayWithCapacity:_mapSize.width];
        for (NSInteger x = 0; x < _mapSize.width; x++) {
            NSMutableArray* array = [NSMutableArray arrayWithCapacity:_mapSize.height];
            for (NSInteger y = 0; y < _mapSize.height; y++) {
                [array addObject:@(RoomMapIDNotRoom)];
            }
            [_roomIDMap addObject:array];
        }
        
        RRGZone* zone = [RRGZone zoneWithRect:CGRectMake(MarginAroundMap,
                                                         MarginAroundMap,
                                                         _mapSize.width
                                                         - MarginAroundMap * 2,
                                                         _mapSize.height
                                                         - MarginAroundMap * 2)];
        [_zoneArray addObject:zone];
        
        [self zoneSplit:zone pOneRoom:[profile[kProfilePOneRoom] integerValue]];
        //CCLOG(@"zoneArray:%@", [_zoneArray description]);
        [self moreCouple];
        [self roomMake];
        [self mapMake];
        
        /*
        if (calculateProbability([levelProfile[kMaze] integerValue])) {
            RRGZone* zoneToMaze = [_zoneArray objectAtRandom];
            [self mazeMake:zoneToMaze];
        }
         */
        /*
        if ([levelProfile[@"moreLine"] boolValue]) {
            [self moreLine];
        }
         */
    }
    return self;
}

#pragma mark - zoneSplit
-(void)zoneSplit:(RRGZone*)zoneParent
        pOneRoom:(NSInteger)pOneRoom
{
    //NSLog(@"%s",__PRETTY_FUNCTION__);
    //再帰の終了条件
    if ([_zoneArray count] >= MaxRoomNum) {
        return;
    }
    if (zoneParent.zoneHeight < MinZoneSize * 2) {
        zoneParent.cantSplitV = YES;
    }
    if (zoneParent.zoneWidth < MinZoneSize * 2) {
        zoneParent.cantSplitH = YES;
    }
    if (zoneParent.cantSplitV && zoneParent.cantSplitH) {
        return;
    }
    
    if (calculateProbability(pOneRoom)) {
        return;
    } else if (zoneParent.cantSplitV) {
        [self zoneSplitHorizontally:zoneParent];
    } else if (zoneParent.cantSplitH) {
        [self zoneSplitVertically:zoneParent];
    } else if (calculateProbability(50)) {
        [self zoneSplitHorizontally:zoneParent];
    } else {
        [self zoneSplitVertically:zoneParent];
    }
}
-(void)zoneSplitVertically:(RRGZone*)zoneParent
{
    CCLOG(@"%s", __PRETTY_FUNCTION__);
    //縦に分割
    RRGZone* zoneChild = [RRGZone zoneWithRect:zoneParent.zoneRect];
    [_zoneArray addObject:zoneChild];
    
    NSInteger splitCoordY = randomInteger(zoneParent.zoneLY + MinZoneSize,
                                          zoneParent.zoneHY - MinZoneSize + 1);
    
    CGRect newParentRect = CGRectMake(zoneParent.zoneLX,
                                      zoneParent.zoneLY,
                                      zoneParent.zoneWidth,
                                      splitCoordY - zoneParent.zoneLY + 1);
    zoneParent.zoneRect = newParentRect;
    CCLOG(@"zoneParent : %@", zoneParent.description);
    CGRect newChildRect = CGRectMake(zoneChild.zoneLX,
                                     splitCoordY,
                                     zoneChild.zoneWidth,
                                     zoneChild.zoneHY - splitCoordY + 1);
    zoneChild.zoneRect = newChildRect;
    CCLOG(@"zoneChild : %@", zoneChild.description);
    
    RRGCouple* couple = [RRGCouple coupleWithVorH:RRGCoupleVertical
                                          Zone0:zoneParent
                                          Zone1:zoneChild];
    [_coupleArray addObject:couple];
    
    zoneParent.cantSplitV = YES;
    [self zoneSplit:zoneParent pOneRoom:3];
    [self zoneSplit:zoneChild pOneRoom:3];
}
-(void)zoneSplitHorizontally:(RRGZone*)zoneParent
{
    CCLOG(@"%s", __PRETTY_FUNCTION__);
    //横に分割
    RRGZone* zoneChild = [RRGZone zoneWithRect:zoneParent.zoneRect];
    [_zoneArray addObject:zoneChild];
    
    NSInteger splitCoordX = randomInteger(zoneParent.zoneLX + MinZoneSize,
                                          zoneParent.zoneHX - MinZoneSize + 1);
    
    CGRect newParentRect = CGRectMake(zoneParent.zoneLX,
                                      zoneParent.zoneLY,
                                      splitCoordX - zoneParent.zoneLX + 1,
                                      zoneParent.zoneHeight);
    zoneParent.zoneRect = newParentRect;
    CCLOG(@"zoneParent : %@", zoneParent.description);
    CGRect newChildRect = CGRectMake(splitCoordX,
                                     zoneChild.zoneLY,
                                     zoneChild.zoneHX - splitCoordX + 1,
                                     zoneParent.zoneHeight);
    zoneChild.zoneRect = newChildRect;
    CCLOG(@"zoneChild : %@", zoneChild.description);
    
    RRGCouple* couple = [RRGCouple coupleWithVorH:RRGCoupleHorizontal
                                          Zone0:zoneParent
                                          Zone1:zoneChild];
    [_coupleArray addObject:couple];
    
    zoneParent.cantSplitH = YES;
    [self zoneSplit:zoneParent pOneRoom:3];
    [self zoneSplit:zoneChild pOneRoom:3];
}

#pragma mark - moreCouple
-(void)moreCouple
{
    NSInteger zoneCount = [_zoneArray count];
    if (zoneCount <= 2) {
        return;
    }
    for (NSInteger i=0; i<10; i++) {
        NSInteger zone0index = randomInteger(0, zoneCount - 2);
        NSInteger zone1index = randomInteger(zone0index, zoneCount - 1);
        RRGZone* zone0 = _zoneArray[zone0index];
        RRGZone* zone1 = _zoneArray[zone1index];
        if (zone0.zoneHX == zone1.zoneLX
            && zone0.zoneLY <= zone1.zoneHY
            && zone1.zoneLY <= zone0.zoneHY) {
            RRGCouple* newCouple = [RRGCouple coupleWithVorH:RRGCoupleHorizontal
                                                     Zone0:zone0
                                                     Zone1:zone1];
            [_coupleArray addObject:newCouple];
            //NSLog(@"New couple horizontal");
        } else if (zone0.zoneHY == zone1.zoneLY
                   && zone0.zoneLX <= zone1.zoneHX
                   && zone1.zoneLX <= zone0.zoneHX) {
            RRGCouple* newCouple = [RRGCouple coupleWithVorH:RRGCoupleVertical
                                                     Zone0:zone0
                                                     Zone1:zone1];
            [_coupleArray addObject:newCouple];
            //NSLog(@"New couple vertical");
        }
    }
}

#pragma mark - roomMake
-(void)roomMake
{
    CCLOG(@"%s",__PRETTY_FUNCTION__);
    if ([_zoneArray count] == 1) {
        id obj = _zoneArray[0];
        NSAssert([obj isKindOfClass:[RRGZone class]], @"not Zone");
        RRGZone* zone = (RRGZone*)obj;
        CGRect roomRect = CGRectMake(zone.zoneLX + MarginBetweenZoneRoom,
                                     zone.zoneLY + MarginBetweenZoneRoom,
                                     zone.zoneWidth - MarginBetweenZoneRoom * 2,
                                     zone.zoneHeight - MarginBetweenZoneRoom * 2);
        RRGRoom* room = [RRGRoom roomWithRect:roomRect
                                     roomType:RRGRoomTypeNormal];
        [_roomArray addObject:room];
        zone.room = room;
        return;
    }
    for (RRGZone* zone in _zoneArray) {
        NSAssert([zone isKindOfClass:[RRGZone class]], @"not Zone");
        NSInteger roomWidth = randomInteger(MinRoomSize,
                                            zone.zoneWidth - MarginBetweenZoneRoom * 2);
        NSInteger roomHeight = randomInteger(MinRoomSize,
                                             zone.zoneHeight - MarginBetweenZoneRoom * 2);
        NSInteger roomX = randomInteger(zone.zoneLX + MarginBetweenZoneRoom,
                                        zone.zoneHX - MarginBetweenZoneRoom + 1
                                        - roomWidth);
        NSInteger roomY = randomInteger(zone.zoneLY + MarginBetweenZoneRoom,
                                        zone.zoneHY - MarginBetweenZoneRoom + 1
                                        - roomHeight);
        CCLOG(@"roomWidth = %zd roomHeight = %zd roomX = %zd roomY = %zd",
              roomWidth, roomHeight, roomX, roomY);
        CGRect roomRect = CGRectMake(roomX, roomY, roomWidth, roomHeight);
        RRGRoom* room = [RRGRoom roomWithRect:roomRect
                                     roomType:RRGRoomTypeNormal];
        [_roomArray addObject:room];
        zone.room = room;
    }
}

#pragma mark - mapMake
-(void)mapMake
{
    CCLOG(@"%s",__PRETTY_FUNCTION__);
    //room
    NSInteger roomCount = [_roomArray count];
    for (NSInteger i=0; i<roomCount; i++) {
        RRGRoom* room = _roomArray[i];
        NSAssert([room isKindOfClass:[RRGRoom class]], @"not Room");
        room.roomNum = i;
        for (NSInteger x=room.roomLX; x<=room.roomHX; x++) {
            for (NSInteger y=room.roomLY; y<=room.roomHY; y++) {
                [self setMapID:MapIDGround At:ccp(x,y)];
                [self setRoomMapID:i At:ccp(x,y)];
            }
        }
    }
    //connect couple
    for (RRGCouple* couple in _coupleArray) {
        NSAssert([couple isKindOfClass:[RRGCouple class]], @"not Couple");
        [self connectCouple:couple];
        //[self connectCouple:couple];
    }
}

-(void)connectCouple:(RRGCouple*)couple
{
    NSInteger p0x,p0y,p1x,p1y;
    RRGRoom* room0 = couple.zone0.room;
    RRGRoom* room1 = couple.zone1.room;
    if (couple.vorh == RRGCoupleHorizontal) {
        NSAssert(couple.zone0.zoneHX == couple.zone1.zoneLX,
                 @"Invalid couple zone0.hx:%zd zone1.lx:%zd",
                 couple.zone0.zoneHX,
                 couple.zone1.zoneLX);
        
        p0x = couple.zone0.zoneHX;
        p0y = randomInteger(room0.roomLY,
                            room0.roomHY);
        
        if ([self mapIDAt:ccp(p0x - 1, p0y)] == MapIDGround
            || [self mapIDAt:ccp(p0x - 1, p0y - 1)] == MapIDGround
            || [self mapIDAt:ccp(p0x - 1, p0y + 1)] == MapIDGround) {
            CCLOG(@"Fail to connect couple");
            return;
        }
        
        p1x = couple.zone1.zoneLX;
        p1y = randomInteger(room1.roomLY,
                            room1.roomHY);
        
        if ([self mapIDAt:ccp(p1x + 1, p1y)] == MapIDGround
            || [self mapIDAt:ccp(p1x + 1, p1y - 1)] == MapIDGround
            || [self mapIDAt:ccp(p1x + 1, p1y + 1)] == MapIDGround) {
            CCLOG(@"Fail to connect couple");
            return;
        }
        
        //draw paths
        CGPoint newGateOut0 = ccp(room0.roomHX + 1, p0y);
        CGPoint newGateOut1 = ccp(room1.roomLX - 1, p1y);
        CGPoint newGateIn0 = ccp(room0.roomHX, p0y);
        CGPoint newGateIn1 = ccp(room1.roomLX, p1y);
        
        [self drawPathFrom:newGateOut0 to:ccp(p0x,p0y)];
        [self drawPathFrom:ccp(p0x,p0y) to:ccp(p1x,p1y)];
        [self drawPathFrom:ccp(p1x,p1y) to:newGateOut1];
        
        [self setRoomMapID:room0.roomNum - 10 At:newGateOut0];
        [self setRoomMapID:room1.roomNum - 10 At:newGateOut1];
        
        [self setRoomMapID:room0.roomNum + 10 At:newGateIn0];
        [self setRoomMapID:room1.roomNum + 10 At:newGateIn1];
        
        [room0 addGateOut:newGateOut0 gateIn:newGateIn0];
        [room1 addGateOut:newGateOut1 gateIn:newGateIn1];
    } else if (couple.vorh == RRGCoupleVertical) {
        NSAssert(couple.zone0.zoneHY == couple.zone1.zoneLY,
                 @"Invalid couple zone0.hy:%zd zone1.ly:%zd",
                 couple.zone0.zoneHY,
                 couple.zone1.zoneLY);
        
        p0x = randomInteger(room0.roomLX,
                            room0.roomHX);
        p0y = couple.zone0.zoneHY;
        
        if ([self mapIDAt:ccp(p0x, p0y - 1)] == MapIDGround
            || [self mapIDAt:ccp(p0x - 1, p0y - 1)] == MapIDGround
            || [self mapIDAt:ccp(p0x + 1, p0y - 1)] == MapIDGround) {
            CCLOG(@"Fail to connect couple");
            return;
        }
        
        p1x = randomInteger(room1.roomLX,
                            room1.roomHX);
        p1y = couple.zone1.zoneLY;
        
        if ([self mapIDAt:ccp(p1x, p1y + 1)] == MapIDGround
            || [self mapIDAt:ccp(p1x - 1, p1y + 1)] == MapIDGround
            || [self mapIDAt:ccp(p1x + 1, p1y + 1)] == MapIDGround) {
            CCLOG(@"Fail to connect couple");
            return;
        }
        
        //draw paths
        CGPoint newGateOut0 = ccp(p0x, room0.roomHY + 1);
        CGPoint newGateOut1 = ccp(p1x, room1.roomLY - 1);
        CGPoint newGateIn0 = ccp(p0x, room0.roomHY);
        CGPoint newGateIn1 = ccp(p1x, room1.roomLY);
        
        [self drawPathFrom:newGateOut0 to:ccp(p0x,p0y)];
        [self drawPathFrom:ccp(p0x,p0y) to:ccp(p1x,p1y)];
        [self drawPathFrom:ccp(p1x,p1y) to:newGateOut1];
        
        [self setRoomMapID:room0.roomNum - 10 At:newGateOut0];
        [self setRoomMapID:room1.roomNum - 10 At:newGateOut1];
        
        [self setRoomMapID:room0.roomNum + 10 At:newGateIn0];
        [self setRoomMapID:room1.roomNum + 10 At:newGateIn1];
        
        [room0 addGateOut:newGateOut0 gateIn:newGateIn0];
        [room1 addGateOut:newGateOut1 gateIn:newGateIn1];
    }
}

-(void)drawPathFrom:(CGPoint)p0
                 to:(CGPoint)p1
{
    NSAssert(p0.x == p1.x || p0.y == p1.y,
             @"Can't draw path from p0%@ to p1%@",
             NSStringFromCGPoint(p0),
             NSStringFromCGPoint(p1));
    if (p0.x == p1.x) {
        NSInteger x = p0.x;
        NSInteger ymin = MIN(p0.y,p1.y);
        NSInteger ymax = MAX(p0.y,p1.y);
        for (NSInteger y=ymin; y<=ymax; y++) {
            [self setMapID:MapIDGround At:ccp(x,y)];
        }
    } else if (p0.y == p1.y) {
        NSInteger xmin = MIN(p0.x,p1.x);
        NSInteger xmax = MAX(p0.x,p1.x);
        NSInteger y = p0.y;
        for (NSInteger x=xmin; x<=xmax; x++) {
            [self setMapID:MapIDGround At:ccp(x,y)];
        }
    }
}

#pragma mark - mapIDMap and roomMap
-(MapID)mapIDAt:(CGPoint)p
{
    return [_mapIDMap[(NSInteger)p.x][(NSInteger)p.y] integerValue];
}
-(void)setMapID:(MapID)mapID
             At:(CGPoint)p
{
    _mapIDMap[(NSInteger)p.x][(NSInteger)p.y] = [NSNumber numberWithInteger:mapID];
}
-(NSInteger)roomMapIDAt:(CGPoint)p
{
    return [_roomIDMap[(NSInteger)p.x][(NSInteger)p.y] integerValue];
}
-(void)setRoomMapID:(NSInteger)mapID
                 At:(CGPoint)p
{
    _roomIDMap[(NSInteger)p.x][(NSInteger)p.y] = [NSNumber numberWithInteger:mapID];
}


///

/*
-(void)mazeMake:(RRGZone*)zone
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    Room* room = zone.room;
    if (room.width <= 4 || room.height <= 4) {
        NSLog(@"Room(width:%d height:%d) is too small to make maze.",
              room.width,room.height);
        return;
    }
    int newLX = room.LX;
    int newLY = room.LY;
    //fill room
    for (int x=newLX; x<=room.HX; x++) {
        for (int y=newLY; y<=room.HY; y++) {
            [self setMapValueOnTilePos:ccp(x,y) mapVal:MID_MAZE];
        }
    }
    //上下
    for (int x=newLX; x<=room.HX; x++) {
        if ([self mapValueOnTilePos:ccp(x,newLY-1)] >= 0) {
            [self setMapValueOnTilePos:ccp(x,newLY-1) mapVal:MID_PATH];
        }
        if ([self mapValueOnTilePos:ccp(x,room.HY+1)] >= 0) {
            [self setMapValueOnTilePos:ccp(x,room.HY+1) mapVal:MID_PATH];
        }
    }
    //左右
    for (int y=newLY; y<=room.HY; y++) {
        if ([self mapValueOnTilePos:ccp(newLX-1,y)] >= 0) {
            [self setMapValueOnTilePos:ccp(newLX-1,y) mapVal:MID_PATH];
        }
        if ([self mapValueOnTilePos:ccp(room.HX+1,y)] >= 0) {
            [self setMapValueOnTilePos:ccp(room.HX+1,y) mapVal:MID_PATH];
        }
    }
    //resize room horizontal
    if (room.width % 2 == 0) {
        for (int y=newLY; y<=room.HY; y++) {
            if ([self mapValueOnTilePos:ccp(newLX-1,y)] >= 0) {
                [self setMapValueOnTilePos:ccp(newLX,y) mapVal:MID_PATH];
                [self setMapValueOnTilePos:ccp(newLX+1,y) mapVal:MID_PATH];
            } else {
                [self setMapValueOnTilePos:ccp(newLX,y) mapVal:_wall];
            }
        }
        newLX++;
    }
    //resize room vertical
    if (room.height % 2 == 0) {
        for (int x=newLX; x<=room.HX; x++) {
            if ([self mapValueOnTilePos:ccp(x,newLY-1)] >= 0) {
                [self setMapValueOnTilePos:ccp(x,newLY) mapVal:MID_PATH];
                [self setMapValueOnTilePos:ccp(x,newLY+1) mapVal:MID_PATH];
            } else {
                [self setMapValueOnTilePos:ccp(x,newLY) mapVal:_wall];
            }
        }
        newLY++;
    }
    //柱
    for (int x=newLX+1; x<=room.HX-1; x+=2) {
        for (int y=newLY+1; y<=room.HY-1; y+=2) {
            [self setMapValueOnTilePos:ccp(x,y) mapVal:_wall];
        }
    }
    int direction;
    CGPoint vector,dest;
    for (int y=newLY+1; y<=room.HY-1; y+=2) {
        for (int x=newLX+1; x<=room.HX-1; x+=2) {
            direction = [RoboRogue randomIntRangeFrom:0 To:3] * 2;
            for (int i=0; i<=6; i+=2) {
                if (y == newLY + 1
                    || [RoboRogue correctDirection:direction + i] != 4) {
                    vector = [RoboRogue vectorFromDirection:[RoboRogue correctDirection:direction + i]];
                    dest = ccpAdd(ccp(x,y), vector);
                    if ([self mapValueOnTilePos:dest] == MID_MAZE) {
                        [self setMapValueOnTilePos:dest mapVal:_wall];
                        break;
                    }
                }
            }
        }
    }
    [_zoneArray removeObject:zone];
}
-(void)moreLine
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    if ([_zoneArray count] <= 1) {
        return;
    }
    for (Zone* zone in _zoneArray) {
        [self randomLine:North zone:zone];
        [self randomLine:East zone:zone];
        [self randomLine:South zone:zone];
        [self randomLine:West zone:zone];
    }
}
-(BOOL)isValidTilePosForMoreLine:(CGPoint)tilePos
                        zoneRect:(CGRect)zoneRect
{
    if (2 <= tilePos.x && tilePos.x <= _mapSize.width - 3
        && 2 <= tilePos.y && tilePos.y <= _mapSize.height - 3
        && CGRectContainsPoint(zoneRect, tilePos)) {
        return YES;
    }
    return NO;
}

-(void)randomLine:(int)direction
             zone:(Zone*)zone
{
    Room* room = zone.room;
    int gateX,gateY;
    switch (direction) {
        case North:
        {
            //上に
            gateX = [RoboRogue randomIntRangeFrom:room.LX To:room.HX];
            gateY = room.HY;
            break;
        }
        case South:
        {
            //下に
            gateX = [RoboRogue randomIntRangeFrom:room.LX To:room.HX];
            gateY = room.LY;
            break;
        }
        case East:
        {
            //右に
            gateX = room.HX;
            gateY = [RoboRogue randomIntRangeFrom:room.LY To:room.HY];
            break;
        }
        case West:
        {
            //左に
            gateX = room.LX;
            gateY = [RoboRogue randomIntRangeFrom:room.LY To:room.HY];
            break;
        }
        default:
            return;
    }
    CGPoint vector = [RoboRogue vectorFromDirection:direction];
    int dirR = [RoboRogue correctDirection:direction + 2];
    int dirL = [RoboRogue correctDirection:direction - 2];
    CGPoint vR = [RoboRogue vectorFromDirection:dirR];
    CGPoint vL = [RoboRogue vectorFromDirection:dirL];
    CGPoint masu1 = ccp(gateX + vector.x,gateY + vector.y);
    CGPoint masu2 = ccp(gateX + vector.x * 2,gateY + vector.y * 2);
    //１マス目チェック
    if (!([self isValidTilePosForMoreLine:masu1
                                 zoneRect:zone.zoneRect]
          && [self mapValueOnTilePos:masu1] < 0
          && [self mapValueOnTilePos:ccpAdd(masu1, vR)] < 0
          && [self mapValueOnTilePos:ccpAdd(masu1, vL)] < 0)) {
        return;
    }
    //２マス目チェック
    if (!([self isValidTilePosForMoreLine:masu2
                                 zoneRect:zone.zoneRect]
          && [self mapValueOnTilePos:masu2] < 0)) {
        return;
    }
    [self drawPathsFromNewGate:ccp(gateX,gateY) inRoom:room];
    //１マス目
    [self setMapValueOnTilePos:masu1 mapVal:room.roomNum + 200];
    //２マス目
    [self setMapValueOnTilePos:masu2 mapVal:MID_PATH];
    //３マス目以降
    int random,direction2;
    int x = masu2.x;
    int y = masu2.y;
    while (YES) {
        random = [RoboRogue randomIntRangeFrom:0 To:2];
        switch (random) {
            case 0:
                direction2 = direction;
                break;
            case 1:
                direction2 = [RoboRogue correctDirection:direction-2];
                break;
            case 2:
                direction2 = [RoboRogue correctDirection:direction+2];
                break;
        }
        vector = [RoboRogue vectorFromDirection:direction2];
        x += vector.x;
        y += vector.y;
        int count;
        if ([self isValidTilePosForMoreLine:ccp(x,y) zoneRect:zone.zoneRect]
            && [self mapValueOnTilePos:ccp(x,y)] < 0) {
            count = 0;
            if ([self mapValueOnTilePos:ccp(x-1,y)] >= 0) {
                count++;
            }
            if ([self mapValueOnTilePos:ccp(x+1,y)] >= 0) {
                count++;
            }
            if ([self mapValueOnTilePos:ccp(x,y-1)] >= 0) {
                count++;
            }
            if ([self mapValueOnTilePos:ccp(x,y+1)] >= 0) {
                count++;
            }
            if (count >= 2) {
                break;
            }
            [self setMapValueOnTilePos:ccp(x,y) mapVal:MID_PATH];
        } else {
            break;
        }
    }
}
 */
@end
