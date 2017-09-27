//
//  CMTLiveNoticeViewController.h
//  MedicalForum
//
//  Created by jiahongfei on 15/8/27.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTBaseViewController.h"

@interface CMTLiveNoticeViewController : CMTBaseViewController<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong)void(^updateNoticeCount)(NSString* count);
-(instancetype)initWithLiveId:(NSString *)liveBroadcastId;

@end
