//
//  CMTDownloadLightVedioViewController.h
//  MedicalForum
//
//  Created by zhaohuan on 2017/3/23.
//  Copyright © 2017年 CMT. All rights reserved.
//

#import "CMTBaseViewController.h"

@interface CMTDownloadLightVedioViewController : CMTBaseViewController
@property (nonatomic ,strong) NSString *vodId;
@property (nonatomic, strong) CMTLivesRecord *myliveParam;
@property (nonatomic, copy)void(^updateReadtime)(CGFloat time);




@end
