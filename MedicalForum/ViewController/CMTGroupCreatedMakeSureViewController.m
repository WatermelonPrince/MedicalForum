//
//  CMTGroupCreatedMakeSureViewController.m
//  MedicalForum
//
//  Created by zhaohuan on 16/3/17.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import "CMTGroupCreatedMakeSureViewController.h"
#import "CMTGroupInfoViewController.h"
#import "CMTCaseCircleViewController.h"

@interface CMTGroupCreatedMakeSureViewController ()
@property (nonatomic, copy)NSString *groupLogoFile;
@property (nonatomic, copy)NSString *groupType;
@property (nonatomic, strong)CMTGroupTypeChoiceTableViewController *groupTypeVC;
@property (nonatomic, copy)NSString *groupCreatedDes;
@property (nonatomic, copy)NSString *groupName;//小组名字
@property (nonatomic, copy)UIImageView *imageView;//小组图片
@property (nonatomic, strong)UILabel *groupNameLabel;//小组名字
@property (nonatomic, strong)UILabel *groupDesLabel;//小组简介
@property (nonatomic, strong)UILabel *groupTypeLabel;//小组类型;
@property (nonatomic, strong)UILabel *groupTypeDesLabel;// 小组简介label;
@property (nonatomic, strong)UIButton *changeButton;//改变小组类型button;
@property (nonatomic, strong)UIButton *ensureButton;//确认按钮;
@property (nonatomic, strong)UIButton *cancleButton;//取消按钮;
@property (nonatomic, strong)UIView *groupTypeView;//小组类型背景图;
@property (nonatomic, strong)UIScrollView *backScrollView;//背景滑动视图
@property (nonatomic, strong)CMTGroup *toGroup;//创建小组成功后的跳转

@end

@implementation CMTGroupCreatedMakeSureViewController

- (instancetype)initWithGroupLogoFile:(NSString *)groupLogoFile
                            groupType:(NSString *)groupType
                    groupTypeChoiceVC:(CMTGroupTypeChoiceTableViewController *)groupTypeVC
                      groupCreatedDes:(NSString *)groupCreatedDes
                            groupName:(NSString *)groupName{
    self = [super init];
    if (self) {
        self.groupLogoFile = groupLogoFile;
        self.groupType = groupType;
        self.groupTypeVC = groupTypeVC;
        self.groupCreatedDes = groupCreatedDes;
        self.groupName = groupName;
    }
    return self;
}

- (UIScrollView *)backScrollView{
    if (_backScrollView == nil) {
        _backScrollView = [[UIScrollView alloc]init];
        _backScrollView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        _backScrollView.contentSize = CGSizeMake(SCREEN_WIDTH, 700);
    }
    return _backScrollView;
}

- (UILabel *)groupNameLabel{
    if (_groupNameLabel == nil) {
        _groupNameLabel = [[UILabel alloc]init];
        _groupNameLabel.font = FONT(19);
        _groupNameLabel.frame = CGRectMake(SCREEN_WIDTH/2 - 50, self.imageView.bottom + 10, 100, 30);
        _groupNameLabel.textAlignment = NSTextAlignmentCenter;
//        _groupNameLabel.backgroundColor = [UIColor redColor];
    }
    return _groupNameLabel;
}

- (UILabel *)groupDesLabel{
    if (_groupDesLabel == nil){
        _groupDesLabel = [[UILabel alloc]init];
        _groupDesLabel.font = FONT(15);
        _groupDesLabel.frame = CGRectMake(20, self.groupNameLabel.bottom, SCREEN_WIDTH - 40, 65);
        _groupDesLabel.textAlignment = NSTextAlignmentCenter;
        _groupDesLabel.textColor = ColorWithHexStringIndex(c_ababab);
        _groupDesLabel.numberOfLines = 0;
     // _groupDesLabel.backgroundColor = [UIColor blueColor];
    }
    return _groupDesLabel;
}


- (UIView *)groupTypeView{
    if (_groupTypeView == nil) {
        _groupTypeView = [[UIView alloc]initWithFrame:CGRectMake(10, self.groupDesLabel.bottom, SCREEN_WIDTH - 20, 120)];
    }
    //_groupTypeView.backgroundColor = [UIColor cyanColor];
    return _groupTypeView;
}

- (UILabel *)groupTypeLabel{
    if (_groupTypeLabel == nil) {
        _groupTypeLabel = [[UILabel alloc]init];
        _groupTypeLabel.frame = CGRectMake(20, 10, 70, 30);
        _groupTypeLabel.font = FONT(17);
        //_groupTypeLabel.backgroundColor = [UIColor redColor];
    }
    return _groupTypeLabel;
}

- (UILabel *)groupTypeDesLabel{
    if (_groupTypeDesLabel == nil) {
        _groupTypeDesLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 40, SCREEN_WIDTH - 60, 50)];
        _groupTypeDesLabel.font = [UIFont boldSystemFontOfSize:15];
        _groupTypeDesLabel.numberOfLines = 0;
        _groupTypeDesLabel.textColor = ColorWithHexStringIndex(c_dcdcdc);
        //_groupTypeDes.backgroundColor = [UIColor blueColor];
    }
    return _groupTypeDesLabel;
}


- (UIButton *)changeButton{
    if (_changeButton == nil) {
        _changeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _changeButton.frame = CGRectMake(self.groupTypeView.right - 70, self.groupTypeLabel.bottom - 30, 40, 30);
        _changeButton.titleLabel.font = FONT(16);
        [_changeButton setTitle:@"修改" forState:UIControlStateNormal];
        [_changeButton setTitleColor:[UIColor colorWithHexString:@"4d99c7"] forState:UIControlStateNormal];
        [_changeButton addTarget:self action:@selector(pushToChange) forControlEvents:UIControlEventTouchUpInside];
    }
    return _changeButton;
}
- (UIButton *)ensureButton{
    if (_ensureButton == nil) {
        _ensureButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        _ensureButton.frame = CGRectMake(20, self.groupTypeView.bottom + 20, SCREEN_WIDTH - 40, 55);
        _ensureButton.layer.cornerRadius = 8;
        _ensureButton.layer.masksToBounds = YES;
        _ensureButton.titleLabel.font = FONT(19);
        _ensureButton.backgroundColor = [UIColor colorWithHexString:@"1eba9c"];
        [_ensureButton setTitle:@"确认创建" forState:UIControlStateNormal];
        [_ensureButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_ensureButton addTarget:self action:@selector(makeSureCreatToServer) forControlEvents:UIControlEventTouchUpInside];
    }
    return _ensureButton;
}

- (UIButton *)cancleButton{
    if (_cancleButton == nil) {
        _cancleButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        _cancleButton.frame = CGRectMake(20, self.ensureButton.bottom + 5, SCREEN_WIDTH - 40, 55);
        _cancleButton.titleLabel.font = FONT(19);
        _cancleButton.layer.cornerRadius = 8;
        _cancleButton.layer.masksToBounds = YES;
        _cancleButton.backgroundColor = ColorWithHexStringIndex(c_ffffff);
        [_cancleButton setTitle:@"取消" forState:UIControlStateNormal];
        [_cancleButton setTitleColor:ColorWithHexStringIndex(c_dcdcdc) forState:UIControlStateNormal];
        [_cancleButton addTarget:self action:@selector(cancleToRootVC) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancleButton;
}

- (UIImageView *)imageView{
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 70, 84, 140, 140)];
        _imageView.clipsToBounds = YES;
        _imageView.contentMode=UIViewContentModeScaleAspectFill;
        _imageView.image = IMAGE(@"groupLogo");
    }
    return _imageView;
}

#pragma 修改按钮方法
- (void)pushToChange{
    CMTGroupTypeChoiceTableViewController *tabVC = [[CMTGroupTypeChoiceTableViewController alloc]init];
    tabVC.lastVC = self;
    @weakify(self);
    tabVC.RetureGroupType=^(NSString * groupType){
        @strongify(self);
        self.groupType = groupType;
        [self configureGroupTypeView];
    };
    [self.navigationController pushViewController:tabVC animated:YES];
}

#pragma 确认按钮方法
- (void)makeSureCreatToServer{
    [self setContentState:CMTContentStateLoading];
    UIImage *image = [UIImage imageWithContentsOfFile:self.groupLogoFile];
    NSDictionary *params = @{
                             @"userId":CMTUSER.userInfo.userId? : @"",
                             @"groupType":self.groupType,
                             @"groupName":self.groupName,
                             @"groupDesc":self.groupCreatedDes,
                             @"groupLogo":image,
                             
                             };
    @weakify(self);
    [[[CMTCLIENT modifyCreatGroup:params]deliverOn:[RACScheduler mainThreadScheduler] ] subscribeNext:^(CMTGroup * group) {
        @strongify(self);
        [self setContentState:CMTContentStateNormal];
        if (group) {
            if (group.auditStatus.integerValue == 0) {
                
            }else{
                if (group.groupId) {
                    NSError *error = nil;
                    [[NSFileManager defaultManager] removeItemAtPath:PATH_CACHE_GROUPTYPECHOICE error:&error];
                    [[NSFileManager defaultManager] removeItemAtPath:[PATH_USERS stringByAppendingPathComponent:@"createGroup"] error:&error];
                    [[NSFileManager defaultManager] removeItemAtPath:[PATH_USERS stringByAppendingPathComponent:@"groupCreatedName"] error:&error];
                    [[NSFileManager defaultManager] removeItemAtPath:[PATH_USERS stringByAppendingPathComponent:@"groupCreatedDes"] error:&error];
                    
                    
                    [self toastAnimation:@"创建小组成功"];
                    self.toGroup = group;
                    @weakify(self);
                    [[RACScheduler mainThreadScheduler]afterDelay:0.5 schedule:^{
                        @strongify(self);
                        [MobClick event:@"B_lunBa_BrowseGroup"];
                        CMTGroupInfoViewController *groupInfoVC = [[CMTGroupInfoViewController alloc]initWithGroup:self.toGroup];
                        groupInfoVC.fromController =FromUpgrade;
                        [self.navigationController pushViewController:groupInfoVC animated:YES];

                    }];
                    
                }
            }
        }
        
        
    } error:^(NSError *error) {
        @strongify(self);
        CMTLog(@"error");
        DEALLOC_HANDLE_SUCCESS
        [self setContentState:CMTContentStateNormal];
        
        NSString *errorCode = error.userInfo[CMTClientServerErrorCodeKey];
        if ([errorCode integerValue] > 100) {
            NSString *errMes = error.userInfo[CMTClientServerErrorUserInfoMessageKey];
            CMTLog(@"errMes = %@",errMes);
            [self toastAnimation:errMes];
        } else {
            CMTLogError(@"modifypicture System Error: %@", error);
        }
        
    }];
}

#pragma 取消按钮方法
- (void)cancleToRootVC{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.rac_willDeallocSignal subscribeCompleted:^{
        CMTLog(@"___CMTGroupCreatedMakeSureViewController");
    }];
    self.titleText = @"确认信息";
    self.groupNameLabel.text = self.groupName;
    self.groupDesLabel.text = self.groupCreatedDes;
    self.imageView.image = [UIImage imageWithContentsOfFile:self.groupLogoFile];
    NSLog(@"+++++%@",CMTUSER.userInfo.userId);
    self.navigationItem.leftBarButtonItems = self.customleftItems;
    [self.contentBaseView addSubview:self.backScrollView];
    [self.backScrollView addSubview:self.imageView];
    [self.backScrollView addSubview:self.groupNameLabel];
    [self.backScrollView addSubview:self.groupDesLabel];
    [self.backScrollView addSubview:self.groupTypeView];
    [self.backScrollView addSubview:self.ensureButton];
    [self.backScrollView addSubview:self.cancleButton];
    [self.groupTypeView addSubview:self.groupTypeLabel];
    [self.groupTypeView addSubview:self.groupTypeDesLabel];
    [self.groupTypeView addSubview:self.changeButton];
    [self configureGroupTypeView];
    // Do any additional setup after loading the view.
}

- (void)configureGroupTypeView{
    if (self.groupType.integerValue == 0) {
        self.groupTypeLabel.text = @"公开";
        self.groupTypeDesLabel.text = @"任何用户都能看到小组，组内成员及其发布的内容。";
    }else{
        self.groupTypeLabel.text = @"封闭";
        self.groupTypeDesLabel.text = @"任何用户都能找到小组并查看小组成员，但只有组内成员能看到发布的内容。";
    }
}


- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
