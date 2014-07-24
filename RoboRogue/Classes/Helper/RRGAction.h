//
//  RRGAction.h
//  RoboRogue
//
//  Created by 山本政徳 on 2014/02/25.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "CCActionInterval.h"

#define RRGActionFromSequence(target, b, seqArray)\
([seqArray count] == 0)?\
nil\
:[RRGAction actionWithTarget:(target)\
action:[CCActionSequence actionWithArray:(seqArray)]\
forSpawn:(b)]


@interface RRGAction : CCActionInterval //<NSCopying>

/** This is the target that the action will be forced to run with */
@property(readwrite,nonatomic,retain) id forcedTarget;
@property(readwrite,nonatomic,retain) CCActionFiniteTime* action;
@property(nonatomic) BOOL forSpawn;

/** Create an action with the specified action and forced target */
+(instancetype)actionWithTarget:(id)target
                         action:(CCActionFiniteTime*)action
                       forSpawn:(BOOL)forSpawn;
+(instancetype)actionWithTarget:(id)target
                         action:(CCActionFiniteTime*)action;

/** Init an action with the specified action and forced target */
-(instancetype)initWithTarget:(id)target
                       action:(CCActionFiniteTime*)action
                     forSpawn:(BOOL)forSpawn;
@end