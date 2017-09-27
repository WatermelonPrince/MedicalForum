//
//  CMTSearchColledgeDataViewController.m
//  MedicalForum
//
//  Created by zhaohuan on 16/10/28.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import "CMTSearchColledgeDataViewController.h"
#import "CMTColledgeSearchField.h"
#import "CMTSearchColledgeDataViewController.h"
#import "CMTSearchColledgeDataCell.h"
#import "CMTSearchVideoViewController.h"
#import "CMTSearchLiveViewController.h"
#import "CMTSearchSeriesCoursesViewController.h"

@interface CMTSearchColledgeDataViewController ()<UITextFieldDelegate, UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>
@property (strong, nonatomic) UIView *mBaseView;
@property (strong, nonatomic) CMTColledgeSearchField *mTfSearch;/*搜索文本框*/
@property (strong, nonatomic) UIImageView *mTfLeftView;//搜索左部视图
@property (strong, nonatomic) UIButton *mCancelBtn;//取消按钮
@property (strong, nonatomic) UIView *mSearchImageView;//搜索背景图片
@property (strong, nonatomic) UITableView *searchHistoryTableView;//搜索历史
@property (strong, nonatomic) UIView *deleteHistyToolbarView;//清理历史工具条;
@property (strong, nonatomic) UIButton *deleteHistyToolButton;//清理历史button;
@property (strong, nonatomic) UIView *switchToolView;//切换工具栏;
@property (strong, nonatomic) UIView *lineView;//线条;
@property (strong, nonatomic) UIButton *liveButton;//直播
@property (strong, nonatomic) UIButton *videoButton;//录播
@property (strong, nonatomic) UIButton *seriesCoursesButton;//系列课程;
@property (strong, nonatomic) UIScrollView *switchScrollView;//切换滚动视图

@property (strong, nonatomic) CMTSearchVideoViewController *searchVideoVC;
@property (strong, nonatomic) CMTSearchLiveViewController *searchLiveVC;
@property (strong, nonatomic) CMTSearchSeriesCoursesViewController *searchSeriesCoursesVC;
@property (strong, nonatomic) UIView *choiceView;//搜索分类视图
@property (strong, nonatomic) UILabel *reminderLabel;//提示label;
@property (strong, nonatomic) UIButton *choiceLiveButton;//直播button;
@property (strong, nonatomic) UIButton *choiceVideoButton;//录播button;
@property (strong, nonatomic) UIButton *choiceSeriesCoursesButton;//系列课程button;
@property (strong, nonatomic) NSMutableArray *dataArray;//搜索历史数据源
@property (strong, nonatomic) NSMutableArray *revideos;
@property (nonatomic) BOOL keyboardHide;//键盘隐藏为yes

@end

@implementation CMTSearchColledgeDataViewController

- (NSMutableArray *)revideos{
    if (!_revideos) {
        _revideos = [NSMutableArray array];
    }
    return _revideos;
}

- (UIView *)choiceView{
    if (!_choiceView) {
        _choiceView = [[UIView alloc]initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT - 64)];
        _choiceView.backgroundColor = COLOR(c_f5f5f5);
    }
    return _choiceView;
}

- (UILabel *)reminderLabel{
    if (!_reminderLabel) {
        _reminderLabel = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH*1/6,  SCREEN_HEIGHT*1/11,  SCREEN_WIDTH * 2/3, 30)];
        _reminderLabel.text = @"搜索你感兴趣的课程";
        _reminderLabel.textAlignment = NSTextAlignmentCenter;
        _reminderLabel.font = [UIFont systemFontOfSize:18];
        _reminderLabel.textColor = [UIColor colorWithHexString:@"#737373"];
    }
    return _reminderLabel;
}
- (UIButton *)choiceLiveButton{
    if (!_choiceLiveButton) {
        _choiceLiveButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _choiceLiveButton.frame =CGRectMake((SCREEN_WIDTH - 40* 3)/4 * 2 + 40,  SCREEN_HEIGHT * 2/12, 40, 40);
        [_choiceLiveButton setImage:[UIImage imageNamed:@"search_live"] forState:UIControlStateNormal];
        [_choiceLiveButton addTarget:self action:@selector(choiceAction:) forControlEvents:UIControlEventTouchUpInside];
        _choiceLiveButton.tag = 101;
    }
    return _choiceLiveButton;
}

- (UIButton *)choiceVideoButton{
    if (!_choiceVideoButton) {
        _choiceVideoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _choiceVideoButton.frame = CGRectMake((SCREEN_WIDTH - 40 * 3)/4, SCREEN_HEIGHT * 2/12, 40, 40);
        [_choiceVideoButton setImage:[UIImage imageNamed:@"search_video"] forState:UIControlStateNormal];
        [_choiceVideoButton addTarget:self action:@selector(choiceAction:) forControlEvents:UIControlEventTouchUpInside];
        _choiceVideoButton.tag = 102;
    }
    return _choiceVideoButton;
}
- (UIButton *)choiceSeriesCoursesButton{
    if (!_choiceSeriesCoursesButton) {
        _choiceSeriesCoursesButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _choiceSeriesCoursesButton.frame = CGRectMake((SCREEN_WIDTH - 40 * 3)/4 * 3 + 40 * 2,  SCREEN_HEIGHT *2/12, 40, 40);
        [_choiceSeriesCoursesButton setImage:[UIImage imageNamed:@"search_series"] forState:UIControlStateNormal];
        [_choiceSeriesCoursesButton addTarget:self action:@selector(choiceAction:) forControlEvents:UIControlEventTouchUpInside];
        _choiceSeriesCoursesButton.tag = 103;
    }
    return _choiceSeriesCoursesButton;
}



#pragma mark--添加分类搜索视图
- (void)configureChoiceView{
    [self.choiceView addSubview:self.reminderLabel];
    [self.choiceView addSubview:self.choiceLiveButton];
    [self.choiceView addSubview:self.choiceVideoButton];
    [self.choiceView addSubview:self.choiceSeriesCoursesButton];
    for (int i = 0; i < 3; i++) {
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(i * SCREEN_WIDTH/3, self.choiceLiveButton.bottom + 5 , SCREEN_WIDTH/3, 20)];
        if (i == 0) {
            label.text = @"直播";
            label.centerX = self.choiceLiveButton.centerX;
        }else if (i == 1){
            label.text =@"录播";
            label.centerX = self.choiceVideoButton.centerX;

        }else{
            label.text = @"系列课程";
            label.centerX = self.choiceSeriesCoursesButton.centerX;

        }
        label.textColor = COLOR(c_1eba9c);
        label.textAlignment = NSTextAlignmentCenter;
        label.font = FONT(18);
        [self.choiceView addSubview:label];
    }
}

- (CMTSearchVideoViewController *)searchVideoVC{
    if (!_searchVideoVC) {
        _searchVideoVC = [[CMTSearchVideoViewController alloc]init];
    }
    return _searchVideoVC;
}
- (CMTSearchLiveViewController *)searchLiveVC{
    if (!_searchLiveVC) {
        _searchLiveVC = [[CMTSearchLiveViewController alloc]init];
    }
    return _searchLiveVC;
}
- (CMTSearchSeriesCoursesViewController *)searchSeriesCoursesVC{
    if (!_searchSeriesCoursesVC) {
        _searchSeriesCoursesVC = [[CMTSearchSeriesCoursesViewController alloc]init];
    }
    return _searchSeriesCoursesVC;
}

#pragma mark--添加搜索结果分类视图

- (void)configureScrollView{
    self.searchVideoVC.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - self.switchToolView.bottom);
    self.searchLiveVC.view.frame = CGRectMake(SCREEN_WIDTH, 0, SCREEN_WIDTH, SCREEN_HEIGHT - self.switchToolView.bottom);
    self.searchSeriesCoursesVC.view.frame = CGRectMake(SCREEN_WIDTH * 2, 0, SCREEN_WIDTH, SCREEN_HEIGHT - self.switchToolView.bottom);
    self.searchVideoVC.parentVC = self;
    self.searchLiveVC.parentVC = self;
    self.searchSeriesCoursesVC.parentVC = self;
    [self.switchScrollView addSubview:self.searchVideoVC.view];
    [self.switchScrollView addSubview:self.searchLiveVC.view];
    [self.switchScrollView addSubview:self.searchSeriesCoursesVC.view];
}
- (UIButton *)seriesCoursesButton{
    if (_seriesCoursesButton == nil) {
        _seriesCoursesButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _seriesCoursesButton.frame = CGRectMake(SCREEN_WIDTH/3 * 2, 0, SCREEN_WIDTH/3, 40);
        [_seriesCoursesButton setTitle:@"系列课程" forState:UIControlStateNormal];
        [_seriesCoursesButton setTitleColor:[UIColor colorWithHexString:@"9b9b9b"] forState:UIControlStateNormal];
        [_seriesCoursesButton setTitleColor:[UIColor colorWithHexString:@"00bb9c"] forState:UIControlStateSelected];
        [_seriesCoursesButton addTarget:self action:@selector(switchSearchAction:) forControlEvents:UIControlEventTouchUpInside];
        _seriesCoursesButton.titleLabel.font = FONT(15);

        _seriesCoursesButton.selected = NO;
    }
    return _seriesCoursesButton;
}

- (UIButton *)videoButton{
    if (_videoButton == nil) {
        _videoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _videoButton.frame = CGRectMake(0 , 0, SCREEN_WIDTH/3, 40);
        [_videoButton setTitle:@"录播" forState:UIControlStateNormal];
        [_videoButton setTitleColor:[UIColor colorWithHexString:@"9b9b9b"] forState:UIControlStateNormal];
        [_videoButton setTitleColor:[UIColor colorWithHexString:@"00bb9c"] forState:UIControlStateSelected];
        [_videoButton addTarget:self action:@selector(switchSearchAction:) forControlEvents:UIControlEventTouchUpInside];
        _videoButton.titleLabel.font = FONT(15);

        _videoButton.selected = YES;
    }
    return _videoButton;
}

- (UIButton *)liveButton{
    if (_liveButton == nil) {
        _liveButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _liveButton.frame = CGRectMake(SCREEN_WIDTH/3 , 0, SCREEN_WIDTH/3, 40);
        [_liveButton setTitle:@"直播" forState:UIControlStateNormal];
        [_liveButton setTitleColor:[UIColor colorWithHexString:@"9b9b9b"] forState:UIControlStateNormal];
        [_liveButton setTitleColor:[UIColor colorWithHexString:@"00bb9c"] forState:UIControlStateSelected];
        [_liveButton addTarget:self action:@selector(switchSearchAction:) forControlEvents:UIControlEventTouchUpInside];
        _liveButton.titleLabel.font = FONT(15);
        _liveButton.selected = NO;
    }
    return _liveButton;
}

- (UIView *)lineView{
    if (_lineView == nil) {
        _lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 40, SCREEN_WIDTH/3, 3)];
        _lineView.backgroundColor = [UIColor colorWithHexString:@"00bb9c"];
    }
    return _lineView;
}

- (UIView *)switchToolView{
    if (!_switchToolView) {
        _switchToolView = [[UIView alloc]initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, 43)];
        _switchToolView.backgroundColor = COLOR(c_f5f5f5);
    }
    return _switchToolView;
}

//配置分类查看结果的工具栏
- (void)configureSwitchToolView{
    [self.switchToolView addSubview:self.videoButton];
    [self.switchToolView addSubview:self.liveButton];
    [self.switchToolView addSubview:self.seriesCoursesButton];
    [self.switchToolView addSubview:self.lineView];
}
#pragma mark--工具栏分类查看结果触发方法
- (void)switchSearchAction:(UIButton *)sender{
    if ([sender.currentTitle isEqualToString:@"录播"]) {
        sender.selected = YES;
        self.liveButton.selected = NO;
        self.seriesCoursesButton.selected = NO;
        self.lineView.frame = CGRectMake(0, 40, SCREEN_WIDTH/3, 3);
        [self.switchScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    }else if ([sender.currentTitle isEqualToString:@"直播"]){
        sender.selected = YES;
        self.videoButton.selected = NO;
        self.seriesCoursesButton.selected = NO;
        self.lineView.frame = CGRectMake(SCREEN_WIDTH/3, 40, SCREEN_WIDTH/3, 3);
        [self.switchScrollView setContentOffset:CGPointMake(SCREEN_WIDTH, 0) animated:YES];

    }else{
        sender.selected = YES;
        self.liveButton.selected = NO;
        self.videoButton.selected = NO;
        self.lineView.frame = CGRectMake(SCREEN_WIDTH/3 * 2, 40, SCREEN_WIDTH/3, 3);
        [self.switchScrollView setContentOffset:CGPointMake(SCREEN_WIDTH * 2, 0) animated:YES];
    }
}

- (UIScrollView *)switchScrollView {
    if (!_switchScrollView) {
        _switchScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, self.switchToolView.bottom, SCREEN_WIDTH, SCREEN_HEIGHT - self.switchToolView.bottom)];
        _switchScrollView.contentSize = CGSizeMake(SCREEN_WIDTH * 3, SCREEN_HEIGHT - self.switchToolView.bottom);
        _switchScrollView.delegate = self;
        _switchScrollView.pagingEnabled = YES;
    }
    return _switchScrollView;
}



- (NSMutableArray *)dataArray{
    if (_dataArray == nil) {
        _dataArray = [NSMutableArray array];
        _dataArray = [NSKeyedUnarchiver unarchiveObjectWithFile:[PATH_USERS stringByAppendingPathComponent:@"searchHis"]];
    }
    return _dataArray;
}

- (UITableView *)searchHistoryTableView{
    if (_searchHistoryTableView == nil) {
        _searchHistoryTableView = [[UITableView alloc]init];
        _searchHistoryTableView.frame = CGRectMake(0, 64, SCREEN_WIDTH, (self.dataArray.count + 1) * 60);
        _searchHistoryTableView.delegate = self;
        _searchHistoryTableView.dataSource = self;
        _searchHistoryTableView.bounces = YES;
        _searchHistoryTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _searchHistoryTableView.backgroundColor = [UIColor clearColor];
        [_searchHistoryTableView registerClass:[CMTSearchColledgeDataCell class] forCellReuseIdentifier:@"CMTSearchColledge"];
        _searchHistoryTableView.hidden = YES;
    }
    return _searchHistoryTableView;
}


- (UIView *)deleteHistyToolbarView{
    if (_deleteHistyToolbarView == nil) {
        _deleteHistyToolbarView = [[UIView alloc]initWithFrame:CGRectMake(0, self.searchHistoryTableView.height - 60, self.searchHistoryTableView.width, 60)];
        _deleteHistyToolbarView.backgroundColor = [UIColor whiteColor];
        [_deleteHistyToolbarView addSubview:self.deleteHistyToolButton];
        
    }
    return _deleteHistyToolbarView;
}

- (UIButton *)deleteHistyToolButton{
    if (_deleteHistyToolButton == nil) {
        _deleteHistyToolButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _deleteHistyToolButton.frame = CGRectMake(0, 0, self.deleteHistyToolbarView.width, 60);
        [_deleteHistyToolButton setTitle:@"清空搜索历史" forState:UIControlStateNormal];
        _deleteHistyToolButton.titleLabel.font = FONT(16);
        [_deleteHistyToolButton setTitleColor:COLOR(c_32c7c2) forState:UIControlStateNormal];
        [[_deleteHistyToolButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            [self.view endEditing:YES];
            if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"是否清除历史记录" message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *trueAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self.dataArray removeAllObjects];
                [NSKeyedArchiver archiveRootObject:self.dataArray toFile:[PATH_USERS stringByAppendingPathComponent:@"searchHis"]];
                if (self.dataArray.count == 0) {
                    self.deleteHistyToolbarView.hidden = YES;
                    self.searchHistoryTableView.hidden = YES;
                }
            }];
            UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                self.deleteHistyToolbarView.hidden = YES;
                self.searchHistoryTableView.hidden = YES;
            }];
            [alertVC addAction:trueAction];
            [alertVC addAction:cancleAction];
            [self presentViewController:alertVC animated:YES completion:^{
                
            }];
            }else{
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"是否清除历史记录" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                [alert.rac_buttonClickedSignal subscribeNext:^(NSNumber * x) {
                    if(x.integerValue == 1){
                        [self.dataArray removeAllObjects];
                        [NSKeyedArchiver archiveRootObject:self.dataArray toFile:[PATH_USERS stringByAppendingPathComponent:@"searchHis"]];
                        if (self.dataArray.count == 0) {
                            self.deleteHistyToolbarView.hidden = YES;
                            self.searchHistoryTableView.hidden = YES;
                        }
                    }else{
                        self.deleteHistyToolbarView.hidden = YES;
                        self.searchHistoryTableView.hidden = YES;
                    }
                }];
                [alert show];
                
            }

             
            
        }];
    }
    return _deleteHistyToolButton;
}

- (UIButton *)mCancelBtn
{
    if (!_mCancelBtn)
    {
        _mCancelBtn  = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [_mCancelBtn setTitleColor:COLOR(c_ffffff) forState:UIControlStateNormal];
        [_mCancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [_mCancelBtn setFrame:CGRectMake(self.mSearchImageView.right, 20,SCREEN_WIDTH-self.mSearchImageView.right, 44)];
        [_mCancelBtn addTarget:self action:@selector(cancelBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        _mCancelBtn.titleLabel.font = FONT(18);
        _mCancelBtn.tag = 100;
    }
    return _mCancelBtn;
}
#pragma mark--搜索框取消/退出按钮触发方法
- (void)cancelBtnPressed:(UIButton *)sender{
    [self.navigationController popViewControllerAnimated:YES];
}
- (UIView *)mBaseView
{
    if (!_mBaseView)
    {
        _mBaseView = [[UIView alloc]initWithFrame:CGRectMake(-PIXEL, 0,SCREEN_WIDTH+PIXEL*2, 64)];
        _mBaseView.backgroundColor = COLOR(c_1eba9c);
        _mBaseView.layer.borderWidth = PIXEL;
        _mBaseView.layer.borderColor = COLOR(c_9e9e9e).CGColor;
    }
    return _mBaseView;
}

- (UIImageView *)mTfLeftView
{
    if (!_mTfLeftView)
    {
        _mTfLeftView = [[UIImageView alloc]initWithImage:IMAGE(@"searchbutton")];
        [_mTfLeftView setFrame:CGRectMake(10, 6, 18, 18)];
    }
    return _mTfLeftView;
}
/*搜索文本框*/
- (CMTColledgeSearchField *)mTfSearch
{
    if (!_mTfSearch)
    {
        _mTfSearch = [[CMTColledgeSearchField alloc]initWithFrame:CGRectMake(44, 26,self.mSearchImageView.right-44, 30)];
       
        _mTfSearch.placeholder = @"输入";

     
        _mTfSearch.clearButtonMode = UITextFieldViewModeAlways;
//        _mTfSearch.clearsOnBeginEditing = YES;
        _mTfSearch.returnKeyType = UIReturnKeySearch;
        _mTfSearch.delegate = self;
        UIButton *button = [_mTfSearch valueForKey:@"_clearButton"];
        [button setImage:[UIImage imageNamed:@"search_delete"] forState:UIControlStateNormal];
        _mTfSearch.textColor = COLOR(c_ffffff);
    }
    return _mTfSearch;
}
- (UIView *)mSearchImageView
{
    if (!_mSearchImageView)
    {
        _mSearchImageView = [[UIView alloc]init];
        _mSearchImageView.backgroundColor=[UIColor colorWithHexString:@"16947c"];
        _mSearchImageView.layer.borderWidth=1;
        _mSearchImageView.layer.cornerRadius=3;
        _mSearchImageView.layer.borderColor=(__bridge CGColorRef)COLOR(c_EBEBEE);
        _mSearchImageView.frame = CGRectMake(10, 26,SCREEN_WIDTH-10-16-45, 30);
        
        
        [_mSearchImageView addSubview:self.mTfLeftView];
    }
    return _mSearchImageView;
}


#pragma mark--viewdidLoad方法
- (void)viewDidLoad{
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
    [self initLayout:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide) name:UIKeyboardDidHideNotification object:nil];
    
}
#pragma mark--键盘隐藏触发方法
- (void)keyboardDidHide{
    self.keyboardHide = YES;
}

- (void)initLayout:(id)sender
{
    [self.contentBaseView addSubview:self.mBaseView];
    [self.contentBaseView addSubview:self.mSearchImageView];
    [self.contentBaseView addSubview:self.mTfSearch];
    [self.contentBaseView addSubview:self.mCancelBtn];
    [self.contentBaseView addSubview:self.switchToolView];
    [self configureSwitchToolView];
    [self.contentBaseView addSubview:self.switchScrollView];
    [self configureScrollView];
    [self.contentBaseView addSubview:self.choiceView];
    [self configureChoiceView];
    [self.contentBaseView addSubview:self.searchHistoryTableView];
    [self.searchHistoryTableView addSubview:self.deleteHistyToolbarView];
    
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}
#pragma mark--tableView代理方法
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CMTSearchColledgeDataCell * cell = [tableView dequeueReusableCellWithIdentifier:@"CMTSearchColledge"];
    NSString *str = self.dataArray[indexPath.row];
    cell.searchLabel.text = str;
    cell.deleteButton.tag = 1000 + indexPath.row;
    [cell.deleteButton addTarget:self action:@selector(deleteOneNote:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.mTfSearch.text = self.dataArray[indexPath.row];
    self.deleteHistyToolbarView.hidden = YES;
    self.searchHistoryTableView.hidden = YES;
    [self.view endEditing:YES];
    [self didSelectedCellForSearch];
    
}

#pragma mark--scrollViewDelegate代理方法
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
        if ([scrollView isMemberOfClass:[UITableView class]]) {
            [self.mTfSearch resignFirstResponder];
        }
    
    if (self.switchScrollView.contentOffset.x == 0) {
        self.lineView.frame = CGRectMake(0, 40, SCREEN_WIDTH/3, 3);
        self.videoButton.selected = YES;
        self.liveButton.selected = NO;
        self.seriesCoursesButton.selected = NO;
    }else if(self.switchScrollView.contentOffset.x/SCREEN_WIDTH == 1){
        self.lineView.frame = CGRectMake(SCREEN_WIDTH/3, 40, SCREEN_WIDTH/3, 3);
        self.videoButton.selected = NO;
        self.liveButton.selected = YES;
        self.seriesCoursesButton.selected = NO;
    }else if (self.switchScrollView.contentOffset.x/SCREEN_WIDTH == 2){
        self.lineView.frame = CGRectMake(SCREEN_WIDTH/3 * 2, 40, SCREEN_WIDTH/3, 3);
        self.videoButton.selected = NO;
        self.liveButton.selected = NO;
        self.seriesCoursesButton.selected = YES;
    }
}




#pragma mark--删除单条搜索记录
- (void)deleteOneNote:(UIButton *)sender{
    NSInteger row = sender.tag - 1000;
    [self.dataArray removeObjectAtIndex:row];
    [NSKeyedArchiver archiveRootObject:self.dataArray toFile:[PATH_USERS stringByAppendingPathComponent:@"searchHis"]];
    self.searchHistoryTableView.frame = CGRectMake(0, 64, SCREEN_WIDTH, (self.dataArray.count + 1) * 60);
    _deleteHistyToolbarView.frame = CGRectMake(0, self.searchHistoryTableView.height - 60, self.searchHistoryTableView.width, 60);
    [self.searchHistoryTableView reloadData];
    if (self.dataArray.count == 0) {
        self.deleteHistyToolbarView.hidden = YES;
        self.searchHistoryTableView.hidden = YES;
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60 ;
}
#pragma mark--搜索狂代理

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    [self.contentBaseView bringSubviewToFront:self.searchHistoryTableView];
    [self.contentBaseView bringSubviewToFront:self.deleteHistyToolbarView];

    self.keyboardHide = NO;
    self.searchHistoryTableView.frame = CGRectMake(0, 64, SCREEN_WIDTH, (self.dataArray.count + 1) * 60 );
    _deleteHistyToolbarView.frame = CGRectMake(0, self.searchHistoryTableView.height - 60, self.searchHistoryTableView.width, 60);
    if (self.dataArray.count == 0) {
        self.deleteHistyToolbarView.hidden = YES;
        self.searchHistoryTableView.hidden = YES;

    }else{
        self.deleteHistyToolbarView.hidden = NO;
        self.searchHistoryTableView.hidden = NO;

    }
}


#pragma mark--cell中删除历史记录触发方法
- (void)didSelectedCellForSearch{
    NSDictionary *pDic = @{
                           @"userId":CMTUSERINFO.userId?:@"0",
                           @"keyword":self.mTfSearch.text?:@"",
                           @"pageSize":@"30",
                           @"type":@"0"
                           };
    [self setContentState:CMTContentStateLoading];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self getSearchDataWithDic:pDic];
    self.choiceView.hidden = YES;

}
#pragma mark--textField代理方法
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    NSString *textstr = [self.mTfSearch.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (textstr.length > 0)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
          
        });
        
        NSString *pKeyWord = textField.text;
        NSDictionary *pDic = @{
                               @"userId":CMTUSERINFO.userId?:@"0",
                               @"keyword":pKeyWord?:@"",
                               @"pageSize":@"30",
                               @"type":@"0"
                               };
        [self.navigationController setNavigationBarHidden:NO animated:NO];
        [self setContentState:CMTContentStateLoading];
        [self getSearchDataWithDic:pDic];
        
        if (![self.dataArray containsObject:pKeyWord]) {
            NSMutableArray *arr = [NSMutableArray arrayWithObject:pKeyWord];
            [arr addObjectsFromArray:self.dataArray];
            self.dataArray  = [arr mutableCopy];
            while (self.dataArray.count > 5) {
                [self.dataArray removeLastObject];
            }
            [self.searchHistoryTableView reloadData];
            [NSKeyedArchiver archiveRootObject:self.dataArray toFile:[PATH_USERS stringByAppendingPathComponent:@"searchHis"]];
        }
        
        self.choiceView.hidden = YES;
        self.deleteHistyToolbarView.hidden = YES;
        self.searchHistoryTableView.hidden = YES;
    }
    else
    {
        [self toastAnimation:@"请输入搜索关键字"];
    }
    return YES;
}

#pragma mark--点击分类搜索按钮
- (void)choiceAction:(UIButton *)sender{
    if (self.mTfSearch.text.length > 0) {
        if (sender.tag == 102) {
            self.videoButton.selected = YES;
            self.liveButton.selected = NO;
            self.seriesCoursesButton.selected = NO;
            self.lineView.frame = CGRectMake(0, 40, SCREEN_WIDTH/3, 3);
            [self.switchScrollView setContentOffset:CGPointMake(0, 0) animated:NO];
        }else if (sender.tag == 101){
            self.videoButton.selected = NO;
            self.liveButton.selected = YES;
            self.seriesCoursesButton.selected = NO;
            self.lineView.frame = CGRectMake(SCREEN_WIDTH/3, 40, SCREEN_WIDTH/3, 3);
            [self.switchScrollView setContentOffset:CGPointMake(SCREEN_WIDTH, 0) animated:NO];
        }else{
            if (sender.tag == 103) {
                self.videoButton.selected = NO;
                self.liveButton.selected = NO;
                self.seriesCoursesButton.selected = YES;
                self.lineView.frame = CGRectMake(SCREEN_WIDTH/3 * 2, 40, SCREEN_WIDTH/3, 3);
                [self.switchScrollView setContentOffset:CGPointMake(SCREEN_WIDTH * 2, 0) animated:NO];
            }
        }
        [self.view endEditing:YES];
        NSString *pKeyWord = self.mTfSearch.text;
        if (![self.dataArray containsObject:pKeyWord]) {
            NSMutableArray *arr = [NSMutableArray arrayWithObject:pKeyWord];
            [arr addObjectsFromArray:self.dataArray];
            self.dataArray  = [arr mutableCopy];
            while (self.dataArray.count > 5) {
                [self.dataArray removeLastObject];
            }
            [self.searchHistoryTableView reloadData];
            [NSKeyedArchiver archiveRootObject:self.dataArray toFile:[PATH_USERS stringByAppendingPathComponent:@"searchHis"]];
        }
        
        [self didSelectedCellForSearch];
        self.choiceView.hidden = YES;
        self.deleteHistyToolbarView.hidden = YES;
        self.searchHistoryTableView.hidden = YES;
    }else{
        [self toastAnimation:@"请输入搜索关键字"];
    }
    
}

#pragma mark--搜索接口
-(void)getSearchDataWithDic:(NSDictionary *)dic{
    @weakify(self);
    [[[CMTCLIENT CMTSearchColledge:dic]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(CMTPlayAndRecordList* searchList) {
        @strongify(self);
        [self.navigationController setNavigationBarHidden:YES animated:NO];

        [self setContentState:CMTContentStateNormal];
        
        [self.searchVideoVC.videoArr removeAllObjects];
        [self.searchLiveVC.liveArr removeAllObjects];
        [self.searchSeriesCoursesVC.seriesArr removeAllObjects];
        self.searchVideoVC.videoArr = [searchList.revideos mutableCopy];
        self.searchLiveVC.liveArr = [searchList.lives mutableCopy];
        self.searchLiveVC.currentDate = searchList.sysDate;
        self.searchSeriesCoursesVC.seriesArr = [searchList.serieses mutableCopy];
        self.searchLiveVC.keyWord = self.mTfSearch.text;
        self.searchVideoVC.keyWord = self.mTfSearch.text;
        self.searchSeriesCoursesVC.keyWord = self.mTfSearch.text;
        [self.searchVideoVC.tableView reloadData];
        [self.searchLiveVC.tableView reloadData];
        [self.searchSeriesCoursesVC.tableView reloadData];
        
        
    }error:^(NSError *error) {
        [self.navigationController setNavigationBarHidden:YES animated:NO];

        @strongify(self);
        if (error.code>=-1009&&error.code<=-1001) {
            [self toastAnimation:@"你的网络不给力"];
            [self setContentState:CMTContentStateReload moldel:@"1"];

        }else{

            [self toastAnimation:error.userInfo[CMTClientServerErrorUserInfoMessageKey]];
            [self setContentState:CMTContentStateNormal];


        }
        
        
    }];
}

- (void)animationFlash{
    [self didSelectedCellForSearch];
}

#pragma mark--状态栏颜色改变
-(UIStatusBarStyle)preferredStatusBarStyle

{
    
    return UIStatusBarStyleLightContent;  //默认的值是黑色的
    
}



@end
