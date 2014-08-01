//
//  RRGLevel+TurnSequence.h
//  RoboRogue
//
//  Created by 山本政徳 on 2014/06/30.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "RRGLevel.h"

@interface RRGLevel (TurnSequence)
-(void)addAction:(CCAction*)action;
-(void)turnStartPhase;
@end
