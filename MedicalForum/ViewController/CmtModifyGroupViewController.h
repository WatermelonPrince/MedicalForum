//
//  CmtModifyGroupViewController.h
//  MedicalForum
//
//  Created by guoyuanchao on 16/3/29.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import "CMTBaseViewController.h"

@interface CmtModifyGroupViewController : CMTBaseViewController
-(instancetype)initWithGroup:(CMTGroup*)group;
@property(nonatomic,strong)void(^ModifyGroupSucess)(CMTGroup* group);
@end
