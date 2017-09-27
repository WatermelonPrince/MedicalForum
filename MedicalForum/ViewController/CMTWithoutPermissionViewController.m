//
//  CMTWithoutPermissionViewController.m
//  MedicalForum
//
//  Created by guoyuanchao on 16/3/22.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import "CMTWithoutPermissionViewController.h"

@interface CMTWithoutPermissionViewController ()
@property(nonatomic,strong)UIImageView *permissionImageView;
@property(nonatomic,strong)UIBarButtonItem *rightBar;
@property(nonatomic,strong)NSString *type;
@end

@implementation CMTWithoutPermissionViewController
-(UIBarButtonItem*)rightBar{
    if(_rightBar==nil){
        UIButton *button=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 45, 30)];
        [button setTitle:@"取消" forState:UIControlStateNormal];
         button.titleLabel.font=[UIFont systemFontOfSize:18];
        [  button setTitleColor:ColorWithHexStringIndex(c_4acbb5) forState:UIControlStateNormal];
        [button addTarget:self action:@selector(goback) forControlEvents:UIControlEventTouchUpInside];
        _rightBar=[[UIBarButtonItem alloc]initWithCustomView:button];
        
    }
    return _rightBar;
}
-(void)goback{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(instancetype)initWithType:(NSString*)type{
   self= [super init];
    if (self) {
        self.type=type;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.rac_willDeallocSignal subscribeCompleted:^{
        CMTLog(@"___CMTWithoutPermissionViewController");
    }];
    
    
    self.permissionImageView=[[UIImageView alloc]initWithFrame:CGRectMake(0,CMTNavigationBarBottomGuide, SCREEN_WIDTH, SCREEN_HEIGHT-CMTNavigationBarBottomGuide)];
    self.permissionImageView.image=IMAGE(@"unPermissionCamer");
    if (self.type.integerValue==1) {
        self.permissionImageView.image=IMAGE(@"unPermissionPhotoalbum");
    }
    [self.contentBaseView addSubview:self.permissionImageView];
    self.navigationItem.rightBarButtonItem = self.rightBar;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
