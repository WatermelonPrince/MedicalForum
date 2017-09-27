//
//  CMTDownloadingTableViewCell.h
//  MedicalForum
//
//  Created by guoyuanchao on 2017/3/20.
//  Copyright © 2017年 CMT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CMTDownloadingTableViewCell : UITableViewCell
@property (strong, nonatomic) UILabel *mLbTitle;
@property (strong, nonatomic) UILabel *mlbdataSize;  //大小
@property (strong, nonatomic) UIImageView *mImageView;
@property (strong, nonatomic) UILabel *mLbloadState;  //下载记录
@property (strong, nonatomic) UIImageView *imageViewStatus;//选中状态
@property (strong, nonatomic) UIView *tapSlectedView;
@property(strong,nonatomic)  UIProgressView  *ProgressView;
@property(strong,nonatomic)  UIButton *playStateimage;
///底线
@property (strong, nonatomic) UIView *bottomLine;
@property(strong,nonatomic)CMTLivesRecord *liveRecord;
@property(nonatomic,copy)void(^updateSelectState)(CMTLivesRecord *live);
- (void)reloadCell:(CMTLivesRecord *)record;

@end
