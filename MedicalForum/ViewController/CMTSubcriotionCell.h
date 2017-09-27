//
//  CMTSubcriotionCell.h
//  MedicalForum
//  1.8.0 订阅页 作者列表cell
//  Created by Bo Shen on 15/1/5.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CMTSubcriotionCell : UITableViewCell
/// 头像
@property (strong, nonatomic) UIImageView *mImageView;
/// 作者名字
@property (strong, nonatomic) UILabel *mTextLabel;
/// 作者简介
@property (strong, nonatomic) UILabel *mDetailTextLabel;
/// 右侧accView
@property (strong, nonatomic) UIImageView *mImageAccView;
/*选中状态*/
@property (assign, nonatomic) BOOL subScrption;

/// 分割线
@property (strong, nonatomic) UIView *separatorLine;
/// 底线
@property (strong, nonatomic) UIView *bottomLine;
/// 底部文章的小图片
@property (strong, nonatomic) UIImageView *mImageViewPostView;
///底部 文章数
@property (strong, nonatomic) UILabel *mLbPostsCount;


/// 左侧色值图(排行显示)
@property (strong, nonatomic) UIView *leftColorView;
/// 底部色值(阴影)
@property (strong, nonatomic) UIView *bottomView;
/// 底部阴影
@property (strong, nonatomic) UIImageView *mImageBottom;

@end
