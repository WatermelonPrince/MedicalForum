//
//  CMTDownloadViewController.h
//  MedicalForum
//
//  Created by Bo Shen on 14/12/27.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTBaseViewController.h"
#import "LLARingSpinnerView.h"

@interface CMTDownloadViewController : CMTBaseViewController


@property (strong, nonatomic) UIImageView *mBackGroundImageView;
@property (strong, nonatomic) UILabel *mLbwaitting;
@property (strong, nonatomic) UILabel *mLbDate;
@property (strong, nonatomic) UILabel *mLbUpdatContent;
@property (strong, nonatomic) UIImageView *mWaitImageView;
@property (strong, nonatomic) LLARingSpinnerView *mAnimationView;
@property (strong, nonatomic) UILabel *mLbProgress;

@property (strong, nonatomic) UIBarButtonItem *mHidItem;
@property (strong, nonatomic) UIBarButtonItem *mCancelItem;
/*更新下载进度指示标签来用*/
@property (strong, nonatomic) NSTimer *mTimer;


- (void) methodHide:(id)sender;

- (void) methodCancel:(id)sender;
/*更新方法*/
- (void)updateProgress;

@end
