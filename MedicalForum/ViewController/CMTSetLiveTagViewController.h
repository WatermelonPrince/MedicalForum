//
//  CMTSetLiveTagViewController.h
//  MedicalForum
//
//  Created by guoyuanchao on 15/8/31.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTBaseViewController.h"

@interface CMTSetLiveTagViewController : CMTBaseViewController<UITableViewDataSource,UITableViewDelegate>
//数据回调
@property(nonatomic,strong)void(^updatetitle)(CMTLiveTag*livetag);
-(instancetype)initWithLiveID:(NSString*)liveID;


@end
