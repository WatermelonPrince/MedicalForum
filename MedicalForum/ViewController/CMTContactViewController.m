//
//  CMTContactViewController.m
//  MedicalForum
//
//  Created by guoyuanchao on 16/10/31.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import "CMTContactViewController.h"
#import "CMTWithoutPermissionViewController.h"
@interface CMTContactViewController ()<UIActionSheetDelegate>
@property(nonatomic,strong)UIImageView *imageview;
@end

@implementation CMTContactViewController
-(UIImageView*)imageview{
    if (_imageview==nil) {
        _imageview=[[UIImageView alloc]initWithFrame:CGRectMake(0, CMTNavigationBarBottomGuide, SCREEN_WIDTH, SCREEN_HEIGHT-CMTNavigationBarBottomGuide)];
        [_imageview setImageURL:CMTAPPCONFIG.readCodeObject.touchme.imgUrl placeholderImage:IMAGE(@"Placeholderdefault")contentSize:CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT-CMTNavigationBarBottomGuide)];
        _imageview.clipsToBounds=YES;
        _imageview.contentMode=UIViewContentModeScaleAspectFill;
        _imageview.userInteractionEnabled=YES;
        UITapGestureRecognizer *longtap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(longtap:)];
        [_imageview addGestureRecognizer:longtap];
        
    }
    return _imageview;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleText=@"联系我们";
    [self setContentState:CMTContentStateNormal];
    [self.contentBaseView addSubview:self.imageview];
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
            [library writeImageToSavedPhotosAlbum:self.imageview.image.CGImage orientation:(ALAssetOrientation)self.imageview.image.imageOrientation completionBlock:^(NSURL *asSetUrl,NSError *error){
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
        [library writeImageToSavedPhotosAlbum:self.imageview.image.CGImage orientation:(ALAssetOrientation)self.imageview.image.imageOrientation completionBlock:^(NSURL *asSetUrl,NSError *error){
            @strongify(self);
            if (error) {
                [self toastAnimation:error.userInfo[NSLocalizedFailureReasonErrorKey]];
            }else{
                [self toastAnimation:@"保存成功"];
            }
        }];
    }

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end
