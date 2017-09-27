//
//  CMTGroupTypeChoiceTableViewController.h
//  MedicalForum
//
//  Created by zhaohuan on 16/3/15.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CMTGroupTypeChoiceTableViewController : UITableViewController
@property (nonatomic, weak)UIViewController *lastVC;
@property (nonatomic, copy)void(^RetureGroupType)(NSString *str);







@end
