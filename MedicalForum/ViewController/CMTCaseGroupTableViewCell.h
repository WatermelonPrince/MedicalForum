//
//  CMTCaseGroupTableViewCell.h
//  MedicalForum
//
//  Created by guoyuanchao on 15/9/24.
//  Copyright © 2015年 CMT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CMTCaseGroupTableViewCell : UITableViewCell
//小组名称
@property(nonatomic,strong)UILabel *groupName;
@property(nonatomic,strong)CMTGroup *mgroup;
@property(nonatomic,strong)CMTGroupLogo *mGroupLogo;
@property(nonatomic,strong)NSString *model;
@property(nonatomic,strong)NSIndexPath *IndexPath;
//搜索关键字
@property(nonatomic,strong)NSString *searchkey;
//是否搜索
@property(nonatomic,assign)BOOL isSearch;
-(void)reloadCell:(CMTGroup*)group;//未加入小组的cell；
-(void)reloadSelectGroupCell:(CMTGroup*)group;//加入小组的cell
@end
