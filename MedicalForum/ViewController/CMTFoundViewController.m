//
//  CMTFoundViewController.m
//  MedicalForum
//
//  Created by guoyuanchao on 15/9/1.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTFoundViewController.h"
#import "CMTBadge.h"
#import "CMTGuideViewController.h"
#import "CMTActivitiesViewController.h"
#import "CMTUpgradeViewController.h"
#import "CMTDigitalNewspaperViewController.h"
#import "CMTWebBrowserViewController.h"

@interface CMTFoundViewController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
@property(nonatomic,strong)UITableView *foundtableView;
@property (nonatomic, strong) CMTTabBar *bottomTabBar; //底部导航条按钮
@property(nonatomic,strong)NSArray *dataArray;
@property (nonatomic,copy)NSString *isShow;//调研是否显示
@property (nonatomic, copy)NSString *surverUrl;//调研url
@end

@implementation CMTFoundViewController
//tab标签按钮
- (CMTTabBar *)bottomTabBar {
    if (_bottomTabBar == nil) {
        _bottomTabBar = [[CMTTabBar alloc] init];
        [_bottomTabBar fillinContainer:self.tabBarContainer WithTop:0.0 Left:0.0 Bottom:0.0 Right:0.0];
        _bottomTabBar.backgroundColor = COLOR(c_clear);
        self.tabBarContainer.hidden = NO;
    }
    
    return _bottomTabBar;
}

-(UITableView*)foundtableView{
    if (_foundtableView==nil) {
        _foundtableView=[[UITableView alloc]initWithFrame:CGRectMake(0, CMTNavigationBarBottomGuide, SCREEN_WIDTH,SCREEN_HEIGHT-CMTNavigationBarBottomGuide-CMTTabBarHeight)];
        _foundtableView.backgroundColor =COLOR(c_efeff4);
        _foundtableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _foundtableView.dataSource = self;
        _foundtableView.delegate = self;
        _foundtableView.scrollEnabled=NO;
        
    }
    return _foundtableView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
     self.titleText=@"发现";
    self.bottomTabBar.selectedIndex=3;
    self.dataArray=@[@"指南",@"活动",@"数字报"];
    [self.contentBaseView addSubview:self.foundtableView];
    [self.contentBaseView bringSubviewToFront:self.bottomTabBar];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSDictionary *params = @{
                             @"userId":CMTUSERINFO.userId?:@"0"
                             };
    //115调研功能
    [[[CMTCLIENT GetSurvey:params] deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(CMTSurvey *result){
        if (result) {
            self.surverUrl = result.link;
            self.isShow = result.isShow;
        }
        [self.foundtableView reloadData];
        
    }error:^(NSError *error) {
       self.isShow = @"0";
        [self.foundtableView reloadData];
    }];
   
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
        return 2;
   }
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        if (self.isShow.integerValue == 1) {
            return 3;
        }
        return 2;
    }
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=nil;
    cell=[tableView dequeueReusableCellWithIdentifier:@"foundcell"];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"foundcell"];
        cell.backgroundColor=COLOR(c_ffffff);
    }
    cell.textLabel.font = FONT(16);
    cell.textLabel.textColor = ColorWithHexStringIndex(c_000000);
    if(indexPath.section == 0){
        if (indexPath.row == 0) {
            cell.imageView.image=IMAGE(@"guideimage");
            cell.textLabel.text= @"指南";
            CMTBadge *bage=[[CMTBadge alloc]init];
            bage.frame=CGRectMake(0, 16, kCMTBadgeWidth, kCMTBadgeWidth);
            bage.backgroundColor=[UIColor redColor];
            bage.text=CMTAPPCONFIG.GuideUnreadNumber;
            bage.hidden=CMTAPPCONFIG.GuideUnreadNumber.integerValue==0;
            cell.accessoryView=bage;
            UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 50 - 0.5, SCREEN_WIDTH, 0.5)];
            lineView.backgroundColor = [UIColor colorWithHexString:@"#ebebec"];
            [cell.contentView addSubview:lineView];
        }else if (indexPath.row == 1){
            cell.imageView.image=IMAGE(@"activityImage");
            cell.textLabel.text= @"活动";
            UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 50 - 0.5, SCREEN_WIDTH, 0.5)];
            lineView.backgroundColor = [UIColor colorWithHexString:@"#ebebec"];
            [cell.contentView addSubview:lineView];
            

        }else if (indexPath.row == 2){
            UITableViewCell *cell1 = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"防止重用,所以新建"];
            cell1.imageView.image = IMAGE(@"surveyImage");
            cell1.textLabel.text = @"有偿调研";
            cell1.textLabel.font = FONT(16);
            cell1.textLabel.textColor = ColorWithHexStringIndex(c_000000);
            return cell1;
            
        }
       
        
    }else if(indexPath.section==1){
        cell.imageView.image=IMAGE(@"digitalNews");
        cell.textLabel.text= @"中国医学论坛报";
    }
    
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section==0) {
        if (indexPath.row == 0) {
            [MobClick event:@"B_Guideline_Faxian"];
            CMTGuideViewController *guide=[[CMTGuideViewController alloc]init];
            [self.navigationController pushViewController:guide animated:YES];
        }else if (indexPath.row == 1){
            [MobClick event:@"B_activity_Faxian"];
            CMTActivitiesViewController *ActivitiesViewController=[[CMTActivitiesViewController alloc]init];
            [self.navigationController pushViewController:ActivitiesViewController animated:YES];
        }else if (indexPath.row == 2){
            [MobClick event:@"B_FaXian_Survey"];
            CMTWebBrowserViewController *surveyWeb = [[CMTWebBrowserViewController alloc]initWithURL:self.surverUrl];
            [self.navigationController pushViewController:surveyWeb animated:YES];
        }
        
    }else if(indexPath.section == 1){
        [MobClick event:@"B_Paper_Faxian"]; 
        CMTDigitalNewspaperViewController *Digital=[[CMTDigitalNewspaperViewController alloc]init];
        [self.navigationController pushViewController:Digital animated:YES];
        

    }
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex==1){
        CMTUpgradeViewController *upgrade=[[CMTUpgradeViewController alloc]init];
        upgrade.lastVC = @"CMTReadCodeBlind";
        [self.navigationController pushViewController:upgrade animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
