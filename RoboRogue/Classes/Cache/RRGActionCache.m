//
//  RRGActionCache.m
//  RoboRogue
//
//  Created by 山本政徳 on 2014/06/14.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "RRGActionCache.h"
#import "RRGCategories.h"

@implementation RRGActionCache
{
    NSCache* _cache;
}
+(RRGActionCache*)sharedInstance
{
    static RRGActionCache* sharedSingleton;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedSingleton = [[RRGActionCache alloc] initSharedInstance];
    });
    return sharedSingleton;
}
-(instancetype)initSharedInstance
{
    self = [super init];
    if (self) {
        // 初期化処理
        _cache = [NSCache new];
    }
    return self;
}
-(instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}
-(CCActionAnimate*)animateWithFormat:(NSString*)format
                          frameCount:(NSUInteger)frameCount
                               delay:(CGFloat)delay
{
    NSString* key = [format stringByAppendingString:
                     [NSString stringWithFormat:@"/%tu/%f",
                      frameCount,
                      delay]];
    CCActionAnimate* action = [_cache objectForKey:key];
    if (action) {
        return [action copy];
    }
    action = [CCActionAnimate animateWithFormat:format
                                     frameCount:frameCount
                                          delay:delay];
    [_cache setObject:action forKey:key];
    return [action copy];
}
-(CCAction*)actionForKey:(NSString *)key
{
    return [[_cache objectForKey:key] copy];
}
-(void)setAction:(CCAction *)action
          forKey:(NSString *)key
{
    [_cache setObject:action forKey:key];
}
@end