//
//  CMTGroupMembersViewController.h
//  MedicalForum
//
//  Created by guoyuanchao on 15/7/24.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTBaseViewController.h"

@interface CMTGroupMembersViewController : CMTBaseViewController<UITableViewDataSource,UITableViewDelegate>
//我的文章
@property(nonatomic,strong)CMTGroup *mygroup;
@property (nonatomic, strong)NSString *showType;
@property (assign)NSInteger managerCount;
@property (nonatomic, copy)NSString *leaderCount;


//删除成员或者拉黑成员成功回调
@property (nonatomic , copy)void(^deleteArrBlock)(NSMutableArray *);
//小组信息修改成功
@property (nonatomic, copy)void(^ModifyGroupSucess)(CMTGroup *group);
-(instancetype)initWithGroup:(CMTGroup*)group;

@end
