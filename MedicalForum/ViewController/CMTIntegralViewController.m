//
//  CMTIntegralViewController.m
//  MedicalForum
//
//  Created by jiahongfei on 15/7/29.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTIntegralViewController.h"

#define TABLE_FIRST_HEIGHT 220
#define TABLE_HEIGHT 70
@interface CMTIntegralViewController ()<UITableViewDataSource, UITableViewDelegate>

@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic, strong)NSMutableArray *scoreList;
@property(nonatomic, strong)NSMutableDictionary *requestParam;
@property(nonatomic, strong)NSString *firstIncrId;
@property(nonatomic, strong)NSString *lastIncrId;
@property(nonatomic,strong) NSString *scoreCount;
@property(nonatomic, strong)UILabel *emptyLabel;

@end

@implementation CMTIntegralViewController{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _scoreCount = @"0";
    
    _scoreList = [[NSMutableArray alloc] init];
//    incrId 	首条或末条消息的自增ID 	为适应动态数据，此次接口所有涉及翻页的地方均不以偏移量与页码翻页，以条件ID进行翻页， 	long 	默认0可不传，表示从最新消息开始取数据 	N
//    incrIdFlag 	翻页标识 	标识incrId为顶条数据，还是末条数据 	int 	默认0表示顶条，可不传；1 表示incrId为末条数据 	N
//    pageSize 	每页显示数量 	默认30，可不传 	int 		N
    _requestParam = [[NSMutableDictionary alloc]init];
    [_requestParam setValue: CMTUSER.userInfo.userId forKey:@"userId"];
    [_requestParam setValue:@"30" forKey:@"pageSize"];
    [_requestParam setValue:@"0" forKey:@"incrId"];
    [_requestParam setValue:@"0" forKey:@"incrIdFlag"];
    
    @weakify(self);
    
    self.titleText = @"积分";
    self.contentBaseView.backgroundColor = [UIColor colorWithRed:242.0/255 green:242.0/255 blue:242.0/255 alpha:1.0];
    [self.contentBaseView addSubview:self.tableView];
    // 刷新控件
    [self.tableView addPullToRefreshWithActionHandler:^{
        @strongify(self);
        [self.requestParam setValue:self.firstIncrId forKey:@"incrId"];
        [self.requestParam setValue:@"0" forKey:@"incrIdFlag"];
        [self getScoreListParam:self.requestParam refreshStatus:0 first:NO];
        [self getScoreCountParam];
        
    }];
    // 翻页控件
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        @strongify(self);
        [self.requestParam setValue:self.lastIncrId forKey:@"incrId"];
        [self.requestParam setValue:@"1" forKey:@"incrIdFlag"];
        [self getScoreListParam:self.requestParam refreshStatus:1 first:NO];
    }];
    RAC(self.tableView, showsInfiniteScrolling) = [[RACObserve(self.tableView, contentSize) distinctUntilChanged] map:^id(NSValue *contentSize) {
        @strongify(self);
        if (contentSize.CGSizeValue.height + self.tableView.contentInset.top <= self.tableView.height) return @NO; return @YES;
    }];
    
    [self emptyLabel];

    _tableView.hidden = NO;
    _emptyLabel.hidden = YES;
    
    [self getScoreListParam:_requestParam refreshStatus:0 first:YES];

    [self getScoreCountParam];
}

-(UILabel *)emptyLabel{
    if(nil == _emptyLabel){
        _emptyLabel = [[UILabel alloc] init];
        [_emptyLabel fillinContainer:self.contentBaseView WithTop:0 Left:0 Bottom:0 Right:0];
        _emptyLabel.textAlignment = NSTextAlignmentCenter;
        _emptyLabel.text = @"没有积分明细";
        _emptyLabel.textColor = COLOR(c_dddddd);
    }
    return _emptyLabel;
}

///根据参数获取积分列表
///@param refreshStatus 0下拉刷新，1上啦更多
///@param first true第一次进入，false不是第一次进入
-(void)getScoreListParam : (NSDictionary *) param
            refreshStatus: (int) refreshStatus
                    first:(BOOL) first{
    @weakify(self);
    [[[CMTCLIENT getScoreList:param]
      deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSArray *scoreList) {
        @strongify(self);
        if(![scoreList isKindOfClass:[NSArray class]] && (nil == scoreList || 0 == [scoreList count])){
           [self toastAnimation:@"没有更多积分"];
            if (first) {
                _tableView.hidden = YES;
                _emptyLabel.hidden = NO;
            }
        }else{
            if(0 == refreshStatus){
                [self.scoreList insertArray:scoreList atIndex:0];
            }else if (1 == refreshStatus){
                [self.scoreList addObjectsFromArray:scoreList];
            }
            self.lastIncrId = [[self.scoreList lastObject] incrId];
            self.firstIncrId = [[self.scoreList firstObject]incrId];
            
            _tableView.hidden = NO;
            _emptyLabel.hidden = YES;
           
        }
        if(0 == refreshStatus){
            [self.tableView.pullToRefreshView stopAnimating];
        }else if (1 == refreshStatus){
            [self.tableView.infiniteScrollingView stopAnimating];
        }
        [_tableView reloadData];
        
    } error:^(NSError *error) {
        [self handleError:error];
        if(0 == refreshStatus){
            [self.tableView.pullToRefreshView stopAnimating];
        }else if (1 == refreshStatus){
            [self.tableView.infiniteScrollingView stopAnimating];
        }
        [_tableView reloadData];
        if (first) {
            _tableView.hidden = YES;
            _emptyLabel.hidden = NO;
        }
    }];

}

// 文章列表 错误提示
- (void)handleError:(NSError *)error {
    // 网络错误
    if ([error.domain isEqual:NSURLErrorDomain]) {
        
//        self.postListRequestNetError = error;
        [self toastAnimation:@"你的网络不给力"];
    }
    // 服务器返回错误
    else if ([error.domain isEqual:CMTClientServerErrorDomain]) {
        // 业务参数错误
        if ([error.userInfo[CMTClientServerErrorCodeKey] integerValue] > 100) {
            
             [self toastAnimation:error.userInfo[CMTClientServerErrorUserInfoMessageKey]];
        }
        // 系统错误/错误代码格式错误
        else {
            
             [self toastAnimation:error.userInfo[CMTClientServerErrorUserInfoMessageKey]];
        }
    }
    // 解析错误/未知错误
    else {
        [self toastAnimation:error.localizedDescription];
    }
}


-(UITableView *)tableView{
    if(nil == _tableView){
        _tableView = [[UITableView alloc] init];
        [_tableView fillinContainer:self.contentBaseView WithTop:0.0 Left:0 Bottom:0 Right:0];
        _tableView.contentInset = UIEdgeInsetsMake(CMTNavigationBarBottomGuide, 0.0, 0.0, 0.0);
        _tableView.scrollIndicatorInsets = UIEdgeInsetsMake(CMTNavigationBarBottomGuide, 0.0, 0.0, 0.0);
        _tableView.backgroundColor = COLOR(c_fafafa);
//        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.dataSource = self;
        _tableView.delegate = self;
    }
    return _tableView;
}

//------------------table delegate-------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(0 == section){
        return 1;
    }else{
        return [_scoreList count];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    UIView *firstItemView = nil;
    UIImageView *headImageView = nil;
    UILabel *nickNameLabel = nil;
    UILabel *firstIntegralLabel = nil;
    
    UIView *itemView = nil;
    UILabel *itemTitleLabel = nil;
    UILabel *itemRightIntegral = nil;
    UILabel *dateLabel = nil;
    if(nil == cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;//不可点击
        //列表第一条
        firstItemView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, TABLE_FIRST_HEIGHT)];
        firstItemView.tag = 106;
        [cell.contentView addSubview:firstItemView];
        UIView *zheZhaoView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-60, TABLE_FIRST_HEIGHT/2-60, 120, 120)];
        [zheZhaoView setBackgroundColor:[UIColor colorWithHexString:@"#33c7c2"]];
        zheZhaoView.layer.cornerRadius = 60;//设置那个圆角的有多圆
        zheZhaoView.layer.borderWidth = 0;//设置边框的宽度，当然可以不要
        zheZhaoView.layer.borderColor = [[UIColor colorWithHexString:@"#33c7c2"] CGColor];//设置边框的颜色
        zheZhaoView.layer.masksToBounds = YES;
        [firstItemView addSubview:zheZhaoView];
        UILabel *firstJifenView = [[UILabel alloc] initWithFrame:CGRectMake(30, 10, 120-60, 30)];
        firstJifenView.text = @"积分";
        firstJifenView.textColor = [UIColor whiteColor];
        firstJifenView.font = FONT(20);
        firstJifenView.textAlignment = NSTextAlignmentCenter;
        [zheZhaoView addSubview:firstJifenView];
        UIView *firstTopView = [[UIView alloc] initWithFrame:CGRectMake(0, 10, SCREEN_WIDTH, 60)];
        [firstItemView addSubview:firstTopView];
        headImageView = [[UIImageView  alloc] initWithFrame:CGRectMake(10, 0, 60, 60)];
        headImageView.tag = 100;
        headImageView.layer.masksToBounds = YES;
        headImageView.layer.cornerRadius = headImageView.frame.size.height/2;
        [headImageView setContentMode:UIViewContentModeScaleAspectFill];
        [headImageView setClipsToBounds:YES];
        headImageView.image = [UIImage imageNamed:@"comment_defaultPicture"];
        [firstTopView addSubview:headImageView];
        nickNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10+60+10, 60/2-50/2, SCREEN_WIDTH-60-70, 50)];
        nickNameLabel.textColor = COLOR(c_9e9e9e);
        nickNameLabel.text = @"";
        nickNameLabel.tag = 101;
        [firstTopView addSubview:nickNameLabel];
        UIView *firstBottomView = [[UIView alloc]init];
        [firstBottomView fillinContainer:firstItemView WithTop:60+10 Left:10+60+10 Bottom:10 Right:0];
        UIImageView *firstLeftIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        firstLeftIcon.image = IMAGE(@"ic_integral_details_first");
        firstLeftIcon.hidden = YES;
        [firstBottomView addSubview:firstLeftIcon];
        firstIntegralLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 10 + 30, 120-20, 60)];
        firstIntegralLabel.textColor = [UIColor whiteColor];
        firstIntegralLabel.text = @"";
        firstIntegralLabel.tag = 102;
        firstIntegralLabel.font = FONT(40);
        firstIntegralLabel.textAlignment = NSTextAlignmentCenter;
        [zheZhaoView addSubview:firstIntegralLabel];
        
        //item
        itemView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, TABLE_HEIGHT)];
        itemView.tag = 107;
        [cell.contentView addSubview:itemView];
        itemTitleLabel = [[UILabel alloc] init];
        itemTitleLabel.tag = 103;
        itemTitleLabel.textColor = COLOR(c_424242);
        itemTitleLabel.text = @"";
        [itemTitleLabel fillinContainer:itemView WithTop:10 Left:10 Bottom:35 Right:10-40-10];
        itemRightIntegral = [[UILabel alloc] init];
        itemRightIntegral.tag = 104;
        itemRightIntegral.text = @"";
        itemRightIntegral.textAlignment = NSTextAlignmentRight;
        [itemRightIntegral fillinContainer:itemView WithTop:10 Left:SCREEN_WIDTH-10-40 Bottom:35 Right:10];
        dateLabel = [[UILabel alloc]init];
        dateLabel.textColor = COLOR(c_dddddd);
        dateLabel.text = @"";
        dateLabel.tag = 105;
        [dateLabel fillinContainer:itemView WithTop:35 Left:10 Bottom:10 Right:10];
    }else{
        headImageView = (UIImageView *)[cell.contentView viewWithTag:100];
        nickNameLabel = (UILabel *)[cell.contentView viewWithTag:101];
        firstIntegralLabel = (UILabel *)[cell.contentView viewWithTag:102];
        itemTitleLabel = (UILabel *)[cell.contentView viewWithTag:103];
        itemRightIntegral = (UILabel *)[cell.contentView viewWithTag:104];
        dateLabel = (UILabel *)[cell.contentView viewWithTag:105];
        firstItemView = (UIView *)[cell.contentView viewWithTag:106];
        itemView = (UIView *)[cell.contentView viewWithTag:107];
    }
    
    if(0 == indexPath.section){
        firstItemView.hidden = NO;
        itemView.hidden = YES;
        [headImageView setImageURL:CMTUSER.userInfo.picture placeholderImage:IMAGE(@"head_default") contentSize:CGSizeMake(60.0, 60.0)];
        nickNameLabel.text = CMTUSER.userInfo.nickname;
        nickNameLabel.hidden = YES;
        headImageView.hidden = YES;
        firstIntegralLabel.text = _scoreCount;
        firstIntegralLabel.adjustsFontSizeToFitWidth = YES;
        
    }else{
        firstItemView.hidden = YES;
        itemView.hidden = NO;
        CMTScore *score = [_scoreList objectAtIndex:indexPath.row];
        
        itemTitleLabel.text = [score content];
        if ([[score score]intValue]>= 0) {
            itemRightIntegral.text = [[NSString alloc]initWithFormat:@"%@%@",@"+",[score score]];
            itemRightIntegral.textColor = [UIColor colorWithHexString:@"#33c7c2"];
        }else{
            itemRightIntegral.text = [[NSString alloc]initWithFormat:@"%@%@",@"",[score score]];
            itemRightIntegral.textColor = COLOR(c_f14545);
        }
        
        dateLabel.text = DATE(score.createTime);

    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(0 == indexPath.section){
        return TABLE_FIRST_HEIGHT;
    }else{
        return TABLE_HEIGHT;
    }
}

///根据参数获取积分总数
-(void)getScoreCountParam {
    NSDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:CMTUSER.userInfo.userId forKey:@"userId"];
    @weakify(self);
    [[[CMTCLIENT getScoreCount:param]
      deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(ScoreCount *scoreCount) {
        @strongify(self);
        if((nil == scoreCount)){
            
        }else{
            self.scoreCount = [[NSString alloc] initWithFormat:@"%@", scoreCount.count];
            [self.tableView reloadData];
        }
    } error:^(NSError *error) {
//        [self toastAnimation:error.domain];
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
