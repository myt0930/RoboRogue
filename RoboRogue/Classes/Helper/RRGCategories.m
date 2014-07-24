//
//  RRGCategories.m
//  RoboRogue
//
//  Created by 山本政徳 on 2014/03/01.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "RRGCategories.h"
#import "RRGFunctions.h"

#pragma mark - NSObject
@implementation NSObject (Extended)
-(NSString*)className
{
    return NSStringFromClass([self class]);
}
@end

#pragma mark - NSNumber
@implementation NSNumber (CGFloat)
+(NSNumber*)numberWithCGFloat:(CGFloat)val
{
#if CGFLOAT_IS_DOUBLE
    return [NSNumber numberWithDouble:val];
#else
    return [NSNumber numberWithFloat:val];
#endif
}
-(CGFloat)CGFloatValue
{
#if CGFLOAT_IS_DOUBLE
    return [self doubleValue];
#else
    return [self floatValue];
#endif
}
@end

#pragma mark - NSUserDefaults
@implementation NSUserDefaults (CGFloat)
-(CGFloat)CGFloatForKey:(NSString *)defaultName
{
#if CGFLOAT_IS_DOUBLE
    return [self doubleForKey:defaultName];
#else
    return [self floatForKey:defaultName];
#endif
}
-(void)setCGFloat:(CGFloat)value forKey:(NSString *)defaultName
{
#if CGFLOAT_IS_DOUBLE
    [self setDouble:value forKey:defaultName];
#else
    [self setFloat:value forKey:defaultName];
#endif
}
@end

#pragma mark - NSCoder
@implementation NSCoder (CGFloat)
-(void)encodeCGFloat:(CGFloat)realv forKey:(NSString *)key
{
#if CGFLOAT_IS_DOUBLE
    return [self encodeDouble:realv forKey:key];
#else
    return [self encodeFloat:realv forKey:key];
#endif
}
-(CGFloat)decodeCGFloatForKey:(NSString*)key
{
#if CGFLOAT_IS_DOUBLE
    return [self decodeDoubleForKey:key];
#else
    return [self decodeFloatForKey:key];
#endif
}
@end

#pragma mark - NSArray
@implementation NSArray (Extended)
-(id)objectAtRandom
{
    if ([self count] == 0) {
        return nil;
    }
    NSInteger index = randomInteger(0, [self count] - 1);
    return [self objectAtIndex:index];
}
-(id)objectAtRandomExceptIndex:(NSInteger)i
{
    if ([self count] == 0) {
        return nil;
    }
    NSInteger index = randomInteger(0, [self count] - 1);
    if (index == i) {
        if (--index < 0) {
            index = [self count] - 1;
        }
    }
    return [self objectAtIndex:index];
}
-(NSArray *)makeRandmizedArray
{
    NSMutableArray *results = [NSMutableArray arrayWithArray:self];
    
    NSInteger i = [results count];
    
    while (--i >0)
    {
        NSInteger j = arc4random_uniform((u_int32_t)(i+1));
        [results exchangeObjectAtIndex:i withObjectAtIndex:j];
    }
    
    return [NSArray arrayWithArray:results];
}
-(NSArray*)reverseArray
{
    return [[self reverseObjectEnumerator] allObjects];
}
@end

#pragma mark - NSMutableArray
@implementation NSMutableArray (Extended)
-(void)replaceObject:(id)anObject withObject:(id)another
{
    NSInteger count = [self count];
    for (NSInteger i = 0; i < count; i++) {
        if (self[i] == anObject) {
            [self removeObjectAtIndex:i];
            [self insertObject:another atIndex:i];
        }
    }
}
@end

#pragma mark - CCNode
@implementation CCNode (Extended)
-(void)runAction:(CCActionFiniteTime*)action
      completion:(void (^)(void))block
{
    CCActionCallBlock* callBlock = [CCActionCallBlock actionWithBlock:block];
    CCActionSequence* seq = [CCActionSequence actions:action, callBlock, nil];
    [self runAction:seq];
}
-(void)runAction:(CCActionFiniteTime*)action
      completion:(SEL)selecter
          target:(id)target
{
    CCActionCallFunc* callFunc = [CCActionCallFunc actionWithTarget:target
                                                           selector:selecter];
    CCActionSequence* seq = [CCActionSequence actions:action, callFunc, nil];
    [self runAction:seq];
}
@end

#pragma mark - CCAnimation
@implementation CCAnimation (Extended)
+(CCAnimation*) animationWithSpriteFrameNames:(NSArray*)names
                                        delay:(CGFloat)delay
{
	NSMutableArray* frames = [NSMutableArray arrayWithCapacity:[names count]];
	for (NSString* name in names)
	{
		CCSpriteFrameCache* frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
		CCSpriteFrame* frame = [frameCache spriteFrameByName:name];
		[frames addObject:frame];
	}
	// create an animation object from all the sprite animation frames
	return [CCAnimation animationWithSpriteFrames:frames
                                            delay:delay];
}
+(CCAnimation*) animationWithFormat:(NSString*)format
                         frameCount:(NSInteger)frameCount
                              delay:(CGFloat)delay
{
    NSMutableArray* names = [NSMutableArray arrayWithCapacity:frameCount];
    for (NSInteger i = 1; i <= frameCount; i++) {
        [names addObject:[NSString stringWithFormat:format, i]];
    }
    return [CCAnimation animationWithSpriteFrameNames:names
                                                delay:delay];
}
@end

#pragma mark - CCActionAnimate
@implementation CCActionAnimate (Extended)
+(CCActionAnimate*)animateWithSpriteFrameNames:(NSArray *)names
                                         delay:(CGFloat)delay
{
    return [CCActionAnimate actionWithAnimation:
            [CCAnimation animationWithSpriteFrameNames:names
                                                 delay:delay]];
}
+(CCActionAnimate*)animateWithFormat:(NSString *)format
                          frameCount:(NSUInteger)frameCount
                               delay:(CGFloat)delay
{
    return [CCActionAnimate actionWithAnimation:
            [CCAnimation animationWithFormat:format
                                  frameCount:frameCount
                                       delay:delay]];
}
@end

#pragma mark - CCActionMoveBy
@implementation CCActionMoveBy (Extended)
+(instancetype)actionWithVelocity:(CCTime)velocity
                         position:(CGPoint)deltaPosition
{
    CCTime duration = velocity * MAX(ABS(deltaPosition.x),
                                     ABS(deltaPosition.y));
    return [CCActionMoveBy actionWithDuration:duration position:deltaPosition];
}
@end

#pragma mark - CCActionSoundEffect
@implementation CCActionSoundEffect (Extended)
+(instancetype)actionWithSoundFile:(NSString *)file
{
    return [[self alloc] initWithSoundFile:file
                                             pitch:1.0f
                                               pan:0.0f
                                              gain:1.0f];
}
@end