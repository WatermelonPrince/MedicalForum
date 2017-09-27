//
//  CMTGroupCardViewController.m
//  MedicalForum
//
//  Created by guoyuanchao on 16/3/16.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import "CMTGroupCardViewController.h"
#import "CMTGroupInfoViewController.h"
#import "CmtModifyGroupViewController.h"

@interface CMTGroupCardViewController ()
@property(nonatomic,strong)CMTGroup *mygroup;
@property(nonatomic,strong)UIImageView *groupimageView;
@property(nonatomic,strong)UILabel *grouptitellable;
@property(nonatomic,strong)UILabel *groupdesclable;
@property(nonatomic,strong)UIImageView *grouptypeImage;
@property(nonatomic,strong)UIButton *logoutbutton;
@property (nonatomic, strong)UIBarButtonItem *NavRightItem;//修改小组按钮
@property (nonatomic, strong)NSArray *rightItems;//导航items数组

@end

@implementation CMTGroupCardViewController
-(instancetype)initWithGroup:(CMTGroup*)group{
    self=[super init];
    if (self) {
        self.mygroup=group;
    }
    return self;
    
}
-(UIBarButtonItem*)NavRightItem{
    if (_NavRightItem==nil) {
         UIButton *creatbutton=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 45, 30)];
        [ creatbutton setTitle:@"修改" forState:UIControlStateNormal];
       creatbutton.titleLabel.font=[UIFont boldSystemFontOfSize:18];
        [ creatbutton setTitleColor:ColorWithHexStringIndex(c_4acbb5) forState:UIControlStateNormal];
        [creatbutton addTarget:self action:@selector(ModifyGroupAction)  forControlEvents:UIControlEventTouchUpInside];
        _NavRightItem=[[UIBarButtonItem alloc]initWithCustomView:creatbutton];
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
-(void)ModifyGroupAction{
     @weakify(self);
    CmtModifyGroupViewController *modify=[[CmtModifyGroupViewController alloc]initWithGroup:self.mygroup];
    modify.ModifyGroupSucess=^(CMTGroup *group){
        @strongify(self);
        self.mygroup.groupDesc=group.groupDesc;
        self.mygroup.groupLogo=group.groupLogo;
        [self.groupimageView setImageURL:self.mygroup.groupLogo.picFilepath placeholderImage:IMAGE(@"placeholder_list_loading") contentSize:CGSizeMake(140*RATIO, 140*RATIO)];
        
        CGFloat oneWordheight= ceilf([CMTGetStringWith_Height getTextheight:@"你好" fontsize:18 width:SCREEN_WIDTH-80]);
        CGFloat height= ceilf([CMTGetStringWith_Height getTextheight:self.mygroup.groupDesc fontsize:18 width:SCREEN_WIDTH-80]);
        height=self.grouptitellable.bottom+10+height>SCREEN_HEIGHT-170-CMTNavigationBarBottomGuide?SCREEN_HEIGHT-170-self.grouptitellable.bottom:height;
         self.groupdesclable.frame=CGRectMake(self.grouptitellable.left, self.grouptitellable.bottom+10,self.grouptitellable.width, height);
        if (height>oneWordheight) {
            self.groupdesclable.textAlignment=NSTextAlignmentLeft;
        }else{
            self.groupdesclable.textAlignment=NSTextAlignmentCenter;
            
        }

         self.groupdesclable.text=self.mygroup.groupDesc;
        if (self.ModifyGroupSucess!=nil) {
            self.ModifyGroupSucess(self.mygroup);
        }

    };
    [self.navigationController pushViewController:modify animated:YES];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.rac_willDeallocSignal subscribeCompleted:^{
        CMTLog(@"CMTGroupCardViewController  willDeallocSignal");
    }];
    self.titleText=@"小组名片";
    
    [self drawView];
    if (self.mygroup.memberGrade.integerValue==0) {
         self.navigationItem.rightBarButtonItems=self.rightItems;
    }
   
}
//绘制视图
-(void)drawView{
    
    CGFloat oneWordheight= ceilf([CMTGetStringWith_Height getTextheight:@"你好" fontsize:18 width:SCREEN_WIDTH-80]);

    self.groupimageView=[[UIImageView alloc]initWithFrame:CGRectMake((SCREEN_WIDTH-140*RATIO)/2,CMTNavigationBarBottomGuide+30, 140*RATIO, 140*RATIO)];
    self.groupimageView.clipsToBounds=YES;
    self.groupimageView.contentMode= UIViewContentModeScaleAspectFill;
    [self.groupimageView setImageURL:self.mygroup.groupLogo.picFilepath placeholderImage:IMAGE(@"placeholder_list_loading") contentSize:CGSizeMake(140*RATIO, 140*RATIO)];
    [self.contentBaseView addSubview:self.groupimageView];

    self.grouptypeImage=[[UIImageView alloc]initWithFrame:CGRectMake(self.groupimageView.width-20, self.groupimageView.height-20, 20, 20)];
    self.grouptypeImage.image=IMAGE(@"unlockGroup");
    self.grouptypeImage.hidden=self.mygroup.groupType.integerValue==0;
    [self.groupimageView addSubview:self.grouptypeImage];
    [self.contentBaseView addSubview:self.groupimageView];

    CGFloat nameheight= ceilf([CMTGetStringWith_Height getTextheight:self.mygroup.groupName fontsize:18 width:SCREEN_WIDTH-80]);
    self.grouptitellable=[[UILabel alloc]initWithFrame:CGRectMake(40, self.groupimageView.bottom+10, SCREEN_WIDTH-80, nameheight)];
    self.grouptitellable.text=self.mygroup.groupName;
    self.grouptitellable.font=[UIFont boldSystemFontOfSize:18];
    self.grouptitellable.textColor=[UIColor blackColor];
    self.grouptitellable.numberOfLines=0;
    [self.contentBaseView addSubview:self.grouptitellable];
    
    if (nameheight>oneWordheight) {
        self.grouptitellable.textAlignment=NSTextAlignmentLeft;
    }else{
        self.grouptitellable.textAlignment=NSTextAlignmentCenter;
        
    }

    
    CGFloat height= ceilf([CMTGetStringWith_Height getTextheight:self.mygroup.groupDesc fontsize:18 width:SCREEN_WIDTH-80]);
    height=self.grouptitellable.bottom+10+height>SCREEN_HEIGHT-170-CMTNavigationBarBottomGuide?SCREEN_HEIGHT-170-self.grouptitellable.bottom:height;
    self.groupdesclable=[[UILabel alloc]initWithFrame:CGRectMake(self.grouptitellable.left, self.grouptitellable.bottom+10,self.grouptitellable.width, height)];
    self.groupdesclable.text=self.mygroup.groupDesc;
    self.groupdesclable.font=[UIFont boldSystemFontOfSize:18];
    self.groupdesclable.textColor=ColorWithHexStringIndex(c_bfbfbf);
    self.groupdesclable.numberOfLines=0;
    self.groupdesclable.lineBreakMode=NSLineBreakByWordWrapping;
    [self.contentBaseView addSubview:self.groupdesclable];
    if (height>oneWordheight) {
         self.groupdesclable.textAlignment=NSTextAlignmentLeft;
    }else{
        self.groupdesclable.textAlignment=NSTextAlignmentCenter;

    }
    
    self.logoutbutton=[[UIButton alloc]initWithFrame:CGRectMake((SCREEN_WIDTH-120)/2,SCREEN_WIDTH==320?self.groupdesclable.bottom+50:SCREEN_HEIGHT-170, 120, 50)];
    [self.logoutbutton setTitle:@"退出小组" forState:UIControlStateNormal];
    [self.logoutbutton.titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
    [self.logoutbutton setTitleColor:ColorWithHexStringIndex(c_838389) forState:UIControlStateNormal];
    [self.contentBaseView addSubview:self.logoutbutton];
    [self.logoutbutton addTarget:self action:@selector(logoutGroupAction) forControlEvents:UIControlEventTouchUpInside];
    if (self.mygroup.memberGrade.integerValue==0||self.mygroup.isJoinIn.integerValue==0) {
        self.logoutbutton.hidden=YES;
    }
}
-(void)logoutGroupAction{
    @weakify(self);
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"确定退出小组？" message:nil delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert show];
    [[alert.rac_buttonClickedSignal deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(NSNumber *x) {
         @strongify(self);
        if (x.integerValue==1) {
            [self logoutGroup];
        }
        
    } error:^(NSError *error) {
        
        
    } completed:^{
        
    }];
}
//退出小组
-(void)logoutGroup{
      @weakify(self);
        NSDictionary *params=@{
                               @"userId": CMTUSERINFO.userId ?: @"0",
                               @"groupId":self.mygroup.groupId?:@"",
                               @"flag":self.mygroup.isJoinIn,
                               };
        [[[CMTCLIENT addTeam:params]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(CMTGroup * group) {
            //判断是否刷新我的小组页面
            @strongify(self);
              self.mygroup.isJoinIn=group.isJoinIn;
            self.mygroup.memberGrade=group.memberGrade;
            [self toastAnimation:@"已退出小组"];
            
            @weakify(self);
            [[RACScheduler mainThreadScheduler]afterDelay:0.5 schedule:^{
                @strongify(self);
                for(UIViewController *Controller in self.navigationController.viewControllers){
                    if ([Controller isKindOfClass:[CMTGroupInfoViewController class]]) {
                        [((CMTGroupInfoViewController *)Controller) logoutSucess:group];
                        [self.navigationController popToViewController:Controller animated:YES];
                    }
                }
            }];

        } error:^(NSError *error) {
             @strongify(self);
            if ([CMTAPPCONFIG.reachability isEqual:@"0"]) {
                [self toastAnimation:@"你的网络不给力"];
            }else{
                 @strongify(self);
                if (error.code!=1001) {
                     [self toastAnimation:[error.userInfo objectForKey:@"errmsg"]];
                }else{
                    [self toastAnimation:@"你无权限对小组进行操作,将自动返回论吧页面"];
                    [[RACScheduler mainThreadScheduler] afterDelay:2.0 schedule:^{
                    CMTAPPCONFIG.refreshmodel=@"1";
                    [self.navigationController popToRootViewControllerAnimated:YES];
                   }];
                }
            }
            
        } completed:^{
            
        }];
        
        
    }
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
