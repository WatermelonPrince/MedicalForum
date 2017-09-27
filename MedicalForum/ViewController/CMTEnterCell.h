//
//  CMTEnterCell.h
//  MedicalForum
//  我的关注页进入专题与某学科下进入作者排行榜
//  Created by Bo Shen on 15/4/1.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMTBadge.h"
#import "CMTBadgePoint.h"

@interface CMTEnterCell : UITableViewCell

@property (strong, nonatomic) UIImageView *mImageLeft;
@property (strong, nonatomic) UILabel *mLabelDes;
///分割线
@property (strong, nonatomic) UIView *separatorLine;
///底线
@property (strong, nonatomic) UIView *bottomLine;
///accView
@property (strong, nonatomic) UIImageView *mImageAccView;

@property (strong, nonatomic) UIView *mTopView;

@property (strong, nonatomic) CMTBadgePoint *badgePoint;
@property (strong, nonatomic) CMTBadge *badge;


@end
