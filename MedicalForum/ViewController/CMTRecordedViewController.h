//
//  CMTRecordedViewController.h
//  MedicalForum
//
//  Created by guoyuanchao on 16/7/22.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import "CMTBaseViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "CMTSeriesDetailsViewController.h"
#import "CmtMoreVideoViewController.h"
@interface CMTRecordedViewController : CMTBaseViewController
//上页面的网络状态
-(instancetype)initWithRecordedParam:(CMTLivesRecord*)Param;
//更新阅读数
@property(nonatomic,strong)void(^updateReadNumber)(CMTLivesRecord*LivesRecord);
//更新阅读时间
@property(nonatomic,strong)void(^updateReadTime)(CMTLivesRecord*LivesRecord);
@end
