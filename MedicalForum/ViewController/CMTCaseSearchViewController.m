//
//  CMTCaseSearchViewController.m
//  MedicalForum
//
//  Created by guoyuanchao on 16/3/11.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import "CMTCaseSearchViewController.h"
#import "CMTTagMarker.h"
#import "CMTOtherPostListViewController.h"
#import "CMTSubjectListViewController.h"
#import "CMTCaseSearchResultViewController.h"
#import "CMTBadgePoint.h"
@interface CMTCaseSearchViewController ()<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource,CMTTagMarkerDelegte>
@property(nonatomic,strong)UIButton *GroupButton;//小组按钮
@property(nonatomic,strong)UIButton *caseButton;//病例按钮
@property(nonatomic,strong)UIView *buttonView;
@property(nonatomic,strong)UIView *lineView;
@property(nonatomic,strong)UIView *searchView;
@property(nonatomic,strong)UITableView *tagtableView;
@property(nonatomic,strong)CMTTagMarker *TagMarkerView; //标签管理视图
@property(nonatomic,strong)NSMutableArray *FocusTagArrays; //已订阅标签数组
@property(nonatomic,assign)BOOL isrefreshSubtableView;// 是否刷新列表
@property(nonatomic,strong)NSString*searchType;
@property(nonatomic,assign)BOOL isclearbage;
@property(nonatomic,strong)CMTBadgePoint *badgePoint;
@end

@implementation CMTCaseSearchViewController
-(CMTBadgePoint*)badgePoint{
    if (_badgePoint==nil) {
        _badgePoint=[[CMTBadgePoint alloc]init];
    }
    return _badgePoint;
}
-(UIView*)searchView{
    if (_searchView==nil) {
        _searchView=[[UIView alloc]initWithFrame:CGRectMake(0, 0,SCREEN_WIDTH, 64)];
        _searchView.backgroundColor=ColorWithHexStringIndex(c_f5f6f6);
        UIView *bgView=[[UIView alloc]initWithFrame:CGRectMake(10,27,SCREEN_WIDTH-75,30)];
        bgView.backgroundColor=ColorWithHexStringIndex(c_ffffff);
        bgView.layer.borderWidth=1;
        bgView.layer.cornerRadius=5;
        bgView.layer.borderColor=ColorWithHexStringIndex(c_F7F7F7).CGColor;
        UIImageView *imageView=[[UIImageView alloc]initWithFrame:CGRectMake(10, 5, 20, 20)];
        imageView.image=IMAGE(@"search_leftItem");
        [bgView addSubview:imageView];
        UITextField *searchField=[[UITextField alloc]initWithFrame:CGRectMake(imageView.right+5, 0, bgView.width-imageView.right-10, 30)];
        searchField.delegate=self;
        searchField.placeholder=@"搜索";
        searchField.returnKeyType=UIReturnKeySearch;
        searchField.clearButtonMode=UITextFieldViewModeWhileEditing;
        
        [bgView addSubview:searchField];
        [_searchView addSubview:bgView];
        
        UIButton *cancelbutton=[[UIButton alloc]initWithFrame:CGRectMake(bgView.right+10, 27, 44, 30)];
        [cancelbutton setTitle:@"取消" forState:UIControlStateNormal];
        [cancelbutton setTitleColor:ColorWithHexStringIndex(c_4acbb5) forState:UIControlStateNormal];
        cancelbutton.titleLabel.font=[UIFont systemFontOfSize:17];
        [cancelbutton addTarget:self action:@selector(gobackTolastController) forControlEvents:UIControlEventTouchUpInside];
        [_searchView addSubview:cancelbutton];
    }
    return _searchView;
}
-(UIView*)buttonView{
    if (_buttonView==nil) {
        _buttonView=[[UIView alloc]initWithFrame:CGRectMake(0, CMTNavigationBarBottomGuide, SCREEN_WIDTH, 40)];
        [_buttonView setBackgroundColor:COLOR(c_f5f6f6)];
        _GroupButton=[[UIButton alloc]initWithFrame:CGRectMake((SCREEN_WIDTH- 400/3*RATIO*2)/2, 0, 400/3*RATIO, _buttonView.height-1)];
        [_GroupButton setTitle:@"小组" forState:UIControlStateNormal];
        [_GroupButton setTitleColor:ColorWithHexStringIndex(c_4acbb5) forState:UIControlStateNormal];
        [_GroupButton addTarget:self action:@selector(changeModel:) forControlEvents:UIControlEventTouchUpInside];
        _lineView=[[UIView alloc]initWithFrame:CGRectMake(_GroupButton.left, _GroupButton.height, 400/3*RATIO, 1)];
        _lineView.backgroundColor=ColorWithHexStringIndex(c_4acbb5);
        [_buttonView addSubview:_GroupButton];
        
        _caseButton=[[UIButton alloc]initWithFrame:CGRectMake(_GroupButton.right, 0, 400/3*RATIO, _buttonView.height-1)];
        [_caseButton setTitle:@"帖子" forState:UIControlStateNormal];
        [_caseButton setTitleColor:COLOR(c_b9b9b9) forState:UIControlStateNormal];
        [_caseButton addTarget:self action:@selector(changeModel:) forControlEvents:UIControlEventTouchUpInside];
        [_buttonView addSubview:_caseButton];
        [_caseButton addSubview:self.badgePoint];
        self.badgePoint.hidden=CMTAPPCONFIG.UnreadCaseNumber_Slide.integerValue==0;
        self.badgePoint.frame=CGRectMake(_caseButton.width/2+15, 5, CMTBadgePointWidth, CMTBadgePointWidth);
        UIView *buttomline=[[UIView alloc]initWithFrame:CGRectMake(0, _caseButton.bottom, SCREEN_WIDTH, 1)];
        buttomline.backgroundColor=[UIColor colorWithHexString:@"F8F8F8"];
        [_buttonView addSubview:buttomline];
        [_buttonView addSubview:_lineView];

        
        
        
    }
    return _buttonView;
}
-(UITableView*)tagtableView{
    if (_tagtableView==nil) {
        _tagtableView=[[UITableView alloc]initWithFrame:CGRectMake(0,self.buttonView.bottom , SCREEN_WIDTH,SCREEN_HEIGHT-self.buttonView.bottom)style:UITableViewStylePlain];
        _tagtableView.delegate=self;
        _tagtableView.dataSource=self;
        _tagtableView.separatorStyle=UITableViewCellSeparatorStyleNone;
        _tagtableView.backgroundColor=COLOR(c_efeff4);
    }
    return _tagtableView;
}
//订阅的标签管理视图
-(CMTTagMarker*)TagMarkerView{
    if (_TagMarkerView==nil) {
        _TagMarkerView=[[CMTTagMarker alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0)];
        _TagMarkerView.delegate=self;
        _TagMarkerView.model=@"1";
    }
    return _TagMarkerView;
}
//获取标签列表 绘制标签视图
-(void)CMTGetTagArray{
    if (self.TagMarkerView !=nil) {
        for (UIView *view in [self.TagMarkerView subviews]) {
            [view removeFromSuperview];
        }
    }
    
    if([[NSFileManager defaultManager] fileExistsAtPath:PATH_FOUSTAG]){
        self.FocusTagArrays=[[NSKeyedUnarchiver unarchiveObjectWithFile:PATH_FOUSTAG]mutableCopy];
        
        [self.TagMarkerView DrawTagMakerMangeView:[self.FocusTagArrays mutableCopy]];
        self.TagMarkerView.frame=CGRectMake(0,0, self.TagMarkerView.width, self.TagMarkerView.height);
        self.tagtableView.tableHeaderView=self.TagMarkerView;
        
        
    }else{
        [self.FocusTagArrays removeAllObjects];
        [self.TagMarkerView DrawTagMakerMangeView:[self.FocusTagArrays mutableCopy]];
        self.TagMarkerView.frame=CGRectMake(0,0, self.TagMarkerView.width, self.TagMarkerView.height);
        self.tagtableView.tableHeaderView=self.TagMarkerView;
    }
}

//TAgMArker视图代理 展示疾病指南文章列表
-(void)CMTGotoGuidePostListView:(CMTDisease*)Disease{
    self.isrefreshSubtableView=YES;
    for (CMTDisease *dis in self.FocusTagArrays) {
        if ([dis.diseaseId isEqualToString:Disease.diseaseId]) {
          CMTAPPCONFIG.UnreadCaseNumber_Slide=[@"" stringByAppendingFormat:@"%ld", (long)[CMTAPPCONFIG.UnreadCaseNumber_Slide integerValue]-[dis.caseCout integerValue]];
            dis.caseCout=@"0";
            dis.caseReadtime=TIMESTAMP;
            self.badgePoint.hidden=CMTAPPCONFIG.UnreadCaseNumber_Slide.integerValue==0;
            break;
        }
    }
    
    [NSKeyedArchiver archiveRootObject:[self.FocusTagArrays mutableCopy] toFile:PATH_FOUSTAG];
    CMTOtherPostListViewController *need=[[CMTOtherPostListViewController alloc] initWithDisease:Disease.disease diseaseIds:Disease.diseaseId
                                                                                          module:@"1"];
    
    [self.navigationController pushViewController:need animated:YES];
}
//添加疾病标签
-(void)CmtAddTagAction{
    [MobClick event:@"B_AddTag_Guideline"];
    self.isrefreshSubtableView=YES;
    CMTSubjectListViewController *suject=[[CMTSubjectListViewController alloc]init];
    [self.navigationController pushViewController:suject animated:YES];
}


#pragma mark 返回上以页面
-(void)gobackTolastController{
    [self.navigationController popViewControllerAnimated:YES];
    if (self.isclearbage) {
        CMTAPPCONFIG.UnreadCaseNumber_Slide=@"0";
        self.FocusTagArrays=[[NSKeyedUnarchiver unarchiveObjectWithFile:PATH_FOUSTAG]mutableCopy];
        for (CMTDisease *disease in self.FocusTagArrays) {
            disease.caseCout=@"0";
            disease.caseReadtime=TIMESTAMP;
        }
        [NSKeyedArchiver archiveRootObject:[self.FocusTagArrays mutableCopy] toFile:PATH_FOUSTAG];
    }
   
}
//改变模式
-(void)changeModel:(UIButton*)sender{
    @weakify(self);
    [UIView animateWithDuration:0.2 animations:^{
        @strongify(self);
        self.lineView.frame=CGRectMake(sender.frame.origin.x, self.lineView.top, self.lineView.width, self.lineView.height);
        
    } completion:^(BOOL finished) {
        @strongify(self);
        if (sender==self.GroupButton) {
            [self.GroupButton setTitleColor:ColorWithHexStringIndex(c_4acbb5) forState:UIControlStateNormal];
            [self.caseButton setTitleColor:COLOR(c_b9b9b9) forState:UIControlStateNormal];
             self.tagtableView.hidden=YES;
             self.searchType=@"0";
        }else{
            [self.caseButton setTitleColor:ColorWithHexStringIndex(c_4acbb5) forState:UIControlStateNormal];
            [self.GroupButton setTitleColor:COLOR(c_b9b9b9) forState:UIControlStateNormal];
            self.tagtableView.hidden=NO;
             self.searchType=@"1";
            self.isclearbage=YES;
        }
        
    }];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [self setContentState:CMTContentStateNormal];
    if (self.isrefreshSubtableView) {
           [self CMTGetTagArray];
    }
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.rac_willDeallocSignal subscribeCompleted:^{
        CMTLog(@"CMTCaseSearchViewController Dealloc");
    }];
     [self CMTGetTagArray];
    self.contentBaseView.backgroundColor=ColorWithHexStringIndex(c_efeff4);
    [self.contentBaseView addSubview:self.searchView];
    [self.contentBaseView addSubview:self.buttonView];
    [self.contentBaseView addSubview:self.tagtableView];
    self.tagtableView.hidden=YES;
    self.searchType=@"0";
    self.isrefreshSubtableView=NO;
    self.isclearbage=NO;
    
}
#pragma mark 搜索
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    CMTCaseSearchResultViewController *reault=[[CMTCaseSearchResultViewController alloc]initWithSearchKey:textField.text type:self.searchType];
    [self.navigationController pushViewController:reault animated:YES];
    return YES;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 0;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    return cell;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
