//
//  CMTCaseSendSubjectViewController.m
//  MedicalForum
//
//  Created by guoyuanchao on 15/8/4.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTCaseSendSubjectViewController.h"
#import "CMTSubject.h"

@interface CMTCaseSendSubjectViewController ()<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong)UITableView *subjectTableView;
@property(nonatomic,strong)NSArray *subjectArray;
@property(nonatomic,assign)CMTSendCaseType module;
@property(nonatomic,strong)CMTSubject *selectedSub;


@end

@implementation CMTCaseSendSubjectViewController
-(UITableView*)subjectTableView{
    if (_subjectTableView==nil) {
        _subjectTableView=[[UITableView alloc]initWithFrame:CGRectMake(0, CMTNavigationBarBottomGuide,SCREEN_WIDTH, SCREEN_HEIGHT-CMTNavigationBarBottomGuide)];
        _subjectTableView.delegate=self;
        _subjectTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
        _subjectTableView.backgroundColor=COLOR(c_efeff4);
        _subjectTableView.dataSource=self;
        _subjectTableView.scrollEnabled=NO;
        
    }
    return _subjectTableView;
}
-(instancetype)initWithModule:(CMTSendCaseType)module{
    self=[super init];
    if (self){
        self.module=module;
        if (module==CMTSendCaseTypeAddPost) {
            self.selectedSub=CMTAPPCONFIG.addPostSubject;
        }
    }
    return self;
    
}
//获取所有学科数据
-(void)CMTGetAllsubjectsArray{
    if ([[NSFileManager defaultManager] fileExistsAtPath:PATH_TOTALSUBSCRIPTION]){
        self.subjectArray=[NSKeyedUnarchiver unarchiveObjectWithFile:PATH_TOTALSUBSCRIPTION];
        NSMutableArray *tempTotleArr = [self.subjectArray mutableCopy];
        
        /*订阅数据筛选*/
        for (CMTConcern *concern in self.subjectArray)
        {
            if ([concern.subjectId isEqualToString:@"8"])
            {
                [tempTotleArr removeObject:concern];
            }
        }
        self.subjectArray=[tempTotleArr copy];
        [self.subjectTableView reloadData];
        [self stopAnimation];
        [self setContentState:CMTContentStateNormal];
    }else{
        @weakify(self);
        [[[CMTCLIENT getDepartmentList:@{@"isNew":@"1"}] deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(NSArray *array) {
            @strongify(self);
            self.subjectArray=[array mutableCopy];
            [NSKeyedArchiver archiveRootObject:[array mutableCopy] toFile:PATH_TOTALSUBSCRIPTION];
            NSMutableArray *tempTotleArr = [self.subjectArray mutableCopy];
            
            /*订阅数据筛选*/
            for (CMTConcern *concern in self.subjectArray)
            {
                if ([concern.subjectId isEqualToString:@"8"])
                {
                    [tempTotleArr removeObject:concern];
                }
            }
            self.subjectArray=[tempTotleArr copy];
            [self.subjectTableView reloadData];
            [self stopAnimation];
            [self setContentState:CMTContentStateNormal];        } error:^(NSError *error) {
            CMTLog(@"获取学科列表失败%@",error);
        } completed:^{
            CMTLog(@"完成");
        }];
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleText=@"选择学科";
    [self.contentBaseView addSubview:self.subjectTableView];
  
    [self CMTGetAllsubjectsArray];
}

#pragma  UItableview dataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.subjectArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"tagCell"];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tagCell"];
        cell.backgroundColor=COLOR(c_efeff4);
    }
    for (UIView *view in [cell.contentView subviews]) {
        [view removeFromSuperview];
    }
    
        CMTConcern *concern=[self.subjectArray objectAtIndex:indexPath.row];
        cell.backgroundColor=COLOR(c_ffffff);
        UILabel *lable=[[UILabel alloc]initWithFrame:CGRectMake(10, 0,tableView.width-60-(RATIO - 1.0)*(CGFloat)10, 60)];
        lable.text=concern.subject;
        lable.font=[UIFont systemFontOfSize:16];
        [cell.contentView addSubview:lable];
    
    
        UIImageView *imageView=[[UIImageView alloc]initWithFrame:CGRectMake(tableView.width-50+(RATIO - 1.0)*(CGFloat)10, 15, 30, 30)];
        imageView.tag=100;
        if ([self.selectedSub.subjectId isEqualToString:concern.subjectId]) {
            imageView.image=IMAGE(@"selectTag");
        }
       [cell.contentView addSubview:imageView];
    
    
       UIView *lineview=[[UIView alloc]initWithFrame:CGRectMake(0, 59, SCREEN_WIDTH, 1)];
       lineview.backgroundColor=[UIColor colorWithHexString:@"E9E9ED"];
       [cell.contentView addSubview:lineview];

    
        
    
    return cell;
}
#pragma  UItableview delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.module==CMTSendCaseTypeAddPost) {
        
        CMTSubject *subject = nil;
        if (indexPath.row < self.subjectArray.count) {
            CMTConcern *concern=[self.subjectArray objectAtIndex:indexPath.row];
            subject = [[CMTSubject alloc] initWithDictionary:@{
                                                               @"subjectId": concern.subjectId ?: @"",
                                                               @"subject": concern.subject ?: @"",
                                                               } error:nil];
        }
        
        CMTAPPCONFIG.addPostSubject = subject;
    }
    if (self.delegate !=nil&&[self.delegate respondsToSelector:@selector(refreshSubjectName)]) {
        [self.delegate refreshSubjectName];
    }
    [self.navigationController popViewControllerAnimated:YES];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   
}

@end
