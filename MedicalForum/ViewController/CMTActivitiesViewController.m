//
//  CMTActivitiesViewController.m
//  MedicalForum
//
//  Created by jiahongfei on 15/8/21.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTActivitiesViewController.h"
#import "CMTWebBrowserViewController.h"

int const margin = 10;

@interface CMTActivitiesViewController ()<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic, strong)UITableView *tableView;
@property(nonatomic, strong)NSMutableArray *dataArray;
@property(nonatomic, assign)int imageHeight;

@end

@implementation CMTActivitiesViewController

-(UITableView*)tableView{
    if (_tableView==nil) {
        _tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, CMTNavigationBarBottomGuide, SCREEN_WIDTH, SCREEN_HEIGHT-CMTNavigationBarBottomGuide)];
        _tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
        _tableView.delegate=self;
//        _tableView.backgroundColor=COLOR(c_efeff4);
        _tableView.dataSource=self;
    }
    return _tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleText = @"活动";
    
    _dataArray = [[NSMutableArray alloc] init];
    
    // 焦点图比例16:9
    _imageHeight = (int) (9 * SCREEN_WIDTH / 16);
    
    [self.contentBaseView addSubview:self.tableView];
    
    [self getActivities];
    
}

#pragma tableView  dataSource代理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString * const CMTCellTeamCellIdentifier = @"CMTCellListCellTeam";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:CMTCellTeamCellIdentifier];
    UIImageView *imageView = nil;
    if(cell==nil){
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:UITableViewCellStyleDefault];
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(margin, margin, SCREEN_WIDTH-2*margin, _imageHeight)];
        imageView.tag = 100;
        [cell.contentView addSubview:imageView];
    }else{
        imageView = (UIImageView *)[cell.contentView viewWithTag:100];
    }
    
    CMTPicture *picture = ((CMTActivities *)[_dataArray objectAtIndex:indexPath.row]).picture;
    
    [imageView setImageURL:picture.picFilepath placeholderImage:IMAGE(@"focus_default") contentSize:CGSizeMake(SCREEN_WIDTH, _imageHeight) ];
    return cell;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
//    return cell.frame.size.height;
    
    return _imageHeight+margin;
}

//点击查看通知文章详情
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CMTActivities *activities = ((CMTActivities *)[_dataArray objectAtIndex:indexPath.row]);
    
    
    CMTWebBrowserViewController *webviewControll = [[CMTWebBrowserViewController alloc] initWithActivities:activities];
    [self.navigationController pushViewController:webviewControll animated:YES];
}

-(void)getActivities{
        NSDictionary *params=@{@"userId": CMTUSERINFO.userId ?:@"0"};
        @weakify(self);
        [[[CMTCLIENT getActivities:params]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(NSArray *array) {
            @strongify(self);
            if([array count] > 0){
                _dataArray=[array mutableCopy];
                [self.tableView reloadData];
                  [self setContentState:CMTContentStateNormal];
                [self stopAnimation];
            }else{
                self.contentEmptyView.contentEmptyPrompt=@"精彩活动正在策划中,敬请耐心等待";
                 [self setContentState:CMTContentStateEmpty];
            }
        }error:^(NSError *error) {
            @strongify(self);
            [self setContentState:CMTContentStateReload];
            [self stopAnimation];
        }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
