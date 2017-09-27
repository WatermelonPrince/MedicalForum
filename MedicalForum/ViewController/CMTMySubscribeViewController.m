//
//  CMTMySubscribeViewController.m
//  MedicalForum
//
//  Created by zhaohuan on 16/9/19.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import "CMTMySubscribeViewController.h"
#import "CMTMySubcribeCell.h"
#import "CMTSeriesDetailsViewController.h"

@interface CMTMySubscribeViewController ()<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong)UITableView *dataTableView;
@property (nonatomic, strong)NSMutableArray *dataArr;


@end

@implementation CMTMySubscribeViewController

- (NSMutableArray *)dataArr{
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
}

-(UITableView*)dataTableView{
    if (_dataTableView==nil) {
        _dataTableView=[[UITableView alloc]initWithFrame:CGRectMake(0,CMTNavigationBarBottomGuide, SCREEN_WIDTH, SCREEN_HEIGHT-CMTNavigationBarBottomGuide) style:UITableViewStylePlain];
        _dataTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
        _dataTableView.dataSource=self;
        _dataTableView.delegate=self;
        _dataTableView.placeholderView=[self tableViewPlaceholderView:_dataTableView text:[self PlaceholderText]];
        [_dataTableView setPlaceholderViewOffset:[NSValue valueWithCGSize:CGSizeMake(0,-_dataTableView.height/2+50)]];
        _dataTableView.backgroundColor=COLOR(c_ffffff);
        [self.contentBaseView addSubview:_dataTableView];
    }
    return _dataTableView;
}
-(NSString*)PlaceholderText{
    
    return @"没有订阅课程存在";
}

- (void)viewDidLoad{
    [super viewDidLoad];
    [self.contentBaseView addSubview:self.dataTableView];
    [[RACObserve(CMTAPPCONFIG, seriesDtlUnreadNumber)deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(NSNumber * x) {
        self.dataArr = [NSKeyedUnarchiver unarchiveObjectWithFile:[PATH_USERS stringByAppendingPathComponent:@"subscribeSeriesList"]];
        if (self.dataArr.count > 0) {
            for (int i = 0; i < self.dataArr.count ; i++) {
                for (int j = i + 1; j<self.dataArr.count; j++) {
                    CMTSeriesDetails* a = [self.dataArr objectAtIndex:i];
                    CMTSeriesDetails* b = [self.dataArr objectAtIndex:j] ;
                    
                    if (a.opTime.longLongValue<b.opTime.longLongValue) { //从小到大
                        
                        [self.dataArr exchangeObjectAtIndex:i withObjectAtIndex:j];
                    }
                }
            }
        }
        [self.dataTableView reloadData];
    }];
    self.titleText = @"我的订阅";
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.dataArr = [NSKeyedUnarchiver unarchiveObjectWithFile:[PATH_USERS stringByAppendingPathComponent:@"subscribeSeriesList"]];
    //倒序排列
    if (self.dataArr.count > 0) {
        for (int i = 0; i < self.dataArr.count; i++) {
            for (int j = i + 1; j<self.dataArr.count; j++) {
                CMTSeriesDetails* a = [self.dataArr objectAtIndex:i];
                CMTSeriesDetails* b = [self.dataArr objectAtIndex:j] ;
                
                if (a.opTime.longLongValue<b.opTime.longLongValue) { //从小到大
                    
                    [self.dataArr exchangeObjectAtIndex:i withObjectAtIndex:j];
                }
            }
        }
    }
    
    [self.dataTableView reloadData];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CMTSeriesDetails *serDtl = self.dataArr[indexPath.row];
    CMTSeriesDetailsViewController *serDtlVC = [[CMTSeriesDetailsViewController alloc]initWithParam:serDtl];
    @weakify(self);
    [serDtlVC setUpdatevideoList:^(NSString *str) {
        @strongify(self);
        [self.dataArr removeObjectAtIndex:indexPath.row];
        [self.dataTableView reloadData];
    }];
    [self.navigationController pushViewController:serDtlVC animated:YES];

    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CMTMySubcribeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[CMTMySubcribeCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    CMTSeriesDetails *seriesDtl = self.dataArr[indexPath.row];
    [cell reloadCellWithData:seriesDtl];
    return cell;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *sectionView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.dataTableView.width, 25)];
    sectionView.backgroundColor=COLOR(c_f5f5f5);
    UILabel *namelable=[[UILabel alloc]initWithFrame:CGRectMake(10,0, SCREEN_WIDTH,sectionView.height)];
    namelable.font=[UIFont systemFontOfSize:14];
    namelable.textColor = [UIColor colorWithHexString:@"a5a5a6"];
    namelable.text=@"系列课程";
    [sectionView addSubview:namelable];
    return sectionView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 202/3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 25;
}


@end
