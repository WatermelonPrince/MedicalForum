//
//  CMTGroupCreatedMakeSureViewController.h
//  MedicalForum
//
//  Created by zhaohuan on 16/3/17.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import "CMTBaseViewController.h"
#import "CMTGroupTypeChoiceTableViewController.h"

@interface CMTGroupCreatedMakeSureViewController : CMTBaseViewController

- (instancetype)initWithGroupLogoFile:(NSString *)groupLogoFile
                            groupType:(NSString *)groupType
                    groupTypeChoiceVC:(CMTGroupTypeChoiceTableViewController *)groupTypeVC
                      groupCreatedDes:(NSString *)groupCreatedDes
                            groupName:(NSString *)groupName;

@end
