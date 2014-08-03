//
//  RRGGameScene.h
//  RoboRogue
//
//  Created by 山本政徳 on 2014/07/08.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "CCScene.h"

#define sharedGameScene [RRGGameScene sharedInstance]

@class RRGLevel, RRGPlayer, CCNodeColor;

@interface RRGGameScene : CCScene
@property (nonatomic) NSDictionary* dungeonProfile;
@property (nonatomic) RRGLevel* level;
@property (nonatomic) CCNodeColor* black;

@property (nonatomic, readonly) NSUInteger goal;
@property (nonatomic, readonly) NSString* dungeonName;
@property (nonatomic, readonly) BOOL displayFloorNum;
@property (nonatomic, readonly) BOOL displayMapLayer;
@property (nonatomic, readonly) NSArray* initialItems;

+(instancetype)sharedInstance;
-(void)saveLevel;

-(void)goToDungeon:(NSString*)dungeonName
          floorNum:(NSUInteger)floorNum
            player:(RRGPlayer*)player
   playerDirection:(CGPoint)playerDirection;
-(void)goToFloorNum:(NSUInteger)floorNum
             player:(RRGPlayer*)player
    playerDirection:(CGPoint)playerDirection;
-(void)goToInitialDungeon;
@end
