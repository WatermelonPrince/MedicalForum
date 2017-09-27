//
//  CMTSubjectThemlistViewController.m
//  MedicalForum
//
//  Created by guoyuanchao on 16/9/13.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import "CMTSubjectThemlistViewController.h"
#import"ThemTableViewCell.h"
#import "CMTOtherPostListViewController.h"
@interface CMTSubjectThemlistViewController ()<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong)NSMutableArray*dataArray;//数据
@property(nonatomic,strong)UITableView *themlisttableView;//列表
@property(nonatomic,strong)CMTSubject *mysubject;
@property(nonatomic,assign)NSInteger pageOffsize;
@end

@implementation CMTSubjectThemlistViewController
//列表
-(UITableView*)themlisttableView{
    if (_themlisttableView==nil) {
        _themlisttableView=[[UITableView alloc]init];
        _themlisttableView.backgroundColor =[UIColor colorWithHexString:@"#EFEFF4"];
        _themlisttableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _themlisttableView.dataSource = self;
        _themlisttableView.delegate = self;
        
    }
    return _themlisttableView;
}
-(NSMutableArray*)dataArray{
    if (_dataArray==nil) {
        _dataArray=[[NSMutableArray alloc]init];
    }
    return _dataArray;
}
-(instancetype)initWithSubject:(CMTSubject*)subject{
    self=[super init];
    if (self) {
        self.mysubject=subject;
        self.pageOffsize=0;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.rac_willDeallocSignal subscribeCompleted:^{
        CMTLog(@"PostList willDeallocSignal");
    }];
    
    self.titleText=self.mysubject.subject;
    [self setContentState:CMTContentStateLoading];
    [self.themlisttableView fillinContainer:self.contentBaseView WithTop:CMTNavigationBarBottomGuide Left:0.0 Bottom:0 Right:0.0];
    [self getnetdata];
    [self ListPageRefresh];

}
#pragma mark 请求网络数据
-(void)getnetdata{
    @weakify(self);
    NSDictionary *param=@{
                          @"userId":CMTUSERINFO.userId?:@"0",
                          @"subjectId":self.mysubject.subjectId?:@"0",
                          @"pageOffset":[NSString stringWithFormat:@"%ld",self.pageOffsize],
                          @"pageSize":@"30",
                        };
    [[[CMTCLIENT getSubjectThemelist:param]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(NSArray*themlistArray) {
        @strongify(self);
        if(themlistArray.count>0){
            self.pageOffsize++;
          self.dataArray=[themlistArray mutableCopy];
          [self.themlisttableView reloadData];
         [self setContentState:CMTContentStateNormal];
        }else{
             [self setContentState:CMTContentStateEmpty];
             self.contentEmptyView.contentEmptyPrompt=@"该学科下没有专题";
        }
       
    } error:^(NSError *error) {
         @strongify(self);
        if (error.code>=-1009&&error.code<=-1001) {
           
            [self toastAnimation:@"你的网络不给力"];
        }else{
            [self toastAnimation:[error.userInfo objectForKey:@"errmsg"]];
        }
          [self setContentState:CMTContentStateReload];

        
    }];
    
}
#pragma mark 重新加载
-(void)animationFlash{
    [super animationFlash];
    [self setContentState:CMTContentStateLoading];
    self.pageOffsize=0;
    [self getnetdata];
}
#pragma mark 上拉翻页
-(void)ListPageRefresh{
    @weakify(self);
    [self.themlisttableView addInfiniteScrollingWithActionHandler:^{
         @strongify(self);
        if (self.dataArray.count<=30) {
            [self toastAnimation:@"没有更多专题"];
            [self.themlisttableView.infiniteScrollingView stopAnimating];

            return ;
        }
        NSDictionary *param=@{
                              @"userId":CMTUSERINFO.userId?:@"0",
                              @"subjectId":self.mysubject.subjectId?:@"0",
                              @"pageOffset":[NSString stringWithFormat:@"%ld",(long)self.pageOffsize],
                              @"pageSize":@"30",
                              };
        [[[CMTCLIENT getSubjectThemelist:param]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(NSArray*themlistArray) {
              @strongify(self);
            if(themlistArray.count>0){
                if(![self.dataArray containsObject:themlistArray.firstObject]){
                   self.pageOffsize++;
                   [self.dataArray addObjectsFromArray:themlistArray];
                    [self.themlisttableView reloadData];
                }else{
                    [self toastAnimation:@"没有更多专题"];
                }

            }else{
                [self toastAnimation:@"没有更多专题"];
            }
            [self.themlisttableView.infiniteScrollingView stopAnimating];
            
        } error:^(NSError *error) {
            @strongify(self);
            [self.themlisttableView.infiniteScrollingView stopAnimating];
            if (error.code>=-1009&&error.code<=-1001) {
                
                [self toastAnimation:@"你的网络不给力"];
            }else{
                [self toastAnimation:[error.userInfo objectForKey:@"errmsg"]];
            }
        }];

    }];
}
#pragma mark tableView 代理
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=[self tableView:tableView cellForRowAtIndexPath:indexPath];
    return  cell.frame.size.height;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ThemTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell==nil) {
        cell=[[ThemTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
     CMTTheme *theme=[self.dataArray objectAtIndex:indexPath.row];
     [cell reloadCell:theme];
      return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
     [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CMTTheme *theme=[self.dataArray objectAtIndex:indexPath.row];
    CMTOtherPostListViewController *pOtherVC = [[CMTOtherPostListViewController alloc] initWithThemeId:theme.themeId
                                                                                                postId:theme.postId
                                                                                                isHTML:theme.isHTML
                                                                                               postURL:theme.url];
    pOtherVC.indexPath = indexPath;
    @weakify(self);
    pOtherVC.updateLive=^(CMTLive* live){
        
        CMTAPPCONFIG.refreshmodel=@"2";
    };
    pOtherVC.updateFocusState=^(void){
        @strongify(self);
        [self.themlisttableView reloadData];
    };
    [self.navigationController pushViewController:pOtherVC animated:YES];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
