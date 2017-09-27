//
//  CMTLightVideoViewController.h
//  MedicalForum
//
//  Created by zhaohuan on 16/6/1.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import "CMTBaseViewController.h"//点播
#import <PlayerSDK/VodSDK.h>
#import "CMTSeriesDetailsViewController.h"
#import "CmtMoreVideoViewController.h"
@interface CMTLightVideoViewController : CMTBaseViewController

@property (nonatomic, strong) downItem *item;
@property (nonatomic, strong) VodPlayer *vodplayer;
@property (nonatomic, assign) BOOL isLivePlay;
@property (nonatomic, strong) CMTLivesRecord *myliveParam;
@property(nonatomic,copy)void(^updateReadNumber)(CMTLivesRecord *live);
@end
