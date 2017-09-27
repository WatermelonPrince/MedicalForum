//
//  LiveTagFilterViewController.h
//  MedicalForum
//
//  Created by jiahongfei on 15/8/28.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTBaseViewController.h"

@interface CMTLiveTagFilterViewController : CMTBaseViewController

//初始化方法
-(instancetype)initWithlive:(CMTLive*)live
         liveBroadcastTagId:(NSString *)liveBroadcastTagId
       liveBroadcastTagName:(NSString *)liveBroadcastTagName;
@property (nonatomic, copy) void (^updatelivedata)(CMTLive* live);

@end
