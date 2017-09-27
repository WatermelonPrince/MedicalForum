//
//  CMTSettingViewController.m
//  MedicalForum
//
//  Created by Bo Shen on 14/12/22.
//  Copyright (c) 2014年 CMT. All rights reserved.
//


#import "CMTSettingViewController.h"
#import "VPImageCropperViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "CMTUpgradeViewController.h"
#import "CMTPostDetailCenter.h"
#import "CMTWebBrowserViewController.h"
#import "CMTGroupInfoViewController.h"
#import "CMTLiveViewController.h"
#import "CMTCaseCircleViewController.h"
#import "CMTFoundViewController.h"
#import "CMTRecordedViewController.h"
#import "CMTLightVideoViewController.h"
#import "CMTSystemTableViewCell.h"
#import "CMTNameEditViewController.h"
#import "CMTProvinceViewController.h"
#import "CMTDepartMentViewController.h"
#import "CMTLevelViewController.h"
#import "CMTDigitalWebViewController.h"
#define ORIGINAL_MAX_WIDTH 640.0f


@interface CMTSettingViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,VPImageCropperDelegate,UIActionSheetDelegate,UITextViewDelegate,UITableViewDataSource,UITableViewDelegate>
@property (assign) BOOL setHead;
@property(nonatomic,strong)UITableView *InformationList;
@property(nonatomic,strong)CMTUserInfo*info;
@property(nonatomic,strong)NSArray *dataSourceArray;
@property(nonatomic,strong)UIButton *saveButton;
@property(nonatomic,strong)UIImageView *rightimageView;
@property(nonatomic,strong)UIImageView *rightimageView1;
@property(nonatomic,strong)UIView*headView;

@end

@implementation CMTSettingViewController
-(CMTUserInfo*)info{
    if(_info==nil){
        _info=[[CMTUserInfo alloc]init];
    }
    return _info;
}
-(UIImageView*)rightimageView{
    if(_rightimageView==nil){
        _rightimageView=[[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-15-9,58/2-(13/2), 9, 13 )];
        _rightimageView.image=[UIImage imageNamed:@"acc"];
        
    }
    return _rightimageView;
}
-(UIImageView*)rightimageView1{
    if(_rightimageView1==nil){
        _rightimageView1=[[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-15-9, 58/2-(13/2), 9, 13 )];
        _rightimageView1.image=[UIImage imageNamed:@"acc"];
        
    }
    return _rightimageView1;
}

- (UIView *)mHeadView
{
    if (!_mHeadView)
    {
        _mHeadView = [[UIView alloc]initWithFrame:CGRectMake(0,0, SCREEN_WIDTH, 58)];
        _mHeadView.backgroundColor =COLOR(c_ffffff);
        UIView *line=[[UIView alloc]initWithFrame:CGRectMake(0, 57, SCREEN_WIDTH, 1)];
        line.backgroundColor=[UIColor colorWithHexString:@"#f7f7f7"];
        [_mHeadView addSubview:line];
        [_mHeadView addSubview:self.lbHead];
        [_mHeadView addSubview:self.mImageViewHead];
        [_mHeadView addSubview:self.rightimageView];
        UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(eiditHeadimage:)];
        [_mHeadView addGestureRecognizer:tap];
    }
    return _mHeadView;
}
- (UIView *)mNickNameView
{
    if (!_mNickNameView)
    {
        _mNickNameView = [[UIView alloc]initWithFrame:CGRectMake(0, self.mHeadView.frame.size.height, SCREEN_WIDTH, 58)];
        _mNickNameView.backgroundColor = COLOR(c_ffffff);
        UIView *line=[[UIView alloc]initWithFrame:CGRectMake(0, 57, SCREEN_WIDTH, 1)];
        line.backgroundColor=[UIColor colorWithHexString:@"#f7f7f7"];
        [_mNickNameView addSubview:line];
        [_mNickNameView addSubview:self.mTextView];
        [_mNickNameView addSubview:self.lbNickName];
        [_mNickNameView addSubview:self.rightimageView1];
        UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(editnickname:)];
        [_mNickNameView addGestureRecognizer:tap];
    }
    return _mNickNameView;
}
- (UITextField *)mTextView
{
    if (!_mTextView)
    {
        _mTextView = [[UITextField alloc]initWithFrame:CGRectMake(self.lbNickName.right+10,0,self.rightimageView1.left-self.lbNickName.right-20, 58)];
        _mTextView.delegate = self;
        _mTextView.textAlignment=NSTextAlignmentRight;
        _mTextView.font = [UIFont systemFontOfSize:16];
        _mTextView.userInteractionEnabled = YES;
        _mTextView.placeholder = @"输入参与讨论时显示的昵称";
        _mTextView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _mTextView.clearButtonMode=UITextFieldViewModeWhileEditing;
        [_mTextView setValue:COLOR(c_ababab) forKeyPath:@"_placeholderLabel.textColor"];
        _mTextView.textColor=COLOR(c_ababab);
    }
    return _mTextView;
}

- (UILabel *)lbHead
{
    if (!_lbHead)
    {
         float with=[CMTGetStringWith_Height CMTGetLableTitleWith:@"修改头像" fontSize:16];
        _lbHead = [[UILabel alloc]initWithFrame:CGRectMake(self.rightimageView.left-with-10, 0,self.rightimageView.left-self.mImageViewHead.right-20,58)];
        _lbHead.text = @"修改头像";
        _lbHead.font=FONT(16);
        _lbHead.adjustsFontSizeToFitWidth = YES;
        _lbHead.textColor=COLOR(c_ababab);
    }
    return _lbHead;
}


- (UILabel *)lbNickName
{
    if (!_lbNickName)
    {
        _lbNickName = [[UILabel alloc]initWithFrame:CGRectMake(15,0, 35, self.lbHead.frame.size.height)];
        _lbNickName.font=FONT(16);
        _lbNickName.text = @"昵称";
        _lbNickName.textColor=COLOR(c_151515);

    }
    return _lbNickName;
}

- (UIImageView *)mImageViewHead
{
    if (!_mImageViewHead)
    {
        _mImageViewHead = [[UIImageView alloc]initWithFrame:CGRectMake(15,5, 48, 48)];
        _mImageViewHead.layer.masksToBounds = YES;
        _mImageViewHead.layer.cornerRadius = _mImageViewHead.frame.size.height/2;
        [_mImageViewHead setContentMode:UIViewContentModeScaleAspectFill];
        [_mImageViewHead setClipsToBounds:YES];
        [_mImageViewHead setImage:IMAGE(@"default")];
    }
    return _mImageViewHead;
    
}
-(UIView*)headView{
    if(_headView==nil){
        _headView=[[UIView alloc]init];
        [_headView addSubview:self.mHeadView];
        [_headView addSubview:self.mNickNameView];
        _headView.frame=CGRectMake(0, 0,SCREEN_WIDTH, self.mNickNameView.bottom);
    }
    return _headView;
}
-(UITableView*)InformationList{
    if(_InformationList==nil){
        _InformationList=[[UITableView alloc]initWithFrame:CGRectMake(0,CMTNavigationBarBottomGuide+20,SCREEN_WIDTH,SCREEN_HEIGHT-CMTNavigationBarBottomGuide-20) style:UITableViewStylePlain];
        _InformationList.separatorStyle=UITableViewCellSeparatorStyleNone;
        _InformationList.delegate=self;
        _InformationList.dataSource=self;
        _InformationList.backgroundColor=COLOR(c_ffffff);
    }
    return _InformationList;
}
- (UIButton *)saveButton{
    if (_saveButton == nil) {
        _saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _saveButton.frame = CGRectMake(0, 0, 45, 30);
        [_saveButton setTitle:@"完成" forState:UIControlStateNormal];
        [_saveButton addTarget:self action:@selector(btnFinishSetting:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _saveButton;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setContentState:CMTContentStateNormal];
    self.contentBaseView.backgroundColor = [UIColor colorWithHexString:@"#f7f7f7"];
    self.navigationItem.rightBarButtonItem = self.mFinishItem;
     [self.contentBaseView addSubview:self.InformationList];
     self.titleText=@"完善信息";
    if(self.nextvc==FromDigital){
        self.dataSourceArray=@[@"姓名",@"医院",@"科室",@"职称"];
         [self.InformationList reloadData];
    }else if(self.nextvc==FromDigitalAndLogin) {
        if(CMTUSERINFO.showInviteCode.integerValue==1){
          self.dataSourceArray=@[@"姓名",@"医院",@"科室",@"职称",@"邀请码"];
        }else{
            self.dataSourceArray=@[@"姓名",@"医院",@"科室",@"职称"];
        }
        self.InformationList.tableHeaderView=self.headView;
        [self.InformationList reloadData];
        self.mTextView.enabled=NO;
        
    }else{
         if(CMTUSERINFO.showInviteCode.integerValue==1){
               self.dataSourceArray=@[@"邀请码"];
         }else{
             self.dataSourceArray=@[];
         }
        [self.InformationList reloadData];
        self.InformationList.tableHeaderView=self.headView;
       
    }
    [[RACObserve(self.saveButton,enabled) deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(NSNumber *x) {
        if (x.integerValue == 0) {
            [self.saveButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        }else{
            [self.saveButton setTitleColor:[UIColor colorWithHexString:@"1eba9c"] forState:UIControlStateNormal];
            
        }
    }];

    //初始为选择照片
    self.hasChosImage = NO;
}
-(void)editnickname:(UITapGestureRecognizer*)tap{
    CMTNameEditViewController *nameEdit=[[CMTNameEditViewController alloc]init];
    nameEdit.row=7;
    nameEdit.lastVCStr=self.mTextView.text;
    @weakify(self);
    nameEdit.updatRealname=^(NSString* realname){
        @strongify(self);
       self.mTextView.text=realname;
    };
    [self.navigationController pushViewController:nameEdit animated:YES];
}
 #pragma mark UItableViewdelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSourceArray.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 58;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CMTSystemTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(cell==nil){
        cell=[[CMTSystemTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.textWith=self.mTextView.width;
        
    }
    switch (indexPath.row) {
        case 0:
            if([self.dataSourceArray[indexPath.row] isEqualToString:@"邀请码"]){
                [cell reloadCell:self.dataSourceArray[indexPath.row] text:self.info.recommendedCode index:indexPath];
            }else{
              [cell reloadCell:self.dataSourceArray[indexPath.row] text:self.info.realName index:indexPath] ;
            }
            break;
        case 1:
             [cell reloadCell:self.dataSourceArray[indexPath.row] text:self.info.hospital index:indexPath];
            break;
        case 2:
             [cell reloadCell:self.dataSourceArray[indexPath.row] text:self.info.subDepart.subDepartment index:indexPath];
            break;
        case 3:
              [cell reloadCell:self.dataSourceArray[indexPath.row] text:self.info.level index:indexPath];
              break;
        case 4:
            [cell reloadCell:self.dataSourceArray[indexPath.row] text:self.info.recommendedCode index:indexPath];
          
              break;
        default:
            break;
    }
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
        case 0:{
            CMTNameEditViewController *nameEdit=[[CMTNameEditViewController alloc]init];
            nameEdit.row=indexPath.row;
            nameEdit.lastVCStr=self.info.realName;
            nameEdit.type=[self.dataSourceArray[indexPath.row] isEqualToString:@"邀请码"]?self.dataSourceArray[indexPath.row]:nil;
            @weakify(self);
            nameEdit.updatRealname=^(NSString* realname){
                @strongify(self);
                if ([self.dataSourceArray[indexPath.row] isEqualToString:@"邀请码"]){
                    self.info.recommendedCode=realname;
                }else{
                     self.info.realName=realname;
                }
                [tableView reloadData];
            };
            [self.navigationController pushViewController:nameEdit animated:YES];
        }
            break;
        case 1:{
             CMTProvinceViewController *provece=[[CMTProvinceViewController alloc]init];
              @weakify(self);
            provece.updateHostpital=^(CMTHospital* hostpital){
                  @strongify(self);
                self.info.hospital=hostpital.hospital;
                self.info.hospitalId=hostpital.hospitalId;
                [tableView reloadData];

            };
            [self.navigationController pushViewController:provece animated:YES];

         }
            
            break;

        case 2:{
             CMTDepartMentViewController *depart=[[CMTDepartMentViewController alloc]init];
            @weakify(self);
            depart.updateDepart=^(CMTSubDepart* depart){
                @strongify(self);
                self.info.subDepart=depart;
                [tableView reloadData];

            };
             [self.navigationController pushViewController:depart animated:YES];
        }
            
            break;

        case 3:{
            CMTLevelViewController *levelVC = [[CMTLevelViewController alloc]init];
            @weakify(self);
            levelVC.updateLeve=^(NSString *leve){
                @strongify(self);
                self.info.level=leve;
                [tableView reloadData];

            };
            [self.navigationController pushViewController:levelVC animated:YES];
         }
         break;

        case 4:{
            CMTNameEditViewController *nameEdit=[[CMTNameEditViewController alloc]init];
            nameEdit.type=@"邀请码";
            nameEdit.lastVCStr=self.info.recommendedCode;
            @weakify(self);
            nameEdit.updatRealname=^(NSString* realname){
                @strongify(self);
                self.info.recommendedCode=realname;
                [tableView reloadData];
            };
            [self.navigationController pushViewController:nameEdit animated:YES];
        }
            
            break;

            
        default:
            break;
    }
    
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    /*从缓存读取头像数据*/
    if (CMTUSER.login == YES && [[NSFileManager defaultManager]fileExistsAtPath:[PATH_CACHE_IMAGES stringByAppendingPathComponent:@"name"]])
    {
        UIImage *pImage = [UIImage imageWithContentsOfFile:[PATH_CACHE_IMAGES stringByAppendingPathComponent:@"name"]];
        self.mImageViewHead.image = pImage;
    }
    else if(CMTUSER.login == YES && [[NSFileManager defaultManager]fileExistsAtPath:[PATH_CACHE_IMAGES stringByAppendingPathComponent:@"name"]]==NO)
    {
        //[self setHeadImage:IMAGE(@"head_default")];
        [self.mImageViewHead setImageURL:CMTUSERINFO.picture placeholderImage:IMAGE(@"default") contentSize:CGSizeMake(48.0, 48.0)];
    }
    else if([[NSFileManager defaultManager]fileExistsAtPath:[PATH_CACHE_IMAGES stringByAppendingPathComponent:@"name"]])
    {
        UIImage *pImage = [UIImage imageWithContentsOfFile:[PATH_CACHE_IMAGES stringByAppendingPathComponent:@"name"]];
         self.mImageViewHead.image = pImage;
    }
    else
    {
          self.mImageViewHead.image = IMAGE(@"ic_default_head");
    }
    if (CMTUSER.login == YES)
    {
        self.mTextView.text = CMTUSER.userInfo.nickname;
    }
    else
    {
        CMTLog(@"nickName=%@",self.mTextView.text);
    }
    if(self.nextvc==FromDigital){
        if(self.info.realName.length>0&&self.info.hospital.length>0&&self.info.level.length>0&&self.info.subDepart!=nil){
            self.mFinishItem.enabled=YES;
        }else{
            self.mFinishItem.enabled=NO;
        }

    }else if(self.nextvc==FromDigitalAndLogin){
        if(self.info.realName.length>0&&self.info.hospital.length>0&&self.info.level.length>0&&self.info.subDepart!=nil&&self.mTextView.text.length>0){
            self.saveButton.enabled=YES;
        }else{
            self.saveButton.enabled=NO;
        }

    }
    
    
}

- (UIBarButtonItem *)mFinishItem
{
    
    _mFinishItem = [[UIBarButtonItem alloc]initWithCustomView:self.saveButton];
    return _mFinishItem;
}

#pragma mark  设置完成
/*个人头像昵称数据同步*/
- (void)btnFinishSetting:(id)sender
{
     if(self.mTextView.text.length==0){
         [self toastAnimation:@"请输入昵称"];
         return;
     }
      if (self.mTextView.text.length>20) {
            self.mTextView.text=[[self.mTextView.text stringByReplacingOccurrencesOfString:@" " withString:@""] substringToIndex:20];
            
        }
        NSDictionary *pDic=@{@"picture":self.hasChosImage?self.mImageViewHead.image:@"",
                             @"nickname":self.mTextView.text ,
                             @"userId":self.mUserInfo.userId?:CMTUSERINFO.userId,
                             @"realName":self.info.realName?:@"" ,
                             @"hospitalId":self.info.hospitalId?:@"",
                             @"hospitalName":self.info.hospital?:@"" ,
                             @"departId":self.info.subDepart.departId?:@"",
                             @"subDepartId":self.info.subDepart.subDepartId?:@"",
                             @"level":self.info.level?:@"",
                             };
                /*缓存头像*/
        if (self.hasChosImage)
        {
            BOOL isCache =[UIImagePNGRepresentation(self.mImageViewHead.image) writeToFile:[PATH_USERS stringByAppendingPathComponent:@"name"] atomically:YES];
            if (isCache)
            {
                CMTLog(@"头像缓存成功");
            }
            else
            {
                CMTLog(@"头像缓存失败");
            }

        }
        else
        {
            UIImage *image = IMAGE(@"ic_default_head");
            [UIImagePNGRepresentation(image) writeToFile:[PATH_USERS stringByAppendingPathComponent:@"name"]atomically:YES];
            
            CMTLog(@"没有设置头像,不需要缓存");
        }
        
        @weakify(self);
    [[[CMTCLIENT modifyPicture:pDic] deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(CMTPicture * picture) {
            @strongify(self);
            DEALLOC_HANDLE_SUCCESS
            CMTLog(@"picture=%@",picture.picture);
            CMTLog(@"个人信息设置完成");
            if(self.mUserInfo==nil){
                self.mUserInfo=CMTUSER.userInfo;
            }
            self.mUserInfo.nickname =self.mTextView.text;
            self.mUserInfo.picture = picture.picture;
            self.mUserInfo.realName=self.info.realName;
            self.mUserInfo.hospital=self.info.hospital;
            self.mUserInfo.hospitalId=self.info.hospitalId;
            self.mUserInfo.subDepartment=self.info.subDepart.subDepartment;
            self.mUserInfo.level=self.info.level;
            if(self.nextvc==FromDigital||self.nextvc==FromDigitalAndLogin){
                  self.mUserInfo.improveStatus=@"1";
            }
            if(self.nextvc==FromDigitalAndLogin){
                self.mUserInfo.canRead=self.mUserInfo.epaperSubjectResult.canRead;
                self.mUserInfo.rcodeState=self.mUserInfo.epaperSubjectResult.rcodeState;
                self.mUserInfo.decryptKey=self.mUserInfo.epaperSubjectResult.decryptKey;

            }
            CMTUSER.login = YES;
    
            CMTUSER.userInfo = self.mUserInfo;
            
            [CMTUSER save];
                
                if (self.nextvc == kDisVC)
                {
                    CMTUpgradeViewController *upgradeVC = [[CMTUpgradeViewController alloc]initWithNibName:nil bundle:nil];
                    upgradeVC.nextVC = self.nextvc;
                    [self.navigationController pushViewController:upgradeVC animated:YES];
                }else if(self.nextvc==FromDigitalAndLogin){
                    NSArray *pArr = self.navigationController.childViewControllers;
                    id obj;
                    for (int i = 0; i < pArr.count; i++)
                    {
                        obj = [pArr objectAtIndex:i];
                        if ([obj isKindOfClass:[CMTDigitalWebViewController class]])
                        {
                            [self.navigationController popToViewController:[pArr objectAtIndex:i] animated:YES];
                            break;
                        }
                    }

                }
                else if (self.nextvc == kComment)
                {
                    NSArray *pArr = self.navigationController.childViewControllers;
                    id obj;
                    for (int i = 0; i < pArr.count; i++)
                    {
                        obj = [pArr objectAtIndex:i];
                        if ([obj isKindOfClass:[CMTDigitalWebViewController class]]||[obj isKindOfClass:[CMTPostDetailCenter class]]||[obj isKindOfClass:[CMTWebBrowserViewController class]]||[obj isKindOfClass:[CMTCaseCircleViewController class]]||[obj isKindOfClass:[CMTGroupInfoViewController class]]||[obj isKindOfClass:[CMTLiveViewController class]]||[obj isKindOfClass:[CMTFoundViewController class]]||[obj isKindOfClass:[LiveVideoPlayViewController class]]||[obj isKindOfClass:[CMTRecordedViewController class]] || [obj isKindOfClass:[CMTLightVideoViewController class]])
                        {
                            [self.navigationController popToViewController:[pArr objectAtIndex:i] animated:YES];
                            break;
                        }
                    }
                }else if(self.nextvc==FromDigital){
                    [self.navigationController popViewControllerAnimated:YES];
                }else{
                    if ([self.navigationController respondsToSelector:@selector(popToRootViewControllerAnimated:)])
                    {
                        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"firstLogin_collection"];
                        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"firstLogin_subcrition"];
                        [[NSUserDefaults standardUserDefaults]synchronize];
                        //刷新病例列表
                        CMTAPPCONFIG.isrefreahCase=@"1";
                        // 同步订阅学科信息
                        [CMTFOCUSMANAGER allCollectionsWithFollows:self.mUserInfo.follows userId:self.mUserInfo.userId];
                        //同步订阅系列课程
                        [CMTFOCUSMANAGER asyneSeriesListForUser:CMTUSERINFO];
                        NSArray *items = @[];
                        NSData *pData = [NSJSONSerialization dataWithJSONObject:items options:NSJSONWritingPrettyPrinted error:nil];
                        NSString *pStr = [[NSString alloc]initWithData:pData encoding:NSUTF8StringEncoding];
                        NSDictionary *pCollectionDic = @{
                                                         @"userId":CMTUSER.userInfo.userId,
                                                         @"items":pStr,
                                                         };
                        // 同步收藏信息
                        [CMTFOCUSMANAGER loginToSych:pCollectionDic];
                        // 同步订阅专题信息
                        [CMTFOCUSMANAGER loginToSychThemes:pCollectionDic];
                        // 获取订阅总列表
                        [CMTFOCUSMANAGER subcriptions:nil];
                        
                        //获取订阅疾病标签
                        [CMTFOCUSMANAGER CMTSysFocusDiseaseTag:CMTUSER.userInfo.userId];
                        //更新论吧系统通知数目
                        [CMTAPPCONFIG updateCaseSysNoticeUnreadNumber];
                        [CMTAPPCONFIG updateCaseNoticeUnreadNumber];


                        [self.navigationController popToRootViewControllerAnimated:YES];
                    }
                }
        } error:^(NSError *error) {
            DEALLOC_HANDLE_SUCCESS
            CMTLog(@"error");
            NSString *errorCode = error.userInfo[CMTClientServerErrorCodeKey];
            if ([errorCode integerValue] > 100) {
                NSString *errMes = error.userInfo[CMTClientServerErrorUserInfoMessageKey];
                CMTLog(@"errMes = %@",errMes);
            } else {
                CMTLogError(@"modifyPicture System Error: %@", error);
            }

        } completed:^{
            DEALLOC_HANDLE_SUCCESS
            CMTLog(@"完成");
        }];
}
-(void)eiditHeadimage:(UITapGestureRecognizer*)tap{
    self.mActionSheet = [[UIActionSheet alloc]initWithTitle:@"选择图片" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"相册", nil];
    [self.mActionSheet showInView:self.contentBaseView];

    
}
#pragma mark   UITextView delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if ([string isEqualToString:@" "]) {
        return NO;
    }
    if (textField.text.length>20) {
        textField.text=[textField.text substringToIndex:20];
        return NO;
    }
    return YES;
}
#pragma mark   UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.text.length>20) {
        textField.text=[[textField.text stringByReplacingOccurrencesOfString:@" " withString:@""] substringToIndex:20];

    }else{
        textField.text=[textField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
   
    [textField resignFirstResponder];
    return YES;
}

/*自定义协议。选择头像确认后*/
#pragma mark VPImageCropperDelegate
- (void)imageCropper:(VPImageCropperViewController *)cropperViewController didFinished:(UIImage *)editedImage {
    
   self.hasChosImage = YES;
   
    BOOL suc = [UIImagePNGRepresentation(editedImage) writeToFile:[PATH_CACHE_IMAGES stringByAppendingPathComponent:@"name"] atomically:YES];
    if (suc)
    {
        CMTLog(@"缓存头像成功");
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"cacheImage"];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
    else
    {
        CMTLog(@"缓存头像失败");
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.mImageViewHead.image = editedImage;
        
    });
    
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
        // TO DO
    }];
}

- (void)imageCropperDidCancel:(VPImageCropperViewController *)cropperViewController {
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
    }];
    self.hasChosImage = NO;
}

#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        // 拍照
        if ([self isCameraAvailable] && [self doesCameraSupportTakingPhotos]) {
            UIImagePickerController *controller = [[UIImagePickerController alloc] init];
            controller.sourceType = UIImagePickerControllerSourceTypeCamera;
            if ([self isFrontCameraAvailable]) {
                controller.cameraDevice = UIImagePickerControllerCameraDeviceFront;
            }
            NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
            [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
            controller.mediaTypes = mediaTypes;
            controller.delegate = self;
            [self presentViewController:controller
                               animated:YES
                             completion:^(void){
                                 CMTLog(@"Picker View Controller is presented");
                             }];
        }
        
    } else if (buttonIndex == 1) {
        // 从相册中选取
        if ([self isPhotoLibraryAvailable]) {
            UIImagePickerController *controller = [[UIImagePickerController alloc] init];
            controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
            [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
            controller.mediaTypes = mediaTypes;
            controller.delegate = self;
            [self presentViewController:controller
                               animated:YES
                             completion:^(void){
                                 CMTLog(@"Picker View Controller is presented");
                             }];
        }
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^() {
        UIImage *portraitImg = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        portraitImg = [self imageByScalingToMaxSize:portraitImg];
        // 裁剪
        VPImageCropperViewController *imgEditorVC = [[VPImageCropperViewController alloc] initWithImage:portraitImg cropFrame:CGRectMake(0, 100.0f, self.view.frame.size.width, self.view.frame.size.width) limitScaleRatio:3.0];
        imgEditorVC.delegate = self;
        [self presentViewController:imgEditorVC animated:YES completion:^{
            // TO DO
            
        }];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^(){
    }];
}

#pragma mark camera utility
- (BOOL) isCameraAvailable{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isRearCameraAvailable{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

- (BOOL) isFrontCameraAvailable {
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}

- (BOOL) doesCameraSupportTakingPhotos {
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isPhotoLibraryAvailable{
    return [UIImagePickerController isSourceTypeAvailable:
            UIImagePickerControllerSourceTypePhotoLibrary];
}
- (BOOL) canUserPickVideosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeMovie sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}
- (BOOL) canUserPickPhotosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (BOOL) cameraSupportsMedia:(NSString *)paramMediaType sourceType:(UIImagePickerControllerSourceType)paramSourceType{
    __block BOOL result = NO;
    if ([paramMediaType length] == 0) {
        return NO;
    }
    NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:paramSourceType];
    [availableMediaTypes enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *mediaType = (NSString *)obj;
        if ([mediaType isEqualToString:paramMediaType]){
            result = YES;
            *stop= YES;
        }
    }];
    return result;
}

#pragma mark image scale utility
- (UIImage *)imageByScalingToMaxSize:(UIImage *)sourceImage {
    if (sourceImage.size.width < ORIGINAL_MAX_WIDTH) return sourceImage;
    CGFloat btWidth = 0.0f;
    CGFloat btHeight = 0.0f;
    if (sourceImage.size.width > sourceImage.size.height) {
        btHeight = ORIGINAL_MAX_WIDTH;
        btWidth = sourceImage.size.width * (ORIGINAL_MAX_WIDTH / sourceImage.size.height);
    } else {
        btWidth = ORIGINAL_MAX_WIDTH;
        btHeight = sourceImage.size.height * (ORIGINAL_MAX_WIDTH / sourceImage.size.width);
    }
    CGSize targetSize = CGSizeMake(btWidth, btHeight);
    return [self imageByScalingAndCroppingForSourceImage:sourceImage targetSize:targetSize];
}

- (UIImage *)imageByScalingAndCroppingForSourceImage:(UIImage *)sourceImage targetSize:(CGSize)targetSize {
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
    }
    UIGraphicsBeginImageContext(targetSize); // this will crop
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil) CMTLog(@"could not scale image");
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    CMTLog(@"当前的名字为%@",self.mTextView.text);
}

@end

