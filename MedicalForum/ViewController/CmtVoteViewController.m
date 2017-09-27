//
//  CmtVoteViewController.m
//  MedicalForum
//
//  Created by guoyuanchao on 15/11/24.
//  Copyright © 2015年 CMT. All rights reserved.
//

#import "CmtVoteViewController.h"
#import"CMTVoteObject.h"
#import "CMTVoteTableViewCell.h"
#import "CMTediteVoteViewController.h"
#import "CMTNavigationController.h"
@interface CmtVoteViewController ()<UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate>
@property (nonatomic, strong) UIBarButtonItem *cancelItem;                          // 取消按钮
@property (nonatomic, strong) UIBarButtonItem *sendItem;                            // 确定按钮
@property (nonatomic,strong) UITableView *tableView;//列表
@property(nonatomic,strong)UIControl *tableHeadView;//列表头
@property(nonatomic,strong)UIView *tableFootView;//列表头
@property(nonatomic,strong)UITextField *titlefield;
@property(nonatomic,strong)UILabel *titleNumber;
@property(nonatomic,strong)NSMutableArray *dataSourceArray;
@end

@implementation CmtVoteViewController
- (UIBarButtonItem *)cancelItem {
    if (_cancelItem == nil) {
        _cancelItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:nil action:nil];
    }
    
    return _cancelItem;
}

- (UIBarButtonItem *)sendItem {
    if (_sendItem == nil) {
        _sendItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:nil action:nil];
    }
    
    return _sendItem;
}
-(UITableView*)tableView{
    if (_tableView==nil) {
        _tableView=[[UITableView alloc]init];
        _tableView.dataSource=self;
        _tableView.delegate=self;
        [_tableView registerClass:[CMTVoteTableViewCell class] forCellReuseIdentifier:@"VoteTableViewCell"];
        _tableView.separatorStyle =UITableViewCellSeparatorStyleNone;
    }
    return _tableView;
}
-(NSMutableArray*)dataSourceArray{
    if (_dataSourceArray==nil) {
        _dataSourceArray=[[NSMutableArray alloc]init];
    }
    return _dataSourceArray;
}
-(UIControl*)tableHeadView{
    if (_tableHeadView==nil) {
        _tableHeadView=[[UIControl alloc]initWithFrame:CGRectMake(10, 0, SCREEN_WIDTH-20,52)];
        UIView *topline=[[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 1)];
        topline.backgroundColor=COLOR(c_f5f5f5);
        UIView *buttomline=[[UIView alloc]initWithFrame:CGRectMake(0, 50, SCREEN_WIDTH, 1)];
         buttomline.backgroundColor=COLOR(c_f5f5f5);
        [_tableHeadView addSubview:topline];
        [_tableHeadView addSubview:buttomline];
        
        self.titleNumber.frame=CGRectMake(_tableHeadView.width-50, 1,50, 50);
        [_tableHeadView addSubview:self.titleNumber];
        
        self.titlefield.frame=CGRectMake(10, 1, _tableHeadView.width-60, 50);
         [_tableHeadView addSubview:self.titlefield];
        [_tableHeadView addTarget:self action:@selector(changeTitleBgcolor) forControlEvents:UIControlEventTouchDown];
        [_tableHeadView addTarget:self action:@selector(settitlefieldText) forControlEvents:UIControlEventTouchUpInside];
        
        
    }
    return _tableHeadView;
}
-(UITextField*)titlefield{
    if (_titlefield==nil) {
        _titlefield=[[UITextField alloc]init];
        _titlefield.textColor=COLOR(c_151515);
        _titlefield.placeholder=@"标题";
         _titlefield.font=FONT(15);
        _titlefield.userInteractionEnabled=NO;
    }
    return _titlefield;
}

-(UILabel*)titleNumber{
    if (_titleNumber==nil) {
        _titleNumber=[[UILabel alloc]init];
        _titleNumber.backgroundColor =[UIColor clearColor];
        _titleNumber.textColor = [UIColor colorWithHexString:@"#C4C4C4"];
        _titleNumber.textAlignment=NSTextAlignmentRight;
        _titleNumber.font = FONT(13);


    }
    return _titleNumber;
}
-(UIView*)tableFootView{
    if (_tableFootView==nil) {
        _tableFootView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 51)];
        UIButton *deleteButton=[[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-80, 0, 70, 51)];
        [deleteButton setTitle:@"删除投票" forState:UIControlStateNormal];
        deleteButton.titleLabel.font=FONT(16);
        [deleteButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [deleteButton addTarget:self action:@selector(deleteVote) forControlEvents:UIControlEventTouchUpInside];
        [_tableFootView addSubview:deleteButton];

    }
    return _tableFootView;
}

/**
 *  设置标题事件
 *
 *  @return <#return value description#>
 */
-(void)settitlefieldText{
    CMTediteVoteViewController *edite=[[CMTediteVoteViewController alloc]initWithtext:self.titlefield.text maxnumber:300];
    @weakify(self);
    edite.updatedata=^(NSString *str){
        @strongify(self);
        self.titlefield.text=str;
        [self.tableView reloadData];
        self.titleNumber.text=[@"" stringByAppendingFormat:@"%ld/300",(long)self.titlefield.text.length];
    };
    CMTNavigationController *nav=[[CMTNavigationController alloc]initWithRootViewController:edite];
    
    [self presentViewController:nav animated:YES completion:^{
        self.tableHeadView.backgroundColor=COLOR(c_clear);
        
    }];
}
-(void)changeTitleBgcolor{
    self.tableHeadView.backgroundColor=[UIColor colorWithHexString:@"#d9d9d9"];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    @weakify(self);
    [self.rac_willDeallocSignal subscribeCompleted:^{
        CMTLog(@"Vote willDeallocSignal");
    }];
    self.titleText=@"创建投票";
    
    [self setContentState:CMTContentStateNormal];
    if (CMTAPPCONFIG.addGroupPostData.voteArray.count>0) {
        [self.dataSourceArray addObjectsFromArray:CMTAPPCONFIG.addGroupPostData.voteArray];
        self.tableView.tableFooterView=self.tableFootView;
    }else{
        CMTVoteObject *voteObject=[[CMTVoteObject alloc]init];
        voteObject.isaddAction=@"1";
        [self.dataSourceArray addObject:[voteObject copy]];
    }
    self.titlefield.text=CMTAPPCONFIG.addGroupPostData.voteTilte;
    self.titleNumber.text=[@"" stringByAppendingFormat:@"%ld/300",(long)self.titlefield.text.length];
    self.tableView.frame=CGRectMake(0, CMTNavigationBarBottomGuide, SCREEN_WIDTH, SCREEN_HEIGHT-CMTNavigationBarBottomGuide);
    [self.contentBaseView addSubview:self.tableView];
    self.tableView.tableHeaderView=self.tableHeadView;
  
    
    
    self.navigationItem.leftBarButtonItem=self.cancelItem;
    self.navigationItem.rightBarButtonItem=self.sendItem;
    self.cancelItem.rac_command=[[RACCommand alloc]initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self);
        [self dismissViewControllerAnimated:YES completion:nil];
        
        return [RACSignal empty];
    }];
    self.sendItem.rac_command=[[RACCommand alloc]initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self);
        if (self.titlefield.text.length==0) {
            [self toastAnimation:@"标题不能为空"];
             return [RACSignal empty];
        }else{
            for (NSInteger index=0;index<self.dataSourceArray.count;index++) {
                if(index!=self.dataSourceArray.count-1){
                    CMTVoteObject *object=[self.dataSourceArray objectAtIndex:index];
                    if (object.text.length==0) {
                        [self toastAnimation:[object.placelhold stringByAppendingString:@"不能为空"]];
                        return [RACSignal empty];
                    }
                }else if(index==25){
                    CMTVoteObject *object=[self.dataSourceArray objectAtIndex:index];
                    if (object.text.length==0) {
                        [self toastAnimation:[object.placelhold stringByAppendingString:@"不能为空"]];
                        return [RACSignal empty];
                    }

                }
            }
            if (self.dataSourceArray.count<3) {
                [self toastAnimation:@"选项不能少于2个"];
                return [RACSignal empty];
            }
            
        }
        CMTAPPCONFIG.addGroupPostData.voteTilte=self.titlefield.text;
        CMTAPPCONFIG.addGroupPostData.voteArray=self.dataSourceArray;
        if (self.updatedata!=nil) {
            self.updatedata();
        }
        [self dismissViewControllerAnimated:YES completion:nil];
        
        return [RACSignal empty];
    }];
    
    

    
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.dataSourceArray count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 51;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CMTVoteTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"VoteTableViewCell"];
    if (cell==nil) {
        cell=[[CMTVoteTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"VoteTableViewCell"];
    }
    @weakify(self)
    cell.addAction=^(NSIndexPath *index){
        @strongify(self);
        CMTVoteObject *vote=[self.dataSourceArray objectAtIndex:index.row];
        if (vote.isaddAction.boolValue) {
            vote.isaddAction=@"0";
            CMTVoteObject* object1=[[CMTVoteObject alloc]init];
            object1.isaddAction=@"1";
            [self.dataSourceArray addObject:[object1 copy]];
            [self.tableView reloadData];
        }else{
            [self.dataSourceArray removeObjectAtIndex:index.row];
            [self.tableView reloadData];
            
        }
        
    };
     CMTVoteObject *voteObject=[self.dataSourceArray objectAtIndex:indexPath.row];
    if (indexPath.row==25) {
        voteObject.isaddAction=@"0";
    }else if(indexPath.row==self.dataSourceArray.count-1){
        voteObject.isaddAction=@"1";

    }
    [cell reloadCell:voteObject indexPath:indexPath];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CMTVoteObject *object=[self.dataSourceArray objectAtIndex:indexPath.row];
    CMTediteVoteViewController *edite=[[CMTediteVoteViewController alloc]initWithtext:object.text maxnumber:50];
    @weakify(self);
    edite.updatedata=^(NSString *str){
        @strongify(self);
        object.text=str;
        object.isaddAction=@"0";
        if(indexPath.row!=25){
        CMTVoteObject *vote=[[CMTVoteObject alloc]init];
         vote.isaddAction=@"1";
          [self.dataSourceArray addObject:vote];
        }
        [self.tableView reloadData];
    };
    CMTNavigationController *nav=[[CMTNavigationController alloc]initWithRootViewController:edite];
    
    [self presentViewController:nav animated:YES completion:nil];
    
}
/**
 *  删除投票
 */
-(void)deleteVote{
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"确定删除投票" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert show];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        CMTAPPCONFIG.addGroupPostData.voteArray=nil;
        CMTAPPCONFIG.addGroupPostData.voteTilte=@"";
        [self dismissViewControllerAnimated:YES completion:nil];
        if (self.updatedata!=nil) {
            self.updatedata();
        }
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}


@end
