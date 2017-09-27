//
//  CMTUpgradeViewController.m
//  MedicalForum
//
//  Created by Bo Shen on 14/12/25.
//  Copyright (c) 2014年 CMT. All rights reserved.
//


#import "CMTUpgradeViewController.h"
#import "CMTNameEditViewController.h"
#import "CMTCommitrPhotoViewController.h"
#import "CMTProvinceViewController.h"
#import "CMTDepartMentViewController.h"
#import "CMTPostDetailCenter.h"
#import "CMTWebBrowserViewController.h"
#import "CMTGroupInfoViewController.h"
#import "SDWebImageManager.h"
#import "CMTWithoutPermissionViewController.h"
#import "CMTLevelViewController.h"
#import <AVFoundation/AVFoundation.h>
@interface CMTUpgradeViewController ()<UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UITextFieldDelegate>
{
    UILabel *pLabel;
    UILabel *pLabel1;
    UILabel *pLabel2;
    UILabel *pLabel3;
    UILabel *pLabel4;
}

@property (strong, nonatomic) CMTNameEditViewController *mNameEditVC;
@property (strong, nonatomic) CMTCommitrPhotoViewController *mCommitVC;
@property (strong, nonatomic) CMTProvinceViewController *mProvVC;
@property (strong, nonatomic) CMTDepartMentViewController *mDepVC;
@property(strong , nonatomic)  CMTGroup*mygroup;

@property (strong, nonatomic) UIImageView *exampleImageView;//示例照片
@property (strong, nonatomic) UIImageView *updateImageView;//上传证件照片按钮

@property (strong, nonatomic) UIView *upDateView;//上传图片cell图；
@property (strong, nonatomic)NSString *licensePicFilepath;//证件照路径

@property (strong, nonatomic)UIButton *saveButton;

@property (assign, nonatomic)BOOL imageNeed;
@property (assign, nonatomic)BOOL docNumNeed;

@property (assign, nonatomic)BOOL changeSuccess;//图片修改成功





@end

@implementation CMTUpgradeViewController
-(instancetype)initWithGroup:(CMTGroup*)group{
    self=[super init];
    if (self) {
        self.mygroup=group;
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    //监听列表cell的数据来控制保存按钮是否置灰
    
    //监听按钮是否可点击
    [[RACObserve(self.saveButton,enabled) deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(NSNumber *x) {
        if (x.integerValue == 0) {
            [self.saveButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        }else{
            [self.saveButton setTitleColor:[UIColor colorWithHexString:@"1eba9c"] forState:UIControlStateNormal];
            
        }
    }];
    [self.view addSubview:self.mTableView];
    self.mArrowsImageView1 = [[UIImageView alloc]initWithImage:IMAGE(@"arrows")];
    self.mArrowsImageView2 = [[UIImageView alloc]initWithImage:IMAGE(@"arrows")];
    
    self.titleText = @"升级为认证用户";
    if (![self.lastVC isEqualToString:@"CaseCircle"]) {
    [self.view addSubview:self.mLbIntroduction];
    }
    [self.view addSubview:self.mImageAuthor];
    self.mImageAuthor.hidden = YES;
    
    self.mPromptView = [[CMTAutPromptView alloc]initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, 36)];
    [self.view addSubview:self.mPromptView];
    
    
    self.mLbAskFor.text = @"以上为本人信息,可申请验证:";

    [self.view addSubview:self.mLbAskFor];
    [self.view addSubview:self.mBtnAskFor];
     self.mLbAskFor.hidden = YES;
    self.mBtnAskFor.hidden = YES;
    
    [self.mPromptView setHidden:YES];
    self.navigationItem.leftBarButtonItems = self.customleftItems;
    CMTUserInfo *info = CMTUSER.userInfo;
    if (CMTUSERINFO.authStatus.intValue == 0 &&CMTUSERINFO.improveStatus.integerValue==0)
    {
                self.mLbRealy.text = @"";
                self.mLbHospital.text = @"";
                self.mLbDepartment.text = @"";
                self.mLbDoctorNum.text = @"";
                self.mLbGrade.text=@"";
                self.mStrGrade=@"";
                self.mStrHospital=@"";
                self.mStrRealy=@"";
                self.mStrDoctorNum=@"";
                self.mStrDepartment=@"";
    }else{
        self.mStrGrade=CMTUSERINFO.level?:@"";
        self.mStrHospital=CMTUSERINFO.hospital?:@"";
        self.mStrRealy=CMTUSERINFO.realName?:@"";
        self.mStrDoctorNum=CMTUSERINFO.doctorNumber?:@"";
        self.mStrDepartment=CMTUSERINFO.subDepartment?:@"";
    }
    int authStatus = CMTUSERINFO.authStatus.intValue;
    if ([info.authStatus isKindOfClass:[NSNull class]])
    {
        authStatus = 0;
    }
    self.navigationItem.rightBarButtonItem = self.mItemSave;
    if (authStatus == 0)
    {
        self.mLbIntroduction.text =info.authDesc?:@"";
        
        self.mItemSave.customView.hidden = NO;
        self.mImageAuthor.hidden = YES;
    }else if (authStatus == 7){
        self.mLbIntroduction.text = info.authDesc?:@"";
            self.mItemSave.customView.hidden = YES;
            self.mImageAuthor.hidden = NO;
    }
   if (self.mLbIntroduction.numberOfLines == 1)
    {
        [self.mImageAuthor setFrame:CGRectMake(8*RATIO, 280, 15, 15)];
    }

   
}
- (void)popViewController
{
    NSArray *pArr = self.navigationController.childViewControllers;
    id obj;
    if (self.nextVC == kDisVC)
    {
        for (int i = 0; i < pArr.count; i++)
        {
            obj = [pArr objectAtIndex:i];
            if ([obj isKindOfClass:[CMTPostDetailCenter class]]||[obj isKindOfClass:[CMTWebBrowserViewController class]])
            {
                [self.navigationController popToViewController:[pArr objectAtIndex:i] animated:YES];
                break;
            }
        }
    }
    else
    {
        if ([self.lastVC isEqualToString:@"CaseCircle"]) {
            [self.navigationController popToRootViewControllerAnimated:YES];
            return;
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}


- (void)viewWillAppear:(BOOL)animated
{
       [super viewWillAppear:animated];
    
       ////⚠️此处天坑，控制器初始化如果写在viewDidload里面 页面消失时会自动释放 导致进入下个页面时 稍微滑动就会整个消失
       [self initViewControllers];
       [self.mTableView reloadData];
    BOOL mustNeed = (self.mLbRealy.text.length || self.mStrRealy.length > 0 )&& (self.mLbHospital.text.length > 0 || self.mStrHospital.length > 0 )&& (self.mLbDepartment.text.length > 0 || self.mStrDepartment.length > 0)&& (self.mLbGrade.text.length > 0||self.mStrGrade.length > 0);
    //判断是否有图片
    NSLog(@"CMTUSERINFO.licensePicFilepath = %@,CMTUSERINFO.licensePic.length=%@,self.licensePicFilepath = %@",CMTUSERINFO.licensePicFilepath,CMTUSERINFO.licensePic,self.licensePicFilepath);
    if (self.licensePicFilepath.length>0||CMTUSERINFO.licensePic.length>0) {
        self.imageNeed = YES;
    }else{
        self.imageNeed = NO;
    }
    BOOL image = self.imageNeed > 0 && mustNeed > 0;
    BOOL docNumber = mustNeed > 0 && (self.mLbDoctorNum.text.length > 0||self.mStrDoctorNum.length>0);
    BOOL allowSave = image > 0 || docNumber > 0;
    if (allowSave) {
        self.saveButton.enabled = YES;
    }else{
        self.saveButton.enabled = NO;
    }
    self.mLbHospital.textColor=[UIColor blackColor];
    self.mLbDepartment.textColor=[UIColor blackColor];
    self.mLbDoctorNum.textColor=[UIColor blackColor];
    self.mLbGrade.textColor=[UIColor blackColor];
    self.mLbRealy.textColor=[UIColor blackColor];
    
}

- (void)initViewControllers
{
    self.mNameEditVC= [[CMTNameEditViewController alloc]init];
    self.mCommitVC = [[CMTCommitrPhotoViewController alloc]init];
    self.mProvVC = [[CMTProvinceViewController alloc]init];
    self.mDepVC = [[CMTDepartMentViewController alloc]init];
}

- (UIImageView *)exampleImageView{
    if (!_exampleImageView) {
        _exampleImageView = [[UIImageView alloc]initWithFrame:CGRectMake((SCREEN_WIDTH - 266)/3*2 + 133,10,  133, 100)];
        _exampleImageView.contentMode=UIViewContentModeScaleAspectFill;
        _exampleImageView.clipsToBounds = YES;
        _exampleImageView.image = IMAGE(@"exampleLicens");
    }
    return _exampleImageView;
}
- (UIImageView *)updateImageView{
    if (_updateImageView == nil) {
        _updateImageView = [[UIImageView alloc]init];
        _updateImageView.frame = CGRectMake((SCREEN_WIDTH - 266)/3, 10, 133, 100);
        _updateImageView.clipsToBounds=YES;
        _updateImageView.contentMode=UIViewContentModeScaleAspectFill;
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(upDatePhoto)];
        singleTap.numberOfTapsRequired = 1;
        _updateImageView.userInteractionEnabled=YES;
        
        if (CMTUSERINFO.authStatus.integerValue == 0 ||[self.lastVC isEqualToString:@"CaseCircle"]) {
            [_updateImageView addGestureRecognizer:singleTap];
        }
        
        
        
        CAShapeLayer *border = [CAShapeLayer layer];
        border.strokeColor = ColorWithHexStringIndex(c_dcdcdc).CGColor;
        border.fillColor = nil;
        border.path = [UIBezierPath bezierPathWithRect:_updateImageView.bounds].CGPath;
        border.frame = _updateImageView.bounds;
        border.lineWidth = 1.f;
        border.lineCap = @"square";
        border.lineDashPattern = @[@4, @2];
        [_updateImageView.layer addSublayer:border];
    }
    
    return _updateImageView;
}

- (UIView *)upDateView{
    if (_upDateView == nil) {
        _upDateView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 120)];
        UILabel *label = [[UILabel alloc]init];
        label.frame = CGRectMake(0, 0, (SCREEN_WIDTH - 30)/2, 20);
        label.center = self.updateImageView.center;
        label.text = @"+上传证件照片";
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = ColorWithHexStringIndex(c_dcdcdc);
        label.font = FONT(15);
        _upDateView.clipsToBounds=YES;
        _upDateView.contentMode=UIViewContentModeScaleAspectFill;
        [_upDateView addSubview:label];
        [_upDateView addSubview:self.updateImageView];
        [_upDateView addSubview:self.exampleImageView];
    }
    return _upDateView;
}

- (UITableView *)mTableView
{
    if (!_mTableView)
    {
        _mTableView = [[UITableView  alloc]initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, 345) style:UITableViewStylePlain];
        _mTableView.delegate = self;
        _mTableView.dataSource = self;
        _mTableView.scrollEnabled = NO;
        _mTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _mTableView;
}

- (UIButton *)saveButton{
    if (_saveButton == nil) {
        _saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _saveButton.frame = CGRectMake(0, 0, 45, 30);
        [_saveButton setTitle:@"提交" forState:UIControlStateNormal];
        [_saveButton addTarget:self action:@ selector(currentSave) forControlEvents:UIControlEventTouchUpInside];
        //_saveButton.enabled = NO;
    }
    return _saveButton;
}


- (UIBarButtonItem *)mItemSave
{
    if (!_mItemSave)
    {
        _mItemSave = [[UIBarButtonItem alloc]initWithCustomView:self.saveButton];
    }
    return _mItemSave;
}
- (UILabel *)mLbIntroduction
{
    if (!_mLbIntroduction)
    {
        _mLbIntroduction = [[UILabel alloc]initWithFrame:CGRectMake(30*RATIO, 415, SCREEN_WIDTH-43*RATIO, 35)];
        _mLbIntroduction.numberOfLines = 0;
        _mLbIntroduction.textColor = [UIColor colorWithRed:172.0/255 green:172.0/255 blue:172.0/255 alpha:1.0];
        _mLbIntroduction.font = [UIFont systemFontOfSize:12];
        
    }
    return _mLbIntroduction;
}

- (UILabel *)mLbAskFor
{
    if (!_mLbAskFor)
    {
        _mLbAskFor = [[UILabel alloc]initWithFrame:CGRectMake(20*RATIO, 280, 162*RATIO, 12)];
        _mLbAskFor.textColor = [UIColor colorWithRed:172.0/255 green:172.0/255 blue:172.0/255 alpha:1.0];
        _mLbAskFor.textAlignment = NSTextAlignmentRight;
        _mLbAskFor.font = [UIFont systemFontOfSize:12];
    }
    return _mLbAskFor;
}

- (UIButton *)mBtnAskFor
{
    if (!_mBtnAskFor)
    {
        _mBtnAskFor = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [_mBtnAskFor setTitle:@"验证信息" forState:UIControlStateNormal];
        [_mBtnAskFor addTarget:self action:@selector(btnInformationCheck:) forControlEvents:UIControlEventTouchUpInside];
        _mBtnAskFor.titleLabel.font = [UIFont boldSystemFontOfSize:13];
        _mBtnAskFor.tintColor = [UIColor colorWithRed:55.0/255 green:81.0/255 blue:151.0/255 alpha:1.0];
        [_mBtnAskFor setFrame:CGRectMake(182*RATIO, 281, 65*RATIO, 12.5)];
    }
    return _mBtnAskFor;
}

- (UIImageView *)mImageAuthor
{
    if (!_mImageAuthor)
    {
        _mImageAuthor = [[UIImageView alloc]initWithImage:IMAGE(@"right")];
        [_mImageAuthor setFrame:CGRectMake(8*RATIO, 425, 15, 15)];
    }
    return _mImageAuthor;
}

/*升级认证需要的成员*/
- (CMTHospital *)mHosptioal
{
    if (!_mHosptioal)
    {
        _mHosptioal = [[CMTHospital alloc]init];
    }
    return _mHosptioal;
}
- (CMTDepart *)mDepart
{
    if (!_mDepart)
    {
        _mDepart = [[CMTDepart alloc]init];
    }
    return _mDepart;
}
- (CMTSubDepart *)mSubDepart
{
    if (!_mSubDepart)
    {
        _mSubDepart = [[CMTSubDepart alloc]init];
    }
    return _mSubDepart;
}



- (void)btnInformationCheck:(id)sender
{
    /*跳转到到个人照片界面*/
    [self.navigationController pushViewController:self.mCommitVC animated:YES];
}

- (UILabel *)mLbRealy
{
    if (!_mLbRealy)
    {
        _mLbRealy = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200*RATIO, 60)];
        _mLbRealy.numberOfLines = 0;
        _mLbRealy.adjustsFontSizeToFitWidth = YES;
        _mLbRealy.textColor = [UIColor blackColor];
        _mLbRealy.textAlignment = NSTextAlignmentRight;
    }
    return _mLbRealy;
}





- (UILabel *)mLbHospital
{
    if (!_mLbHospital)
    {
        _mLbHospital = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200*RATIO, 60)];
        _mLbHospital.textAlignment = NSTextAlignmentRight;
    }
    return _mLbHospital;
}
- (UILabel *)mLbDepartment
{
    if (!_mLbDepartment)
    {
        _mLbDepartment = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 120*RATIO, 30)];
        _mLbDepartment.textAlignment = NSTextAlignmentRight;
    }
    return _mLbDepartment;
}
- (UILabel *)mLbGrade
{
    if (!_mLbGrade)
    {
        _mLbGrade = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 120*RATIO, 30)];
        _mLbGrade.textAlignment = NSTextAlignmentRight;
    }
    return _mLbGrade;
}

- (UILabel *)mLbDoctorNum
{
    if (!_mLbDoctorNum)
    {
        _mLbDoctorNum = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 165*RATIO, 60)];
        _mLbDoctorNum.textAlignment = NSTextAlignmentRight;
    }
    return _mLbDoctorNum;
}

#pragma 上传个人照片
- (void)upDatePhoto{
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
    
       BOOL sucess=[UIImagePNGRepresentation([self reduceImage:info[UIImagePickerControllerEditedImage] percent:0.5] ) writeToFile:[PATH_USERS stringByAppendingPathComponent:@"updateVipPhoto"]atomically:YES];
        if (sucess) {
            self.licensePicFilepath=[PATH_USERS stringByAppendingPathComponent:@"updateVipPhoto"];
            CMTUSERINFO.licensePicFilepath=  self.licensePicFilepath;
            UIImage *image = [UIImage imageWithContentsOfFile:[PATH_USERS stringByAppendingPathComponent:@"updateVipPhoto"]];
            self.updateImageView.image = image;
            self.changeSuccess = YES;
          
            // 隐藏当前模态窗口
            [self dismissViewControllerAnimated:YES completion:nil];

        }
 }
//压缩图片
-(UIImage *)reduceImage:(UIImage *)image percent:(float)percent
{
    NSData *imageData = UIImageJPEGRepresentation(image, percent);
    UIImage *newImage = [UIImage imageWithData:imageData];
    return newImage;
}




#pragma mark   save  
/*根据请求结果做具体处理*/
- (void)currentSave
{
    
    
            CMTUserInfo *info = CMTUSER.userInfo;
            NSNumber *hosptialId = [NSNumber numberWithInt:self.mHosptioal.hospitalId.intValue];
            NSDictionary *pDic = @{
                                   @"userId":info.userId?:@"",
                                   @"realName":self.mStrRealy?:@"",
                                   @"hospitalId":hosptialId.intValue!=0?hosptialId:(!isEmptyString(CMTUSERINFO.hospitalId)?CMTUSERINFO.hospitalId:@"0"),
                                   @"departId":self.mDepart.departId?:@"0",
                                   @"subDepartId":self.mSubDepart.subDepartId?:@"0",
                                   @"doctorNumber":self.mLbDoctorNum.text?:@"",
                                   @"hospitalName":self.mStrHospital?:@"",
                                   @"provCode":@"",
                                   @"cityCode":@"",
                                   @"licensePic":self.licensePicFilepath?:@"",
                                   @"level":self.mLbGrade.text?:@"",
                                   @"forCreateGroup":@"1",
                                   
                                   };
            @weakify(self);
            [[[CMTCLIENT promoteVip:pDic]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(CMTScore *x) {
                DEALLOC_HANDLE_SUCCESS
                @strongify(self);
                
                    CMTLog(@"认证成功");
                    if (self.updateCreatebuttonState!=nil) {
                        self.updateCreatebuttonState(@"5");
                    }else {
                         CMTUSERINFO.authStatus =x.authStatus;
                    }
                    CMTUSERINFO.realName = self.mStrRealy;
                    CMTUSERINFO.hospital = self.mLbHospital.text;
                    CMTUSERINFO.subDepartment = self.mLbDepartment.text;
                    CMTUSERINFO.level = self.mLbGrade.text;
                    CMTUSERINFO.licensePicFilepath = self.licensePicFilepath;
                    CMTUSERINFO.doctorNumber = self.mLbDoctorNum.text;
                    [CMTUSER save];
                                //同步网络小组信息
                  if (CMTUSER.login)
                  {
                    [CMTAPPCONFIG getUserInfo];
                  }

                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (self.mygroup!=nil) {
                            [self.navigationController popViewControllerAnimated:YES];
                        }
                        if ([self.lastVC isEqualToString:@"CMTReadCodeBlind"]) {
                            [self.navigationController popViewControllerAnimated:YES];
                        }
                        if ([self.lastVC isEqualToString:@"CaseCircle"]) {
                            [self.navigationController popToRootViewControllerAnimated:YES];
                        }

                    });
                
            } error:^(NSError *error) {
                DEALLOC_HANDLE_SUCCESS
                CMTLog(@"error=%@",error);
                 NSString *errMes = error.userInfo[CMTClientServerErrorUserInfoMessageKey];
                    CMTLog(@"errMes = %@",errMes);
                    [self toastAnimation:errMes];
                CMTLog(@"认证失败状态为:%@",error.userInfo[CMTClientServerErrorCodeKey]);
               

            } completed:^{
                DEALLOC_HANDLE_SUCCESS
                CMTLog(@"空表");
            }];

            
           
}

#pragma mark  tableview  delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CMTLog(@"%@",[tableView cellForRowAtIndexPath:indexPath].textLabel.text);
    
    int authStatus = CMTUSERINFO.authStatus.intValue;
    if (authStatus == 0 || [self.lastVC isEqualToString:@"CaseCircle"])
    {
        switch (indexPath.row)
        {
            case 0:
            {
                self.mNameEditVC.row = indexPath.row;
                self.mNameEditVC.lastVCStr = self.mLbRealy.text;
                [self.navigationController pushViewController:self.mNameEditVC animated:YES];
            }
                break;
            case 1:
            {
                CMTLog(@"跳入医院界面");
                [self.navigationController pushViewController:self.mProvVC animated:YES];
            }
                break;
            case 2:
            {
                CMTLog(@"跳入科室界面");
                [self.navigationController pushViewController:self.mDepVC animated:YES];
            }
                break;
            case 3:
            {
                CMTLevelViewController *levelVC = [[CMTLevelViewController alloc]init];
                [self.navigationController pushViewController:levelVC animated:YES];
            }
                break;
            case 4:
            {
                
            }
                break;
            case 5:
            {
                self.mNameEditVC.lastVCStr = self.mLbDoctorNum.text;

                self.mNameEditVC.row = indexPath.row;
                [self.navigationController pushViewController:self.mNameEditVC animated:YES];
            }
                break;
           
                
            default:
                break;
        }
    }
    else
    {
        CMTLog(@"不做任何操作");
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 4) {
        return 120;
    }
    return 45;
}

#pragma makr   tableView  datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifer = @"cell";
    UITableViewCell *pCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifer];
    
    if (!pCell)
    {
        pCell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifer];
    
        
    }
    CMTUserInfo *info = CMTUSER.userInfo;
    int authStatus = info.authStatus.intValue;
    switch (indexPath.row)
        {
            case 0:
            {
                 if (!pLabel)
                    {
                        pLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, 90, 45)];
                    }
                    pLabel.font = [UIFont systemFontOfSize:16];
                    pLabel.text = @"姓名";
                    pLabel.textColor = [UIColor colorWithHexString:@"b3b3b3"];
                    [pCell.contentView addSubview:pLabel];
              
                    self.mLbRealy.text =self.mStrRealy;
                  pCell.accessoryView = self.mLbRealy;
            }
                break;
            
            case 1:
            {
                    if (!pLabel1)
                    {
                        pLabel1 = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, 90, 45)];
                    }
                    pLabel1.font = [UIFont systemFontOfSize:16];
                    pLabel1.text = @"医院";
                    pLabel1.textColor = [UIColor colorWithHexString:@"b3b3b3"];
                    [pCell.contentView addSubview:pLabel1];
                    self.mLbHospital.text = self.mStrHospital;
                    if (self.mLbHospital.text.length > 0)
                    {
                        pCell.accessoryView = self.mLbHospital;
                    }
                    else
                    {
                        pCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    }
            }
                break;
            case 2:
            {
                    if (!pLabel2)
                    {
                        pLabel2 = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, 90, 45)];
                    }
                    pLabel2.font = [UIFont systemFontOfSize:16];
                    pLabel2.text = @"科室";
                    pLabel2.textColor = [UIColor colorWithHexString:@"b3b3b3"];
                   [pCell.contentView addSubview:pLabel2];
                    self.mLbDepartment.text = self.mStrDepartment;
                if (self.mLbDepartment.text.length > 0)
                {
                    pCell.accessoryView = self.mLbDepartment;
                }
                else
                {
                    pCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                }
            }
                break;
            case 3:
            {
                if (!pLabel3)
                {
                    pLabel3 = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, 90, 45)];
                }
                pLabel3.font = [UIFont systemFontOfSize:16];
                pLabel3.text = @"职称";
                pLabel3.textColor = [UIColor colorWithHexString:@"b3b3b3"];
                [pCell.contentView addSubview:pLabel3];
                self.mLbGrade.text =self.mStrGrade;
                if (self.mLbGrade.text.length > 0)
                {
                    pCell.accessoryView = self.mLbGrade;
                }
                else
                {
                    pCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                }
            }
                break;
            case 4:
            {
                NSLog(@"mmdmdmdmdmdmdm%@",CMTUSERINFO);

                if (authStatus ==  1 || authStatus == 4 || authStatus == 5 || authStatus == 7 || authStatus == 6)
                {
                    if(CMTUSERINFO.licensePic.length==0&&CMTUSERINFO.licensePicFilepath.length>0){
                    UIImage *image=[UIImage imageWithContentsOfFile:CMTUSERINFO.licensePicFilepath];
                    self.updateImageView.image=image;
                    
                    }else if (CMTUSERINFO.licensePic.length == 0 && CMTUSERINFO.licensePicFilepath.length == 0){
                        NSLog(@"+++++++%@++++++%@",CMTUSERINFO.licensePic,CMTUSERINFO.licensePicFilepath);
                        self.updateImageView.image = nil;
                    }
                    else if(CMTUSERINFO.licensePic.length > 0 && CMTUSERINFO.licensePicFilepath.length > 0 && self.changeSuccess > 0){
                        //此种情况为认证信息已存在，创建小组审核时修改图片
                       self.updateImageView.image = [UIImage imageWithContentsOfFile:CMTUSERINFO.licensePicFilepath];
                    }else{
                        [self.updateImageView setImageURL:CMTUSERINFO.licensePic placeholderImage:nil contentSize:self.updateImageView.frame.size];
                    }

                }
                [pCell.contentView addSubview:self.upDateView];
            }
                break;
            case 5:
            {
                    if (!pLabel4)
                    {
                        pLabel4 = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, 120, 45)];
                    }
                    pLabel4.font = [UIFont systemFontOfSize:16];
                    pLabel4.text = @"或 执业医师号";
                    pLabel4.textColor = [UIColor colorWithHexString:@"b3b3b3"];
                    [pCell.contentView addSubview:pLabel4];

                self.mLbDoctorNum.text = self.mStrDoctorNum;
                pCell.accessoryView = self.mLbDoctorNum;
            }
                break;
            default:
                break;
        }

   
    pCell.selectionStyle = UITableViewCellSelectionStyleNone;
    pCell.textLabel.font = [UIFont systemFontOfSize:14];
    //划线
    UIView *lineView = [[UIView alloc]init];
    if (indexPath.row == 4) {
        lineView.frame = CGRectMake(10, 159, SCREEN_WIDTH - 20, 0.5);
        lineView.backgroundColor = ColorWithHexStringIndex(c_clear);
    }else{
        lineView.frame = CGRectMake(10, 44, SCREEN_WIDTH - 20, 0.5);
        lineView.backgroundColor = [UIColor colorWithHexString:@"f4f4f4"];
    }
    [pCell.contentView addSubview:lineView];
    return pCell;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
        CMTUSERINFO.licensePicFilepath = nil;
    

}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
