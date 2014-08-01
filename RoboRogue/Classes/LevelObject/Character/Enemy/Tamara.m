//
//  Slime.m
//  RoboRogue
//
//  Created by 山本政徳 on 2014/02/28.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "Tamara.h"
#import "RRGCategories.h"

@implementation Tamara
-(void)setDefaultAttributes
{
    [super setDefaultAttributes];
    self.isTamara = YES;
    [self setLevelNamesArray:@[@"Tamara",
                               @"Silver_Tamara",
                               @"Gold_Tamara"]];
}
@end
@implementation Silver_Tamara
@end
@implementation Gold_Tamara
@end

#pragma mark - subspecies
@implementation TamaraSubspecies
-(void)setDefaultAttributes
{
    [super setDefaultAttributes];
    [self setLevelNamesArray:@[@"Tamara",
                               self.className]];
}
@end

@implementation Steel_Tamara
@end
@implementation Crystalline_Tamara
@end
@implementation Brood_Tamara
@end
@implementation Toxin_Tamara
@end
@implementation Plague_Tamara
@end
@implementation Mesmeric_Tamara
@end
@implementation Bomb_Tamara
@end
@implementation Dementia_Tamara
@end
@implementation Shifting_Tamara
@end
@implementation Big_Tamara
@end
@implementation Big_Bomb_Tamara
@end
@implementation Big_Silver_Tamara
@end
@implementation Big_Gold_Tamara
@end
@implementation Big_Crystalline_Tamara
@end
@implementation Devil_Tamara
@end
@implementation King_Tamara
@end