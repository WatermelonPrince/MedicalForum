//
//  CMTBaseViewController+CMTExtension.h
//  MedicalForum
//
//  Created by guoyuanchao on 16/11/28.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import "CMTBaseViewController.h"
@interface CMTBaseViewController(CMTExtension)
//分享公共方法
- (void)shareImageAndTextToPlatformType:(UMSocialPlatformType)platformType shareTitle:(NSString*)title  sharetext:(NSString*)text sharetype:(NSString*)shareType sharepic:(NSString*)sharepic shareUrl:(NSString*)shareUrl  StatisticalType:(NSString*)StatisticalType shareData:(CMTObject*)sharedata;
-(void)StartDiagramAndUpdatedVersion;
//广告点击数
-(void)AdClickStatistics:(NSDictionary*)param;
@end
