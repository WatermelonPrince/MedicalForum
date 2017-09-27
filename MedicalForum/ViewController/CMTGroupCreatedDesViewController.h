//
//  CMTGroupCreatedDesViewController.h
//  MedicalForum
//
//  Created by zhaohuan on 16/3/16.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import "CMTBaseViewController.h"
@class CMTGroupTypeChoiceTableViewController;
//创建小组简介
@interface CMTGroupCreatedDesViewController : CMTBaseViewController
- (instancetype)initWithGroupLogoFile:(NSString *)groupLogoFile
                            groupType:(NSString *)groupType
                    groupTypeChoiceVC:(CMTGroupTypeChoiceTableViewController *)groupTypeVC
                            groupName:(NSString *)groupName;
//更新小组简介
- (instancetype)initWithtext:(NSString*)text from:(NSString*)from;
//更新小组简介
@property(nonatomic,copy)void(^updateGroupDes)(NSString *text);
@end
