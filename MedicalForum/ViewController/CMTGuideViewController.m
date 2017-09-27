//
//  CMTGuideViewController.m
//  MedicalForum
//
//  Created by CMT on 15/6/1.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTGuideViewController.h"
#import "CMTGuideSujectCell.h"
#import "CMTSubject.h"
#import "CMTSearchView.h"
#import "CMTDiseaseListViewController.h"//疾病列表
#import"CMTTagMarker.h"//疾病标签
#import"CMTSubjectListViewController.h" //学科列表
#import "CMTNeedMoreGuideViewController.h" //指南更过需求
#import "CMTOtherPostListViewController.h" //其他文章列表
@interface CMTGuideViewController()<CMTTagMarkerDelegte>
@property (nonatomic, strong) UIImageView *titleView;  // 标题
@property(nonatomic,strong)UIButton *searchbutton; //搜索按钮
@property(nonatomic,strong)CMTTagMarker *TagMarkerView; //标签管理视图
@property(nonatomic,strong)UITableView *guidetableView;  //指南列表视图
@property(nonatomic,strong)NSMutableArray *FocusTagArrays; //已订阅标签数组
@property(nonatomic,strong)NSMutableArray *FocusSubjectArray; //订阅的学科列表
@property(nonatomic,strong)NSMutableArray *allSujectsArray;  //全部学科列表
@property(nonatomic,strong)UIControl *footControl; //底部展开全部学科按钮
@property(nonatomic,assign)BOOL isShowTableViewFoot;//是否拥有列表底部按钮
@property(nonatomic,strong)NSMutableArray *listDataSourceArray;
@property(nonatomic,strong)UIView *SearchView;//搜索视图
@property(nonatomic,strong)UIView *headView; //tableView head头
@property(nonatomic,assign)BOOL isrefreshSubtableView;// 是否刷新列表
@end
@implementation CMTGuideViewController

-(UIView*)SearchView{
    if (_SearchView==nil) {
        _SearchView=[[UIView alloc]initWithFrame:CGRectMake(0, 0,SCREEN_WIDTH, 40)];
        _SearchView.backgroundColor=COLOR(c_efeff4);
        CMTSearchView *CmtSearchView=[[CMTSearchView alloc]initWithFrame:CGRectMake(10,10, SCREEN_WIDTH-20, 30)];
        CmtSearchView.lastController=self;
        CmtSearchView.searchTypeID=@"1";
        CmtSearchView.titlefontSize=13;
        CmtSearchView.module=@"2";
        [CmtSearchView setBackgroundColor:ColorWithHexStringIndex(c_ffffff)];
        [CmtSearchView drawSearchButton:@"搜索指南"];
        
        [_SearchView addSubview:CmtSearchView];
    }
    return _SearchView;
}
-(UIView*)headView{
    if (_headView==nil) {
        _headView=[[UIView alloc]initWithFrame:CGRectMake(0, 0,SCREEN_WIDTH,50)];
        [_headView addSubview:self.SearchView];
        [_headView addSubview:self.TagMarkerView];
    }
    return _headView;
}
//订阅的标签管理视图
-(CMTTagMarker*)TagMarkerView{
    if (_TagMarkerView==nil) {
        _TagMarkerView=[[CMTTagMarker alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0)];
        _TagMarkerView.delegate=self;
        _TagMarkerView.model=@"2";
    }
    return _TagMarkerView;
}
//列表
-(UITableView*)guidetableView{
    if (_guidetableView==nil) {
        _guidetableView=[[UITableView alloc]init];
        [_guidetableView fillinContainer:self.contentBaseView WithTop:0 Left:0.0 Bottom:0 Right:0.0];
        _guidetableView.contentInset = UIEdgeInsetsMake(CMTNavigationBarBottomGuide, 0.0, 0.0, 0.0);
        _guidetableView.scrollIndicatorInsets = UIEdgeInsetsMake(CMTNavigationBarBottomGuide, 0.0, CMTTabBarHeight, 0.0);
        _guidetableView.backgroundColor =COLOR(c_efeff4);
        _guidetableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _guidetableView.dataSource = self;
        _guidetableView.delegate = self;
        [_guidetableView registerClass:[CMTGuideSujectCell class] forCellReuseIdentifier:@"CMTGuideSujectCell"];

    }
    return _guidetableView;
}
-(NSMutableArray*)allSujectsArray{
    if (_allSujectsArray==nil) {
        _allSujectsArray=[[NSMutableArray alloc]init];
    }
    return _allSujectsArray;
}
-(UIControl*)footControl{
    if (_footControl==nil) {
        _footControl=[[UIControl  alloc]initWithFrame:CGRectMake(0, 0,SCREEN_WIDTH, 30)];
        _footControl.backgroundColor=COLOR(c_ffffff);
        UILabel *textlable=[[UILabel alloc]initWithFrame:CGRectMake(10, 0, SCREEN_WIDTH-10, 30)];
        textlable.text=@"全部学科";
        [textlable setFont:FONT(12)];
        [textlable setTextColor:[UIColor colorWithHexString:@"#5B84AE"]];
        [_footControl addSubview:textlable];
        [_footControl addTarget:self action:@selector(OpenAllSubject) forControlEvents:UIControlEventTouchUpInside];
    }
    return _footControl;
}

-(NSMutableArray*)listDataSourceArray{
    if (_listDataSourceArray==nil) {
        _listDataSourceArray=[[NSMutableArray alloc]init];
  }
    return _listDataSourceArray;
}
#pragma 控制器生命周期
-(void)viewDidLoad{
    [super viewDidLoad];
    [self.rac_willDeallocSignal subscribeCompleted:^{
        CMTLog(@"PostList willDeallocSignal");
    }];

    self.isrefreshSubtableView=YES;
    self.titleText=@"指南";
    self.guidetableView.estimatedRowHeight=50;
    self.guidetableView.rowHeight=50;
    [self setContentState:CMTContentStateNormal];
    self.guidetableView.tableHeaderView=self.headView;
}
-(void)viewWillAppear:(BOOL)animated{
    //清空数据
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    
    //处理订阅的标签
    [self CMTGetTagArray];
    
   //是否刷新学科目录列表
    if (self.isrefreshSubtableView) {
        [self.FocusSubjectArray removeAllObjects];
        [self.allSujectsArray removeAllObjects];
        [self.listDataSourceArray removeAllObjects];
        //获取已经订阅的学科列表
        [self CMTGetAndSortFocusSuject];
        // 获取所有的学科列表
        [self CMTGetAllsubjectsArray];

    }else{
        self.isrefreshSubtableView=YES;
    }
    
}
-(void)viewWillDisappear:(BOOL)animated{
    CMTLog(@"消失");
    [super viewWillDisappear:animated];
}

#pragma 获取已经关订阅的学科列表
-(void)CMTGetAndSortFocusSuject{
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[PATH_USERS stringByAppendingPathComponent:@"subscription"]]){
        self.FocusSubjectArray=[[NSKeyedUnarchiver unarchiveObjectWithFile:[PATH_USERS stringByAppendingPathComponent:@"subscription"]]mutableCopy];
        NSMutableArray *fouceArray=[[NSMutableArray alloc]initWithArray:[self.FocusSubjectArray copy]];;
        for (CMTConcern *concern in self.FocusSubjectArray) {
            if ([concern.subjectId isEqual:@"8"]||[concern.subjectId isEqual:@"9"]||[concern.subjectId isEqualToString:@"6"]) {
                [fouceArray removeObject:concern];
            }
            if ([concern.subject isEqualToString:@"消化"]) {
                concern.subject=@"消化&肝病";
            }
        }
        self.FocusSubjectArray=[fouceArray mutableCopy];
        self.FocusSubjectArray = [[self.FocusSubjectArray sortedArrayUsingComparator:^NSComparisonResult(CMTConcern* obj1, CMTConcern* obj2) {
            return [obj1.subjectId compare:obj2.subjectId options:NSCaseInsensitiveSearch];
        }]mutableCopy];
        
    }else{
        [self.FocusSubjectArray removeAllObjects];
    }


}
//获取总的学科列表
-(void)CMTGetAllsubjectsArray{
    if ([[NSFileManager defaultManager] fileExistsAtPath:PATH_TOTALSUBSCRIPTION]){
        self.allSujectsArray=[[NSKeyedUnarchiver unarchiveObjectWithFile:PATH_TOTALSUBSCRIPTION]mutableCopy];
        NSMutableArray *tempTotleArr = [self.allSujectsArray mutableCopy];
        
        /*订阅数据筛选*/
        if([self.FocusSubjectArray count]==0){
            for (CMTSubject *subject in self.allSujectsArray){
                if ([subject.subjectId isEqualToString:@"8"]||[subject.subjectId isEqualToString:@"9"]||[subject.subjectId isEqualToString:@"6"])
                {
                    [tempTotleArr removeObject:subject];
                }
            }
            
        }else{
            for (CMTConcern *concern in self.FocusSubjectArray)
            {
                for (CMTSubject *subject in self.allSujectsArray)
                {
                    if ([concern.subjectId isEqualToString:subject.subjectId]||[subject.subjectId isEqualToString:@"8"]||[subject.subjectId isEqualToString:@"9"]||[subject.subjectId isEqualToString:@"6"])
                    {
                        [tempTotleArr removeObject:subject];
                    }
                }
            }
        }
        
        [self.listDataSourceArray addObjectsFromArray:self.FocusSubjectArray];
        [self.listDataSourceArray addObjectsFromArray:tempTotleArr];
        if ([self.FocusSubjectArray count]<[self.listDataSourceArray count]&&[self.FocusSubjectArray count]>0) {
            self.isShowTableViewFoot=YES;
            
        }else{
            self.isShowTableViewFoot=NO;
        }
        [self.guidetableView reloadData];
    }else{
        @weakify(self);
        [[[CMTCLIENT getDepartmentList:@{@"isNew":@"1"}] deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(NSArray *array) {
            @strongify(self);
            self.allSujectsArray=[array mutableCopy];
            /*请求完成，完成数据筛选*/
            
            NSMutableArray *tempTotleArr = [self.allSujectsArray mutableCopy];
            /*订阅数据筛选*/
            for (CMTConcern *concern in self.FocusSubjectArray)
            {
                for (CMTSubject *subject in self.allSujectsArray)
                {
                    if ([concern.subjectId isEqualToString:subject.subjectId])
                    {
                        [tempTotleArr removeObject:subject];
                    }
                }
            }
            
            [self.listDataSourceArray addObjectsFromArray:self.FocusSubjectArray];
            [self.listDataSourceArray addObjectsFromArray:tempTotleArr];
            if ([self.FocusSubjectArray count]<[self.listDataSourceArray count]) {
                self.isShowTableViewFoot=YES;
            }else{
                self.isShowTableViewFoot=NO;
            }
            [self.guidetableView reloadData];
            
        } error:^(NSError *error) {
            CMTLog(@"获取学科列表失败%@",error);
        } completed:^{
            CMTLog(@"完成");
        }];
    }
   
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
        self.TagMarkerView.frame=CGRectMake(0, self.SearchView.bottom, self.TagMarkerView.width, self.TagMarkerView.height);
        self.headView.frame=CGRectMake(0, 0, SCREEN_WIDTH,self.TagMarkerView.frame.size.height+self.SearchView.height);
        self.guidetableView.tableHeaderView=self.headView;
        
        
    }else{
        [self.FocusTagArrays removeAllObjects];
        [self.TagMarkerView DrawTagMakerMangeView:[self.FocusTagArrays mutableCopy]];
        self.TagMarkerView.frame=CGRectMake(0, self.SearchView.bottom, self.TagMarkerView.width, self.TagMarkerView.height);
        self.headView.frame=CGRectMake(0, 0, SCREEN_WIDTH,self.TagMarkerView.frame.size.height+self.SearchView.height);
        self.guidetableView.tableHeaderView=self.headView;
    }
}

//TAgMArker视图代理 展示疾病指南文章列表
-(void)CMTGotoGuidePostListView:(CMTDisease*)Disease{
    self.isrefreshSubtableView=NO;
    for (CMTDisease *dis in self.FocusTagArrays) {
        if ([dis.diseaseId isEqualToString:Disease.diseaseId]) {
           
         CMTAPPCONFIG.GuideUnreadNumber=[@"" stringByAppendingFormat:@"%ld", (long)[CMTAPPCONFIG.GuideUnreadNumber integerValue]-[dis.count integerValue]];
            dis.count=@"0";
            dis.readTime=TIMESTAMP;
            break;
        }
    }

    [NSKeyedArchiver archiveRootObject:[self.FocusTagArrays mutableCopy] toFile:PATH_FOUSTAG];
    CMTOtherPostListViewController *need=[[CMTOtherPostListViewController alloc] initWithDisease:Disease.disease diseaseIds:Disease.diseaseId
                                          module:@"2"];

    [self.navigationController pushViewController:need animated:YES];
}
//添加疾病标签
-(void)CmtAddTagAction{
    [MobClick event:@"B_AddTag_Guideline"];
    self.isrefreshSubtableView=NO;
    CMTSubjectListViewController *suject=[[CMTSubjectListViewController alloc]init];
    [self.navigationController pushViewController:suject animated:YES];
}


//展开所有列表
-(void)OpenAllSubject{
    self.isShowTableViewFoot=NO;
    [self.guidetableView reloadData];
}
#pragma tableView 代理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return !_isShowTableViewFoot?[self.listDataSourceArray count]:[self.FocusSubjectArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CMTGuideSujectCell *cell=[[CMTGuideSujectCell alloc]initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:@"CMTGuideSujectCell"];
    if (cell==nil) {
        cell=[[CMTGuideSujectCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CMTGuideSujectCell"];
    }
    CMTSubject *subject=[!_isShowTableViewFoot?self.listDataSourceArray:self.FocusSubjectArray objectAtIndex:indexPath.row];
    NSLog(@"jdjjdjdjdjjdjdjddjjd%@%@",subject.subject,subject.subjectId);
    [cell reloadSujectCell:subject];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=[self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
   }
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return self.footControl;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (self.isShowTableViewFoot) {
        return 30;
    }else{
        return 0;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.isrefreshSubtableView=NO;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CMTSubject *suject=[self.isShowTableViewFoot?self.FocusSubjectArray:self.listDataSourceArray objectAtIndex:indexPath.row];
    [self addGuideStatistical:suject];
    CMTDiseaseListViewController *dislist=[[CMTDiseaseListViewController alloc]initWithSuject:suject isFromDic:YES];
    [self.navigationController pushViewController:dislist animated:YES];
    
//    CMTActivitiesViewController *activitiesViewController = [[CMTActivitiesViewController alloc] init];
//    [self.navigationController pushViewController:activitiesViewController animated:YES];
}
//添加点击监听
-(void)addGuideStatistical:(CMTSubject*)sub{
    
    if ([sub.subjectId isEqualToString:@"1"])
    {
        //肿瘤
        [MobClick event:@"B_Tumour_Guideline"];
    }
    else if ([sub.subjectId isEqualToString:@"2"])
    {
        //心血管
        [MobClick event:@"B_Cardio_Guideline"];
    }
    else if ([sub.subjectId isEqualToString:@"3"])
    {
        //内分泌
        [MobClick event:@"B_Endocrine_Guideline"];
    }
    else if ([sub.subjectId isEqualToString:@"4"])
    {
        //消化&肝病
        [MobClick event:@"B_Digestion_Guideline"];
    }
    else if ([sub.subjectId isEqualToString:@"5"])
    {
        //神经
        [MobClick event:@"B_Nerve_Guideline"];
    }
    else if ([sub.subjectId isEqualToString:@"6"])
    {
        //JAMA
        [MobClick event:@"B_JAMA_Paper"];
    } else if ([sub.subjectId isEqualToString:@"7"])
    {
        //口腔
        [MobClick event:@"B_Dental_Guideline"];
    }
    
}

@end
