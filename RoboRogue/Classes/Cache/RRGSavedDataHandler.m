//
//  RRGSavedDataHandler.m
//  RoboRogue
//
//  Created by 山本政徳 on 2014/06/14.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "RRGSavedDataHandler.h"
#import "RRGCategories.h"

static NSString* const kGameSpeed = @"gameSpeed";
static NSString* const kInvalidShutDown = @"invalidShutDown";

static NSString* const kLevelPath = @"level.dat";

@implementation RRGSavedDataHandler
{
    NSUserDefaults* _defaults;
}
+(RRGSavedDataHandler*)sharedInstance
{
    static RRGSavedDataHandler* sharedSingleton;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedSingleton = [[RRGSavedDataHandler alloc] initSharedInstance];
    });
    return sharedSingleton;
}
-(instancetype)initSharedInstance
{
    self = [super init];
    if (self) {
        // 初期化処理
        [self registerInitialValues];
    }
    return self;
}
-(instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}
-(void)registerInitialValues
{
    NSString* userDefaultsValuesPath = [[NSBundle mainBundle] pathForResource:@"UserDefaults"
                                                                       ofType:@"plist"];
    NSDictionary* userDefaultsValuesDict = [NSDictionary dictionaryWithContentsOfFile:userDefaultsValuesPath];
    
    _defaults = [NSUserDefaults standardUserDefaults];
    [_defaults registerDefaults:userDefaultsValuesDict];
}
-(void)reset
{
    NSString *domainName = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:domainName];
    
    [self registerInitialValues];
}
#pragma mark - save data
-(CGFloat)gameSpeed
{
    return [_defaults CGFloatForKey:kGameSpeed];
}
-(void)setGameSpeed:(CGFloat)gameSpeed
{
    [_defaults setCGFloat:gameSpeed forKey:kGameSpeed];
    [_defaults synchronize];
}
-(BOOL)invalidShutDown
{
    return [_defaults boolForKey:kInvalidShutDown];
}
-(void)setInvalidShutDown:(BOOL)invalidShutDown
{
    [_defaults setBool:invalidShutDown forKey:kInvalidShutDown];
    [_defaults synchronize];
}
-(RRGLevel*)level
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:kLevelPath];
    return [NSKeyedUnarchiver unarchiveObjectWithFile:path];
}
-(void)setLevel:(RRGLevel *)level
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:kLevelPath];
    [NSKeyedArchiver archiveRootObject:level toFile:path];
}
@end