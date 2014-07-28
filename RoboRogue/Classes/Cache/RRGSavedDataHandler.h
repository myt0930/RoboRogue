//
//  RRGSavedDataHandler.h
//  RoboRogue
//
//  Created by 山本政徳 on 2014/06/14.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DelayAnimation 0.1f
#define VelocityWalk 0.2f * [RRGSavedDataHandler sharedInstance].gameSpeed
#define VelocityJump 0.05f * [RRGSavedDataHandler sharedInstance].gameSpeed
#define VelocityMagicBullet 0.1f * [RRGSavedDataHandler sharedInstance].gameSpeed
#define DurationAttack 0.2f * [RRGSavedDataHandler sharedInstance].gameSpeed
#define DurationBlink 0.1f * [RRGSavedDataHandler sharedInstance].gameSpeed

#define sharedSavedDataHandler [RRGSavedDataHandler sharedInstance]

@class RRGLevel;

@interface RRGSavedDataHandler : NSObject
+(RRGSavedDataHandler*)sharedInstance;

//settings
@property (nonatomic) CGFloat gameSpeed;
@property (nonatomic) BOOL invalidShutDown;

@property (nonatomic) RRGLevel* level;
@end