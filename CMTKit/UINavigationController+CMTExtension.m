//
//  UINavigationController+CMTExtension.m
//  MedicalForum
//
//  Created by fenglei on 15/4/27.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "UINavigationController+CMTExtension.h"

@implementation UINavigationController (CMTExtension)

- (UIViewController *)popThenPushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    UIViewController *poppedViewController = [self popViewControllerAnimated:NO];
    [self pushViewController:viewController animated:animated];
    
    return poppedViewController;
}

@end
