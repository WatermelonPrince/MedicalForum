//
//  CMTLiveShareView.m
//  MedicalForum
//
//  Created by guoyuanchao on 16/7/21.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import "CMTLiveShareView.h"

@implementation CMTLiveShareView
- (instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        self.Sharebutton=[UIButton buttonWithType:UIButtonTypeCustom];
        self.Sharebutton.frame=CGRectMake(10, 10,self.width-20, self.height-20);
        self.Sharebutton.layer.cornerRadius=5;
        [self.Sharebutton setBackgroundColor:[UIColor colorWithHexString:@"fdb32b"]];
        [self.Sharebutton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.Sharebutton addTarget:self action:@selector(showSharaAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.Sharebutton];
        
    }
    return self;
}
-(void)showSharaAction{
    [self.parentView.mShareView.mBtnFriend addTarget:self action:@selector(methodShare:) forControlEvents:UIControlEventTouchUpInside];
    [self.parentView.mShareView.mBtnSina addTarget:self action:@selector(methodShare:) forControlEvents:UIControlEventTouchUpInside];
    [self.parentView.mShareView.mBtnWeix addTarget:self action:@selector(methodShare:) forControlEvents:UIControlEventTouchUpInside];
    [self.parentView.mShareView.mBtnMail addTarget:self action:@selector(methodShare:) forControlEvents:UIControlEventTouchUpInside];
    [self.parentView.mShareView.cancelBtn addTarget:self action:@selector(methodShare:) forControlEvents:UIControlEventTouchUpInside];
    //自定义分享
    [self.parentView shareViewshow:self.parentView.mShareView bgView:self.parentView.tempView currentViewController:self.parentView.navigationController];

}
///平台按钮关联的分享方法
- (void)methodShare:(UIButton *)btn {
  
    // 没有网络连接
    if (!NET_WIFI && !NET_CELL && btn.tag != 5555) {
        [self.parentView toastAnimation:@"你的网络不给力" top:0];
        [self.parentView shareViewDisapper];
        return;
    }
    
    NSString *shareType = nil;
    switch (btn.tag)
    {
        case 1111:
        {
            if ([self respondsToSelector:@selector(friendCircleShare)]) {
                [self performSelector:@selector(friendCircleShare) withObject:nil afterDelay:0.20];
            }
            
        }
            break;
        case 2222:
        {
            if ([self respondsToSelector:@selector(weixinShare)]) {
                [self performSelector:@selector(weixinShare) withObject:nil afterDelay:0.20];
            }
        }
            break;
        case 3333:
        {
            shareType = @"3";
            if ([self respondsToSelector:@selector(weiboShare)]) {
                [self performSelector:@selector(weiboShare) withObject:nil afterDelay:0.20];
            }
        }
            break;
        case 4444:
        {
            CMTLog(@"邮件");
            shareType = @"4";
             [self shareAction:shareType];
            NSString *shareText =[self.LivesRecord.shareDesc stringByAppendingFormat:@" %@%@",self.LivesRecord.shareUrl,@" 来自@壹生<br>"];
            [self.parentView shareImageAndTextToPlatformType:UMSocialPlatformType_Email shareTitle:shareText sharetext:shareText sharetype:shareType sharepic:self.LivesRecord.sharePic.picFilepath shareUrl:self.LivesRecord.shareUrl StatisticalType:@"ShareStatisticsCourse" shareData:self.LivesRecord];
        }
            break;
        case 5555:
            [self.parentView shareViewDisapper];
            break;
        default:
            CMTLog(@"其他分享");
            break;
    }
    if ([self respondsToSelector:@selector(removeTargets)]) {
        [self performSelector:@selector(removeTargets) withObject:nil afterDelay:0.2];
    }
    
    [self.parentView shareViewDisapper];
}

- (void)removeTargets {
    [self.parentView.mShareView.mBtnFriend removeTarget:self action:@selector(methodShare:) forControlEvents:UIControlEventTouchUpInside];
    [self.parentView.mShareView.mBtnMail removeTarget:self action:@selector(methodShare:) forControlEvents:UIControlEventTouchUpInside];
    [self.parentView.mShareView.mBtnSina removeTarget:self action:@selector(methodShare:) forControlEvents:UIControlEventTouchUpInside];
    [self.parentView.mShareView.mBtnWeix removeTarget:self action:@selector(methodShare:) forControlEvents:UIControlEventTouchUpInside];
}

// 朋友圈分享
- (void)friendCircleShare {
    NSString *shareType = @"1";
    [self shareAction:shareType];
    CMTLog(@"朋友圈");
    
    NSString *shareText = self.LivesRecord.title.HTMLUnEscapedString;
    [self.parentView shareImageAndTextToPlatformType:UMSocialPlatformType_WechatTimeLine shareTitle:shareText sharetext:shareText sharetype:shareType sharepic:self.LivesRecord.sharePic.picFilepath shareUrl:self.LivesRecord.shareUrl StatisticalType:@"ShareStatisticsCourse" shareData:self.LivesRecord];
     }

/// 微信好友分享
- (void)weixinShare {
    NSString *shareType = @"2";
    NSString *shareTitle = self.LivesRecord.title.HTMLUnEscapedString;
    NSString *shareText = self.LivesRecord.shareDesc;
    NSString *shareURL = self.LivesRecord.shareUrl;
    if (BEMPTY(shareText)) {
        shareText =shareTitle;
    }
     [self shareAction:shareType];
    CMTLog(@"微信好友\nshareTitle: %@\nshareText: %@\nshareURL: %@", shareTitle, shareText, shareURL);
    [self.parentView shareImageAndTextToPlatformType:UMSocialPlatformType_WechatSession shareTitle:shareTitle sharetext:shareText sharetype:shareType sharepic:self.LivesRecord.sharePic.picFilepath shareUrl:self.LivesRecord.shareUrl StatisticalType:@"ShareStatisticsCourse" shareData:self.LivesRecord];
}

- (void)weiboShare {
   NSString *shareType=@"3";
    NSString *shareText = [@"#壹生#" stringByAppendingFormat:@"%@ %@%@",self.LivesRecord.title,self.LivesRecord.shareUrl,@" 来自@壹生_CMTopDr"];
    
    CMTLog(@"新浪文博\nshareText:%@", shareText);
    [self shareAction:shareType];
    [self.parentView shareImageAndTextToPlatformType:UMSocialPlatformType_Sina shareTitle:shareText sharetext:shareText sharetype:shareType sharepic:self.LivesRecord.sharePic.picFilepath shareUrl:self.LivesRecord.shareUrl StatisticalType:@"ShareStatisticsCourse" shareData:self.LivesRecord];
}
///下面得到分享完成的回调
-(void)shareAction:(NSString*)shareType{
    if(self.LivesRecord.classRoomId!=nil){
          NSDictionary *param=@{
                              @"userId": CMTUSERINFO.userId ?: @"",
                              @"classRoomType": self.LivesRecord.classRoomType ?: @"",
                              @"shareType": shareType ?: @"",
                              @"classRoomId":self.LivesRecord.classRoomId?:@"",
                              @"shareBatch":@"1",
                              @"coursewareId":self.LivesRecord.coursewareId?:@"",
                              };
        [[[CMTCLIENT ShareStatisticsCourse:param]deliverOn:[RACScheduler mainThreadScheduler]]
         subscribeNext:^(CMTLivesRecord *x) {
             CMTLog(@"sharePost success: %@", x);
             if (self.updateUsersnumber!=nil) {
                 self.updateUsersnumber(x);
             }
         } error:^(NSError *error) {
             NSString *errorStr = error.userInfo[@"errmsg"];
             [self.parentView toastAnimation:errorStr top:0];
             CMTLogError(@"sharePost error: %@", error);
         }];
    }

}

@end
