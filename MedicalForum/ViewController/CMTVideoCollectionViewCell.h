//
//  CMTVideoCollectionViewCell.h
//  MedicalForum
//
//  Created by zhaohuan on 2017/2/13.
//  Copyright © 2017年 CMT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMTLivesRecord.h"

@interface CMTVideoCollectionViewCell : UITableViewCell
@property (strong, nonatomic) UILabel *mLbTitle;
@property (strong, nonatomic) UILabel *mLbAuthor;  //学院
@property (strong, nonatomic) UIImageView *mImageView;
@property (strong, nonatomic) UILabel *mLbDate;   //观看记录、时间
@property (strong, nonatomic) UIImageView *imageViewStatus;//选中状态
@property (strong, nonatomic) UIView *tapSlectedView;
///底线
@property (strong, nonatomic) UIView *bottomLine;
@property(strong,nonatomic)CMTLivesRecord *liveRecord;
@property(nonatomic,copy)void(^updateSelectState)(CMTLivesRecord *live);
//当str为空时，从收藏进入，当str不为空时，从历史记录进入  str传00:00:00格式
- (void)reloadCellWithdate:(NSString *)type
                     model:(CMTLivesRecord *)record;

@end
