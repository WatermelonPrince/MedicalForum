//
//  CMTNavigationController.m
//  MedicalForum
//
//  Created by fenglei on 14/12/10.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTNavigationController.h"
#import "NavigationInteractiveTransition.h"
#import "CMTGroupMembersViewController.h"
#import "CMTCollectionViewController.h"
#import "CMTSearchMemberViewController.h"
#import "CMTLightVideoViewController.h"
#import "LiveVideoPlayViewController.h"
#import "CMTRecordedViewController.h"
#import "CMTGroupInfoViewController.h"
#import "CMTLearnRecordViewController.h"
#import "CMTDownCenterViewController.h"
#import "CMTDownloadLightVedioViewController.h"
#import "LDZMoviePlayerController.h"
#import "CMTAboutViewController.h"
@interface CMTNavigationController ()<UIGestureRecognizerDelegate>
@property (nonatomic, weak) UIPanGestureRecognizer *popRecognizer;
/**
 *  方案一不需要的变量
 */
@property (nonatomic, strong) NavigationInteractiveTransition *navT;
@property(nonatomic,strong) NSString *isallowGesturesToreturn;

@end

@implementation CMTNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
    // Do any additional setup after loading the view.
    
    // bar背景色
//    self.navigationBar.backgroundColor = COLOR(c_clear);
//    CMTSET(self.navigationBar, barTintColor) = COLOR(c_f5f5f5f5);
    
    // items渲染色
    self.navigationBar.tintColor = COLOR(c_32c7c2);
    
    // 返回键
    UIImage *backIndicator = IMAGE(@"naviBar_back");
    CMTSET(self.navigationBar, backIndicatorImage) = backIndicator;
    CMTSET(self.navigationBar, backIndicatorTransitionMaskImage) = backIndicator;
    
    //添加左划返回手势
    UIGestureRecognizer *gesture = self.interactivePopGestureRecognizer;
    gesture.enabled = NO;
    UIView *gestureView = gesture.view;
    
    UIPanGestureRecognizer *popRecognizer = [[UIPanGestureRecognizer alloc] init];
    popRecognizer.delegate = self;
    popRecognizer.maximumNumberOfTouches = 1;
    [gestureView addGestureRecognizer:popRecognizer];
    
    _navT = [[NavigationInteractiveTransition alloc] initWithViewController:self];
    [popRecognizer addTarget:_navT action:@selector(handleControllerPop:)];
     self.isallowGesturesToreturn=@"0";

}
//控制滑动删除
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if ([self.topViewController isKindOfClass:[CMTGroupMembersViewController class]]||[self.topViewController isKindOfClass:[CMTCollectionViewController class]]||[self.topViewController isKindOfClass:[CMTSearchMemberViewController class]]||[self.topViewController isKindOfClass:[CMTLightVideoViewController class]]||[self.topViewController isKindOfClass:[LiveVideoPlayViewController class]]||[self.topViewController isKindOfClass:[CMTRecordedViewController class]]) {
        return NO;
    }else if ([self.topViewController isKindOfClass:[CMTGroupInfoViewController class]]){
          CMTGroupInfoViewController *groupVC = (CMTGroupInfoViewController *)self.topViewController;
            if (groupVC.fromController == FromUpgrade){
                 return NO;
             }
     }
    if([self.topViewController isKindOfClass:[CMTLearnRecordViewController class]]||[self.topViewController isKindOfClass:[CMTDownCenterViewController class]]||[self.topViewController isKindOfClass:[CMTDownloadLightVedioViewController class]]||[self.topViewController isKindOfClass:[LDZMoviePlayerController class]]||[self.topViewController isKindOfClass:[CMTAboutViewController class]]){
        return NO;
    }
     return YES;
}
- (UIViewController *)childViewControllerForStatusBarStyle{
    return self.topViewController;
}
- (UIStatusBarStyle)preferredStatusBarStyle{
   UIViewController *topVC = self.topViewController;
    return [topVC preferredStatusBarStyle];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
