//
//  CMTContactViewController.h
//  MedicalForum
//
//  Created by guoyuanchao on 16/10/31.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import "CMTBaseViewController.h"
typedef NS_OPTIONS(NSUInteger, CMTImageType) {
    CMTTContactUsImage = 0,      //联系为我们
    CMTTRecommendedImage,         //推荐给好友
};

@interface CMTContactViewController : CMTBaseViewController

@end
