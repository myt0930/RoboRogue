//
//  RRGLevel+MapID.h
//  RoboRogue
//
//  Created by 山本政徳 on 2014/06/22.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "RRGLevel.h"

//MapID
typedef NS_ENUM(NSInteger, MapID)
{
    MapIDGround = 0,
    MapIDLava = -1,
    MapIDWater = -2,
    MapIDSky = -3,
    MapIDWall = -4,
    MapIDWallFragile = -5,
    MapIDWallUnbreakable = -6
};

extern const NSInteger RoomMapIDNotRoom;

@interface RRGLevel (MapID)
-(MapID)mapIDAtTileCoord:(CGPoint)tileCoord;
-(NSInteger)roomMapIDAtTileCoord:(CGPoint)tileCoord;
-(NSInteger)roomNumAtTileCoord:(CGPoint)tileCoord;
-(RRGRoom*)roomAtTileCoord:(CGPoint)tileCoord;
-(RRGRoom*)roomForRoomNum:(NSUInteger)roomNum;
-(BOOL)inRoomAtTileCoord:(CGPoint)tileCoord;
-(BOOL)gateOutOfRoom:(RRGRoom *)room atTileCoord:(CGPoint)tileCoord;
-(BOOL)gateInOfRoom:(RRGRoom *)room atTileCoord:(CGPoint)tileCoord;

-(BOOL)groundAtTileCoord:(CGPoint)tileCoord;
-(BOOL)wallAtTileCoord:(CGPoint)tileCoord;
-(BOOL)walkableWallAtTileCoord:(CGPoint)tileCoord;
-(BOOL)unwalkableWallAtTileCoord:(CGPoint)tileCoord;
-(BOOL)lavaAtTileCoord:(CGPoint)tileCoord;
-(BOOL)waterAtTileCoord:(CGPoint)tileCoord;
-(BOOL)skyAtTileCoord:(CGPoint)tileCoord;
@end
