//
//  CMTSearchSeriesCoursesViewController.m
//  MedicalForum
//
//  Created by zhaohuan on 16/10/31.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import "CMTSearchSeriesCoursesViewController.h"
#import "CMTSeriousListViewCell.h"
#import "CMTSeriesDetailsViewController.h"
#import "CMTMySubcribeCell.h"


@interface CMTSearchSeriesCoursesViewController ()<UITableViewDataSource,UITableViewDelegate>


@end

@implementation CMTSearchSeriesCoursesViewController

- (NSMutableArray *)seriesArr{
    if (!_seriesArr) {
        _seriesArr = [NSMutableArray array];
    }
    return _seriesArr;
}

- (void)initTableView {
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0,SCREEN_WIDTH, SCREEN_HEIGHT - 107) style:UITableViewStylePlain];
    _tableView.delegate       = self;
    _tableView.dataSource     = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tableView registerClass:[CMTMySubcribeCell class] forCellReuseIdentifier:@"CMTSeriousListViewCell"];
    
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

    [self CMTmoreVideoInfIniteRefresh];
}

#pragma mark 上拉翻页
-(void)CMTmoreVideoInfIniteRefresh{
    @weakify(self);
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        @strongify(self);
        if (self.seriesArr.count<30) {
            [self.parentVC toastAnimation:@"没有更多课程"];
            [self.tableView.infiniteScrollingView stopAnimating];
            return ;
        }
        CMTSeriesDetails *seriesDetail = [[CMTSeriesDetails alloc]init];
        seriesDetail.pageOffset = @"0";
        if (self.seriesArr.count > 0) {
            seriesDetail = [self.seriesArr lastObject];
        }
        NSDictionary *param = @{
                                @"userId":CMTUSERINFO.userId?:@"0",
                                @"pageOffset":seriesDetail.pageOffset,
                                @"pageSize":@"30",
                                @"type":@"3",
                                @"keyword":self.keyWord?:@"",
                                };
        @weakify(self);
        [[[CMTCLIENT CMTSearchColledge:param] deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^( CMTPlayAndRecordList* searchList) {
            @strongify(self);
            NSMutableArray *arr = [searchList.serieses mutableCopy];
            if (arr.count == 0) {
                [self.parentVC toastAnimation:@"没有更多课程"];
            }else{
                [self.seriesArr addObjectsFromArray:arr];
                [self.tableView reloadData];
            }
            [self.tableView.infiniteScrollingView stopAnimating];
            
        } error:^(NSError *error) {
            @strongify(self);
            if (CMTAPPCONFIG.reachability.integerValue==0||([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus==AFNetworkReachabilityStatusNotReachable)||(error.code>=-1009&&error.code<=-1001)) {
                @strongify(self);
                [self.parentVC toastAnimation:@"你的网络不给力"];
                
            }else{
                @strongify(self);
                [self.parentVC toastAnimation:[error.userInfo objectForKey:@"errmsg"]];
            }
            [self.tableView.infiniteScrollingView stopAnimating];
            
            
            
        }];
        
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.seriesArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    
    CMTMySubcribeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CMTSeriousListViewCell"];
    if (cell == nil) {
        cell = [[CMTMySubcribeCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CMTSeriousListViewCell"];
    }
    [cell reloadCellWithData: self.seriesArr[indexPath.row]];
    
    //标题搜索关键字高亮
    NSRange range = [cell.titleLabel.text rangeOfString:self.keyWord];
    NSMutableAttributedString *pStr = [[NSMutableAttributedString alloc]initWithString:cell.titleLabel.text];
    [pStr addAttribute:NSForegroundColorAttributeName value:COLOR(c_32c7c2) range:range];
    cell.titleLabel.attributedText= pStr;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
     return 202/3;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CMTSeriesDetailsViewController *det=[[CMTSeriesDetailsViewController alloc]initWithParam:[self.seriesArr[indexPath.row] copy]];
    
    [self.parentVC.navigationController pushViewController:det animated:YES];
}


@end
