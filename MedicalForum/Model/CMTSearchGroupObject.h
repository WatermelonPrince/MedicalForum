//
//  CMTSearchObject.h
//  MedicalForum
//
//  Created by guoyuanchao on 16/3/15.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import "CMTObject.h"
#import "CMTGroup.h"
@interface CMTSearchGroupObject : CMTObject
//已加入的小组
@property(nonatomic,strong)NSArray *inGroups;
//未加入的小组
@property(nonatomic,strong)NSArray *unInGroups;
@end
