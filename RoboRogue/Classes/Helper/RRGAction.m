//
//  RRGAction.m
//  RoboRogue
//
//  Created by 山本政徳 on 2014/02/25.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "RRGAction.h"

@implementation RRGAction

+(instancetype)actionWithTarget:(id)target
                         action:(CCActionFiniteTime *)action
                       forSpawn:(BOOL)forSpawn
{
    return [(RRGAction*)[self alloc] initWithTarget:target
                                                    action:action
                                           forSpawn:forSpawn];
}
+(instancetype)actionWithTarget:(id)target
                         action:(CCActionFiniteTime *)action
{
    return [(RRGAction*)[self alloc] initWithTarget:target
                                             action:action
                                           forSpawn:NO];
}
-(instancetype)initWithTarget:(id)target
                       action:(CCActionFiniteTime *)action
                     forSpawn:(BOOL)forSpawn
{
    self = [super initWithDuration:action.duration];
    if(self)
	{
		_forcedTarget = target;
		_action = action;
        _forSpawn = forSpawn;
	}
	return self;
}

-(id)copyWithZone:(NSZone*)zone
{
	CCAction *copy = [(RRGAction*) [[self class] allocWithZone: zone]
                      initWithTarget:_forcedTarget
                      action:[_action copy]
                      forSpawn:_forSpawn];
	return copy;
}

-(void)startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
	[_action startWithTarget:_forcedTarget];
}

-(void)stop
{
	[_action stop];
}

-(void)update:(CCTime)time
{
	[_action update:time];
}

-(BOOL)isDone
{
    return [_action isDone];
}
@end