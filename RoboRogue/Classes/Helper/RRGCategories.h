//
//  RRGCategories.h
//  RoboRogue
//
//  Created by 山本政徳 on 2014/03/01.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "cocos2d.h"
#import "CCAnimation.h"

//NSCoding
#define OBJC_STRINGIFY(x) @#x
#define encodeObject(x) [coder encodeObject:x forKey:OBJC_STRINGIFY(x)]
#define decodeObject(x) x = [coder decodeObjectForKey:OBJC_STRINGIFY(x)]
#define encodeCGRect(x) [coder encodeCGRect:x forKey:OBJC_STRINGIFY(x)]
#define decodeCGRect(x) x = [coder decodeCGRectForKey:OBJC_STRINGIFY(x)]
#define encodeCGPoint(x) [coder encodeCGPoint:x forKey:OBJC_STRINGIFY(x)]
#define decodeCGPoint(x) x = [coder decodeCGPointForKey:OBJC_STRINGIFY(x)]
#define encodeCGSize(x) [coder encodeCGSize:x forKey:OBJC_STRINGIFY(x)]
#define decodeCGSize(x) x = [coder decodeCGSizeForKey:OBJC_STRINGIFY(x)]
#define encodeInteger(x) [coder encodeInteger:x forKey:OBJC_STRINGIFY(x)]
#define decodeInteger(x) x = [coder decodeIntegerForKey:OBJC_STRINGIFY(x)]
#define encodeCGFloat(x) [coder encodeCGFloat:x forKey:OBJC_STRINGIFY(x)]
#define decodeCGFloat(x) x = [coder decodeCGFloatForKey:OBJC_STRINGIFY(x)]
#define encodeBool(x) [coder encodeBool:x forKey:OBJC_STRINGIFY(x)]
#define decodeBool(x) x = [coder decodeBoolForKey:OBJC_STRINGIFY(x)]

#define CGRectForEach(rect) NSUInteger LX = CGRectGetMinX(rect);\
NSUInteger LY = CGRectGetMinY(rect);\
NSUInteger HX = LX + CGRectGetWidth(rect) - 1;\
NSUInteger HY = LY + CGRectGetHeight(rect) - 1;\
for (NSUInteger x = LX; x <= HX; x++)\
for (NSUInteger y = LY; y <= HY; y++)

@class RRGAction;

@interface NSObject (Extended)
-(NSString*)className;
@end

@interface NSNumber (CGFloat)
+(NSNumber*)numberWithCGFloat:(CGFloat)val;
-(CGFloat)CGFloatValue;
@end

@interface NSUserDefaults (CGFloat)
-(CGFloat)CGFloatForKey:(NSString*)defaultName;
-(void)setCGFloat:(CGFloat)value forKey:(NSString*)defaultName;
@end

@interface NSCoder (CGFloat)
-(void)encodeCGFloat:(CGFloat)realv forKey:(NSString *)key;
-(CGFloat)decodeCGFloatForKey:(NSString*)key;
@end

@interface NSArray (Extended)
-(id)objectAtRandom;
-(id)objectAtRandomExceptIndex:(NSInteger)i;
-(NSArray*)makeRandmizedArray;
-(NSArray*)reverseArray;
@end

@interface NSMutableArray (Extended)
-(void)replaceObject:(id)anObject withObject:(id)another;
@end

@interface CCNode (Extended)
-(void)runAction:(CCActionFiniteTime*)action
      completion:(void (^)(void))block;
-(void)runAction:(CCActionFiniteTime*)action
      completion:(SEL)selecter
          target:(id)target;

@end

@interface CCAnimation (Extended)
+(CCAnimation*)animationWithSpriteFrameNames:(NSArray*)names
                                       delay:(CGFloat)delay;
+(CCAnimation*)animationWithFormat:(NSString*)format
                        frameCount:(NSInteger)frameCount
                             delay:(CGFloat)delay;
@end

@interface CCActionAnimate (Extended)
+(CCActionAnimate*)animateWithSpriteFrameNames:(NSArray*)names
                                         delay:(CGFloat)delay;
+(CCActionAnimate*)animateWithFormat:(NSString*)format
                          frameCount:(NSUInteger)frameCount
                               delay:(CGFloat)delay;
@end

@interface CCActionMoveBy (Extended)
+(instancetype)actionWithVelocity:(CCTime)velocity
                         position:(CGPoint)deltaPosition;
@end

@interface CCActionSoundEffect (Extended)
+(instancetype)actionWithSoundFile:(NSString *)file;
@end