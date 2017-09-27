//
//  CMTDiseaseListViewController.m
//  MedicalForum
//
//  Created by CMT on 15/6/8.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTDiseaseListViewController.h"
#import "CMTSubject.h"
#import "CMTDiseaseListCell.h"
#import "CMTOtherPostListViewController.h"
@interface CMTDiseaseListViewController()
@property(nonatomic,strong)UITableView *DisListTableView;//病例列表
@property(nonatomic,strong)CMTSubject *subject; //学科
@property(nonatomic,strong)NSMutableArray *listDataSource;//列表数据源
@property(nonatomic,strong)NSMutableDictionary *cacheDic;//缓存数据字典
@property(nonatomic,strong)NSMutableDictionary *subjectcache;//当前学科缓存;
@property(nonatomic,strong)NSString *savetime; //疾病列表存储时间
@property(nonatomic,assign)BOOL isfromDic; //是否从指南目录进入
@end
@implementation CMTDiseaseListViewController
-(instancetype)initWithSuject:(CMTSubject*)subject isFromDic:(BOOL)isfromDic{
    self=[super init];
    if (self) {
        self.subject=subject;
        self.isfromDic=isfromDic;
    }
    return self;
}
-(CMTSubject*)subject{
    if (_subject==nil) {
        _subject=[[CMTSubject alloc]init];
    }
    return _subject;
}
-(NSMutableDictionary*)cacheDic{
    if (_cacheDic==nil) {
        _cacheDic=[[NSMutableDictionary alloc]init];
    }
    return _cacheDic;
}
-(NSMutableArray*)listDataSource{
    if (_listDataSource==nil) {
        _listDataSource=[[NSMutableArray alloc]init];
    }
    return _listDataSource;
}
-(UITableView*)DisListTableView{
    if (_DisListTableView ==nil) {
        _DisListTableView=[[UITableView alloc]init];
        [_DisListTableView fillinContainer:self.contentBaseView WithTop:CMTNavigationBarBottomGuide Left:0 Bottom:0 Right:0];
        [_DisListTableView setBackgroundColor:[UIColor colorWithHexString:@"#EFEFF4"]];
        _DisListTableView.delegate=self;
        _DisListTableView.dataSource=self;
        _DisListTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
        [_DisListTableView registerClass:[CMTDiseaseListCell class] forCellReuseIdentifier:@"CMTDiseaseListCell"];
        if (!self.isfromDic) {
            [self.DisListTableView setAllowsSelection:NO];
        }
    }
    return _DisListTableView;
}
-(NSMutableDictionary*)subjectcache{
    if (_subjectcache==nil) {
        _subjectcache=[[NSMutableDictionary alloc]init];
    }
    return _subjectcache;
}

#pragma 控制器生命周期
-(void)viewDidLoad{
    [super viewDidLoad];
   //监听对象释放
    [self.rac_willDeallocSignal subscribeCompleted:^{
        CMTLog(@"CMTDiseaseListViewController willDeallocSignal");
    }];

    self.titleText=self.subject.subject;
   //设置跳立方
    [self setContentState:CMTContentStateLoading];
    
    //获取数据加载列表
    [self CMTGetListData];

}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tabBarContainer.hidden=YES;
}
-(void)viewWillDisappear:(BOOL)animated{
    self.tabBarContainer.hidden=NO;
}
//获取列表数据
-(void)CMTGetListData{
    if([[NSFileManager defaultManager ] fileExistsAtPath:PATH_CACHE_DRSEAAELIST]){
        self.cacheDic=[NSKeyedUnarchiver unarchiveObjectWithFile:PATH_CACHE_DRSEAAELIST];
        self.savetime=[[self.cacheDic objectForKey:self.subject.subjectId] objectForKey:@"savetime"];
        self.listDataSource=[[self.cacheDic objectForKey:self.subject.subjectId] objectForKey:@"data"];
        if ([self.listDataSource count]>0) {
     
            if (![self isNeedUdateCache]) {
                [self.DisListTableView reloadData];
                [self stopAnimation];
                [self setContentState:CMTContentStateNormal];
            }else{
                [self CMTGetNetdata];
            }
        }else{
            [self CMTGetNetdata];
        }
    }else{
         [self CMTGetNetdata];
    }
}
//判断是否需要更新缓存
-(BOOL)isNeedUdateCache{
    BOOL isneed=false;
    if (([TIMESTAMP integerValue]- [self.savetime integerValue])/60/24/60/1000>=7) {
        isneed=YES;
    }
    return isneed;
}
//获取网络数据
-(void)CMTGetNetdata{
    NSDictionary *pic=@{@"subjectId":self.subject.subjectId};
    @weakify(self);
    [[[CMTCLIENT GetDiseaseList:pic]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(NSArray *array){
        @strongify(self);
        self.listDataSource=[array mutableCopy];
        [self.subjectcache setValue:self.listDataSource forKey:@"data"];
        [self.subjectcache setValue:TIMESTAMP forKey:@"savetime"];
        [self.cacheDic setObject:self.subjectcache forKey:self.subject.subjectId];
        [NSKeyedArchiver archiveRootObject:self.cacheDic toFile:PATH_CACHE_DRSEAAELIST];
        if([self.listDataSource count]>0){
          [self.DisListTableView reloadData];
          [self setContentState:CMTContentStateNormal];
        }else{
            [self setContentState:CMTContentStateEmpty];
            self.contentEmptyView.contentEmptyPrompt=@"该学科下暂无疾病信息";
        }
        [self stopAnimation];
    } error:^(NSError *error) {
        @strongify(self);
        CMTLog(@"网络请求错误%@",error);
           [self setContentState:CMTContentStateReload];
        [self stopAnimation];
        
    }];
    
}
#pragma mark 重新加载

- (void)animationFlash {
    [super animationFlash];
    [self CMTGetNetdata];
}


//UItableView 代理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.listDataSource count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CMTDiseaseListCell *cell=[tableView dequeueReusableCellWithIdentifier:@"CMTDiseaseListCell"];
    if (cell==nil) {
        cell=[[CMTDiseaseListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CMTDiseaseListCell"];
    }
    cell.isShowFocusButton=!self.isfromDic;
    CMTDisease *dis=[self.listDataSource objectAtIndex:indexPath.row];
    [cell reloadCellData:dis index:indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=[self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CMTDisease *Disease=[self.listDataSource objectAtIndex:indexPath.row];
    CMTOtherPostListViewController *dis=[[CMTOtherPostListViewController alloc] initWithDisease:Disease.disease diseaseIds:Disease.diseaseId
                                                                                          module:@"2"];
    [self.navigationController pushViewController:dis animated:YES];
    NSMutableArray *Disarray=[[NSMutableArray alloc]init];
    Disarray=[[NSKeyedUnarchiver unarchiveObjectWithFile:PATH_FOUSTAG]mutableCopy];
    for(CMTDisease *dis in Disarray){
        if ([dis.diseaseId isEqualToString:Disease.diseaseId]) {
           
                CMTAPPCONFIG.GuideUnreadNumber=[@"" stringByAppendingFormat:@"%ld", (long)[CMTAPPCONFIG.GuideUnreadNumber integerValue]-[dis.count integerValue]];
                dis.count=@"0";
                dis.readTime=TIMESTAMP;
            break;
        }
    }
    [NSKeyedArchiver archiveRootObject:[Disarray mutableCopy] toFile:PATH_FOUSTAG];

 }


@end
