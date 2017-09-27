//
//  CmtModifyGroupViewController.m
//  MedicalForum
//
//  Created by guoyuanchao on 16/3/29.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import "CmtModifyGroupViewController.h"
#import "CMTGroupCreatedDesViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "CMTWithoutPermissionViewController.h"
#import "CMTImageCompression.h"
@interface CmtModifyGroupViewController ()<UIGestureRecognizerDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property(nonatomic,strong)CMTGroup *mygroup;
@property(nonatomic,strong)UIImageView *groupimageView;
@property(nonatomic,strong)UILabel *grouptitellable;
@property(nonatomic,strong)UILabel *groupdesclable;
@property(nonatomic,strong)UILabel *groupType;
@property(nonatomic,strong)UIButton *logoutbutton;
@property (nonatomic, strong)UIBarButtonItem *NavRightItem;//修改小组按钮
@property(nonatomic,strong)UIButton *createButton;
@property (nonatomic, strong)NSArray *rightItems;//导航items数组
@property (nonatomic, strong)NSString *filePath;//导航items数组
@property(nonatomic,strong)NSString *isModify;

@end

@implementation CmtModifyGroupViewController
-(instancetype)initWithGroup:(CMTGroup*)group{
    self=[super init];
    if (self) {
        self.mygroup=group;
        self.isModify=@"0";
    }
    return self;
    
}

-(UIBarButtonItem*)NavRightItem{
    if (_NavRightItem==nil) {
        self.createButton=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 45, 30)];
        self .createButton.userInteractionEnabled=NO;
        [_createButton setTitle:@"完成" forState:UIControlStateNormal];
        _createButton.userInteractionEnabled=NO;
        [_createButton setTitleColor:[UIColor colorWithHexString:@"#d4d4d4"] forState:UIControlStateNormal];
        [_createButton addTarget:self action:@selector(ModifySavection)  forControlEvents:UIControlEventTouchUpInside];
        _NavRightItem=[[UIBarButtonItem alloc]initWithCustomView:_createButton];
    }
    return _NavRightItem;
}
- (NSArray *)rightItems {
    if (_rightItems == nil) {
        UIBarButtonItem *FixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        FixedSpace.width = -7.5 + (RATIO - 1.0)*(CGFloat)12.0;
        _rightItems=[[NSArray alloc]initWithObjects:FixedSpace,self.NavRightItem, nil];
    }
    
    return _rightItems;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    @weakify(self);
    [self.rac_willDeallocSignal subscribeCompleted:^{
        CMTLog(@"CMTGroupCardViewController  willDeallocSignal");
    }];
    self.titleText=@"修改小组";
    
    [self drawView];
    self.navigationItem.rightBarButtonItems=self.rightItems;

    [[[RACObserve(self,isModify)distinctUntilChanged]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(NSString *x) {
        @strongify(self);
        if (x.integerValue==1) {
            self.createButton.userInteractionEnabled=YES;
            [self.createButton setTitle:@"完成" forState:UIControlStateNormal];
            self.createButton.titleLabel.font=[UIFont boldSystemFontOfSize:18];
            [ self.createButton setTitleColor:ColorWithHexStringIndex(c_4acbb5) forState:UIControlStateNormal];

        }else{
            self.createButton.userInteractionEnabled=NO;
            [_createButton setTitle:@"完成" forState:UIControlStateNormal];
            _createButton.userInteractionEnabled=NO;
            [_createButton setTitleColor:[UIColor colorWithHexString:@"#d4d4d4"] forState:UIControlStateNormal];
            
        }
        
    } error:^(NSError *error) {
        
    }];
}
//绘制视图
-(void)drawView{
    
    CGFloat oneWordheight= ceilf([CMTGetStringWith_Height getTextheight:@"你好" fontsize:18 width:SCREEN_WIDTH-80]);
    self.groupimageView=[[UIImageView alloc]initWithFrame:CGRectMake((SCREEN_WIDTH-140*RATIO)/2,CMTNavigationBarBottomGuide+30, 140*RATIO, 140*RATIO)];
    self.groupimageView.clipsToBounds=YES;
    self.groupimageView.userInteractionEnabled=YES;
    self.groupimageView.contentMode= UIViewContentModeScaleAspectFill;
    [self.groupimageView setImageURL:self.mygroup.groupLogo.picFilepath placeholderImage:IMAGE(@"placeholder_list_loading") contentSize:CGSizeMake(140*RATIO, 140*RATIO)];
    [self.contentBaseView addSubview:self.groupimageView];
    UITapGestureRecognizer *imagetap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(Modifyimage)];
    imagetap.numberOfTouchesRequired = 1; //手指数
    imagetap.numberOfTapsRequired = 1; //tap次数
    imagetap.delegate = self;
    [self.groupimageView addGestureRecognizer:imagetap];

     CGFloat height1= ceilf([CMTGetStringWith_Height getTextheight:self.mygroup.groupName fontsize:18 width:SCREEN_WIDTH-80]);
    self.grouptitellable=[[UILabel alloc]initWithFrame:CGRectMake(40, self.groupimageView.bottom+10, SCREEN_WIDTH-80, height1)];
    self.grouptitellable.text=self.mygroup.groupName;
    self.grouptitellable.textAlignment=NSTextAlignmentCenter;
    self.grouptitellable.font=[UIFont boldSystemFontOfSize:18];
    self.grouptitellable.textColor=ColorWithHexStringIndex(c_bfbfbf);
    self.grouptitellable.numberOfLines=2;
    [self.contentBaseView addSubview:self.grouptitellable];
    
    if (height1>oneWordheight) {
        self.grouptitellable.textAlignment=NSTextAlignmentLeft;
    }else{
        self.grouptitellable.textAlignment=NSTextAlignmentCenter;
        
    }

    
    self.groupType=[[UILabel alloc]initWithFrame:CGRectMake(40, self.grouptitellable.bottom+10, SCREEN_WIDTH-80, 30)];
    self.groupType.text=self.mygroup.groupType.integerValue==0?@"公开":@"封闭";
    self.groupType.font=[UIFont systemFontOfSize:18];
    self.groupType.textColor=ColorWithHexStringIndex(c_bfbfbf);
    [self.contentBaseView addSubview:self.groupType];
    
    CGFloat height= ceilf([CMTGetStringWith_Height getTextheight:self.mygroup.groupDesc fontsize:18 width: self.grouptitellable.width])+5;
    self.groupdesclable=[[UILabel alloc]initWithFrame:CGRectMake(self.grouptitellable.left, self.groupType.bottom+10,self.grouptitellable.width, height)];
    self.groupdesclable.userInteractionEnabled=YES;
    self.groupdesclable.text=self.mygroup.groupDesc;
    self.groupdesclable.font=[UIFont systemFontOfSize:18];
    self.groupdesclable.textColor=[UIColor blackColor];
    self.groupdesclable.numberOfLines=0;
    self.groupdesclable.textAlignment=NSTextAlignmentLeft;
    self.groupdesclable.lineBreakMode=NSLineBreakByWordWrapping;
    [self.contentBaseView addSubview:self.groupdesclable];
    UIView *lineView=[[UIView alloc]initWithFrame:CGRectMake(0, height-1, self.grouptitellable.width, 1)];
    lineView.tag=1000;
    lineView.backgroundColor=[UIColor colorWithHexString:@"#e6e6e6"];
    [self.groupdesclable addSubview:lineView];
    
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(Modifytext)];
    tap.numberOfTouchesRequired = 1; //手指数
    tap.numberOfTapsRequired = 1; //tap次数
    tap.delegate = self;
    [self.groupdesclable addGestureRecognizer:tap];
 }
-(void)Modifyimage{
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
    BOOL sucess=[UIImagePNGRepresentation([self reduceImage:info[UIImagePickerControllerEditedImage] percent:0.5] ) writeToFile:[PATH_USERS stringByAppendingPathComponent:@"ModifyGroup"]atomically:YES];
    if (sucess) {
        self.filePath =[PATH_USERS stringByAppendingPathComponent:@"ModifyGroup"];
        UIImage *image = [UIImage imageWithContentsOfFile:[PATH_USERS stringByAppendingPathComponent:@"ModifyGroup"]];
        self.groupimageView.image = image;
         self.isModify=@"1";
        // 隐藏当前模态窗口
        [self dismissViewControllerAnimated:YES completion:nil];
        
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
//保存修改
-(void)ModifySavection{
    @weakify(self);
    [self setContentState:CMTContentStateLoading moldel:@"1"];
    NSDictionary *params = @{
                             @"userId":CMTUSER.userInfo.userId? : @"",
                             @"groupType":self.mygroup.groupType,
                             @"groupId":self.mygroup.groupId,
                             @"groupName":self.mygroup.groupName,
                             @"groupDesc":self.mygroup.groupDesc,
                             @"groupLogo":self.filePath?:@""
                             
                             };

    [[[CMTCLIENT modifUpdateGroup:params]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(CMTGroup *x) {
        @strongify(self);
         self.isModify=@"0";
        self.mygroup.groupDesc=x.groupDesc;
        self.mygroup.groupLogo=x.groupLogo;
        [self toastAnimation:@"修改成功"];
        if(self.ModifyGroupSucess!=nil){
            self.ModifyGroupSucess(self.mygroup);
        }
        [self setContentState:CMTContentStateNormal moldel:@"1"];
          [self stopAnimation];
        [CMTImageCompression deleteFile:self.filePath];
        self.filePath=@"";
        @weakify(self);
        [[RACScheduler mainThreadScheduler]afterDelay:0.5 schedule:^{
             @strongify(self);
            [self.navigationController popViewControllerAnimated:YES];
        }];
        
    } error:^(NSError *error) {
         @strongify(self);
        [self setContentState:CMTContentStateNormal moldel:@"1"];
        [self stopAnimation];
        [self toastAnimation:@"修改失败"];
    } completed:^{
        
    }];
}
-(void)Modifytext{
    @weakify(self);
    CMTGroupCreatedDesViewController *groupDes=[[CMTGroupCreatedDesViewController alloc]initWithtext:self.mygroup.groupDesc from:@"1"];
    groupDes.updateGroupDes=^(NSString* str){
        @strongify(self);
        if (![str isEqualToString:self.mygroup.groupDesc]) {
            self.isModify=@"1";
        }
        self.groupdesclable.text=str;
        self.mygroup.groupDesc=str;

        CGFloat height= ceilf([CMTGetStringWith_Height getTextheight:self.mygroup.groupDesc fontsize:18 width:SCREEN_WIDTH-80]);
        self.groupdesclable.frame=CGRectMake(self.grouptitellable.left, self.groupType.bottom+10,self.grouptitellable.width, height);
        [self.groupdesclable viewWithTag:1000].frame=CGRectMake(0, height-1, self.grouptitellable.width, 1);
     };
    [self.navigationController pushViewController:groupDes animated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end
