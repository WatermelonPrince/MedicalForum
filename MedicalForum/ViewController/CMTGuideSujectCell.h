//
//  CMTSujectCell.h
//  MedicalForum
//
//  Created by CMT on 15/6/1.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMTBadgePoint.h"
#import "CMTSubject.h"
@interface CMTGuideSujectCell : UITableViewCell
@property(nonatomic,strong)UIView *topline;//上分割线
@property (strong, nonatomic) UILabel *mLbSub;//文本标签
@property(strong,nonatomic)CMTBadgePoint *badgePoint;//更新显示
@property(nonatomic,strong)UIView *splitline;//分割线
@property(nonatomic,strong)UILabel *mSubArticleNumber;//文章数量（目前未用）
@property(nonatomic,copy,readonly)NSDictionary* cellData;//cell数据
@property(nonatomic,strong)UIImageView *nextImage;//下一级指示图片
-(void)reloadSujectCell:(CMTSubject*)object ;

@end
