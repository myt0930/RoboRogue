//
//  Player.m
//  RoboRogue
//
//  Created by 山本政徳 on 2014/02/25.
//  Copyright (c) 2014年 山本政徳. All rights reserved.
//

#import "RRGPlayer.h"
#import "RRGCategories.h"
#import "RRGFunctions.h"
#import "RRGSword.h"
#import "RRGShield.h"
#import "RRGRoom.h"
#import "RRGTrap.h"
#import "RRGLabelLayer.h"
#import "RRGStaff.h"
#import "RRGSavedDataHandler.h"
#import "RRGActionCache.h"
#import "RRGAction.h"
#import "RRGButtonLayer.h"

#import "RRGLevel.h"
#import "RRGLevel+AddObject.h"
#import "RRGLevel+Particle.h"
#import "RRGLevel+TurnSequence.h"

static const NSUInteger MaxNumberOfItems = 30;
static const NSInteger ProbabilityWakeUpWhenEnterOrLeaveRoom = 50;

NSString* const kChangePlayerHP = @"changePlayerHP";
NSString* const kChangePlayerMaxHP = @"changePlayerMaxHP";
NSString* const kChangePlayerLevel = @"changePlayerLevel";

@implementation RRGPlayer
#pragma mark - NSCoding
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        decodeObject(_items);
        decodeObject(_swordEquipped);
        decodeObject(_shieldEquipped);
        decodeObject(_staffEquipped);
        [self updateSprites];
    }
    return self;
}
-(void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    encodeObject(_items);
    encodeObject(_swordEquipped);
    encodeObject(_shieldEquipped);
    encodeObject(_staffEquipped);
}
#pragma mark - reference
-(RRGLabelLayer*)labelLayer
{
    return self.level.labelLayer;
}
-(RRGPlayer*)player
{
    return self;
}
-(BOOL)inView
{
    return YES;
}
-(BOOL)inPlayerView
{
    return YES;
}
-(BOOL)inPlayerViewForMapping
{
    return YES;
}
#pragma mark - clear attributes

#pragma mark - attributes
-(void)clearAttributesForNewLevel:(RRGLevel*)level
{
    self.level = level;
    self.actionCount = 0;
    self.prevRoom = nil;
    self.exitGateOut = CGPointZero;
    self.status = [NSMutableDictionary dictionary];
    [self.items
     enumerateObjectsWithOptions:NSEnumerationConcurrent
     usingBlock:^(RRGItem* obj, NSUInteger idx, BOOL* stop){
         obj.level = level;
     }];
}
-(void)setDefaultAttributes
{
    [super setDefaultAttributes];
    _items = [NSMutableArray array];
}
-(CGFloat)speedFactor
{
    return 1.0f;
}
-(NSInteger)offenseValue
{
    if ([self haveState:kStatePygmy]) {
        return 0;
    }
    NSInteger l = log10((double)(self.characterLevel * 0.4 + 1)) * 24 - 3;
    NSInteger c = self.strength;
    /*
    NSInteger s = 0;//power of sword
    if (self.swordEquipped) {
        s = self.swordEquipped.strength;
    }
     */
    //CCLOG(@"offenseValue = %zd", l + c);
    return l + c;
}
-(NSInteger)defenseValue
{
    if ([self haveState:kStatePygmy]) {
        return 0;
    }
    NSInteger s = 0;//power of shield
    if (self.shieldEquipped) {
        s = self.shieldEquipped.strength;
    }
    return (NSInteger)(s / 2);
}
-(NSInteger)damageToTarget:(RRGCharacter *)target
{
    NSInteger swordStrength = 0;
    if (self.swordEquipped) {
        swordStrength = self.swordEquipped.strength;
    }
    return [self damageToTarget:target withSwordStrength:swordStrength];
}
-(NSString*)spriteFolderName
{
    if (self.swordEquipped) {
        if (self.shieldEquipped) {
            return @"PlayerSwordShield";
        } else {
            return @"PlayerSword";
        }
    } else {
        if (self.shieldEquipped) {
            return @"PlayerShield";
        } else {
            return @"PlayerNoEquip";
        }
    }
}
-(CGRect)playerViewRect
{
    return CGRectUnion([super viewRect], [self.level viewRect]);
}
-(CGRect)playerViewRectForMapping
{
    if (self.level.shadow) {
        return self.viewRect;
    } else {
        return self.playerViewRect;
    }
}
#pragma mark - setter
-(void)setHP:(NSUInteger)HP
{
    [super setHP:HP];
    
    __weak RRGPlayer* weakSelf = self;
    CCActionCallBlock* block = [CCActionCallBlock actionWithBlock:^{
        [weakSelf.level.labelLayer setPlayerHPString:HP];
    }];
    [self.level addAction:[RRGAction actionWithTarget:self
                                               action:block
                                             forSpawn:YES]];
}
-(void)setMaxHP:(NSUInteger)maxHP
{
    [super setMaxHP:maxHP];
    
    __weak RRGPlayer* weakSelf = self;
    CCActionCallBlock* block = [CCActionCallBlock actionWithBlock:^{
        [weakSelf.level.labelLayer setPlayerMaxHPString:maxHP];
    }];
    [self.level addAction:[RRGAction actionWithTarget:self
                                               action:block
                                             forSpawn:YES]];
}
-(void)setCharacterLevel:(NSUInteger)characterLevel
{
    [super setCharacterLevel:characterLevel];
    
    __weak RRGPlayer* weakSelf = self;
    CCActionCallBlock* block = [CCActionCallBlock actionWithBlock:^{
        [weakSelf.level.labelLayer setPlayerLevelString:characterLevel];
    }];
    [self.level addAction:[RRGAction actionWithTarget:self
                                               action:block
                                             forSpawn:YES]];
}
-(void)setStaffEquipped:(RRGStaff *)staffEquipped
{
    _staffEquipped = staffEquipped;
    [self.level.buttonLayer updateSubWeaponButtons];
}
#pragma mark - action
-(void)addAction
{
    if ([self haveState:kStateMad]) {
        [self actionMad];
    }
    
    if (!self.isDead) {
        [self poisonHPLoss];
    }
    if (!self.isDead) {
        [self statusDecrement];
    }
}
-(void)poisonHPLoss
{
    NSInteger changeHP = 1 - [self poisonVal];
    if (changeHP != 0) {
        [self changeHP:changeHP byCharacter:nil];
    }
}
-(void)didEnterRoom:(RRGRoom*)room
{
    [super didEnterRoom:room];
    [self wakeUpEnemiesInRect:room.roomRect
                  probability:ProbabilityWakeUpWhenEnterOrLeaveRoom];
}
-(void)didLeaveRoom:(RRGRoom*)room
{
    [super didLeaveRoom:room];
    [self wakeUpEnemiesInRect:room.roomRect
                  probability:ProbabilityWakeUpWhenEnterOrLeaveRoom];
}

-(void)wakeUpEnemiesInRect:(CGRect)rect
               probability:(NSInteger)probability
{
    CGRectForEach(rect)
    {
        RRGCharacter* chara = [self.level characterAtTileCoord:ccp(x,y)];
        if (chara && [chara haveState:kStateNapping]) {
            if (calculateProbability(probability)) {
                [chara removeState:kStateNapping];
                chara.actionCount -= 1;
            }
        }
    }
}
-(void)setTileCoord:(CGPoint)tileCoord
{
    CGPoint oldTileCoord = self.tileCoord;
    [super setTileCoord:tileCoord];
    
    if (CGPointEqualToPoint(oldTileCoord, tileCoord)) return;
    
    //隣接する敵を起こす
    CGRect rect = CGRectMake(tileCoord.x - 1,
                             tileCoord.y - 1,
                             3,
                             3);
    [self wakeUpEnemiesInRect:rect probability:100];
}

#pragma mark - attack
-(void)attackToDirection:(CGPoint)direction
{
    [super attackToDirection:direction];
    
    CGPoint front = ccpAdd(self.tileCoord, direction);
    RRGTrap* trap = [self.level trapAtTileCoord:front];
    if (trap) {
        [self.level addAction:[CCActionCallBlock actionWithBlock:^{
            trap.found = YES;
        }]];
    }
}
-(void)didAttackToCharacter:(RRGCharacter *)character
{
    [super didAttackToCharacter:character];
    if (!self.isDead) {
        [self.swordEquipped didAttackToCharacter:character];
    }
}
#pragma mark - damage
-(void)didBeDealtDamage:(NSInteger)damage byCharacter:(RRGCharacter *)character
{
    [self.shieldEquipped didBeDealtDamage:damage
                              byCharacter:character];
}
-(void)changeSpeed:(CGFloat)multiplyingVal
{
    [super changeSpeed:multiplyingVal];
    
    [self.level.characters
     enumerateObjectsWithOptions:NSEnumerationConcurrent
     usingBlock:^(RRGCharacter* character, NSUInteger idx, BOOL* stop){
         character.actionCount = 0;
     }];
}
-(void)killCharacter:(RRGCharacter *)character
{
    if (character) {
        NSUInteger getExp = character.experience * character.characterLevel;
        [self.level addMessage:[NSString stringWithFormat:@"%@ got %tu experience points.",
                                self.displayName,
                                getExp]];
        [self changeExperience:getExp];
    }
}
-(void)killedByCharacter:(RRGCharacter *)character
{
    self.killer = character;
    self.isDead = YES;
    
    __weak RRGPlayer* weakSelf = self;
    [self.level addAction:[CCActionCallBlock actionWithBlock:^{
        weakSelf.visible = NO;
        weakSelf.level.buttonLayer.visible = NO;
        weakSelf.level.labelLayer.visible = NO;
    }]];
    [self.level addParticleWithName:kParticleExplosion
                        atTileCoord:self.tileCoord
                              sound:YES];
}
#pragma mark - experience and level
-(void)changeExperience:(NSInteger)changeExp
{
    [super changeExperience:changeExp];
    
    NSUInteger newLevel = characterLevelForExperience(self.experience);
    if (self.characterLevel != newLevel) {
        [self changeCharacterLevel:newLevel - self.characterLevel];
    }
}
-(void)changeCharacterLevel:(NSInteger)changeLevel
{
    NSUInteger oldLv = self.characterLevel;
    [super changeCharacterLevel:changeLevel];
    NSUInteger newLv = self.characterLevel;
    NSInteger change = newLv - oldLv;
    
    if (change > 0) {
        [self changeMaxHP:5 * change];
        [self changeHP:5 * change byCharacter:nil];
        [self.level addAction:[CCActionSoundEffect actionWithSoundFile:@"levelUp.caf"]];
        [self.level addMessage:[NSString stringWithFormat:@"%@ raised to Level %tu.",
                                self.displayName,
                                self.characterLevel]];
    } else if (change < 0) {
        [self changeMaxHP:5 * change];
        [self.level addAction:[CCActionSoundEffect actionWithSoundFile:@"levelDown.caf"]];
        [self.level addMessage:[NSString stringWithFormat:@"%@ dropped to Level %tu.",
                                self.displayName,
                                self.characterLevel]];
    }
}
-(void)changeExperienceAndCharacterLevel:(NSInteger)changeLevel
{
    NSInteger newLv = self.characterLevel + changeLevel;
    newLv = MAX(1, MIN(99, newLv));
    if (self.characterLevel == newLv) return;
    
    NSInteger change = newLv - self.characterLevel;
    
    NSUInteger newExp = (change > 0)?
    experienceForCharacterLevel(newLv):
    experienceForCharacterLevel(newLv + 1) - 1;
    
    [self changeExperience:newExp - self.experience];
}
NSUInteger characterLevelForExperience(NSUInteger experience)
{
    for (NSUInteger l = 1; l < 100; l++) {
        if (experience < experienceForCharacterLevel(l + 1)) {
            return l;
        }
    }
    return 99;
}
NSUInteger experienceForCharacterLevel(NSInteger level)
{
    return level * (level - 1) * (level + 13) / 3;
}
#pragma mark - step on trap or item
-(void)stepOnItem
{
    RRGItem* itemOnGround = [self.level itemAtTileCoord:self.tileCoord];
    if (itemOnGround) {
        if ([self getItem:itemOnGround] == NO) {
            [self.level addMessage:
             [NSString stringWithFormat:@"%@ cannot carry anything more.",
              self.displayName]];
            return;
        }
        
        [self.level removeObject:itemOnGround];
        
        [self.level addMessage:[NSString stringWithFormat:@"%@ picked up %@.",
                                self.displayName,
                                itemOnGround.displayName]];
        [self.level addAction:[CCActionSoundEffect actionWithSoundFile:@"pickUpItem.caf"]];
    }
}
-(void)stepOnTrap
{
    RRGTrap* trap = [self.level trapAtTileCoord:self.tileCoord];
    if (trap && trap.targetPlayer && !self.canFly) {
        [trap steppedOnBy:self message:YES];
    }
}
#pragma mark - item action
-(BOOL)getItem:(RRGItem*)item
{
    if ([self.items count] >= MaxNumberOfItems) return NO;
    [self.items addObject:item];
    return YES;
}
-(void)useItem:(RRGItemUseOnce*)item
{
    [self.items removeObject:item];
    [item useToCharacter:self byCharacter:self];
}
-(void)waveStaff:(RRGStaff*)staff
{
    [self.level addMessage:
     [NSString stringWithFormat:@"%@ waved %@.",
      self.displayName,
      staff.displayName]];
    [self.level addAction:[CCActionSoundEffect actionWithSoundFile:@"waveStaff.caf"]];
    
    NSInteger frameCount = 3;
    CGFloat duration = DurationAttack;// / self.speedFactor;
    
    //animation
    NSString* format = [NSString stringWithFormat:@"%@/waveStaff/%@/",
                        [self spriteFolderName],
                        directionString(self.direction)];
    format = [format stringByAppendingString:@"%04d.png"];
    //CCLOG(@"format = %@", format);
    CCActionAnimate* animate = [sharedActionCache
                                animateWithFormat:format
                                frameCount:frameCount
                                delay:duration * .5f / frameCount];
    //CCLOG(@"animate.duration = %f", animate.duration);
    
    [self.level addAction:[CCActionCallFunc actionWithTarget:self.objectSprite
                                                    selector:@selector(stopAllActions)]];
    [self.level addAction:[RRGAction actionWithTarget:self.objectSprite
                                               action:animate]];
    [self updateObjectSprite];
    
    [staff wavedByCharacter:self];
}
-(void)equipItem:(RRGItemEquipment*)item
{
    [item equippedByPlayer:self];
}
-(void)unequipItem:(RRGItemEquipment*)item
{
    [item unequippedByPlayer:self];
}
-(void)throwItem:(RRGItem*)item
{
    if ([item isKindOfClass:[RRGItemEquipment class]]) {
        RRGItemEquipment* equipment = (RRGItemEquipment*)item;
        if (equipment.equipped) {
            [equipment unequippedByPlayer:self
                     soundAndMessage:NO];
            
            if (equipment.equipped) return;
        }
    }
    [self.items removeObject:item];
    [super throwItem:item];
}
-(void)putOnItem:(RRGItem*)item
{
    //unequip
    if ([item isKindOfClass:[RRGItemEquipment class]]) {
        RRGItemEquipment* equipment = (RRGItemEquipment*)item;
        if (equipment.equipped) {
            [equipment unequippedByPlayer:self
                     soundAndMessage:NO];
            
            if (equipment.equipped) return;
        }
    }
    
    [self.items removeObject:item];
    [self.level addObject:item atTileCoord:self.tileCoord];
    
    [self.level addMessage:[NSString stringWithFormat:@"%@ put %@ on the ground.",
                            self.displayName,
                            item.displayName]];
}
-(void)swapItem:(RRGItem *)item
{
    //unequip
    if ([item isKindOfClass:[RRGItemEquipment class]]) {
        RRGItemEquipment* equipment = (RRGItemEquipment*)item;
        if (equipment.equipped) {
            [equipment unequippedByPlayer:self
                     soundAndMessage:NO];
            
            if (equipment.equipped) return;
        }
    }
    
    RRGItem* itemOnGround = [self.level itemAtTileCoord:self.tileCoord];
    
    [self.level removeObject:itemOnGround];
    [self.items replaceObject:item withObject:itemOnGround];
    
    [self.items removeObject:item];
    [self.level addObject:item atTileCoord:self.tileCoord];
    
    [self.level addMessage:[NSString stringWithFormat:@"%@ swapped %@ with %@.",
                            self.displayName,
                            item.displayName,
                            itemOnGround.displayName]];
    
    [self.level addAction:[CCActionSoundEffect actionWithSoundFile:@"pickUpItem.caf"]];
}
-(void)sortItems
{
    NSSortDescriptor* sortEquipped = [[NSSortDescriptor alloc] initWithKey:@"equipped"
                                                                 ascending:NO];
    NSSortDescriptor* sortDispNum = [[NSSortDescriptor alloc] initWithKey:@"dispNumber"
                                                                ascending:YES];
    NSSortDescriptor* sortName = [[NSSortDescriptor alloc] initWithKey:@"displayName"
                                                             ascending:YES];
    NSArray *sortDescArray = [NSArray arrayWithObjects:sortEquipped,
                              sortDispNum,
                              sortName,
                              nil];
    
    [self.items sortUsingDescriptors:sortDescArray];
}
-(void)update:(CCTime)delta
{
    //do nothing
}
@end