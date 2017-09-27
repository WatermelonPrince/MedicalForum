//
//  LiveVideoPlayViewController.h
//  MedicalForum
//
//  Created by guoyuanchao on 16/5/31.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import "CMTBaseViewController.h"
#import <QuartzCore/QuartzCore.h>
@interface LiveVideoPlayViewController :CMTBaseViewController{
    CGRect docRect;//初始大小
    CGRect smallRect;//竖屏初始小窗口位置
    CGRect landscapesmallRect;//横屏初始小窗口位置
     CGRect landscapedocRect;//横屏窗口大小
    
}
-(instancetype)initWithParam:(CMTLivesRecord*)param;
-(instancetype)initWithPushContent:(CMTLivesRecord*)param from:(BOOL)push;
@property(nonatomic,copy)void(^updateLiveList)(CMTLivesRecord *live);
@property (nonatomic, strong) GSPPlayerManager *playerManager;//直播实力控制器
@property (nonatomic, copy)NSString *networkReachabilityStatus;
@property(nonatomic,assign)NSUInteger EnterType;//进入类型
@end
