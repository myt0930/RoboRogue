//
//  RRGGameScene.h
//  RoboRogue
//
//  Created by 山本政徳 on 2014/07/08.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "CCScene.h"

#define sharedGameScene [RRGGameScene sharedInstance]

@class RRGLevel, RRGPlayer;

@interface RRGGameScene : CCScene
@property (nonatomic) RRGLevel* level;

+(instancetype)sharedInstance;
-(void)saveLevel;

-(void)goToDungeon:(NSString*)dungeonName
          floorNum:(NSUInteger)floorNum
            player:(RRGPlayer*)player
   playerDirection:(CGPoint)playerDirection;
-(void)goToInitialDungeon;
@end
