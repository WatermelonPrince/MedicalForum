//
//  CMTSetCaseTagViewController.h
//  MedicalForum
//
//  Created by guoyuanchao on 15/7/31.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTBaseViewController.h"
#import "CMTBarButtonItem.h"
#import "CMTSendCaseType.h"
//代理
@protocol CMTSetCaseTagViewDelegate <NSObject>
//设置疾病标签数据
-(void)setCaseTagData;
@end

@interface CMTSetCaseTagViewController : CMTBaseViewController
//初始化 module 0 文章详情 1 病例广场 2 小组
-(instancetype)initWithSubject:(NSString*)subjectId module:(CMTSendCaseType)module;
@property(nonatomic,weak)id<CMTSetCaseTagViewDelegate>deleagte;
@end
