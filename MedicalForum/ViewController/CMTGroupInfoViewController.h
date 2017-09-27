//
//  CMTGroupInfoViewController.h
//  MedicalForum
//
//  Created by guoyuanchao on 15/7/22.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTBaseViewController.h"
#import "CMTCaseLIstCell.h"

@interface CMTGroupInfoViewController : CMTBaseViewController<UITableViewDataSource,UITableViewDelegate,CMTCaseListCellDelegate>
-(instancetype)initWithGroup:(CMTGroup*)group;
-(instancetype)initWithGroupUuid:(NSString*)pUuid;
//更新小组数据
@property (nonatomic, copy)void(^updateGroup)(CMTGroup *group);
//更新小组气泡数目
@property(nonatomic,copy)void(^updateGroupBubbles)(void);
@property(nonatomic,assign)NSInteger fromController;
//退出成功
-(void)logoutSucess:(CMTGroup *)group;
@end
