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
@interface Silver_Tamara : Tamara <NSCoding>
@end
@interface Gold_Tamara : Tamara <NSCoding>
@end

@interface TamaraSubspecies : Tamara <NSCoding>
@end

@interface Steel_Tamara : TamaraSubspecies <NSCoding>
@end

@interface Crystalline_Tamara : TamaraSubspecies <NSCoding>
@end
@interface Brood_Tamara : TamaraSubspecies <NSCoding>
@end
@interface Toxin_Tamara : TamaraSubspecies <NSCoding>
@end
@interface Plague_Tamara : TamaraSubspecies <NSCoding>
@end
@interface Mesmeric_Tamara : TamaraSubspecies <NSCoding>
@end
@interface Bomb_Tamara : TamaraSubspecies <NSCoding>
@end
@interface Dementia_Tamara : TamaraSubspecies <NSCoding>
@end
@interface Shifting_Tamara : TamaraSubspecies <NSCoding>
@end
@interface Big_Tamara : TamaraSubspecies <NSCoding>
@end
@interface Big_Bomb_Tamara : TamaraSubspecies <NSCoding>
@end
@interface Big_Silver_Tamara : TamaraSubspecies <NSCoding>
@end
@interface Big_Gold_Tamara : TamaraSubspecies <NSCoding>
@end
@interface Big_Crystalline_Tamara : TamaraSubspecies <NSCoding>
@end
@interface Devil_Tamara : TamaraSubspecies <NSCoding>
@end
@interface King_Tamara : TamaraSubspecies <NSCoding>
@end