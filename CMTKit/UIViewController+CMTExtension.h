//
//  UIViewController+CMTExtension.h
//  MedicalForum
//
//  Created by fenglei on 15/5/4.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (CMTExtension)

- (void)addToParentViewController:(UIViewController *)parentViewController callingAppearanceMethods:(BOOL)callAppearanceMethods;
- (void)removeFromParentViewControllerCallingAppearanceMethods:(BOOL)callAppearanceMethods;

@end
