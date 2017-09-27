//
//  CMTRecordControlView.h
//  VodSDKDemo 
//
//  Created by zhaohuan on 16/6/5.
//  Copyright © 2016年 Gensee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBFlashCtntLabel.h"

@interface CMTRecordControlView : UIView
@property (nonatomic, strong)UIView *topView;
@property (nonatomic, strong)UIView *bottomView;
@property (nonatomic, strong)UIButton *controlButton;
@property (nonatomic, strong)UISlider *progress;
@property (nonatomic, strong)UIButton *fullModeButton;
@property (nonatomic, strong)UIButton *switchButton;
@property (nonatomic, strong)UIButton *returnButton;
@property (nonatomic, strong)UIButton *shareButton;
@property (nonatomic, strong)UIImageView *left_seprationImage;
@property (nonatomic, strong)UIImageView *right_seprationImage;
@property (nonatomic, strong)UILabel *havePlay;
@property (nonatomic, strong)UILabel *remainPlay;
@property (nonatomic, strong)BBFlashCtntLabel *livetitle;
@property (nonatomic, strong)UIView *touchView;
@property (nonatomic, strong)UIView *topLineView;//顶部视图
@property (nonatomic, strong)UIView *bottomLineView;





- (instancetype)initWithFrame:(CGRect)frame
                 isfullScreen:(BOOL)fullScreen;

- (void)resetFrame:(CGRect)frame
        isFullMode:(BOOL)fullMode;

@end
