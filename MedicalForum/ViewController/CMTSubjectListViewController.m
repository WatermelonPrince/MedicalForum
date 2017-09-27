//
//  CMTGuideSubjectListViewController.m
//  MedicalForum
//
//  Created by CMT on 15/6/10.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTSubjectListViewController.h"
#import "CMTGuideSujectCell.h"
#import "CMTSubject.h"
#import "CMTDiseaseListViewController.h"

@interface CMTSubjectListViewController()
@property(nonatomic,strong)UITableView *subjectTableView;  //指南列表视图
@property(nonatomic,strong)NSMutableArray *allSujectsArray;  //全部学科列表
@end
@implementation CMTSubjectListViewController
//列表
-(UITableView*)subjectTableView{
    if (_subjectTableView==nil) {
        _subjectTableView=[[UITableView alloc]init];
        _subjectTableView.backgroundColor =[UIColor colorWithHexString:@"#EFEFF4"];
        _subjectTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _subjectTableView.dataSource = self;
        _subjectTableView.delegate = self;
        [_subjectTableView registerClass:[CMTGuideSujectCell class] forCellReuseIdentifier:@"CMTGuideSujectCell"];
        
    }
    return _subjectTableView;
}
-(NSMutableArray*)allSujectsArray{
    if (_allSujectsArray==nil) {
        _allSujectsArray=[[NSMutableArray alloc]init];
    }
    return _allSujectsArray;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}
-(void)viewDidLoad{
    [super viewDidLoad];
    [self.rac_willDeallocSignal subscribeCompleted:^{
        CMTLog(@"PostList willDeallocSignal");
    }];

    self.titleText=@"选择学科";
    [self setContentState:CMTContentStateNormal];
    [self.subjectTableView fillinContainer:self.contentBaseView WithTop:CMTNavigationBarBottomGuide Left:0.0 Bottom:0 Right:0.0];
    [self CMTGetAllsubjectsArray];
}

//获取所有学科数据
-(void)CMTGetAllsubjectsArray{
    if ([[NSFileManager defaultManager] fileExistsAtPath:PATH_TOTALSUBSCRIPTION]){
        self.allSujectsArray=[NSKeyedUnarchiver unarchiveObjectWithFile:PATH_TOTALSUBSCRIPTION];
        NSMutableArray *tempTotleArr = [self.allSujectsArray mutableCopy];
        
        /*订阅数据筛选*/
        for (CMTSubject *concern in self.allSujectsArray)
        {
            if(APPDELEGATE.tabBarController.selectedIndex==3){
                if ([concern.subjectId isEqualToString:@"8"]||[concern.subjectId isEqualToString:@"9"]||[concern.subjectId isEqualToString:@"6"])
                {
                    [tempTotleArr removeObject:concern];
                }

               }else{
                if ([concern.subjectId isEqualToString:@"8"]||[concern.subjectId isEqualToString:@"6"])
                    {
                        [tempTotleArr removeObject:concern];
                    }
                }
        }
        self.allSujectsArray=[tempTotleArr mutableCopy];
           [self.subjectTableView reloadData];
    }else{
        @weakify(self);
        [[[CMTCLIENT getDepartmentList:@{@"isNew":@"1"}] deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(NSArray *array) {
            @strongify(self);
            self.allSujectsArray=[array mutableCopy];
            NSMutableArray *tempTotleArr = [self.allSujectsArray mutableCopy];
            /*订阅数据筛选*/
            for (CMTSubject *concern in self.allSujectsArray)
            {
                if(APPDELEGATE.tabBarController.selectedIndex==3){
                    if ([concern.subjectId isEqualToString:@"8"]||[concern.subjectId isEqualToString:@"9"]||[concern.subjectId isEqualToString:@"6"])
                    {
                        [tempTotleArr removeObject:concern];
                    }
                    
                }else{
                    if ([concern.subjectId isEqualToString:@"8"]||[concern.subjectId isEqualToString:@"6"])
                    {
                        [tempTotleArr removeObject:concern];
                    }
                }
            }
             self.allSujectsArray=[tempTotleArr mutableCopy];
            [self.subjectTableView reloadData];
            
        } error:^(NSError *error) {
            CMTLog(@"获取学科列表失败%@",error);
        } completed:^{
            CMTLog(@"完成");
        }];
    }

}

#pragma tableView 代理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.allSujectsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CMTGuideSujectCell *cell=[[CMTGuideSujectCell alloc]initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:@"CMTGuideSujectCell"];
    if (cell==nil) {
        cell=[[CMTGuideSujectCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CMTGuideSujectCell"];
    }
    CMTSubject *subject=[self.allSujectsArray objectAtIndex:indexPath.row];
    [cell reloadSujectCell:subject];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=[self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
     CMTSubject*suject=[self.allSujectsArray objectAtIndex:indexPath.row];
    [self addGuideStatistical:suject];
    CMTDiseaseListViewController *dislist=[[CMTDiseaseListViewController alloc]initWithSuject:suject isFromDic:NO];
    [self.navigationController pushViewController:dislist animated:YES];
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
