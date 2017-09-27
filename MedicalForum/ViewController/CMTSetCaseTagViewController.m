//
//  CMTSetCaseTagViewController.m
//  MedicalForum
//
//  Created by guoyuanchao on 15/7/31.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTSetCaseTagViewController.h"

@interface CMTSetCaseTagViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UIBarButtonItem *CancelItem;//打开取消按钮
@property (nonatomic, strong) UIBarButtonItem *ConfirmItem;//打开确认按钮
@property(nonatomic,strong)NSArray *rightItems;//右侧按钮数组
@property(nonatomic,strong)NSArray *leftItems;//左侧按钮数组
@property(nonatomic,strong)UITableView *subjectTableView;
@property(nonatomic,strong)UITableView *tagTableView;
@property(nonatomic,strong)NSArray *subjectArray;//学科数组
@property(nonatomic,strong)NSArray *casetagArray;//疾病数组
@property(nonatomic,strong)NSMutableDictionary *cacheDic;//疾病缓存
@property(nonatomic,strong)NSMutableDictionary *subjectcache;//当前学科缓存;
@property(nonatomic,strong)NSMutableArray *selectDieaseArray;//选中数组
@property(nonatomic,strong)NSString *subjectId;//学科ID
@property(nonatomic,strong)UIView *ListEmptyBgView; //列表视图数据为空时的提示;
@property(nonatomic,strong)UILabel *EmptyLable;//空提示语
@property(nonatomic,assign)CMTSendCaseType module;

@end

@implementation CMTSetCaseTagViewController
- (UIBarButtonItem *)CancelItem {
    if (_CancelItem == nil) {
        _CancelItem = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(gotoback)];
        NSDictionary* textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                        COLOR(c_46CDC8),NSForegroundColorAttributeName,
                                        nil];
        [_CancelItem setTitleTextAttributes:textAttributes forState:0];
    }
    
    return _CancelItem;
}
- (UIBarButtonItem *)ConfirmItem {
    if (_ConfirmItem == nil) {
        _ConfirmItem = [[UIBarButtonItem alloc]initWithTitle:@"确定" style:UIBarButtonItemStyleDone target:self action:@selector(CMTSaveTag)];
        NSDictionary* textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                        COLOR(c_46CDC8),NSForegroundColorAttributeName,
                                        nil];
         [_ConfirmItem setTitleTextAttributes:textAttributes forState:0];
    }
   
    
    
   
    return _ConfirmItem;
}


- (NSArray *)leftItems {
    if (_leftItems == nil) {
        UIBarButtonItem *leftFixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        leftFixedSpace.width =(RATIO - 1.0)*(CGFloat)10;
        _leftItems = @[leftFixedSpace, self.CancelItem];
    }
    
    return _leftItems;
}
- (NSArray *)rightItems {
    if (_rightItems == nil) {
        UIBarButtonItem *FixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        FixedSpace.width = (RATIO - 1.0)*(CGFloat)10;
        _rightItems=[[NSArray alloc]initWithObjects:FixedSpace,self.ConfirmItem, nil];
            
    }
    
    return _rightItems;
}
-(UITableView*)subjectTableView{
    if (_subjectTableView==nil) {
        _subjectTableView=[[UITableView alloc]initWithFrame:CGRectMake(0, CMTNavigationBarBottomGuide,120, SCREEN_HEIGHT-CMTNavigationBarBottomGuide)];
        _subjectTableView.delegate=self;
        _subjectTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
        _subjectTableView.backgroundColor=COLOR(c_efeff4);
        _subjectTableView.dataSource=self;
        _subjectTableView.scrollEnabled=NO;

    }
    return _subjectTableView;
}
-(UITableView*)tagTableView{
    if (_tagTableView==nil) {
        _tagTableView=[[UITableView alloc]initWithFrame:CGRectMake(120, CMTNavigationBarBottomGuide,SCREEN_WIDTH-120, SCREEN_HEIGHT-CMTNavigationBarBottomGuide)];
        _tagTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
        _tagTableView.delegate=self;
        _tagTableView.backgroundColor=COLOR(c_ffffff);
        _tagTableView.dataSource=self;
        
    }
    return _tagTableView;
}
-(NSMutableArray*)selectDieaseArray{
    if (_selectDieaseArray==nil) {
        _selectDieaseArray=[[NSMutableArray alloc]init];
    }
    return _selectDieaseArray;
}
-(UIView*)ListEmptyBgView{
    if (_ListEmptyBgView==nil) {
        _ListEmptyBgView=[[UIView alloc]initWithFrame:CGRectMake(120, CMTNavigationBarBottomGuide,SCREEN_WIDTH-120, SCREEN_HEIGHT-CMTNavigationBarBottomGuide)];
        _ListEmptyBgView.hidden=NO;
        [_ListEmptyBgView setBackgroundColor:COLOR(c_ffffff)];
        self.EmptyLable=[[UILabel alloc]initWithFrame:CGRectMake(0,(_ListEmptyBgView.height-35)/2, _ListEmptyBgView.width, 35)];
        [ self.EmptyLable setTextColor:[UIColor colorWithHexString:@"#c8c8c8"]];
        [ self.EmptyLable setFont:[UIFont systemFontOfSize:20]];
        [ self.EmptyLable setTextAlignment:NSTextAlignmentCenter];
        [ self.EmptyLable setText:@"该学科下暂无疾病信息"];
        [_ListEmptyBgView addSubview: self.EmptyLable];
    }
    return _ListEmptyBgView;
}
-(NSMutableDictionary*)cacheDic{
    if (_cacheDic==nil) {
        _cacheDic=[[NSMutableDictionary alloc]init];
    }
    return _cacheDic;
}
-(NSMutableDictionary*)subjectcache{
    if (_subjectcache==nil) {
        _subjectcache=[[NSMutableDictionary alloc]init];
    }
    return _subjectcache;
}

-(instancetype)initWithSubject:(NSString*)subjectId module:(CMTSendCaseType)module{
    self=[super init];
    if (self) {
        self.subjectId=subjectId;
        self.module=module;
        if ((self.module==CMTSendCaseTypeAddPostDescribe)||(self.module==CMTSendCaseTypeAddPostConclusion)) {
            [self.selectDieaseArray addObjectsFromArray:CMTAPPCONFIG.addPostAdditionalData.diseaseTagArray];
        }else if (self.module==CMTSendCaseTypeAddPost){
            [self.selectDieaseArray addObjectsFromArray:CMTAPPCONFIG.addPostData.diseaseTagArray];

        }else if (self.module==CMTSendCaseTypeAddGroupPost){
            [self.selectDieaseArray addObjectsFromArray:CMTAPPCONFIG.addGroupPostData.diseaseTagArray];
            
        }

    }
    return self;
    
}
//返回上一级
-(void)gotoback{
    [self dismissViewControllerAnimated:YES completion:nil];
}
//保存tag
-(void)CMTSaveTag{
    if ((self.module==CMTSendCaseTypeAddPostDescribe)||(self.module==CMTSendCaseTypeAddPostConclusion)) {
       CMTAPPCONFIG.addPostAdditionalData.diseaseTagArray=[self.selectDieaseArray copy];
    }else if (self.module==CMTSendCaseTypeAddPost){
        CMTAPPCONFIG.addPostData.diseaseTagArray=[self.selectDieaseArray copy];
        
    }else if (self.module==CMTSendCaseTypeAddGroupPost){
        CMTAPPCONFIG.addGroupPostData.diseaseTagArray=[self.selectDieaseArray copy];
        
    }
    if (self.deleagte!=nil) {
        [self.deleagte setCaseTagData];
    }


    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    //调立方
    [self.rac_willDeallocSignal subscribeCompleted:^{
        CMTLog(@"setCaseTag willDeallocSignal");
    }];
    [self setContentState:CMTContentStateLoading];
    
    self.navigationItem.leftBarButtonItems=self.leftItems;
    self.navigationItem.rightBarButtonItems=self.rightItems;
    [self.contentBaseView addSubview:self.subjectTableView];
    [self.contentBaseView addSubview:self.ListEmptyBgView];
    [self.contentBaseView addSubview:self.tagTableView];
    [self gettableViewdData];
}
//获取列表数据
-(void)gettableViewdData{
    [self CMTGetAllsubjectsArray];
  
}
//获取疾病列表
-(void)getDieaseaList{
    self.cacheDic=[NSKeyedUnarchiver unarchiveObjectWithFile:PATH_CACHE_DRSEAAELIST];
    self.casetagArray=[[self.cacheDic objectForKey:self.subjectId] objectForKey:@"data"];
    if (self.casetagArray==nil) {
        [self CMTGetDieasedata];
    }else{
        if (self.casetagArray.count==0) {
            self.tagTableView.hidden=YES;
            
        }else{
            self.tagTableView.hidden=NO;
            
            [self.tagTableView reloadData];
        }
        [self setContentState:CMTContentStateNormal];
        [self stopAnimation];

        
    }

}
//获取所有学科数据
-(void)CMTGetAllsubjectsArray{
    if ([[NSFileManager defaultManager] fileExistsAtPath:PATH_TOTALSUBSCRIPTION]){
        self.subjectArray=[NSKeyedUnarchiver unarchiveObjectWithFile:PATH_TOTALSUBSCRIPTION];
        NSMutableArray *tempTotleArr = [self.subjectArray mutableCopy];
        
        /*订阅数据筛选*/
        for (CMTConcern *concern in self.subjectArray)
        {
            if ([concern.subjectId isEqualToString:@"8"]||[concern.subjectId isEqualToString:@"6"])
            {
                [tempTotleArr removeObject:concern];
            }
        }
        self.subjectArray=[tempTotleArr copy];
        [self.subjectTableView reloadData];
        //获取选中位置
        [self getArrayindex];
        [self getDieaseaList];
    }else{
        @weakify(self);
        [[[CMTCLIENT getDepartmentList:@{@"isNew":@"1"}] deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(NSArray *array) {
            @strongify(self);
            self.subjectArray=[array mutableCopy];
            [NSKeyedArchiver archiveRootObject:[array mutableCopy] toFile:PATH_TOTALSUBSCRIPTION];
            /*请求完成，完成数据筛选*/
            
            NSMutableArray *tempTotleArr = [array mutableCopy];
            /*订阅数据筛选*/
            for (CMTConcern *concern in self.subjectArray)
            {
                if ([concern.subjectId isEqualToString:@"8"]||[concern.subjectId isEqualToString:@"6"])
                {
                    [tempTotleArr removeObject:concern];
                }
            }
            self.subjectArray=[tempTotleArr copy];
            [self.subjectTableView reloadData];
            //获取选中位置
            [self getArrayindex];
            [self getDieaseaList];
            
        } error:^(NSError *error) {
            CMTLog(@"获取学科列表失败%@",error);
        } completed:^{
            CMTLog(@"完成");
        }];
    }
}

//获取网络数据
-(void)CMTGetDieasedata{
    NSDictionary *pic=@{@"subjectId":self.subjectId?:@" "};
    @weakify(self);
    [[[CMTCLIENT GetDiseaseList:pic]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(NSArray *array){
        @strongify(self);
        self.casetagArray=[array mutableCopy];
        [self.cacheDic setValue:self.casetagArray forKey:@"data"];
        [self.subjectcache setValue:TIMESTAMP forKey:@"savetime"];
        [self.cacheDic setObject:self.subjectcache forKey:self.subjectId];
        [NSKeyedArchiver archiveRootObject:self.cacheDic toFile:PATH_CACHE_DRSEAAELIST];
        if([self.casetagArray count]>0){
            self.tagTableView.hidden=NO;
            [self.tagTableView reloadData];
            [self setContentState:CMTContentStateNormal];
        }else{
            self.tagTableView.hidden=YES;
        }
        [self stopAnimation];
        [self setContentState:CMTContentStateNormal];
    } error:^(NSError *error) {
        @strongify(self);
        CMTLog(@"网络请求错误%@",error);
        [self setContentState:CMTContentStateReload];
        [self stopAnimation];
        
    }];
    
}
- (void)animationFlash {
    [super animationFlash];
    [self CMTGetDieasedata];
}

//获取选中的位置
-(void)getArrayindex{
    if (self.subjectId==nil) {
        NSIndexPath *first = [NSIndexPath indexPathForRow:0 inSection:0];
        
        CMTConcern *concern=[self.subjectArray objectAtIndex:0];
        self.subjectId=concern.subjectId;
        [self.subjectTableView selectRowAtIndexPath:first
                                           animated:YES
                                     scrollPosition:UITableViewScrollPositionNone];
    }else{
        for (int i=0;i<[self.subjectArray count];i++) {
            CMTConcern *concern=[self.subjectArray objectAtIndex:i];
            if ([concern.subjectId isEqualToString:self.subjectId]) {
                NSIndexPath *first = [NSIndexPath indexPathForRow:i  inSection:0];
                [self.subjectTableView selectRowAtIndexPath:first
                                                   animated:YES
                                             scrollPosition:UITableViewScrollPositionNone];
                return;
            }
        }
    }
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView==self.tagTableView) {
        return  [self.casetagArray count];
    }else{
        return [self.subjectArray count];
    }
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
    

    if (tableView==_tagTableView) {
        CMTDisease *dis=[self.casetagArray objectAtIndex:indexPath.row];
        cell.backgroundColor=COLOR(c_ffffff);
        UILabel *lable=[[UILabel alloc]initWithFrame:CGRectMake(30, 0,tableView.width-80-(RATIO - 1.0)*(CGFloat)10, 60)];
        lable.text=dis.disease;
        lable.font=[UIFont systemFontOfSize:14];
        [cell.contentView addSubview:lable];
        UIImageView *imageView=[[UIImageView alloc]initWithFrame:CGRectMake(tableView.width-50+(RATIO - 1.0)*(CGFloat)10, 15, 30, 30)];
        imageView.tag=100;
        if ([self.selectDieaseArray containsObject:dis]) {
            imageView.image=IMAGE(@"selectTag");
        }
        [cell.contentView addSubview:imageView];
        
        
    }else{
         CMTConcern *concern=[self.subjectArray objectAtIndex:indexPath.row];
         cell.textLabel.text=concern.subject;
         cell.selectedBackgroundView =[[UIView alloc] initWithFrame:cell.frame];
         cell.selectedBackgroundView.backgroundColor=COLOR(c_ffffff);
         cell.textLabel.highlightedTextColor = COLOR(c_46CDC8);
        UIView *lineview=[[UIView alloc]initWithFrame:CGRectMake(0, 59, cell.width, 1)];
        lineview.backgroundColor=[UIColor colorWithHexString:@"E9E9ED"];
        [cell.contentView addSubview:lineview];
    }
    
       return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView==self.subjectTableView) {
          CMTConcern *concern=[self.subjectArray objectAtIndex:indexPath.row];
        self.cacheDic=[NSKeyedUnarchiver unarchiveObjectWithFile:PATH_CACHE_DRSEAAELIST];
        self.casetagArray=[[self.cacheDic objectForKey:concern.subjectId] objectForKey:@"data"];
        self.subjectId=concern.subjectId;
        if (self.casetagArray==nil) {
            [self CMTGetDieasedata];
        }else{
            if (self.casetagArray.count==0) {
                self.tagTableView.hidden=YES;
                
            }else{
                 self.tagTableView.hidden=NO;
                [self.tagTableView reloadData];
            }

            
        }

    }else{
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        CMTDisease *dis=[self.casetagArray objectAtIndex:indexPath.row];
        UITableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
        if ([self.selectDieaseArray containsObject:dis]) {
            ((UIImageView*)[cell.contentView viewWithTag:100]).image=nil;
            [self.selectDieaseArray removeObject:dis];

        }else{
            if ([self.selectDieaseArray count]==10) {
                [self toastAnimation:@"病例标签最多选择10个"];
            }else{
               [self.selectDieaseArray addObject:dis];
                ((UIImageView*)[cell.contentView viewWithTag:100]).image=IMAGE(@"selectTag");
            }
        }
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
