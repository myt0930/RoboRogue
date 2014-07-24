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
                               @"SilverTamara",
                               @"GoldTamara"]];
}
@end
@implementation SilverTamara
@end
@implementation GoldTamara
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

@implementation SteelTamara
@end
@implementation CrystallineTamara
@end
@implementation BroodTamara
@end
@implementation ToxinTamara
@end
@implementation PlagueTamara
@end
@implementation MesmericTamara
@end
@implementation BombTamara
@end
@implementation DementiaTamara
@end
@implementation ShiftingTamara
@end
@implementation BigTamara
@end
@implementation BigBombTamara
@end
@implementation BigSilverTamara
@end
@implementation BigGoldTamara
@end
@implementation BigCrystallineTamara
@end
@implementation DevilTamara
@end
@implementation KingTamara
@end