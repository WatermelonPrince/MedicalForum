//
//  CMTSetLiveTagViewController.m
//  MedicalForum
//
//  Created by guoyuanchao on 15/8/31.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTSetLiveTagViewController.h"

@interface CMTSetLiveTagViewController ()
@property(nonatomic,strong)UITableView *LiveTagTableView;
@property(nonatomic,strong)NSArray *LiveTagArray;
@property(nonatomic,strong)CMTLiveTag *selectedLivetag;
@property(nonatomic,strong)NSString *liveID;


@end

@implementation CMTSetLiveTagViewController
-(UITableView*)LiveTagTableView{
    if (_LiveTagTableView==nil) {
        _LiveTagTableView=[[UITableView alloc]initWithFrame:CGRectMake(0, CMTNavigationBarBottomGuide,SCREEN_WIDTH, SCREEN_HEIGHT-CMTNavigationBarBottomGuide)];
        _LiveTagTableView.delegate=self;
        _LiveTagTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
        _LiveTagTableView.backgroundColor=COLOR(c_efeff4);
        _LiveTagTableView.dataSource=self;
    }
    return _LiveTagTableView;
}
-(instancetype)initWithLiveID:(NSString*)liveID{
    self=[super init];
    if (self) {
        self.liveID=liveID;
        self.selectedLivetag=CMTAPPCONFIG.addLivemessageData.livetag;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.rac_willDeallocSignal subscribeCompleted:^{
        CMTLog(@"setLive willDeallocSignal");
    }];

    self.titleText=@"直播标签";
    [self.contentBaseView addSubview:self.LiveTagTableView];
    
      //跳立方
    [self setContentState:CMTContentStateLoading];
    [self CMTgetLiveTagList];
    
}
-(void)CMTgetLiveTagList{
    NSDictionary *pic=@{@"liveBroadcastId":self.liveID?:@"0"};
    @weakify(self);
    [[[CMTCLIENT getLiveTagList:pic]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(NSArray *array){
        @strongify(self);
        self.LiveTagArray=[array mutableCopy];
        if([self.LiveTagArray count]>0){
            [self.LiveTagTableView reloadData];
            [self setContentState:CMTContentStateNormal];
        }else{
            [self setContentState:CMTContentStateEmpty];

        }
        [self stopAnimation];
        [self setContentState:CMTContentStateNormal];
    } error:^(NSError *error) {
        @strongify(self);
        CMTLog(@"网络请求错误%@",error);
        [self setContentState:CMTContentStateReload];
        [self stopAnimation];
        
    }];

}
#pragma  UItableview dataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.LiveTagArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"tagCell"];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tagCell"];
        cell.backgroundColor=COLOR(c_efeff4);
    }
    for (UIView *view in [cell.contentView subviews]) {
        [view removeFromSuperview];
    }
    
    CMTLiveTag *livetag=[self.LiveTagArray objectAtIndex:indexPath.row];
    cell.backgroundColor=COLOR(c_ffffff);
    UILabel *lable=[[UILabel alloc]initWithFrame:CGRectMake(10, 0,tableView.width-60-(RATIO - 1.0)*(CGFloat)10, 60)];
    lable.text=livetag.name;
    lable.font=[UIFont systemFontOfSize:16];
    [cell.contentView addSubview:lable];
    
    
    UIImageView *imageView=[[UIImageView alloc]initWithFrame:CGRectMake(tableView.width-50+(RATIO - 1.0)*(CGFloat)10, 15, 30, 30)];
    imageView.tag=100;
    if ([self.selectedLivetag.liveBroadcastTagId isEqualToString:livetag.liveBroadcastTagId]) {
        imageView.image=IMAGE(@"selectTag");
    }
    [cell.contentView addSubview:imageView];
    
    
    UIView *lineview=[[UIView alloc]initWithFrame:CGRectMake(0, 59, SCREEN_WIDTH, 1)];
    lineview.backgroundColor=[UIColor colorWithHexString:@"E9E9ED"];
    [cell.contentView addSubview:lineview];
    
    
    
    
    return cell;
}
#pragma  UItableview delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
        CMTLiveTag *livetage=[self.LiveTagArray objectAtIndex:indexPath.row];
    if ([self.selectedLivetag.liveBroadcastTagId isEqualToString:livetage.liveBroadcastTagId]) {
        livetage=nil;
    }
    CMTAPPCONFIG.addLivemessageData.liveBroadcastMessage.liveBroadcastTag=livetage;
    self.updatetitle(livetage);
    CMTAPPCONFIG.addLivemessageData.livetag=livetage;
    [self.navigationController popViewControllerAnimated:YES];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
