//
//  CMTPostProgressView.h
//  MedicalForum
//
//  Created by guoyuanchao on 15/8/3.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMTSendCaseType.h"
@protocol CMTPostProgressViewDelegate <NSObject>
//删除进度条
-(void)DeletePosting;
//刷新文章列表
-(void)reloadCaselistData:(CMTAddPost*)newCase;
@end
@interface CMTPostProgressView : UIView
-(instancetype)initWithFrame:(CGRect)frame module:(CMTSendCaseType)module;
@property(nonatomic,weak)id<CMTPostProgressViewDelegate> delegate;
//开始
-(void)start;
//设置进度
-(void)setProgress;
//删除文章
-(void)deletePostSend;
//发送失败
-(void)SendFailure;
//发送成功
-(void)SendSuccess;
@end
