//
//  CMTLiveViewController.h
//  MedicalForum
//
//  Created by guoyuanchao on 15/8/21.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTBaseViewController.h"

@interface CMTLiveViewController : CMTBaseViewController<UIGestureRecognizerDelegate>
//初始化方法
-(instancetype)initWithlive:(CMTLive*)live;
-(instancetype)initWithliveUuid:(NSString*)Uuid;
@property(nonatomic,strong)UIImage *shareimage;
@property (nonatomic, copy) void (^updatelivedata)(CMTLive* live);

@end
