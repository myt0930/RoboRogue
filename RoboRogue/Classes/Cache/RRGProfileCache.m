//
//  RRGProfileCache.m
//  RoboRogue
//
//  Created by 山本政徳 on 2014/03/10.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "RRGProfileCache.h"

@implementation RRGProfileCache
{
    NSCache* _cache;
}
+(RRGProfileCache*)sharedInstance
{
    static RRGProfileCache* sharedSingleton;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedSingleton = [[RRGProfileCache alloc] initSharedInstance];
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
#pragma mark - get profile
-(NSDictionary*)profileForKey:(NSString*)key
{
    NSDictionary* profile = [_cache objectForKey:key];
    if (profile) {
        return profile;
    }
    NSString* path = [[NSBundle mainBundle] pathForResource:key
                                                     ofType:@"plist"];
    if (path == nil) {
        CCLOG(@"cannot find path of profile %@", key);
        return nil;
    }
    profile = [NSDictionary dictionaryWithContentsOfFile:path];
    if (profile) {
        [_cache setObject:profile forKey:key];
    }
    return profile;
}
@end