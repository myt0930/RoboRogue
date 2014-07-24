//
//  RRGEnemy.h
//  RoboRogue
//
//  Created by 山本政徳 on 2014/02/26.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "RRGCharacter.h"

@class Player;

@interface RRGEnemy : RRGCharacter <NSCoding>
//profile
@property (nonatomic) NSInteger pDropItem;
@property (nonatomic) NSString* itemNameToDrop;
@property (nonatomic, copy) NSString* levelRaiseTo;
@property (nonatomic, copy) NSString* levelDropTo;
-(void)setLevelNamesArray:(NSArray*)array;
@end
