//
//  CMTSearchVideoViewController.m
//  MedicalForum
//
//  Created by zhaohuan on 16/10/31.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import "CMTSearchVideoViewController.h"
#import "CMTLightVideoViewController.h"

#import "CMTCourseCell.h"
#import "CMTRecordedViewController.h"

@interface CMTSearchVideoViewController ()<UITableViewDataSource,UITableViewDelegate,CMTVedioCellDelegate>

@end

@implementation CMTSearchVideoViewController

- (NSMutableArray *)videoArr{
    if (!_videoArr) {
        _videoArr = [NSMutableArray array];
    }
    return _videoArr;
}



- (void)initTableView {
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0,SCREEN_WIDTH, SCREEN_HEIGHT - 107) style:UITableViewStylePlain];
    _tableView.delegate       = self;
    _tableView.dataSource     = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
   [_tableView registerClass:[CMTCourseCell class] forCellReuseIdentifier:@"CMTCourseCell"];
    _tableView.placeholderView=[self tableViewPlaceholderView];
    [_tableView setPlaceholderViewOffset:[NSValue valueWithCGSize:CGSizeMake(0,-self.tableView.height/2+50)]];
    [self.contentBaseView addSubview:_tableView];
    
}

- (UIView *)tableViewPlaceholderView {
    UIView *placeholderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0,self.tableView.width, 100.0)];
    placeholderView.backgroundColor = COLOR(c_clear);
    
    UILabel *placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, placeholderView.width, 100.0)];
    placeholderLabel.backgroundColor = COLOR(c_clear);
    placeholderLabel.textColor = COLOR(c_9e9e9e);
    placeholderLabel.font = FONT(17.0);
    placeholderLabel.textAlignment = NSTextAlignmentCenter;
    placeholderLabel.text =@"未找到相关课程，换个关键词试试吧！";
    
    [placeholderView addSubview:placeholderLabel];
    
    
    return placeholderView;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    [self initTableView];
    [self.contentBaseView addSubview:self.tableView];
    [self CMTmoreVideoInfIniteRefresh];
}


#pragma mark 上拉翻页
-(void)CMTmoreVideoInfIniteRefresh{
    @weakify(self);
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        @strongify(self);
        if (self.videoArr.count<30) {
            [self.parentVC toastAnimation:@"没有更多课程"];
            [self.tableView.infiniteScrollingView stopAnimating];
            return ;
        }
        CMTLivesRecord *Record=[[CMTLivesRecord alloc]init];
        Record.pageOffset=@"0";
        if(self.videoArr.count>0){
            Record=self.videoArr.lastObject;
        }
        NSDictionary *param=@{@"userId":CMTUSERINFO.userId?:@"0",
                              @"pageOffset":Record.pageOffset,
                              @"pageSize":@"30",
                              @"keyword":self.keyWord?:@"0",
                              @"type":@"1",
                              };
        @weakify(self);
        [[[CMTCLIENT CMTSearchColledge:param]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(CMTPlayAndRecordList* searchList) {
            @strongify(self);
            NSArray *arr = [searchList.revideos mutableCopy];
            if (arr.count==0) {
                [self.parentVC toastAnimation:@"没有更多课程"];
            }else{
                [self.videoArr addObjectsFromArray:arr];
                [self.tableView reloadData];
            }
            [self.tableView.infiniteScrollingView stopAnimating];
            
        } error:^(NSError *error) {
            @strongify(self);
            if (error.code>=-1009&&error.code<=-1001) {
                @strongify(self);
                [self.parentVC toastAnimation:@"你的网络不给力"];
                
            }else{
                @strongify(self);
                [self.parentVC toastAnimation:[error.userInfo objectForKey:@"errmsg"]];
            }
            [self.tableView.infiniteScrollingView stopAnimating];
            
        } completed:^{
            NSLog(@"完成");
        }];
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CMTLivesRecord *model;
    CMTLivesRecord *model1;
    if (indexPath.row * 2 + 1 <= self.videoArr.count) {
        model = self.videoArr[indexPath.row * 2];
    }
    if (indexPath.row * 2 + 2 <= self.videoArr.count) {
        model1 = self.videoArr[indexPath.row * 2 + 1];
    }
    NSMutableArray *modelarr = [NSMutableArray array];
    if (model!=nil) {
        [modelarr addObject:model];
    }
    if (model1!=nil) {
        [modelarr addObject:model1];
    }
    CMTCourseCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CMTCourseCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    cell.searchKey=self.keyWord;
    [cell reloadCellWithData:modelarr];
    return cell;
    
    
}


#pragma seriousCellDelegate 系列课程cell点击事件回调
- (void)didSelecteVideo:(CMTLivesRecord*)Record{
    if([self getNetworkReachabilityStatus].integerValue==0){
        
        [self.parentVC toastAnimation:@"无法连接到网络，请检查网络设置"];
        return;
    }else{
        if(Record.themeInfo.themeUuid.length>0){
            CMTSeriesDetails *seriesDetails=[[CMTSeriesDetails alloc]init];
            seriesDetails.themeUuid=Record.themeInfo.themeUuid;
            CMTSeriesDetailsViewController *series=[[CMTSeriesDetailsViewController alloc]initWithParam:seriesDetails];
            @weakify(self);
            [series setUpdatevideoList:^(NSString *themUuid) {
                @strongify(self);
                Record.themeInfo.themeUuid = @"";
                [self.tableView reloadData];
            }];
            [self.parentVC.navigationController pushViewController:series animated:YES];
            return;
        }
        if (Record.type.integerValue==1) {
            CMTLightVideoViewController *lightVideoViewController = [[CMTLightVideoViewController alloc]init];
            //  播放网络
            lightVideoViewController.myliveParam = Record;
            
            [self.parentVC.navigationController pushViewController:lightVideoViewController animated:YES];
            
        }else{
            CMTRecordedViewController *recordView=[[CMTRecordedViewController alloc]initWithRecordedParam:[Record copy]];
            
            [self.parentVC.navigationController pushViewController:recordView animated:YES];
            
        }
    }
    
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    CMTLivesRecord *Record=self.videoArr[indexPath.row];
//    if([self getNetworkReachabilityStatus].integerValue==0){
//        
//        [self.parentVC toastAnimation:@"无法连接到网络，请检查网络设置"];
//        return;
//    }else{
//        if (Record.type.integerValue==1) {
//            CMTLightVideoViewController *lightVideoViewController = [[CMTLightVideoViewController alloc]init];
//            //  播放网络
//            lightVideoViewController.myliveParam = Record;
//
//            [self.parentVC.navigationController pushViewController:lightVideoViewController animated:YES];
//            
//        }else{
//            CMTRecordedViewController *recordView=[[CMTRecordedViewController alloc]initWithRecordedParam:[Record copy]];
//
//            [self.parentVC.navigationController pushViewController:recordView animated:YES];
//            
//            
//        }
//    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.videoArr.count == 0) {
        return 0;
    }else{
        return [self tableView:tableView cellForRowAtIndexPath:indexPath].height;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger z = floor(self.videoArr.count/2);
    NSInteger a = self.videoArr.count%2;
    return z + a;
}

@end
