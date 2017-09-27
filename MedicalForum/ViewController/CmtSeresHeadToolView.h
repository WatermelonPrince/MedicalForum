//
//  CmtSeresToolView.h
//  MedicalForum
//
//  Created by guoyuanchao on 16/9/12.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CmtSeresHeadToolViewDelegate <NSObject>

- (void)subscribeAction:(UIButton *)action;

@end

@interface CmtSeresHeadToolView : UIView


// share
@property (nonatomic, strong) UIImageView *shareImage;//分享图片
@property (nonatomic, strong) UIButton *shareButton;//分享按钮
// focus


@property (nonatomic, weak) id<CmtSeresHeadToolViewDelegate> delegate;

@property (nonatomic, strong, readwrite) UIImageView *focusImage;//订阅图片
@property (nonatomic, strong, readwrite) UIButton *focusButton;//订阅按钮
@property (nonatomic, strong) UIView *toolBar;//分享 关注工具条
@property (nonatomic, strong) UIView *toolBarShadow;//工具条阴影
@property (nonatomic, strong) UIView *toolBarSeparator;//分割线
@property(nonatomic,strong)CMTSeriesDetails *mySeriesDetails;//系列数据
//工具条初始化方法

-(instancetype)initWithFrame:(CGRect)frame CMTSeriesDetails:(CMTSeriesDetails*)mySeriesDetails;

//添加订阅成功刷新按钮文字逻辑
-(void)reloadWithSeresDetail:(CMTSeriesDetails *)seresDetail;
@end
