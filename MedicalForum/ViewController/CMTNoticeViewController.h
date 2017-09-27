//
//  CMTNoticeViewController.h
//  MedicalForum
//
//  Created by guoyuanchao on 15/7/26.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTBaseViewController.h"

@interface CMTNoticeViewController : CMTBaseViewController<UITableViewDataSource,UITableViewDelegate>
//0 首页 2 病例
-(instancetype)initWithModel:(NSString *)module;
-(instancetype)initWithGroup:(CMTGroup *)group;
//更新通知数目
@property(nonatomic,strong)void(^updatenoticeNumber)();
//带参数的更新通数目
@property(nonatomic,strong)void(^updatenotice)(NSString *number);
//文章屏蔽成功
@property(nonatomic, copy) void (^ShieldingArticleSucess)(CMTPost *post);
//文章置顶或取消置顶成功
@property(nonatomic, copy) void (^PlacedTheTopSucess)(CMTPost *post);

@end
