//
//  RRGLevel+MapID.m
//  RoboRogue
//
//  Created by 山本政徳 on 2014/06/22.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "RRGLevel+MapID.h"

#import "RRGRoom.h"

const NSInteger RoomMapIDNotRoom = -11;

@implementation RRGLevel (MapID)
#pragma mark - mapID and roomNum
-(MapID)mapIDAtTileCoord:(CGPoint)tileCoord
{
    return [self.mapIDMap[(NSUInteger)tileCoord.x][(NSUInteger)tileCoord.y] integerValue];
}
-(NSInteger)roomMapIDAtTileCoord:(CGPoint)tileCoord
{
    return [self.roomIDMap[(NSUInteger)tileCoord.x][(NSUInteger)tileCoord.y] integerValue];
}
-(NSInteger)roomNumAtTileCoord:(CGPoint)tileCoord
{
    NSInteger roomMapID = [self roomMapIDAtTileCoord:tileCoord];
    if (roomMapID == RoomMapIDNotRoom) {
        return -1;
    }
    if (roomMapID < 0) {
        roomMapID += 10;
    }
    return roomMapID % 10;
}
-(RRGRoom*)roomAtTileCoord:(CGPoint)tileCoord
{
    NSInteger roomNum = [self roomNumAtTileCoord:tileCoord];
    if (roomNum == -1) {
        return nil;
    }
    return [self roomForRoomNum:roomNum];
}
-(RRGRoom*)roomForRoomNum:(NSUInteger)roomNum
{
    RRGRoom* room = self.roomArray[roomNum];
    if (room.roomType != RRGRoomTypeUnused) {
        return room;
    }
    return nil;
}
-(BOOL)inRoomAtTileCoord:(CGPoint)tileCoord
{
    return ([self roomMapIDAtTileCoord:tileCoord] >= 0)?YES:NO;
}
-(BOOL)gateOutOfRoom:(RRGRoom *)room atTileCoord:(CGPoint)tileCoord
{
    if (room == nil) {
        return NO;
    }
    return ([self roomMapIDAtTileCoord:tileCoord] == room.roomNum - 10)?YES:NO;
}
-(BOOL)gateInOfRoom:(RRGRoom *)room atTileCoord:(CGPoint)tileCoord
{
    if (room == nil) {
        return NO;
    }
    return ([self roomMapIDAtTileCoord:tileCoord] == room.roomNum + 10)?YES:NO;
}

#pragma mark - mapID at tileCoord
-(BOOL)groundAtTileCoord:(CGPoint)tileCoord
{
    return ([self mapIDAtTileCoord:tileCoord] == MapIDGround)?YES:NO;
}
-(BOOL)wallAtTileCoord:(CGPoint)tileCoord
{
    return ([self mapIDAtTileCoord:tileCoord] <= MapIDWall)?YES:NO;
}
-(BOOL)walkableWallAtTileCoord:(CGPoint)tileCoord
{
    return ([self mapIDAtTileCoord:tileCoord] == MapIDWall
            || [self mapIDAtTileCoord:tileCoord] == MapIDWallFragile)?YES:NO;
}
-(BOOL)unwalkableWallAtTileCoord:(CGPoint)tileCoord
{
    return ([self mapIDAtTileCoord:tileCoord] == MapIDWallUnbreakable)?YES:NO;
}
-(BOOL)lavaAtTileCoord:(CGPoint)tileCoord
{
    return ([self mapIDAtTileCoord:tileCoord] == MapIDLava)?YES:NO;
}
-(BOOL)waterAtTileCoord:(CGPoint)tileCoord
{
    return ([self mapIDAtTileCoord:tileCoord] == MapIDWater)?YES:NO;
}
-(BOOL)skyAtTileCoord:(CGPoint)tileCoord
{
    return ([self mapIDAtTileCoord:tileCoord] == MapIDSky)?YES:NO;
}
@end