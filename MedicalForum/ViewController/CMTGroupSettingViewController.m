//
//  CMTGroupSettingViewController.m
//  MedicalForum
//
//  Created by zhaohuan on 16/3/16.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import "CMTGroupSettingViewController.h"
#import "SDWebImageManager.h"
#import "CMTGroupCreatedDesViewController.h"
#import "CMTGroupTypeChoiceTableViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "CMTWithoutPermissionViewController.h"


@interface CMTGroupSettingViewController ()<UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UITextFieldDelegate>

@property (nonatomic, strong)UIScrollView *scrollView;
@property (nonatomic, strong)UITextField *textField;
@property (nonatomic, strong)UIImageView *imageView;
@property (nonatomic, strong)UIView *bottomView;
@property(nonatomic,strong)NSString *filepath;//小组图片存储路径
@property (nonatomic, strong)CMTGroup *group;
@property (nonatomic, strong)UIBarButtonItem *rightItem;
@property (nonatomic, strong)UIView *lineView;//输入框下面的一条线
@property (nonatomic, strong)UILabel *textCountLabel;//小组名字计数label;
@property (nonatomic, strong)UIView *groupTypeView;//小组类型背景图
@property (nonatomic, strong)UILabel *groupTypeLabel;//小组类型
@property (nonatomic, strong)UILabel *groupTypeDes;//小组类型描述
@property (nonatomic, strong)UIButton *changeButton;//改变小组类型Button;
@property (nonatomic, weak)CMTGroupTypeChoiceTableViewController *groupTypeVC;

@property (nonatomic, strong)UIButton *continueButton;//继续按钮

@property (nonatomic, assign)BOOL textCountNeed;//监听小组名字不为0时为YES
@property (nonatomic, assign)BOOL imageNeed;//监听图片不为默认图片为YES



@end

@implementation CMTGroupSettingViewController

- (instancetype)initWithGroup:(CMTGroup *)group
                 choiceTypeVC:(CMTGroupTypeChoiceTableViewController *)choiceTypeVC{
    self = [super init];
    if (self) {
        self.group = group;
        self.groupTypeVC = choiceTypeVC;
    }
    return self;
}

- (UIView *)bottomView{
    if (_bottomView == nil) {
        self.bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 370)];
        
    }
    return _bottomView;
}
- (UIScrollView *)scrollView{
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, CMTNavigationBarBottomGuide, SCREEN_WIDTH, SCREEN_HEIGHT-CMTNavigationBarBottomGuide)];_scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT * 1.2);
        _scrollView.bounces = NO;
        [self.view addSubview:self.scrollView];
        
    }
    return _scrollView;
}
- (UITextField *)textField{
    if (_textField == nil) {
        _textField = [[UITextField alloc]init];
        _textField.frame = CGRectMake(10, self.imageView.bottom + 30, SCREEN_WIDTH - 20, 42);
        //        [self.textField setBorderStyle:UITextBorderStyleRoundedRect];
        _textField.placeholder = @"  小组名称";
//        _textField.layer.borderColor = [UIColor colorWithRed:221/255.0f green:223/255.0f blue:224/255.0f alpha:1.0].CGColor;
//        _textField.layer.borderWidth =1.0;
//        _textField.layer.cornerRadius =5.0;
        _textField.borderStyle = UITextBorderStyleNone;
        _textField.textAlignment = NSTextAlignmentCenter;
        [_textField setValue:[UIFont boldSystemFontOfSize:16] forKeyPath:@"_placeholderLabel.font"];
        _textField.font=[UIFont boldSystemFontOfSize:19];
        _textField.clearsOnBeginEditing = YES;
        _textField.delegate = self;
        
    }
    return _textField;
}
- (UIView *)lineView{
    if (_lineView == nil) {
        _lineView = [[UIView alloc]init];
        _lineView.backgroundColor = ColorWithHexStringIndex(c_dcdcdc);
        _lineView.frame = CGRectMake(30, self.textField.bottom, SCREEN_WIDTH - 60, 1);
    }
    return _lineView;
}

- (UILabel *)textCountLabel{
    if (_textCountLabel == nil) {
        _textCountLabel = [[UILabel alloc]init];
        _textCountLabel.frame = CGRectMake(self.lineView.right - 40, self.lineView.bottom, 40, 20);
        _textCountLabel.text = @"0/20";
        _textCountLabel.font = FONT(13);
        _textCountLabel.textAlignment = NSTextAlignmentRight;
        _textCountLabel.textColor = ColorWithHexStringIndex(c_dcdcdc);
    }
    return _textCountLabel;
}
- (UIView *)groupTypeView{
    if (_groupTypeView == nil) {
        _groupTypeView = [[UIView alloc]initWithFrame:CGRectMake(10, self.textCountLabel.bottom + 10, SCREEN_WIDTH - 20, 120)];
    }
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

- (UILabel *)groupTypeDes{
    if (_groupTypeDes == nil) {
        _groupTypeDes = [[UILabel alloc]initWithFrame:CGRectMake(20, 40, SCREEN_WIDTH - 60, 50)];
        _groupTypeDes.font = [UIFont boldSystemFontOfSize:16];
        _groupTypeDes.numberOfLines = 0;
        _groupTypeDes.textColor = ColorWithHexStringIndex(c_dcdcdc);
        //_groupTypeDes.backgroundColor = [UIColor blueColor];
    }
    return _groupTypeDes;
}

- (UIButton *)changeButton{
    if (_changeButton == nil) {
        _changeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _changeButton.frame = CGRectMake(self.groupTypeView.right - 70, self.groupTypeLabel.bottom - 30, 40, 30);
        _changeButton.titleLabel.font = FONT(16);
        [_changeButton setTitle:@"修改" forState:UIControlStateNormal];
        [_changeButton setTitleColor:[UIColor colorWithHexString:@"4d99c7"] forState:UIControlStateNormal];
        [_changeButton addTarget:self action:@selector(popViewController1) forControlEvents:UIControlEventTouchUpInside];
    }
    return _changeButton;
}


- (UIImageView *)imageView{
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 70, 30, 140, 140)];
        //_imageView.image = IMAGE(@"groupLogo");
        _imageView.clipsToBounds=YES;
        _imageView.contentMode=UIViewContentModeScaleAspectFill;
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTapAction)];
        singleTap.numberOfTapsRequired = 1;
        _imageView.userInteractionEnabled=YES;
        [_imageView addGestureRecognizer:singleTap];
        
        CAShapeLayer *border = [CAShapeLayer layer];
        border.strokeColor = ColorWithHexStringIndex(c_dcdcdc).CGColor;
        border.fillColor = nil;
        border.path = [UIBezierPath bezierPathWithRect:_imageView.bounds].CGPath;
        border.frame = _imageView.bounds;
        border.lineWidth = 1.f;
        border.lineCap = @"square";
        border.lineDashPattern = @[@4, @2];
        [_imageView.layer addSublayer:border];
       
        
    }
    return _imageView;
}

- (UIButton *)continueButton{
    if (_continueButton == nil) {
        _continueButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _continueButton.frame = CGRectMake(0, 0, 45, 30);
        [_continueButton setTitle:@"继续" forState:UIControlStateNormal];
        
        [_continueButton addTarget:self action:@selector(makeSureCreatGroup) forControlEvents:UIControlEventTouchUpInside];
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


- (void)popViewController1{
    CMTGroupTypeChoiceTableViewController *groupTypeVC = [[CMTGroupTypeChoiceTableViewController alloc]init];
    groupTypeVC.lastVC = self;
    @weakify(self);
    [groupTypeVC setRetureGroupType:^(NSString *groupType) {
        @strongify(self);
        self.group.groupType = groupType;
        [self configureGroupTypeView];
    }];
    [self.navigationController pushViewController:groupTypeVC animated:YES];
}

- (void)configureBottomView{
    UIImageView *centerImageView = [[UIImageView alloc]initWithFrame:CGRectMake(140/2 - 27, 140/2 - 27, 54, 54)];
    centerImageView.image = IMAGE(@"groupLogo");
    centerImageView.center = self.imageView.center;
    [self.bottomView addSubview:centerImageView];

    [self.bottomView addSubview:self.imageView];
    [self.bottomView addSubview:self.textField];
    [self.scrollView addSubview:self.bottomView];
    [self.bottomView addSubview:self.lineView];
    [self.bottomView addSubview:self.textCountLabel];
    [self.bottomView addSubview:self.groupTypeView];
    [self.groupTypeView addSubview:self.groupTypeLabel];
    [self.groupTypeView addSubview:self.groupTypeDes];
    [self.groupTypeView addSubview:self.changeButton];
}

- (void)configureGroupTypeView{
    if (self.group.groupType.integerValue == 0) {
        self.groupTypeLabel.text = @"公开";
        self.groupTypeDes.text = @"任何用户都能看到小组，组内成员及其发布的内容。";
    }else{
        self.groupTypeLabel.text = @"封闭";
        self.groupTypeDes.text = @"任何用户都能找到小组并查看小组成员，但只有组内成员能看到发布的内容。";
    }
}

#pragma 导航栏item事件
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.view endEditing:NO];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    [NSKeyedArchiver archiveRootObject:self.textField.text toFile:[PATH_USERS stringByAppendingPathComponent:@"groupCreatedName"]];
}

- (void)makeSureCreatGroup{
    [self.view endEditing:NO];
    if (self.textField.text.length==0 && [self.imageView.image isEqual:IMAGE(@"groupLogo")]) {
        [self toastAnimation:@"群组名称长度为1-20个字"];
        
    }else if (self.textField.text.length != 0 && [self.imageView.image isEqual:IMAGE(@"groupLogo")]){
        [self toastAnimation:@"小组图片不能为空"];
    }else{
        NSDictionary *params = @{
                                 @"groupName":self.textField.text,
                                 };
        @weakify(self);
        [[[CMTCLIENT groupCheckName:params] deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(CMTGroupCeatedCheckName *groupCheckName) {
            @strongify(self);
            if (groupCheckName.isDuplicated.integerValue) {
                [self toastAnimation:@"小组名称已有创建者使用"];
                return ;
            }
            [MobClick event:@"B_lunBa_Continue2"];
            CMTGroupCreatedDesViewController *createdDesVC = [[CMTGroupCreatedDesViewController alloc]initWithGroupLogoFile:self.filepath groupType:self.group.groupType groupTypeChoiceVC:self.groupTypeVC groupName:self.textField.text];
            [self.navigationController pushViewController:createdDesVC animated:YES];
            
        } error:^(NSError *error) {
            @strongify(self);
            NSString *errorCode = error.userInfo[CMTClientServerErrorCodeKey];
            if ([errorCode integerValue] > 100) {
                CMTLog(@"errMes:%@",error.userInfo[CMTClientServerErrorUserInfoMessageKey]);
                
                [self toastAnimation:error.userInfo[CMTClientServerErrorUserInfoMessageKey]];
                
            } else {
                [self toastAnimation:@"你的网络不给力"];
                CMTLogError(@"Request verification code System Error: %@", error);
            }
            
            


            
        }];
       
    }
    
}


#pragma viewDidLoad方法
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.rac_willDeallocSignal subscribeCompleted:^{
        CMTLog(@"PostList willDeallocSignal_____CMTGroupSettingViewController.h");
    }];
    if ([[NSFileManager defaultManager] fileExistsAtPath:[PATH_USERS stringByAppendingPathComponent:@"createGroup"]]) {
//        NSString *str = [NSKeyedUnarchiver unarchiveObjectWithFile:[PATH_USERS stringByAppendingPathComponent:@"groupCreatedLogo"]];
        self.imageView.image = [UIImage imageWithContentsOfFile:[PATH_USERS stringByAppendingPathComponent:@"createGroup"]];
        self.imageNeed = YES;
        self.filepath = [PATH_USERS stringByAppendingPathComponent:@"createGroup"];
    }
    self.titleText = @"设置小组";
    self.navigationItem.rightBarButtonItem=self.rightItem;
    self.navigationItem.leftBarButtonItems = self.customleftItems;
   
    [self configureGroupTypeView];
    [self configureBottomView];
    //读取存档groupName
    if ([[NSFileManager defaultManager] fileExistsAtPath:[PATH_USERS stringByAppendingPathComponent:@"groupCreatedName"]]) {
        self.textField.text = [NSKeyedUnarchiver unarchiveObjectWithFile:[PATH_USERS stringByAppendingPathComponent:@"groupCreatedName"]];
    }
   
    //textField开启监听
    @weakify(self);
    [[[self.textField rac_textSignal] deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        @strongify(self);
//        self.textField.text = [self.textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if (self.textField.text.length > 20) {
            self.textField.text = [self.textField.text substringToIndex:20];
            [self toastAnimation:@"小组名称只能在20字以内"];
        }
        self.textCountLabel.text = [NSString stringWithFormat:@"%lu/20",self.textField.text.length];
        if (self.textField.text.length > 0) {
            self.textCountNeed = YES;
        }else{
            self.textCountNeed = NO;
        }
    }];
    //监听继续按钮是否可点击
    RAC(self.continueButton,enabled) = [[RACSignal combineLatest:@[RACObserve(self, textCountNeed),
                                RACObserve(self, imageNeed)]reduce:^(NSNumber *a,NSNumber *b){
                                    BOOL lighted = a.integerValue == 1 && b.integerValue == 1;
                                    return @(lighted);
                                    
                                }] deliverOn:[RACScheduler mainThreadScheduler]];
    
    //监听按钮是否可点击
    [[RACObserve(self.continueButton,enabled) deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(NSNumber *x) {
        @strongify(self);
        if (x.integerValue == 0) {
            [self.continueButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        }else{
            [self.continueButton setTitleColor:ColorWithHexStringIndex(c_1eba9c) forState:UIControlStateNormal];

        }
    }];
    // 监听键盘
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kbFrmWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    //点击空白回收键盘手势
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(backKeyboard)];
    singleTap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:singleTap];
    // Do any additional setup after loading the view.
}

#pragma 回收键盘
- (void)backKeyboard{
    [self.view endEditing:NO];
    self.scrollView.contentOffset = CGPointMake(0, 0);
    
}



#pragma 键盘弹出收回触发的方法
-(void)kbFrmWillChange:(NSNotification *)noti{
    NSLog(@"%@",noti.userInfo);
    
    // 获取窗口的高度
    
    
    
    // 键盘结束的Frm
    CGRect kbEndFrm = [noti.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    // 获取键盘结束的y值
    CGFloat kbEndY = kbEndFrm.origin.y;
    if (kbEndY < 360) {
        self.scrollView.contentOffset = CGPointMake(0, 360 - kbEndY);
    }else{
        self.scrollView.contentOffset = CGPointMake(0, 0);
    }
    
    
}

#pragma textfieldDelegate
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    [NSKeyedArchiver archiveRootObject:self.textField.text toFile:[PATH_USERS stringByAppendingPathComponent:@"groupCreatedName"]];
    return YES;
}



#pragma 图像操作
//图像操作
- (void)singleTapAction{
    [self backKeyboard];
    NSArray *postTypeArray=@[@"拍照",@"相册"];
    UIActionSheet *postTypeActionSheet = [[UIActionSheet alloc] init];
    postTypeActionSheet.delegate=self;
    for (NSString *postType in postTypeArray) {
        [postTypeActionSheet addButtonWithTitle:postType];
    }
    [postTypeActionSheet addButtonWithTitle:@"取消"];
    postTypeActionSheet.cancelButtonIndex = postTypeArray.count;
    [postTypeActionSheet showInView:self.view];
}

#pragma actionsheet代理
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 2){//取消
        return;
    }
    if(buttonIndex==0){
        NSString *mediaType = AVMediaTypeVideo;
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
        if(authStatus == ALAuthorizationStatusRestricted || authStatus == ALAuthorizationStatusDenied){
            
            NSLog(@"相机权限受限");
            CMTWithoutPermissionViewController *per= [[CMTWithoutPermissionViewController alloc]init];
            UINavigationController *nav=[[UINavigationController alloc]initWithRootViewController:per];
            [self presentViewController:nav animated:YES completion:nil];
            
            return;
        }
    }
    if (buttonIndex==1) {
        ALAuthorizationStatus authStatus =[ALAssetsLibrary authorizationStatus];
        if(authStatus == ALAuthorizationStatusRestricted || authStatus == ALAuthorizationStatusDenied){
            
            NSLog(@"相册权限受限");
            CMTWithoutPermissionViewController *per= [[CMTWithoutPermissionViewController alloc]initWithType:@"1"];
            UINavigationController *nav=[[UINavigationController alloc]initWithRootViewController:per];
            [self presentViewController:nav animated:YES completion:nil];
            return;
        }

    }
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    // 设置代理
    imagePicker.delegate =self;
    
    // 设置允许编辑
    imagePicker.allowsEditing = YES;
    
    if (buttonIndex == 0) {//照相
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }else{//相册
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    // 显示图片选择器
    [self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark 图片选择器的代理
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    NSLog(@"%@",info);
    BOOL sucess=[UIImagePNGRepresentation([self reduceImage:info[UIImagePickerControllerEditedImage] percent:0.5] ) writeToFile:[PATH_USERS stringByAppendingPathComponent:@"createGroup"]atomically:YES];
    if (sucess) {
        self.filepath =[PATH_USERS stringByAppendingPathComponent:@"createGroup"];
        UIImage *image = [UIImage imageWithContentsOfFile:[PATH_USERS stringByAppendingPathComponent:@"createGroup"]];
        self.imageView.image = image;
        
        // 隐藏当前模态窗口
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }


    if ([self.imageView.image isEqual:IMAGE(@"groupLogo")]) {
        self.imageNeed = NO;
    }else{
        self.imageNeed = YES;
    }
    
    
    // 隐藏当前模态窗口
    [self dismissViewControllerAnimated:YES completion:nil];
    
    
}
//压缩图片
-(UIImage *)reduceImage:(UIImage *)image percent:(float)percent
{
    NSData *imageData = UIImageJPEGRepresentation(image, percent);
    UIImage *newImage = [UIImage imageWithData:imageData];
    return newImage;
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
