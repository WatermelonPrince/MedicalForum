//
//  CMTApplyNoticeCell.h
//  MedicalForum
//
//  Created by zhaohuan on 15/11/25.
//  Copyright © 2015年 CMT. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface CMTApplyNoticeCell : UITableViewCell
@property (nonatomic, strong)UIButton *aceeptButton;//同意
@property (nonatomic, strong)UIButton *refuseButton;//拒绝
//配置cell
- (void)configureCellWithModel:(CMTCaseSystemNoticeModel *)model;

@end
