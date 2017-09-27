//
//  CMTThemAllSubjectViewController.m
//  MedicalForum
//
//  Created by guoyuanchao on 16/9/13.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import "CMTThemAllSubjectViewController.h"
#import "CMTGuideSujectCell.h"
#import "CMTSubjectThemlistViewController.h"
@interface CMTThemAllSubjectViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)UITableView *subjectTableView;  //指南列表视图
@property(nonatomic,strong)NSMutableArray *allSujectsArray;  //全部学科列表
@property(nonatomic,strong)NSMutableArray*focusSujectsArray;//全部关注学科
@property(nonatomic,strong)NSMutableArray*unfocusSujectsArray;//未关注学科
@end

@implementation CMTThemAllSubjectViewController
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
-(NSMutableArray*)focusSujectsArray{
    if (_focusSujectsArray==nil) {
        _focusSujectsArray=[[NSMutableArray alloc]init];
    }
    return _focusSujectsArray;
}
-(NSMutableArray*)unfocusSujectsArray{
    if (_unfocusSujectsArray==nil) {
        _unfocusSujectsArray=[[NSMutableArray alloc]init];
    }
    return _unfocusSujectsArray;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}
-(void)viewDidLoad{
    [super viewDidLoad];
    [self.rac_willDeallocSignal subscribeCompleted:^{
        CMTLog(@"PostList willDeallocSignal");
    }];
    
    self.titleText=@"全部专题";
    [self setContentState:CMTContentStateNormal];
    [self.subjectTableView fillinContainer:self.contentBaseView WithTop:CMTNavigationBarBottomGuide Left:0.0 Bottom:0 Right:0.0];
    [self CMTGetAllsubjectsArray];
}

//获取所有学科数据
-(void)CMTGetAllsubjectsArray{
    if([[NSFileManager defaultManager] fileExistsAtPath:[PATH_USERS stringByAppendingPathComponent:@"subscription"]]){
        self.focusSujectsArray=[NSKeyedUnarchiver unarchiveObjectWithFile:[PATH_USERS stringByAppendingPathComponent:@"subscription"]];
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:PATH_TOTALSUBSCRIPTION]){
        self.allSujectsArray=[NSKeyedUnarchiver unarchiveObjectWithFile:PATH_TOTALSUBSCRIPTION];
        
        for (CMTSubject* sub in self.allSujectsArray) {
            bool flag=YES;
            for (CMTSubject *sub1 in self.focusSujectsArray) {
                if ([sub.subjectId isEqualToString:sub1.subjectId]) {
                    flag=NO;
                }
            }
            if (flag) {
                [self.unfocusSujectsArray addObject:sub];
            }
        }
         [self.subjectTableView reloadData];
    }else{
        @weakify(self);
        [[[CMTCLIENT getDepartmentList:@{@"isNew":@"1"}] deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(NSArray *array) {
            @strongify(self);
            self.allSujectsArray=[array mutableCopy];
            for (CMTSubject* sub in self.allSujectsArray) {
                bool flag=YES;
                for (CMTSubject *sub1 in self.focusSujectsArray) {
                    if ([sub.subjectId isEqualToString:sub1.subjectId]) {
                        flag=NO;
                    }
                }
                if (flag) {
                    [self.unfocusSujectsArray addObject:sub];
                }
            }

            [self.subjectTableView reloadData];
            
        } error:^(NSError *error) {
            CMTLog(@"获取学科列表失败%@",error);
        } completed:^{
            CMTLog(@"完成");
        }];
    }
    
}

#pragma tableView 代理
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section==0) {
        return self.focusSujectsArray.count;
    }
    return [self.unfocusSujectsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CMTGuideSujectCell *cell=[[CMTGuideSujectCell alloc]initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:@"CMTGuideSujectCell"];
    if (cell==nil) {
        cell=[[CMTGuideSujectCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CMTGuideSujectCell"];
    }
    CMTSubject *subject=nil;
    if (indexPath.section==0) {
        subject=[self.focusSujectsArray objectAtIndex:indexPath.row];
    }else{
        subject=[self.unfocusSujectsArray objectAtIndex:indexPath.row];
    }
    
    [cell reloadSujectCell:subject];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=[self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if((self.focusSujectsArray.count<self.allSujectsArray.count)&&self.focusSujectsArray.count>0){
        if (section==1) {
            return 10;
        }

    }
  return 0;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CMTSubject *subject=nil;
    if (indexPath.section==0) {
        subject=[self.focusSujectsArray objectAtIndex:indexPath.row];
    }else{
        subject=[self.unfocusSujectsArray objectAtIndex:indexPath.row];
    }

    [self addGuideStatistical:subject];
    CMTSubjectThemlistViewController *dislist=[[CMTSubjectThemlistViewController alloc]initWithSubject:subject];
    [self.navigationController pushViewController:dislist animated:YES];
}
//添加点击监听
-(void)addGuideStatistical:(CMTSubject*)sub{
     switch (sub.subjectId.integerValue) {
          case 1:
            //肿瘤
            [MobClick event:@"B_Tumour_AllTheme"];
            break;
          case 2:
            //心血管
            [MobClick event:@"B_Cardio_AllTheme"];
            break;
          case 3:
            //内分泌
           [MobClick event:@"B_Endocrine_AllTheme"];
            break;
          case 4:
            //消化与肝病
            [MobClick event:@"B_Digestion_AllTheme"];
            break;
          case 5:
            //神经
            [MobClick event:@"B_Nerve_AllTheme"];
            break;
          case 6:
            //全科
            [MobClick event:@"B_General_AllTheme"];
            break;
          case 7:
            //口腔
            [MobClick event:@"B_Dental_AllTheme"];
            break;
          case 8:
            //JAMA
            [MobClick event:@"B_JAMA_AllTheme"];
            break;
          case 9:
            //综合与人文
            [MobClick event:@"B_Culture_AllTheme"];
            }
}

@end
