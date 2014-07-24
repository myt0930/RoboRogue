//
//  RRGMap.h
//  RoboRogue
//
//  Created by 山本政徳 on 2014/03/01.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RRGMap : NSObject
@property (nonatomic) NSMutableArray* mapIDMap;
@property (nonatomic) NSMutableArray* roomIDMap;
@property (nonatomic) NSMutableArray* zoneArray;
@property (nonatomic) NSMutableArray* roomArray;
@property (nonatomic) NSMutableArray* coupleArray;

+(instancetype)mapWithProfile:(NSDictionary*)profile;
@end