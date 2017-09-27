//
//  UINavigationController+CMTExtension.h
//  MedicalForum
//
//  Created by fenglei on 15/4/27.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (CMTExtension)

- (UIViewController *)popThenPushViewController:(UIViewController *)viewController animated:(BOOL)animated;

@end
