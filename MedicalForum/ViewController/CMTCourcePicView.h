//
//  CMTCourcePicView.h
//  MedicalForum
//
//  Created by guoyuanchao on 16/12/19.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CMTCourcePicView : UIControl
@property(nonatomic,strong)UIImageView *VideoimageView;//视频缩略图
@property(nonatomic,strong)UIImageView *VideoSymbol;//系列标志
@property(nonatomic,strong)UIView *VideoSymbolView;//系列标志背景
@property(nonatomic,strong)UILabel *VideoSymbolName;
@property(nonatomic,strong)UILabel*titlelable;//标题名称
@property(nonatomic,strong)UILabel*usersLable;//阅读数
@property (nonatomic, strong)UIView *heatImageViewbgView;//热度图片
@property(nonatomic,strong)CMTLivesRecord*LivesRecord;
@property(nonatomic,strong)NSString *searchKey;
-(void)reloadData:(CMTLivesRecord*)model;
@end
