//
//  CMTSubscriptionGuideViewController.m
//  MedicalForum
//
//  Created by fenglei on 15/3/19.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTSubscriptionGuideViewController.h"
#import "CMTSubscriptionGuideCell.h"
#import "CMTCenterViewController.h"             // 首页文章列表

NSString * const CMTSubscriptionGuideCellIdentifier = @"CMTSubscriptionGuideCellIdentifier";

@interface CMTSubscriptionGuideViewController ()

/* view */
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *confirmView;
@property (nonatomic, strong) UIButton *confirmButton;

/* data */
@property (nonatomic, strong) NSArray *data;
@property (nonatomic, strong) NSMutableDictionary *subscriptions;

@end

@implementation CMTSubscriptionGuideViewController

#pragma mark Initializers

- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] init];
        [_tableView sizeToFillinContainer:self.view WithTop:CMTNavigationBarBottomGuide Left:0 Bottom:54.5 Right:0];
        _tableView.backgroundColor = COLOR(c_ffffff);
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [_tableView registerClass:[CMTSubscriptionGuideCell class] forCellReuseIdentifier:CMTSubscriptionGuideCellIdentifier];
    }
    
    return _tableView;
}

- (UIView *)confirmView {
    if (_confirmView == nil) {
        _confirmView = [[UIView alloc] init];
        [_confirmView sizeToFillinContainer:self.view WithTop:self.tableView.bottom Left:0 Bottom:0 Right:0];
        _confirmView.backgroundColor = COLOR(c_ffffff);
        
        // 确认按钮
        [self.confirmButton builtinContainer:_confirmView WithLeft:0 Top:6.5 Width:281.0 Height:43.5];
        self.confirmButton.centerX = _confirmView.centerX;
        
        // 分隔线
        UIView *topLine = [[UIView alloc] init];
        [topLine builtinContainer:_confirmView WithLeft:0 Top:0 Width:_confirmView.width Height:PIXEL];
        topLine.backgroundColor = COLOR(c_9e9e9e);
    }
    
    return _confirmView;
}

- (UIButton *)confirmButton {
    if (_confirmButton == nil) {
        _confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _confirmButton.backgroundColor = COLOR(c_32c7c2);
        [_confirmButton setTitleColor:COLOR(c_ffffff) forState:UIControlStateNormal];
        [_confirmButton setTitleColor:COLOR(c_9e9e9e) forState:UIControlStateDisabled];
        [_confirmButton setTitle:@"确定" forState:UIControlStateNormal];
        _confirmButton.titleLabel.font = FONT(18.0);
        _confirmButton.layer.masksToBounds = YES;
        _confirmButton.layer.borderColor = COLOR(c_32c7c2).CGColor;
        _confirmButton.layer.borderWidth = PIXEL;
        _confirmButton.layer.cornerRadius = 6.0;
    }
    
    return _confirmButton;
}

- (NSArray *)data {
    if (_data == nil) {
        _data = @[
                  [[CMTConcern alloc] initWithDictionary:@{
                                                           @"subjectId" : @"1",
                                                           @"subject" : @"肿瘤",
                                                           @"CMT_selected" : @"0",
                                                           } error:nil],
                  
                  [[CMTConcern alloc] initWithDictionary:@{
                                                           @"subjectId" : @"2",
                                                           @"subject" : @"心血管",
                                                           @"CMT_selected" : @"0",
                                                           } error:nil],
                  
                  [[CMTConcern alloc] initWithDictionary:@{
                                                           @"subjectId" : @"3",
                                                           @"subject" : @"内分泌",
                                                           @"CMT_selected" : @"0",
                                                           } error:nil],
                  
                  [[CMTConcern alloc] initWithDictionary:@{
                                                           @"subjectId" : @"4",
                                                           @"subject" : @"消化&肝病",
                                                           @"CMT_selected" : @"0",
                                                           } error:nil],
                  
                  [[CMTConcern alloc] initWithDictionary:@{
                                                           @"subjectId" : @"5",
                                                           @"subject" : @"神经",
                                                           @"CMT_selected" : @"0",
                                                           } error:nil],
                  
                  [[CMTConcern alloc] initWithDictionary:@{
                                                           @"subjectId" : @"6",
                                                           @"subject" : @"全科",
                                                           @"CMT_selected" : @"0",
                                                           } error:nil],
                  
                  
                 
                  
                  [[CMTConcern alloc] initWithDictionary:@{
                                                           @"subjectId" : @"9",
                                                           @"subject" : @"综合&人文",
                                                           @"CMT_selected" : @"0",
                                                           } error:nil],
                  
                  [[CMTConcern alloc] initWithDictionary:@{
                                                           @"subjectId" : @"7",
                                                           @"subject" : @"口腔",
                                                           @"CMT_selected" : @"0",
                                                           } error:nil],
                  
                  ];
    }
    
    return _data;
}

- (NSMutableDictionary *)subscriptions {
    if (_subscriptions == nil) {
        _subscriptions = [NSMutableDictionary dictionary];
    }
    
    return _subscriptions;
}

#pragma mark LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    CMTLog(@"%s", __FUNCTION__);
    @weakify(self);
    [self.rac_willDeallocSignal subscribeCompleted:^{
        CMTLog(@"SubscriptionGuideView willDeallocSignal");
    }];
    
    self.view.backgroundColor = COLOR(c_clear);
    self.titleText = @"选择订阅的学科";
    
    [self.view addSubview:self.tableView];
    [self.tableView reloadData];
    
    [self.view addSubview:self.confirmView];
    self.confirmButton.enabled = NO;
    self.confirmButton.backgroundColor = COLOR(c_dfdfdf);
    self.confirmButton.layer.borderColor = COLOR(c_9e9e9e).CGColor;
    
    // 点击确定
    [[self.confirmButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        
        if (!NET_WIFI && !NET_CELL && ![AFNetworkReachabilityManager sharedManager].isReachable) {
            [self toastAnimation:@"你的网络不给力，不允许添加订阅"];
            return;
        }
        
        NSMutableArray *subscriptions = [[self.subscriptions allValues] mutableCopy];
        CMTLog(@"强制订阅: %@", subscriptions);
        
        // 存储
        if (![NSKeyedArchiver archiveRootObject:subscriptions toFile:[PATH_USERS stringByAppendingPathComponent:@"subscription"]]) {
            CMTLogError(@"Archive force subscriptions:%@\nto Store Error: %@", subscriptions, [PATH_USERS stringByAppendingPathComponent:@"subscription"]);
        }
        
        // 更新用户订阅信息
        CMTUSERINFO.follows = subscriptions;
        [CMTUSER save];
        
        // 刷新首页列表
        id navi = APPDELEGATE.centerNavigationController;
        if ([navi respondsToSelector:@selector(viewControllers)]) {
            CMTCenterViewController *centerViewController = [[navi viewControllers] firstObject];
            if ([centerViewController respondsToSelector:@selector(refreshPostListFromLaunch)]) {
                [centerViewController refreshPostListFromLaunch];
            }
        }
        
        // 同步服务器
        NSMutableArray *pTempArr = [NSMutableArray array];
        for (CMTConcern *concer in subscriptions) {
            NSMutableDictionary *pDic = [NSMutableDictionary dictionary];
            [pDic setObject:concer.subjectId forKey:@"subjectId"];
            [pDic setObject:concer.opTime forKey:@"opTime"];
            [pTempArr addObject:pDic];
        }
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:pTempArr options:NSJSONWritingPrettyPrinted error:nil];
        NSString *pStr = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        CMTLog(@"hhdhdhdhdhddhdhh%@",pStr);
        [self.rac_deallocDisposable addDisposable:
         [[CMTCLIENT syncConcern:@{
                                   @"userId": @"0",
                                   @"items": pStr
                                   }]
          subscribeNext:^(NSArray * array) {
              CMTLog(@"SubscriptionGuideView Sync Concerns Success: %@", array);
          } error:^(NSError *error) {
              CMTLogError(@"SubscriptionGuideView Sync Concerns Error: %@", error);
          }]];
        
        // 切换动画
        [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.view.alpha = 0.0;
        } completion:^(BOOL finished) {
            [APPDELEGATE.window makeKeyAndVisible];
            APPDELEGATE.subscriptionGuideWindow = nil;
        }];
        
        // 记录强制订阅版本
        CMTAPPCONFIG.subscriptionRecordedVersion = APP_VERSION;
        CMTAPPCONFIG.isAllowPlaymusic=@"1";
    }];
    
}

#pragma mark TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.data.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CMTSubscriptionGuideCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CMTSubscriptionGuideCellIdentifier forIndexPath:indexPath];
    
    [cell reloadSubscription:self.data[indexPath.row] tableView:tableView indexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // 添加时间
    CMTConcern *concern = self.data[indexPath.row];
    concern.opTime = TIMESTAMP;
    
    // 选中标记
    if ([concern.CMT_selected boolValue] == YES) {
        concern.CMT_selected = @"0";
        [self.subscriptions removeObjectForKey:concern.subjectId];
    }
    else {
        concern.CMT_selected = @"1";
        [self.subscriptions setObject:concern forKey:concern.subjectId];
    }
    
    // 选中纪录
    if (self.subscriptions.count == 0) {
        self.confirmButton.enabled = NO;
        self.confirmButton.backgroundColor = COLOR(c_dfdfdf);
        self.confirmButton.layer.borderColor = COLOR(c_9e9e9e).CGColor;
    }
    else {
        self.confirmButton.enabled = YES;
        self.confirmButton.backgroundColor = COLOR(c_32c7c2);
        self.confirmButton.layer.borderColor = COLOR(c_32c7c2).CGColor;
    }
    
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

@end
