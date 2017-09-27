//
//  CMTSendCaseViewController.h
//  MedicalForum
//
//  Created by fenglei on 15/7/31.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTNavigationController.h"
#import "CMTBaseViewController.h"
#import "CMTSendCaseType.h"

/// 发帖
@interface CMTSendCaseViewController : CMTBaseViewController

/* init */
-(instancetype)initWithSenLivemassge:(CMTLive*)live;
/// designated initializer
- (instancetype)initWithSendCaseType:(CMTSendCaseType)sendCaseType
                              postId:(NSString *)postId
                          postTypeId:(NSString *)postTypeId
                             groupId:(NSString *)groupId
                      groupSubjectId:(NSString *)groupSubjectId;

/// 发帖后刷新列表
@property (nonatomic, copy) void (^updateCaseList)(CMTAddPost *);
-(void)setNumberlableText:(NSString *)text;
@property(nonatomic,strong)UILabel *numberlable;
@property(nonatomic,strong)UILabel *numberlable2;


@end
