//
//  CMTTabBar.m
//  MedicalForum
//
//  Created by fenglei on 15/5/8.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

// view
#import "CMTTabBar.h"                   // header file

static const NSInteger CMTTabBarDefaultItemCount = 5;

@interface CMTTabBar ()

// output
@property (nonatomic, weak, readwrite) CMTTabBarItem *selectedItem;                 // 当前选中的条目

// view
@property (nonatomic, strong) UIToolbar *blurView;                                  // 模糊视图
@property (nonatomic, strong) UIImageView *shadow;                                  // 阴影
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;                   // 点击手势
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;                   // 滑动手势
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;       // 长按手势

// data
@property (nonatomic, copy) NSMutableArray *tabBarItems;                            // 所有导航栏条目

@property (nonatomic, assign) BOOL initialization;                                  // 是否初始化frame

@end

@implementation CMTTabBar

#pragma mark Initializers

- (UIToolbar *)blurView {
    if (_blurView == nil) {
        _blurView = [[UIToolbar alloc] init];
        _blurView.backgroundColor = COLOR(c_clear);
        _blurView.barTintColor = COLOR(c_f5f5f5f5);
        _blurView.barStyle = UIBarStyleDefault;
        // to do 模糊效果
        // translucent = YES 会导致navigationBar push/pop时右侧出现阴影
        _blurView.translucent = NO;
        // to do clipsToBounds = YES 可隐藏toolBar上面的分隔线
        _blurView.clipsToBounds = NO;
    }
    
    return _blurView;
}

- (UIImageView *)shadow {
    if (_shadow == nil) {
        _shadow = [[UIImageView alloc] init];
        _shadow.backgroundColor = COLOR(c_clear);
    }
    
    return _shadow;
}

- (UITapGestureRecognizer *)tapGesture {
    if (_tapGesture == nil) {
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    }
    
    return _tapGesture;
}

- (UIPanGestureRecognizer *)panGesture {
    if (_panGesture == nil) {
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        _panGesture.maximumNumberOfTouches = 1;
    }
    
    return _panGesture;
}

- (UILongPressGestureRecognizer *)longPressGesture {
    if (_longPressGesture == nil) {
        _longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    }
    
    return _longPressGesture;
}

- (NSMutableArray *)tabBarItems {
    if (_tabBarItems == nil) {
        _tabBarItems = [NSMutableArray array];
    }
    
    return _tabBarItems;
}

- (instancetype)init {
    self = [super init];
    if (self == nil) return nil;
    CMTLog(@"%s", __FUNCTION__);
    @weakify(self);
    [self.rac_willDeallocSignal subscribeCompleted:^{
        CMTLog(@"TabBar willDeallocSignal");
    }];
    
    // 准备数据
    NSArray *images = @[
                        @"tabBar_home_normal",
                        @"tabBar_case_normal",
                        @"tabBar_university_normal",
                        @"tabBar_guide_normal",
                        @"tabBar_mine_normal",
                        ];
    NSArray *selectedImages = @[
                                @"tabBar_home_selected",
                                @"tabBar_case_selected",
                                @"tabBar_university_selected",
                                @"tabBar_guide_selected",
                                @"tabBar_mine_selected",
                                ];
    NSArray *titles = @[
                        @"资讯",
                        @"论吧",
                        @"壹生大学",
                        @"发现",
                        @"我的"
                        ];
    // 初始化
    for (NSInteger index = 0; index < CMTTabBarDefaultItemCount; index++) {
        CMTTabBarItem *tabBarItem = [[CMTTabBarItem alloc] initWithTitle:titles[index]
                                                                   image:IMAGE(images[index])
                                                           selectedImage:IMAGE(selectedImages[index]) index:index];
        [self.tabBarItems addObject:tabBarItem];
        if (index == 0) {
            self.selectedItem = tabBarItem;
            tabBarItem.selected = YES;
        }
    }
    
    self.backgroundColor = COLOR(c_clear);
    
    // 初始化frame
    [[RACObserve(self, frame)
      deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        @strongify(self);
        if (self.frame.size.height > 0 && !self.initialization) {
            self.initialization = [self initializeWithSize:self.frame.size];
        }
    }];
    
#pragma mark 手势识别
    
    [self addGestureRecognizer:self.tapGesture];
    [self addGestureRecognizer:self.panGesture];
    [self addGestureRecognizer:self.longPressGesture];
    
#pragma mark 标记通知
    
    // 未读专题文章数
    RACSignal *themeUnreadNumberSignal = [RACObserve(CMTAPPCONFIG, HomeNoticeUnreadNumber) ignore:nil];
    // 未读专题文章数
    RACSignal *HomePushUnreadNumberSignal = [RACObserve(CMTAPPCONFIG, HomePushUnreadNumber) ignore:nil];
   //未读指南文章数 add by guoyuanchaO
    
    RACSignal *guideUnreadNumberSignal=[RACObserve(CMTAPPCONFIG, GuideUnreadNumber) ignore:nil];
    //未读圈子文章数和圈子通知数 add by guoyuanchaO
    
    RACSignal * CaseNoticeNumberSignal=[RACObserve(CMTAPPCONFIG, CaseNoticeNumber) ignore:nil];
    RACSignal * CollegeNumberSignal=[RACObserve(CMTAPPCONFIG, collagePushUnreadNumber) ignore:nil];

    
    
    // '首页'标记红点
    [[[RACSignal merge:@[
                         themeUnreadNumberSignal,
                         HomePushUnreadNumberSignal,
                         ]]
      deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSString *HomeNoticeUnreadNumber) {
        @strongify(self);
        CMTTabBarItem *tabBarItem = self.tabBarItems[0];
        if (CMTAPPCONFIG.HomeNoticeUnreadNumber.integerValue>0) {
            tabBarItem.isShowBagde=YES;
            tabBarItem.badgeValue = CMTAPPCONFIG.HomeNoticeUnreadNumber;
        }else{
            tabBarItem.isShowBagde=NO;
            tabBarItem.badgeValue = CMTAPPCONFIG.HomePushUnreadNumber;
        }
        
    }];
    // "学院更新标记"标记红点
    [[CollegeNumberSignal
      deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSString *HomeNoticeUnreadNumber) {
        @strongify(self);
        CMTTabBarItem *tabBarItem = self.tabBarItems[2];
        tabBarItem.isShowBagde=NO;
        tabBarItem.badgeValue=CMTAPPCONFIG.collagePushUnreadNumber;
    }];

    // 圈子标记数目
    [[CaseNoticeNumberSignal
      deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSString *CaseNoticeNumber) {
        @strongify(self);
        CMTTabBarItem *tabBarItem = self.tabBarItems[1];
        tabBarItem.isShowBagde=YES;
        tabBarItem.badgeValue =CaseNoticeNumber;
        UINavigationController *navigation=[[APPDELEGATE.tabBarController viewControllers]objectAtIndex:APPDELEGATE.tabBarController.selectedIndex];
        if (APPDELEGATE.tabBarController.selectedIndex==1) {
            if ([navigation.topViewController isKindOfClass:[CMTCaseCircleViewController class]]&&[CMTAPPCONFIG.isrefreahCase boolValue]){
                [((CMTCaseCircleViewController*)navigation.topViewController) getCaseTeamlistData];
                CMTAPPCONFIG.isrefreahCase =@"0";
            }
        }

    }];
  //指南未读文章数 add by guoyuanchao
    [[guideUnreadNumberSignal  deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(NSString *guideUnreadNumber) {
        @strongify(self);
        CMTTabBarItem *tabBarItem=self.tabBarItems[3];
        tabBarItem.isShowBagde=YES;
        tabBarItem.badgeValue=guideUnreadNumber;
        UINavigationController *navigation=[[APPDELEGATE.tabBarController viewControllers]objectAtIndex:APPDELEGATE.tabBarController.selectedIndex];
        if (APPDELEGATE.tabBarController.selectedIndex==3) {
            if ([navigation.topViewController isKindOfClass:[CMTGuideViewController class]]&&[CMTAPPCONFIG.isReloadGuadeTagView boolValue]){
                [((CMTGuideViewController*)navigation.topViewController) CMTGetTagArray];
                CMTAPPCONFIG.isReloadGuadeTagView=@"false";
            }else{
                 CMTAPPCONFIG.isReloadGuadeTagView=@"false";
            }
        }else{
            CMTAPPCONFIG.isReloadGuadeTagView=@"false";
        }
        
    }];
    
    return self;
}

- (BOOL)initializeWithSize:(CGSize)size {
    CMTLog(@"%s", __FUNCTION__);
    
    [self.blurView fillinContainer:self WithTop:0.0 Left:0.0 Bottom:0.0 Right:0.0];
    [self.shadow builtinContainer:self WithLeft:0.0 Top:0.0 Width:self.width Height:0.0];
    
    CGFloat tabBarItemWidth = self.width / (CGFloat)CMTTabBarDefaultItemCount;
    for (NSInteger index = 0; index < CMTTabBarDefaultItemCount; index ++) {
        CMTTabBarItem *tabBarItem = self.tabBarItems[index];
        [tabBarItem builtinContainer:self WithLeft:tabBarItemWidth * index Top:0.0 Width:tabBarItemWidth Height:self.height];
    }
    
    return YES;
}

#pragma mark LifeCycle

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    if (_selectedIndex == selectedIndex) {
        return;
    }
    
    if (selectedIndex >= CMTTabBarDefaultItemCount) {
        return;
    }
    
    _selectedIndex = selectedIndex;
    
    for (CMTTabBarItem *tabBarItem in self.tabBarItems) {
        tabBarItem.selected = NO;
    }
    
    self.selectedItem = self.tabBarItems[selectedIndex];
    self.selectedItem.selected = YES;
}

- (void)handleTap:(UITapGestureRecognizer *)recognizer {
    NSInteger index = [self indexOfLocation:[recognizer locationInView:self]];
    if (index != NSNotFound) {
        [self didSelectedItemAtIndex:index];
    }
}

- (void)handlePan:(UIPanGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        NSInteger index = [self indexOfLocation:[recognizer locationInView:self]];
        if (index != NSNotFound) {
            @weakify(self);
            [[RACScheduler mainThreadScheduler] afterDelay:0.15 schedule:^{
                @strongify(self);
                [self didSelectedItemAtIndex:index];
            }];
        }
    }
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        NSInteger index = [self indexOfLocation:[recognizer locationInView:self]];
        if (index != NSNotFound) {
            [self didSelectedItemAtIndex:index];
        }
    }
}

- (NSInteger)indexOfLocation:(CGPoint)location {
    __block NSUInteger index = NSNotFound;
    
    [self.tabBarItems enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
        if (CGRectContainsPoint(view.frame, location)) {
            index = idx;
            *stop = YES;
        }
    }];
    
    return index;
}

- (void)didSelectedItemAtIndex:(NSInteger)index {
    @try {
        UITabBarController *tabBarController = APPDELEGATE.tabBarController;
        if (index < tabBarController.viewControllers.count) {
            tabBarController.selectedIndex = index;
        }
        if (index == 1) {
            [MobClick event:@"B_LunBa"];
        }else if(index==2){
            [MobClick event:@"B_College"];
           [CMTAPPCONFIG ProcessingInformBage:2];
        }else if (index == 3) {
            [MobClick event:@"B_FaXian"];
        }else if (index == 4) {
            [MobClick event:@"B_Mine"];
        }else{
            [CMTAPPCONFIG ProcessingInformBage:0];
         }
    }
    @catch (NSException *exception) {
        CMTLogError(@"TabBar Select Item Exception: %@", exception);
    }
}

@end
