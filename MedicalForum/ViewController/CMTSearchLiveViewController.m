//
//  CMTSearchLiveViewController.m
//  MedicalForum
//
//  Created by zhaohuan on 16/10/31.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import "CMTSearchLiveViewController.h"

#import "LightVideolistCell.h"
#import "TimeCell.h"

@interface CMTSearchLiveViewController ()<UITableViewDelegate, UITableViewDataSource>

@end

@implementation CMTSearchLiveViewController

- (NSMutableArray *)liveArr{
    if (!_liveArr) {
        _liveArr = [NSMutableArray array];
    }
    return _liveArr;
}



- (void)initTableView {
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0,SCREEN_WIDTH, SCREEN_HEIGHT - 107) style:UITableViewStylePlain];
    _tableView.delegate       = self;
    _tableView.dataSource     = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tableView registerClass:[TimeCell class] forCellReuseIdentifier:@"TimeCell"];
   
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
        if (self.liveArr.count<30) {
            [self.parentVC toastAnimation:@"没有更多课程"];
            [self.tableView.infiniteScrollingView stopAnimating];
            return ;
        }
        CMTLivesRecord *Record=[[CMTLivesRecord alloc]init];
        Record.pageOffset=@"0";
        if(self.liveArr.count>0){
            Record=self.liveArr.lastObject;
        }
        NSDictionary *param=@{@"userId":CMTUSERINFO.userId?:@"0",
                              @"pageOffset":Record.pageOffset,
                              @"pageSize":@"30",
                              @"keyword":self.keyWord?:@"0",
                              @"type":@"2",
                              };
        @weakify(self);
        [[[CMTCLIENT CMTSearchColledge:param]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(CMTPlayAndRecordList* searchList) {
            @strongify(self);
            self.currentDate = searchList.sysDate;
            NSArray *arr = [searchList.revideos mutableCopy];
            if (arr.count==0) {
                [self.parentVC toastAnimation:@"没有更多课程"];
            }else{
                [self.liveArr addObjectsFromArray:arr];
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


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.liveArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CMTLivesRecord * model = self.liveArr[indexPath.row];

    TimeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TimeCell"];
    [cell loadData:model indexPath:indexPath currentDate:self.currentDate];
    cell.m_registrationButton.hidden = YES;
    NSRange range = [cell.m_titleLabel.text rangeOfString:self.keyWord];
    //标题搜索关键字高亮
    NSMutableAttributedString *pStr = [[NSMutableAttributedString alloc]initWithString:cell.m_titleLabel.text];
    [pStr addAttribute:NSForegroundColorAttributeName value:COLOR(c_32c7c2) range:range];
    cell.m_titleLabel.attributedText= pStr;
    
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return SCREEN_WIDTH * 9/16 + 200/3;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if([self getNetworkReachabilityStatus].integerValue==0){
        
        [self.parentVC toastAnimation:@"无法连接到网络，请检查网络设置"];
        return;
    }else if ([self getNetworkReachabilityStatus].integerValue==1) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"当前非wifi环境下\n是否继续观看课程" message:nil delegate:nil
                                           cancelButtonTitle:@"取消" otherButtonTitles:@"继续观看", nil];
        @weakify(self)
        [[[alert rac_buttonClickedSignal]deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSNumber *index) {
            @strongify(self);
            if ([index integerValue] == 1) {
                CMTLivesRecord *liveLivesRecord=self.liveArr[indexPath.row];
                LiveVideoPlayViewController *live=[[LiveVideoPlayViewController alloc]initWithParam:[liveLivesRecord copy]];
                live.EnterType = 1;
                live.networkReachabilityStatus =[self.parentVC getNetworkReachabilityStatus];
                @weakify(self);
                live.updateLiveList=^(CMTLivesRecord* liveRec){
                    @strongify(self);
                        liveLivesRecord.isJoin=liveRec.isJoin;
                        liveLivesRecord.sysDate=liveRec.sysDate;
                        liveLivesRecord.startDate=liveRec.startDate;
                        liveLivesRecord.endDate=liveRec.endDate;
                        self.currentDate=liveRec.sysDate;
                        [tableView reloadData];
                };

                
                
                [self.parentVC.navigationController pushViewController:live animated:YES];
                
            }
        }];
        [alert show];
        
    }else{
        CMTLivesRecord *liveLivesRecord=self.liveArr[indexPath.row];
        LiveVideoPlayViewController *live=[[LiveVideoPlayViewController alloc]initWithParam:[liveLivesRecord copy]];
        live.EnterType = 1;
        live.networkReachabilityStatus =[self.parentVC getNetworkReachabilityStatus];
        @weakify(self);
        live.updateLiveList=^(CMTLivesRecord* liveRec){
            @strongify(self);
            
            liveLivesRecord.isJoin=liveRec.isJoin;
            liveLivesRecord.sysDate=liveRec.sysDate;
            liveLivesRecord.startDate=liveRec.startDate;
            liveLivesRecord.endDate=liveRec.endDate;
            self.currentDate=liveRec.sysDate;
            [tableView reloadData];
        };
        [self.parentVC.navigationController pushViewController:live animated:YES];
        
    }
    
}

@end
