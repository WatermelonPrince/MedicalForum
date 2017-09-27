//
//  CMTCaseSendSubjectViewController.h
//  MedicalForum
//
//  Created by guoyuanchao on 15/8/4.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTBaseViewController.h"
#import"CMTSendCaseType.h"
//刷新学科名称
@protocol CMTSendSubjectDelegate <NSObject>
-(void)refreshSubjectName;
@end
@interface CMTCaseSendSubjectViewController : CMTBaseViewController
@property(weak,nonatomic)id<CMTSendSubjectDelegate>delegate;
-(instancetype)initWithModule:(CMTSendCaseType)module;
@end
