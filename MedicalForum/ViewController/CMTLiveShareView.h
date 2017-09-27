//
//  CMTLiveShareView.h
//  MedicalForum
//
//  Created by guoyuanchao on 16/7/21.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMTBaseViewController.h"
@interface CMTLiveShareView : UIView
@property(nonatomic,strong)UIButton *Sharebutton;
@property(nonatomic,weak)CMTBaseViewController *parentView;
///分享title
@property (strong, nonatomic) NSString *shareTitle;
///分享brief
@property (strong, nonatomic) NSString *shareBrief;
///分享url
@property (strong, nonatomic) NSString *shareUrl;
@property(strong,nonatomic)CMTLivesRecord *LivesRecord;
@property(strong,nonatomic)void(^updateUsersnumber)(CMTLivesRecord*rect);
-(void)showSharaAction;
@end
