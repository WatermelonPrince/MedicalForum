//
//  CMTTagButton.h
//  MedicalForum
//
//  Created by CMT on 15/6/9.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMTBadgePoint.h"
#import "CMTBadge.h"
@interface CMTTagButton : UIControl
@property(nonatomic,strong)CMTBadge *badge;//更新提示气泡
@property(nonatomic,strong)UILabel *mlabe;//疾病名称lable
@property(nonatomic,strong)CMTDisease *disease; //疾病对象
@property(nonatomic,assign)float fontsize;//文字
@property(nonatomic,assign)BOOL isShowbubble;
@property(nonatomic,strong)NSString *model;
//刷新button 内部控件
-(void)setTagelayout:(CMTDisease*)disease;
@end
