//
//  CMTGroupCardViewController.h
//  MedicalForum
//
//  Created by guoyuanchao on 16/3/16.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import "CMTBaseViewController.h"

@interface CMTGroupCardViewController : CMTBaseViewController
-(instancetype)initWithGroup:(CMTGroup*)group;
//小组信息修改成功
@property (nonatomic, copy)void(^ModifyGroupSucess)(CMTGroup *group);

@end
