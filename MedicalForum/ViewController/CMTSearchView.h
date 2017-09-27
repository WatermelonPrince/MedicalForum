//
//  CMTSearchView.h
//  MedicalForum
//
//  Created by CMT on 15/6/5.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CMTSearchViewDelegate <NSObject>

- (void)pushToNextVC;

@end

@interface CMTSearchView : UIView
@property(nonatomic,strong)UIButton *searchbutton;//搜索按钮
@property(nonatomic,strong)NSString *searchTypeID;//搜索类型
@property(nonatomic,assign)float titlefontSize;//标题大小
@property(nonatomic,weak)UIViewController *lastController;//上一级控制器
@property(nonatomic,strong)NSString *module;//模式
@property(nonatomic,strong)UILabel *titlelable;
@property (assign)id<CMTSearchViewDelegate> delegate;
-(void)drawSearchButton:(NSString*)titleString;


@end
