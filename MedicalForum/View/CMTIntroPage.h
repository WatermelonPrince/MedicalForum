//
//  CMTIntroPage.h
//  MedicalForum
//
//  Created by fenglei on 15/3/13.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol StartAction <NSObject>

-(void) onStartAction;

@end

@interface CMTIntroPage : UIView

/* constructor */
+ (instancetype)pageWithFrame:(CGRect)frame
                        title:(NSString *)title
                     subTitle:(NSString *)subTitle
             descriptionImage:(UIImage *)descriptionImage
                   indexImage:(UIImage *)indexImage
            actionButtonTitle:(NSString *)actionButtonTitle;

/* constructor */
+ (instancetype)pageWithFrame:(CGRect)frame
                        title:(UIImage *)title
             descriptionImage:(UIImage *)descriptionImage
                   indexImage:(UIImage *)indexImage
            actionButtonTitle:(NSString *)actionButtonTitle ;

/* output */
/// 点击按钮
@property (nonatomic, strong, readonly) RACSignal *actionButtonSignal;
@property(nonatomic,strong)id<StartAction> startActionDelegate;

-(void)startButton:(UIGestureRecognizer *)gestureRecognizer;

@end
