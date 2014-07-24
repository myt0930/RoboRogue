//
//  RRGClippingNode.m
//  RoboRogue
//
//  Created by 山本政徳 on 2014/05/21.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "RRGClippingNode.h"

@implementation RRGClippingNode
+(instancetype)nodeWithViewRect:(CGRect)viewRect
                    contentSize:(CGSize)contentSize
{
    return [[self alloc] initWithViewRect:viewRect
                              contentSize:contentSize];
}
-(instancetype)initWithViewRect:(CGRect)viewRect
                    contentSize:(CGSize)contentSize
{
    self = [super init];
    if (self) {
        _viewRect = viewRect;
        _contentSize = contentSize;
    }
    return self;
}
-(void)visit:(CCRenderer *)renderer parentTransform:(const GLKMatrix4 *)parentTransform
{
    CGPoint worldPosition = [self convertToWorldSpace:self.viewRect.origin];
    const CGFloat s = [[CCDirector sharedDirector] contentScaleFactor];
    
    CGFloat w = self.viewRect.size.width;
    CGFloat h = self.viewRect.size.height;
    [renderer enqueueBlock:^{
        glEnable(GL_SCISSOR_TEST);
        glScissor(worldPosition.x * s,
                  worldPosition.y * s,
                  w * s,
                  h * s);
    } globalSortOrder:0 debugLabel:nil threadSafe:YES];
    
    [super visit:renderer parentTransform:parentTransform];
    
    [renderer enqueueBlock:^{
        glDisable(GL_SCISSOR_TEST);
    } globalSortOrder:0 debugLabel:nil threadSafe:YES];
}
@end