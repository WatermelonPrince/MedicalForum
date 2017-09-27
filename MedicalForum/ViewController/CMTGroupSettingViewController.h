//
//  CMTGroupSettingViewController.h
//  MedicalForum
//
//  Created by zhaohuan on 16/3/16.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import "CMTBaseViewController.h"
#import "CMTGroupTypeChoiceTableViewController.h"

@interface CMTGroupSettingViewController : CMTBaseViewController

- (instancetype)initWithGroup:(CMTGroup *)group
                 choiceTypeVC:(CMTGroupTypeChoiceTableViewController *)choiceTypeVC;

@end
