//
//  CMTBaseViewController+CMTExtension.m
//  MedicalForum
//
//  Created by guoyuanchao on 16/11/28.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import "CMTBaseViewController+CMTExtension.h"
#import "CMTAdvertisingController.h"
#import "CMTHolidayViewController.h"
#import "CMTWebBrowserViewController.h"
#import "CMTBindingViewController.h"
@implementation CMTBaseViewController(CMTExtension)
//分享图片和文字
- (void)shareImageAndTextToPlatformType:(UMSocialPlatformType)platformType shareTitle:(NSString*)title  sharetext:(NSString*)text sharetype:(NSString*)shareType sharepic:(NSString*)sharepic shareUrl:(NSString*)shareUrl  StatisticalType:(NSString*)StatisticalType shareData:(CMTObject*)sharedata
{
    
    float top=[sharedata isKindOfClass:[CMTLivesRecord class]]?0:64;
    //创建分享消息对象
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    //创建图片内容对象
    if(shareType.integerValue==3||shareType.integerValue==4){
        //创建图片内容对象
        messageObject.text=text;
        UMShareImageObject *shareObject = [[UMShareImageObject alloc] init];
        //如果有缩略图，则设置缩略图
        shareObject.thumbImage =sharepic.length==0?IMAGE(@"AppIcon60x60"):sharepic;
        [shareObject setShareImage:sharepic.length==0?IMAGE(@"AppIcon60x60"):sharepic];
        messageObject.shareObject = shareObject;
    }else{
        UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:title descr:text thumImage:sharepic.length==0?IMAGE(@"AppIcon60x60"):sharepic];
        //设置网页地址
        shareObject.webpageUrl =shareUrl;
        //分享消息对象设置分享内容对象
        messageObject.shareObject = shareObject;
    }
    //调用分享接口
    [[UMSocialManager defaultManager] shareToPlatform:platformType messageObject:messageObject currentViewController:self completion:^(id data, NSError *error) {
        if (error) {
            UMSocialLogInfo(@"************Share fail with error %@*********",error);
            if(error.userInfo.allKeys.count==0){
                if(shareType.integerValue==1||shareType.integerValue==2)
                    [self toastAnimation: @"未安装微信客户端" top:top];
            }else{
              [self toastAnimation:@"分享失败" top:top];
            }
        }else{
            if ([data isKindOfClass:[UMSocialShareResponse class]]) {
                [self toastAnimation:@"分享成功" top:top];
                [[self StatisticalType:StatisticalType sharetype:shareType shareData:sharedata ]
                 subscribeNext:^(id x) {
                     CMTLog(@"sharePost success: %@", x);
                 } error:^(NSError *error) {
                     CMTLogError(@"sharePost error: %@", error);
                 }];
            }else{
                UMSocialLogInfo(@"response data is %@",data);
            }
        }
    }];
}
-(RACSignal*)StatisticalType:(NSString*)type sharetype:(NSString*)shareType shareData:(CMTObject*)sharedata{
    if([type isEqualToString:@"shareTheme"]){
      return [CMTCLIENT  shareTheme:@{
                                 @"userId": CMTUSERINFO.userId ?: @"",
                                 @"themeId": ((CMTTheme*)sharedata).themeId ?: @"",
                                 @"shareType": shareType ?: @"",
                                 }];
    }else if([type isEqualToString:@"sharePost"]){
       return [CMTCLIENT sharePost:@{
                                @"userId": CMTUSERINFO.userId ?: @"",
                                @"groupId":[sharedata  isKindOfClass:[CMTCaseLIstData class]]?(((CMTCaseLIstData*)sharedata).groupInfo.groupId ?: @""):@"",
                                 @"postId":[sharedata  isKindOfClass:[CMTPost class]]?( ((CMTPost*)sharedata).postId?: @""):@"",
                                 @"shareType": shareType ?: @"",
                                }];
    }else if([type isEqualToString:@"commonShare"]){
       return  [CMTCLIENT commonShare:@{
                                 @"userId": CMTUSERINFO.userId ?: @"",
                                 @"serviceId": ((CMTPost*)sharedata).postId?: @"",
                                 @"type": @"2",
                                 @"shareType": shareType ?: @"",
                                 }];
    }else if([type isEqualToString:@"getShareLive"]){
         return  [CMTCLIENT getShareLive:@{
                               @"userId": CMTUSERINFO.userId ?: @"",
                               @"type":((CMTLive*)sharedata).shareModel?:@"0",
                               @"serviceId":((CMTLive*)sharedata).shareServiceId?:@"",
                               @"shareType": shareType ?: @"",
                               }];
    }
    
  return [RACSignal empty];
}
//版本更新和启动首页
-(void)StartDiagramAndUpdatedVersion{
    RACSignal *currentVersion=[RACObserve(CMTAPPCONFIG,recordedVersion) ignore:nil];
    RACSignal *subscription=[RACObserve(CMTAPPCONFIG,subscriptionRecordedVersion) ignore:nil];
    RACSignal *InitObject=[RACObserve(CMTAPPCONFIG,InitObject) ignore:nil];
    RACSignal *StartObject=[RACObserve(CMTAPPCONFIG,IsStartWebDisappear) ignore:nil];

    // 监听启动图
    @weakify(self);
    [[[RACSignal merge:CMTAPPCONFIG.currentVersionFirstLaunch?@[InitObject,currentVersion,subscription,StartObject]:@[InitObject,StartObject]] deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(id x) {
        @strongify(self);
        if(CMTAPPCONFIG.InitObject!=nil&&CMTAPPCONFIG.recordedVersion!=nil&&CMTAPPCONFIG.subscriptionRecordedVersion!=nil&&CMTAPPCONFIG.IsStartWebDisappear.integerValue==1){
            if(CMTAPPCONFIG.InitObject.adver.picUrl.length>0&&!CMTAPPCONFIG.IsStartedGuidePage){
                CMTAdvertisingController *Advertising=[[CMTAdvertisingController alloc]init];
                @weakify(self);
                Advertising.jumpLinks=^(){
                     @strongify(self)
                    BOOL flag=[CMTAPPCONFIG.InitObject.adver.jumpLinks handleWithinArticle:CMTAPPCONFIG.InitObject.adver.jumpLinks viewController:self];
                    if(flag){
                        CMTWebBrowserViewController *web=[[CMTWebBrowserViewController alloc]initWithURL:CMTAPPCONFIG.InitObject.adver.jumpLinks];
                      [self.navigationController pushViewController:web animated:YES];
                    }

                };
                [self.navigationController pushViewController:Advertising animated:NO];
            }else{
                NSArray *items=CMTAPPCONFIG.InitObject.items;
                for (CMTInitObject *object in items) {
                    if (object.type.integerValue==1) {
                        CMTHolidayViewController *Holiday=[[CMTHolidayViewController alloc]initWithUrl:object.val];
                        CMTNavigationController *nav=[[CMTNavigationController alloc]initWithRootViewController:Holiday];
                        [self presentViewController:nav animated:NO completion:nil];
                        return ;
                    }
                }

            }
            
        }
        
    } completed:^{
        
    }];
    // 监听版本更新
    RACSignal *AppVersion=[RACObserve(CMTAPPCONFIG, AppVersionObject) ignore:nil];
    [[[RACSignal merge:CMTAPPCONFIG.currentVersionFirstLaunch?@[AppVersion,currentVersion,subscription]:@[AppVersion,StartObject]] deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(CMTInitObject *object) {
        if(CMTAPPCONFIG.AppVersionObject!=nil&&CMTAPPCONFIG.recordedVersion!=nil&&CMTAPPCONFIG.subscriptionRecordedVersion!=nil&&CMTAPPCONFIG.IsStartWebDisappear.integerValue==1){
            NSInteger updateStatus=CMTAPPCONFIG.AppVersionObject.updateStatus.integerValue;
            NSString *Version=[CMTAPPCONFIG.AppVersionObject.version stringByReplacingOccurrencesOfString:@"." withString:@""];
            if (Version.length>0) {
                NSString *CurrentVersion=[APP_VERSION stringByReplacingOccurrencesOfString:@"." withString:@""];
                if(Version.length>CurrentVersion.length){
                    for(int i=0;i<Version.length-CurrentVersion.length;i++){
                        CurrentVersion=[CurrentVersion stringByAppendingString:@"0"];
                    }
                }
                if (Version.integerValue>CurrentVersion.integerValue) {
                    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"请升级新版本" message:CMTAPPCONFIG.AppVersionObject.desc delegate:nil cancelButtonTitle:updateStatus==0?@"下次再说":@"立即更新" otherButtonTitles:updateStatus==1?nil:@"立即更新", nil];
                    [alert.rac_buttonClickedSignal subscribeNext:^(NSNumber *index) {
                        // 确定 跳转App Store
                        if ([index integerValue] ==(alert.numberOfButtons-1)) {
                            [[UIApplication sharedApplication] openURL:
                             [NSURL URLWithString:@"itms-apps://itunes.apple.com/us/app/yi-sheng/id548271766?l=zh&ls=1&mt=8"]];
                        }else{
                            CMTAPPCONFIG.AppVersionObject=nil;
                        }
                        
                    } error:^(NSError *error) {
                        
                    }];
                    [alert show];
                }
                
                
            }
        }
        
    } completed:^{
        
    }];
    
}
-(void)AdClickStatistics:(NSDictionary*)param{
    [[[CMTCLIENT GetAdClickStatistics:param]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(id x) {
        
    } error:^(NSError *error) {
        NSLog(@"统计失败");
    }];
}
@end
