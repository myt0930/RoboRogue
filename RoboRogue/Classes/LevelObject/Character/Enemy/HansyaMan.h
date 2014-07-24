//
//  HansyaMan.h
//  RoboRogue
//
//  Created by 山本政徳 on 2014/05/08.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "RRGEnemy.h"

@interface HansyaMan : RRGEnemy <NSCoding>
@end
@interface MirrorMan : HansyaMan <NSCoding>
@end
@interface MirrorKing : HansyaMan <NSCoding>
@end