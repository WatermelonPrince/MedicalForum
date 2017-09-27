//
//  CMTBaseViewController.h
//  MedicalForum
//
//  Created by fenglei on 14/12/1.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SVPullToRefresh.h"                                                 // 下拉刷新

#import "CMTContentEmptyView.h"                                             // 空内容提示
#import "CMTToastView.h"                                                    // toast
#import "CMTShareView.h"                                                    // 分享
#import "CMTLivesRecord.h"
#import "CMTIntegralToastView.h" 
//积分
#import "UITableView+CMTExtension_PlaceholderView.h"
FOUNDATION_EXPORT const CGFloat CMTNavigationBarBottomGuide;
FOUNDATION_EXPORT const CGFloat CMTTabBarHeight;

/// 内容显示状态
typedef NS_OPTIONS(NSUInteger, CMTContentState) {
    CMTContentStateNormal = 0,      // 显示 contentBaseView
    CMTContentStateLoading,         // 显示 mAnimationImageView
    CMTContentStateReload,          // 显示 mReloadBaseView
    CMTContentStateEmpty,           // 显示 contentEmptyView
    CMTContentStateBlank,           // 空白页
};

/// 视图控制器基类
@interface CMTBaseViewController : UIViewController

///点播webView内跳转标记
@property (nonatomic, copy) NSString *nextVC;

/// 导航栏标题
@property (nonatomic, copy) NSString *titleText;

/// 底部导航栏视图层
/// 默认隐藏 需要加载底部导航栏时 取消隐藏
@property (nonatomic, strong) UIView *tabBarContainer;

/// 内容显示状态
@property (nonatomic, assign) CMTContentState contentState;

/// 内容视图
@property (nonatomic, strong) UIView *contentBaseView;

/// 空内容提示 (默认隐藏)
@property (nonatomic, strong) CMTContentEmptyView *contentEmptyView;

/// 加载动画
@property (strong, nonatomic) UIImageView *mAnimationImageView;
/// 执行加载动画
- (void)runAnimationInPosition:(CGPoint)point;
- (void)stopAnimation;

/// 重新加载
@property (strong, nonatomic) UIView *mReloadBaseView;
@property (strong, nonatomic) UIImageView *mReloadImgView;
@property (strong, nonatomic) UILabel *mLbupload;
@property(strong,nonatomic)UIView *MaskTheview;


/// 执行重新加载
- (void)animationFlash;

/// 自定义导航栏返回按钮
@property (strong, nonatomic) UIBarButtonItem *leftItem;
@property (strong, nonatomic) NSArray *customleftItems;

/// 自定义导航栏返回按钮执行方法
- (void)popViewController;

/// toast
@property (copy, nonatomic) CMTToastView *mToastView;
//积分提示
@property (copy, nonatomic) CMTIntegralToastView *mintegralToastView;

//@property(strong,nonatomic)
/// toast动画
/// prompt为提示语
- (void)toastAnimation:(NSString *)prompt;
- (void)toastAnimation:(NSString *)prompt top:(float)top;
- (void)hidden:(CMTToastView *)view;
- (void)toastIntegralAnimation:(NSString *)prompt title:(NSString*)title;
/// 断网提示
@property (nonatomic, strong) CMTToastView *offlineToast;

///自定义分享视图
@property (strong, nonatomic) CMTShareView *mShareView;
///弹出自定义视图后,背景图层
@property (strong, nonatomic) UIView *tempView;
///背景图层上的点击动作
@property (strong, nonatomic) UITapGestureRecognizer *tapGesture;
///自定义分享视图,动画弹出
- (void)shareViewshow:(CMTShareView *)
shareView bgView:(UIView *)bgView;

//自定义分享视图方法2;
- (void)shareViewshow:(CMTShareView *)shareView bgView:(UIView *)bgView currentViewController:(UIViewController*)controller;
///自定义分享视图,动画弹回
- (void)shareViewDisapper;
///修改字符串颜色
- (NSString *)string:(NSString *)str WithColor:(UIColor *)color;
//设置视图状态
- (void)setContentState:(CMTContentState)contentState moldel:(NSString*)model;
//设置带有遮罩的加载视图
- (void)setContentState:(CMTContentState)contentState moldel:(NSString*)model height:(float)height;
//获取网络状态
-(NSString*)getNetworkReachabilityStatus;
//查找并替换字符串
-(NSString*)findAndreplacestring:(NSString*)str formatten:(NSString*)regulaStr;
//UItableView提示语
- (UIView *)tableViewPlaceholderView:(UITableView*)tableView text:(NSString*)text;
#pragma mark 统计观看人数
-(void)StatisticsThenumber:(CMTLivesRecord*)myliveParam;
//判断声音是否后台播放
-(void)addAVAudioSessionNotification;
-(void)DeleteLearningRecord:(NSDictionary*)param sucess:(void (^)(CMTObject *))sucessback error:(void (^)(NSError *))errorback;
#pragma mark 处理应用内点播webView链接
-(BOOL)handleWithinLightVedio:(NSString*)urlString URLScheme:(NSString *)URLScheme viewController:(CMTBaseViewController*)Controller;
@end
