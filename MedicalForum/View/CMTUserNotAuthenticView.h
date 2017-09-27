//
//  CMTUserNotAuthenticView.h
//  MedicalForum
//
//  Created by fenglei on 15/2/3.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import <UIKit/UIKit.h>

/// 用户未认证提示
@interface CMTUserNotAuthenticView : UIView

/* output */

/// 点击申请认证按钮
@property (nonatomic, strong, readonly) RACSignal *requestAuthenticationSignal;

@end
