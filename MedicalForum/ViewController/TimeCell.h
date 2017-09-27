//
//  TimeCell.h
//  CountDownTimerForTableView
//
//  Created by FrankLiu on 15/9/14.
//  Copyright (c) 2015年 FrankLiu. All rights reserved.
//

#import "BaseTableViewCell.h"

#define TIME_CELL               @"TimeCell"
#define NOTIFICATION_TIME_CELL  @"NotificationTimeCell"

@interface TimeCell : BaseTableViewCell

@property (nonatomic, strong) UIButton    *m_registrationButton;//报名
@property (nonatomic, strong) UILabel     *m_titleLabel;

@property (nonatomic, strong) UILabel     *m_userNameLabel;//姓名

@property (nonatomic, strong) UILabel     *m_hospitalLabel;//医院



@end
