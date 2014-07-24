//
//  Slime.h
//  RoboRogue
//
//  Created by 山本政徳 on 2014/02/28.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "RRGEnemy.h"

@interface Tamara : RRGEnemy <NSCoding>
@end
@interface SilverTamara : Tamara <NSCoding>
@end
@interface GoldTamara : Tamara <NSCoding>
@end

@interface TamaraSubspecies : Tamara <NSCoding>
@end

@interface SteelTamara : TamaraSubspecies <NSCoding>
@end

@interface CrystallineTamara : TamaraSubspecies <NSCoding>
@end
@interface BroodTamara : TamaraSubspecies <NSCoding>
@end
@interface ToxinTamara : TamaraSubspecies <NSCoding>
@end
@interface PlagueTamara : TamaraSubspecies <NSCoding>
@end
@interface MesmericTamara : TamaraSubspecies <NSCoding>
@end
@interface BombTamara : TamaraSubspecies <NSCoding>
@end
@interface DementiaTamara : TamaraSubspecies <NSCoding>
@end
@interface ShiftingTamara : TamaraSubspecies <NSCoding>
@end
@interface BigTamara : TamaraSubspecies <NSCoding>
@end
@interface BigBombTamara : TamaraSubspecies <NSCoding>
@end
@interface BigSilverTamara : TamaraSubspecies <NSCoding>
@end
@interface BigGoldTamara : TamaraSubspecies <NSCoding>
@end
@interface BigCrystallineTamara : TamaraSubspecies <NSCoding>
@end
@interface DevilTamara : TamaraSubspecies <NSCoding>
@end
@interface KingTamara : TamaraSubspecies <NSCoding>
@end