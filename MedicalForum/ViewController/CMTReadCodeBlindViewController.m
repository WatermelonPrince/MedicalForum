//
//  CMTReadCodeBlindViewController.m
//  MedicalForum
//
//  Created by zhaohuan on 15/12/24.
//  Copyright © 2015年 CMT. All rights reserved.
//

#import "CMTReadCodeBlindViewController.h"
#import "CMTWebBrowserViewController.h"
#import "CMTWithoutPermissionViewController.h"

@interface CMTReadCodeBlindViewController ()<UITextFieldDelegate,UIActionSheetDelegate>
@property (nonatomic, strong) UIScrollView *backgroundScrollView; //底部滑动视图；
@property (nonatomic, strong)UITextField *BlindTextFiled;
@property (nonatomic, strong)UIButton *BlindButton;
@property (nonatomic, strong)UIImageView *WeiXinImageView;
@property (nonatomic, strong)UILabel *FirstLineLabel;//第一行Label;
@property (nonatomic, strong)UILabel *SecondLineLabel;//第二行Label;
@property (nonatomic, strong)NSMutableArray *labelTextArr;

@end

@implementation CMTReadCodeBlindViewController
- (NSMutableArray *)labelTextArr{
    if (!_labelTextArr) {
        _labelTextArr = [NSMutableArray array];
        
    }
    return _labelTextArr;
}

-(UIImageView*)WeiXinImageView{
    if (_WeiXinImageView==nil) {
        _WeiXinImageView=[[UIImageView alloc]initWithFrame:CGRectMake((SCREEN_WIDTH - 130)/2,self.BlindTextFiled.bottom + 90 , 130, 130)];
        [_WeiXinImageView setImageURL:CMTAPPCONFIG.readCodeObject.readcode.imgUrl placeholderImage:IMAGE(@"Placeholderdefault")contentSize:CGSizeMake(130, 130)];
        _WeiXinImageView.clipsToBounds=YES;
        _WeiXinImageView.contentMode=UIViewContentModeScaleAspectFill;
        _WeiXinImageView.userInteractionEnabled=YES;
        UITapGestureRecognizer *longtap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(longtap:)];
        [_WeiXinImageView addGestureRecognizer:longtap];
        _WeiXinImageView.backgroundColor = [UIColor cyanColor];
    }
    return _WeiXinImageView;
}

- (UILabel *)FirstLineLabel{
    if (_FirstLineLabel==nil) {
        _FirstLineLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, self.WeiXinImageView.bottom + 22, SCREEN_WIDTH, 30)];
        _FirstLineLabel.numberOfLines = 1;
        _FirstLineLabel.font = FONT(14);
        _FirstLineLabel.textColor = [UIColor blackColor];
        _FirstLineLabel.textAlignment = NSTextAlignmentCenter;
        _FirstLineLabel.text =self.labelTextArr.count>0?self.labelTextArr[0]:@"";
    }
    return _FirstLineLabel;
}
- (UILabel *)SecondLineLabel{
    if (_SecondLineLabel==nil) {
        _SecondLineLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, self.FirstLineLabel.bottom, SCREEN_WIDTH, 30)];
        _SecondLineLabel.numberOfLines = 1;
        _SecondLineLabel.font = FONT(14);
        _SecondLineLabel.textColor = [UIColor blackColor];
        _SecondLineLabel.textAlignment = NSTextAlignmentCenter;
        _SecondLineLabel.text =self.labelTextArr.count>1?self.labelTextArr[1]:@" ";


    }
    return _SecondLineLabel;
}


- (UIScrollView *)backgroundScrollView{
    if (_backgroundScrollView == nil) {
        _backgroundScrollView = [[UIScrollView alloc]init];
        _backgroundScrollView.frame = CGRectMake(0,0, SCREEN_WIDTH, SCREEN_HEIGHT);
        _backgroundScrollView.contentSize = CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT);
        _backgroundScrollView.backgroundColor = [UIColor colorWithHexString:@"#f2f2f2"];
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(backKB)];
        singleTap.numberOfTapsRequired = 1;
        [_backgroundScrollView addGestureRecognizer:singleTap];
    }
    return _backgroundScrollView;
}

- (UIButton *)BlindButton{
    if (!_BlindButton)
    {
        _BlindButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_BlindButton setFrame:CGRectMake(self.BlindTextFiled.frame.size.width-1*RATIO, 83, SCREEN_WIDTH-self.BlindTextFiled.frame.size.width, self.BlindTextFiled.frame.size.height)];
        //[_BlindButton setUserInteractionEnabled:NO];
        _BlindButton.backgroundColor = [UIColor colorWithRed:212.0/255 green:212.0/255 blue:212.0/255 alpha:1.0];
        [_BlindButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_BlindButton setTitle:@"绑定" forState:UIControlStateNormal];
        
        [_BlindButton addTarget:self action:@selector(blindReadCode:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _BlindButton;


}
- (UITextField *)BlindTextFiled{
    if (!_BlindTextFiled)
    {
        _BlindTextFiled = [[UITextField alloc]initWithFrame:CGRectMake(-1*RATIO, 83, 246*RATIO, 45)];
        _BlindTextFiled.placeholder = @"请输入16位阅读码";
        _BlindTextFiled.backgroundColor = [UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1.0];
        _BlindTextFiled.clearsOnBeginEditing = NO;
        _BlindTextFiled.clearButtonMode = UITextFieldViewModeWhileEditing;
        _BlindTextFiled.borderStyle = UITextBorderStyleNone;
        _BlindTextFiled.delegate = self;
        UIView *pView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 15*RATIO, 45)];
        _BlindTextFiled.leftView = pView;
        _BlindTextFiled.leftViewMode = UITextFieldViewModeAlways;
        _BlindTextFiled.keyboardType = UIKeyboardTypeNumberPad;
        
    }
    
    return _BlindTextFiled;
}

-(void)longtap:(UITapGestureRecognizer*)PressGesture{
    //判断是否有权限
    ALAuthorizationStatus authStatus =[ALAssetsLibrary authorizationStatus];
    if(authStatus == ALAuthorizationStatusRestricted || authStatus == ALAuthorizationStatusDenied){
        
        NSLog(@"相册权限受限");
        CMTWithoutPermissionViewController *per= [[CMTWithoutPermissionViewController alloc]initWithType:@"1"];
        UINavigationController *nav=[[UINavigationController alloc]initWithRootViewController:per];
        [self presentViewController:nav animated:YES completion:nil];
        return;
    }
    
    if([[[UIDevice currentDevice] systemVersion] floatValue] <8.0){
        UIActionSheet *Sheet=[[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"保存到相册" otherButtonTitles:nil, nil];
        [Sheet showInView:self.contentBaseView];
    }else{
        UIAlertController *alert=[UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *saveAction=[UIAlertAction  actionWithTitle:@"保存到相册" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            @weakify(self);
            ALAssetsLibrary *library = [[ALAssetsLibrary alloc]init];
            [library writeImageToSavedPhotosAlbum:self.WeiXinImageView.image.CGImage orientation:(ALAssetOrientation)self.WeiXinImageView.image.imageOrientation completionBlock:^(NSURL *asSetUrl,NSError *error){
                @strongify(self);
                if (error) {
                    //失败
                    [self toastAnimation:error.userInfo[NSLocalizedFailureReasonErrorKey]];
                }else{
                    [self toastAnimation:@"保存成功"];
                }
            }];
            [alert dismissViewControllerAnimated:YES completion:^{
                
            }];
            
        }];
        
        UIAlertAction *cancelAction=[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [alert dismissViewControllerAnimated:YES completion:^{
                
            }];
            
        }];
        [alert addAction:saveAction];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex==0){
        @weakify(self);
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc]init];
        [library writeImageToSavedPhotosAlbum:self.WeiXinImageView.image.CGImage orientation:(ALAssetOrientation)self.WeiXinImageView.image.imageOrientation completionBlock:^(NSURL *asSetUrl,NSError *error){
            @strongify(self);
            if (error) {
                [self toastAnimation:error.userInfo[NSLocalizedFailureReasonErrorKey]];
            }else{
                [self toastAnimation:@"保存成功"];
            }
        }];
    }
    
}


//跳转到购买页面
- (void)jumpToOrderViewController{
    CMTWebBrowserViewController *orderWeb = [[CMTWebBrowserViewController alloc]init];
    orderWeb.lastViewController = self;
    [self.navigationController pushViewController:orderWeb animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"++++%@",CMTAPPCONFIG.readCodeObject.readcode.des);
    self.labelTextArr = [[CMTAPPCONFIG.readCodeObject.readcode.des componentsSeparatedByString:@"\\n"] mutableCopy];
    self.titleText = @"绑定阅读码";
    // Do any additional setup after loading the view.
    [self.rac_willDeallocSignal subscribeCompleted:^{
        CMTLog(@"PostList willDeallocSignal___CMTCreatGroupViewController.h");
    }];
    [self.view addSubview:self.backgroundScrollView];
    [self.backgroundScrollView addSubview:self.BlindTextFiled];
    [self.backgroundScrollView addSubview:self.BlindButton];
    [self.backgroundScrollView addSubview:self.WeiXinImageView];
    [self.backgroundScrollView addSubview:self.FirstLineLabel];
    [self.backgroundScrollView addSubview:self.SecondLineLabel];
    // 监听键盘
     @weakify(self);
    [[[self.BlindTextFiled rac_textSignal]deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x){
         @strongify(self);
        self.BlindButton.enabled = [self.BlindTextFiled.text length] >= 16;
        if ([self.BlindTextFiled.text length] >16) {
            [self toastAnimation:@"请输入16位阅读码"];
            self.BlindTextFiled.text = [self.BlindTextFiled.text substringToIndex:16];
        }
        if (self.BlindButton.enabled) {
            self.BlindButton.backgroundColor = [UIColor colorWithHexString:@"#38bdb4"];
        }else{
            self.BlindButton.backgroundColor = [UIColor colorWithHexString:@"#d4d4d4"];
        }
    }];
    
}
//绑定事件

- (void)blindReadCode:(UIButton *)sender{
    NSDictionary *params = @{
                             @"userId":CMTUSERINFO.userId?:@"",
                             @"rcode":self.BlindTextFiled.text,
                             };
     @weakify(self);
    [[[CMTCLIENT readCodeBlind:params] deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(CMTBlindReadCodeResult *blindResult) {
        @strongify(self);
        if (blindResult.rcodeState.integerValue == 0) {
            CMTUSERINFO.canRead = @"1";
            CMTUSERINFO.decryptKey = blindResult.decryptKey;
            [self.navigationController popViewControllerAnimated:YES];
        }else if (blindResult.rcodeState.integerValue == 1){
            [self toastAnimation:@"阅读码有误"];
        }else if (blindResult.rcodeState.integerValue == 2){
            [self toastAnimation:@"阅读码已过期"];
        }else if (blindResult.rcodeState.integerValue == 3){
            [self toastAnimation:@"阅读码已使用"];
        }
            
        
        
        
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



//点击空白回收键盘
- (void)backKB{
    [self.view endEditing:YES];
}
//textfild代理
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
