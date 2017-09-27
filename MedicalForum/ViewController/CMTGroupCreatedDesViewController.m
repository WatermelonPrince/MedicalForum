//
//  CMTGroupCreatedDesViewController.m
//  MedicalForum
//
//  Created by zhaohuan on 16/3/16.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import "CMTGroupCreatedDesViewController.h"
#import "UITextView+Placeholder.h"
#import "CMTGroupCreatedMakeSureViewController.h"


@interface CMTGroupCreatedDesViewController ()<UITextViewDelegate>
@property (nonatomic, strong)UITextView *groupDesTextView;
@property (nonatomic, strong)UIView *textViewLine;
@property (nonatomic, copy)NSString *groupLogo;//小组logo路径
@property (nonatomic, copy)NSString *groupType;//小组类型
@property (nonatomic, copy)NSString *groupDes;//小组简介
@property (nonatomic, copy)NSString *groupName;//小组名字
@property (nonatomic, strong)UILabel *textCountLabel;//文字个数
@property (nonatomic, strong)UIBarButtonItem *rightItem;//继续Item
@property(nonatomic,strong)NSString *from;//从哪里来
@property (nonatomic, strong)UIButton *continueButton;//继续按钮
@property (nonatomic, strong)CMTGroupTypeChoiceTableViewController *groupTypeVC;
@property (nonatomic, assign)BOOL continueTextNeed; //当描述字数大于0  为YES


@end

@implementation CMTGroupCreatedDesViewController

- (instancetype)initWithGroupLogoFile:(NSString *)groupLogoFile
                            groupType:(NSString *)groupType
                    groupTypeChoiceVC:(CMTGroupTypeChoiceTableViewController *)groupTypeVC
                            groupName:(NSString *)groupName{
    self = [super init];
    if (self) {
        self.groupLogo = groupLogoFile;
        self.groupType = groupType;
        self.groupTypeVC = groupTypeVC;
        self.groupName = groupName;
    }
    return self;
}
- (instancetype)initWithtext:(NSString*)text from:(NSString*)from{
    self = [super init];
    if (self) {
        self.groupDes=text;
        self.from=from;
    }
    return self;
}

- (UILabel *)textCountLabel{
    if (_textCountLabel == nil) {
        _textCountLabel = [[UILabel alloc]init];
        _textCountLabel.frame = CGRectMake(self.textViewLine.right - 40, self.textViewLine.bottom + 5, 40, 20);
        _textCountLabel.text = @"0/40";
        _textCountLabel.font = FONT(13);
        _textCountLabel.textAlignment = NSTextAlignmentRight;
        _textCountLabel.textColor = ColorWithHexStringIndex(c_dcdcdc);

    }
    return _textCountLabel;
}

- (UITextView *)groupDesTextView {
    if (_groupDesTextView == nil) {
        _groupDesTextView = [[UITextView alloc] init];
        _groupDesTextView.frame = CGRectMake(20, 84, SCREEN_WIDTH - 40, 34);
        _groupDesTextView.backgroundColor = COLOR(c_clear);
        _groupDesTextView.textColor = COLOR(c_151515);
        _groupDesTextView.showsHorizontalScrollIndicator = NO;
        _groupDesTextView.showsVerticalScrollIndicator = NO;
        _groupDesTextView.font = FONT(15.0);
        _groupDesTextView.layoutManager.allowsNonContiguousLayout = NO;
        _groupDesTextView.delegate = self;
        _groupDesTextView.placeholder=@"小组简介，便于用户快速加入";
        _groupDesTextView.clearsContextBeforeDrawing = YES;
    }
    
    return _groupDesTextView;
}
- (UIView *)textViewLine{
    if (_textViewLine == nil) {
        _textViewLine = [[UIView alloc]init];
        _textViewLine.frame = CGRectMake(self.groupDesTextView.left, self.groupDesTextView.bottom, SCREEN_WIDTH - 40, 1);
        _textViewLine.backgroundColor = ColorWithHexStringIndex(c_dcdcdc);
    }
    return _textViewLine;
}

//- (UIBarButtonItem *)rightItem{
//    if (_rightItem == nil) {
//        _rightItem =  [[UIBarButtonItem alloc]initWithTitle:self.from.length==0? @"继续":@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(makeSureCreatGrop)];
//    }
//    return _rightItem;
//}
- (UIButton *)continueButton{
    if (_continueButton == nil) {
        _continueButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _continueButton.frame = CGRectMake(0, 0, 45, 30);
        [_continueButton setTitle:self.from.length==0? @"继续":@"完成" forState:UIControlStateNormal];
        
        [_continueButton addTarget:self action:@selector(makeSureCreatGrop) forControlEvents:UIControlEventTouchUpInside];
        _continueButton.enabled = NO;
    }
    return _continueButton;
}
- (UIBarButtonItem *)rightItem{
    if (_rightItem == nil) {
        
        _rightItem = [[UIBarButtonItem alloc]initWithCustomView:self.continueButton];
    }
    return _rightItem;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.rac_willDeallocSignal subscribeCompleted:^{
        CMTLog(@"___CMTGroupCreatedDesViewController");
    }];
    [self.contentBaseView addSubview:self.groupDesTextView];
    [self.contentBaseView addSubview:self.textViewLine];
    [self.contentBaseView addSubview:self.textCountLabel];
    self.navigationItem.rightBarButtonItem = self.rightItem;
    //读取存储
    self.groupDesTextView.text =self.from.length==0?[NSKeyedUnarchiver unarchiveObjectWithFile:[PATH_USERS stringByAppendingPathComponent:@"groupCreatedDes"]]:self.groupDes;
    //监听textView数字变化
    @weakify(self);
    [[self.groupDesTextView.rac_textSignal deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(id x) {
        @strongify(self);
//        self.groupDesTextView.text = [self.groupDesTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        CGFloat height = self.groupDesTextView.contentSize.height;
        self.groupDesTextView.size = CGSizeMake(SCREEN_WIDTH - 40, height);
        self.textViewLine.frame = CGRectMake(self.groupDesTextView.left, self.groupDesTextView.bottom, SCREEN_WIDTH - 40, 1);
        self.textCountLabel.frame = CGRectMake(self.groupDesTextView.right - 40, self.groupDesTextView.bottom,40 , 20);
        if (self.groupDesTextView.text.length > 40) {
            self.groupDesTextView.text = [self.groupDesTextView.text substringToIndex:40];
            [self toastAnimation:@"小组简介只能在40字以内"];
            
        }
        if (self.groupDesTextView.text.length > 0) {
            self.continueTextNeed = YES;
        }else{
            self.continueTextNeed = NO;
        }
        self.textCountLabel.text = [NSString stringWithFormat:@"%lu/40",self.groupDesTextView.text.length];
    }];
    //根据输入框是否为空关联按钮是否高亮，是否可点击
    RAC(self.continueButton,enabled) = [[RACSignal combineLatest:@[RACObserve(self, continueTextNeed)
                                                                   ]reduce:^(NSNumber *a){
                                                                       BOOL lighted = a.integerValue;
                                                                       return @(lighted);
                                                                       
                                                                   }] deliverOn:[RACScheduler mainThreadScheduler]];
    //监测按钮是否可点击
    [[RACObserve(self.continueButton,enabled) deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSNumber *x) {
        @strongify(self);
        if (x.integerValue == 0) {
            [self.continueButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        }else{
            [self.continueButton setTitleColor:ColorWithHexStringIndex(c_1eba9c) forState:UIControlStateNormal];
            
        }
    }];
    self.titleText = @"设置小组简介";
    
    // Do any additional setup after loading the view.
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(backKeyboard)];
    singleTap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:singleTap];
}

- (void)makeSureCreatGrop{
    if(self.from.length>0){
        if (self.updateGroupDes!=nil) {
            self.updateGroupDes(self.groupDesTextView.text);
        }
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [MobClick event:@"B_lunBa_Confirm"];
        CMTGroupCreatedMakeSureViewController *groupCreatedMakeSureVC = [[CMTGroupCreatedMakeSureViewController alloc]initWithGroupLogoFile:self.groupLogo groupType:self.groupType groupTypeChoiceVC:self.groupTypeVC groupCreatedDes:self.groupDesTextView.text groupName:self.groupName];
        [self.navigationController pushViewController:groupCreatedMakeSureVC animated:YES];
    }
}

#pragma 回收键盘
- (void)backKeyboard{
    [self.view endEditing:NO];
}

#pragma TextView代理
- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    if (self.from.length==0) {
         [NSKeyedArchiver archiveRootObject:self.groupDesTextView.text toFile:[PATH_USERS stringByAppendingPathComponent:@"groupCreatedDes"]];
    }
   
    return YES;
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
