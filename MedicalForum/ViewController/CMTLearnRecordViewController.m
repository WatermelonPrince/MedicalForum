//
//  CMTLearnRecordViewController.m
//  MedicalForum
//
//  Created by guoyuanchao on 17/2/15.
//  Copyright © 2017年 CMT. All rights reserved.
//

#import "CMTLearnRecordViewController.h"
#import "CMTDeleteView.h"
#import "CMTVideoCollectionViewCell.h"
#import "CMTLightVideoViewController.h"
#import "CMTRecordedViewController.h"
@interface CMTLearnRecordViewController ()<UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate>
@property(nonatomic,strong)UITableView *recordTableView;//学习记录
@property(nonatomic,strong)NSMutableArray *dataSourceArray;//数据源
@property(nonatomic,strong)UIBarButtonItem *editButtonItem;//编辑按钮
@property(nonatomic,strong)CMTDeleteView *deleteView;//删除视图
@property(nonatomic,assign)BOOL isneedUpdateData;//是否需要跟新数据据
@property(nonatomic,strong)NSMutableArray *selectArray;//选中数组
@property(nonatomic,assign)BOOL isdeletall;//是否删除全部 0 单个删除 1 全部删除
@end

@implementation CMTLearnRecordViewController
-(UIBarButtonItem*)editButtonItem{
    if(_editButtonItem==nil){
      _editButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(editorAction:)];    }
    return _editButtonItem;
}
-(void)editorAction:(UIBarButtonItem*)button{
    [self.recordTableView setEditing:!self.recordTableView.editing animated:YES];
    if(self.recordTableView.editing){
       button.title=@"取消";
        self.deleteView.hidden=NO;
        self.recordTableView.height-=50;
        
    }else{
       button.title=@"编辑";
        self.deleteView.hidden=YES;
        self.recordTableView.height+=50;
        self.isdeletall=NO;
        [self.selectArray removeAllObjects];
        [_deleteView.checkAllButton setTitle:@"全选" forState:UIControlStateNormal];
        [_deleteView.deleteButton setTitle:@"删除" forState:UIControlStateNormal];
        for (CMTLivesRecord *live in self.dataSourceArray) {
            live.isSelected=NO;
        }

    }
     [self.recordTableView reloadData];
}
-(NSMutableArray*)dataSourceArray{
    if(_dataSourceArray==nil){
        _dataSourceArray=[NSMutableArray new];
    }
    return _dataSourceArray;
}
-(NSMutableArray*)selectArray{
    if(_selectArray==nil){
        _selectArray=[NSMutableArray new];
    }
    return _selectArray;
}
-(CMTDeleteView*)deleteView{
    if(_deleteView==nil){
        @weakify(self);
        _deleteView=[[CMTDeleteView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT-50, SCREEN_WIDTH, 50)];
        _deleteView.backgroundColor = ColorWithHexStringIndex(c_ffffff);
        _deleteView.layer.shadowOffset = CGSizeMake(0, -1);
        _deleteView.layer.shadowColor = ColorWithHexStringIndex(c_32c7c2).CGColor;
        _deleteView.layer.shadowOpacity = 0.5;
        _deleteView.hidden=YES;
        _deleteView.checkAllButton.rac_command=[[RACCommand alloc]initWithSignalBlock:^RACSignal *(id input) {
            @strongify(self);
            if(self.isdeletall){
                self.isdeletall=NO;
                 [self.selectArray removeAllObjects];
                [_deleteView.checkAllButton setTitle:@"全选" forState:UIControlStateNormal];
                 [_deleteView.deleteButton setTitle:@"删除" forState:UIControlStateNormal];
                for (CMTLivesRecord *live in self.dataSourceArray) {
                    live.isSelected=NO;
                }
                [self.recordTableView reloadData];

            }else{
                self.isdeletall=YES;
                [self.selectArray removeAllObjects];
                for (CMTLivesRecord *live in self.dataSourceArray) {
                    live.isSelected=YES;
                    [self.selectArray addObject:live.dataId];
                }
                [self.recordTableView reloadData];
                [_deleteView.checkAllButton setTitle:@"取消全选" forState:UIControlStateNormal];
                [_deleteView.deleteButton setTitle:[@"删除" stringByAppendingFormat:@"(%ld)",self.dataSourceArray.count ] forState:UIControlStateNormal];
            }
            
            return [RACSignal empty];
        }];
        _deleteView.deleteButton.rac_command=[[RACCommand alloc]initWithSignalBlock:^RACSignal *(id input) {
            @strongify(self);
            if(self.selectArray.count==0){
                 return [RACSignal empty];
            }
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:[@"确定要删除选中的" stringByAppendingFormat:@"%ld条记录吗？",self.selectArray.count]  message:nil delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            [alert show];
            [alert.rac_buttonClickedSignal subscribeNext:^(NSNumber *x) {
                if(x.integerValue==1){
                    [self DeleteLearningRecord:YES];
                }
            } error:^(NSError *error) {
                
            }];
            return [RACSignal empty];
        }];
        
        [self.contentBaseView addSubview:_deleteView];
    }
    return _deleteView;
}
-(UITableView*)recordTableView{
    if(_recordTableView==nil){
        _recordTableView=[[UITableView alloc]initWithFrame:CGRectMake(0, CMTNavigationBarBottomGuide, SCREEN_WIDTH, SCREEN_HEIGHT-CMTNavigationBarBottomGuide) style:UITableViewStylePlain];
        _recordTableView.delegate=self;
        _recordTableView.dataSource=self;
        _recordTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
        _recordTableView.placeholderView=[self tableViewPlaceholderView];
        [_recordTableView setPlaceholderViewOffset:[NSValue valueWithCGSize:CGSizeMake(0,-self.recordTableView.height/2+50)]];
        UISwipeGestureRecognizer *Swipe=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(backAction)];
        Swipe.numberOfTouchesRequired=1;
        Swipe.direction=UISwipeGestureRecognizerDirectionRight;
        [Swipe setDelaysTouchesBegan:YES];
        Swipe.delegate=self;
        [_recordTableView addGestureRecognizer:Swipe];
    }
    return _recordTableView;
}
-(void)backAction{
    [self.navigationController popViewControllerAnimated:YES];
}
- (UIView *)tableViewPlaceholderView {
    UIView *placeholderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0,self.recordTableView.width, 100.0)];
    placeholderView.backgroundColor = COLOR(c_clear);
    
    UILabel *placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, placeholderView.width, 100.0)];
    placeholderLabel.backgroundColor = COLOR(c_clear);
    placeholderLabel.textColor = COLOR(c_9e9e9e);
    placeholderLabel.font = FONT(17.0);
    placeholderLabel.textAlignment = NSTextAlignmentCenter;
    placeholderLabel.text =@"您还未学习任何课程哦！";
    [placeholderView addSubview:placeholderLabel];
    
    return placeholderView;
}

-(instancetype)initWithData:(NSArray*)array{
    self=[super init];
    if(self){
        self.dataSourceArray=[array mutableCopy];
        self.isdeletall=NO;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
     [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    @weakify(self);
    [self.rac_willDeallocSignal subscribeCompleted:^{
        NSLog(@"学习记录");
    }];
    self.navigationItem.rightBarButtonItem=self.editButtonItem;
    [self.contentBaseView addSubview:self.recordTableView];
    self.titleText=@"学习记录";
    if(self.dataSourceArray.count==0){
        [self setContentState:CMTContentStateLoading];
        [self AccessToLearningRecordList];
    }
    [[[RACObserve(self, self.dataSourceArray)distinctUntilChanged]deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        @strongify(self);
        if(self.dataSourceArray.count==0){
            self.deleteView.checkAllButton.enabled=NO;
            self.deleteView.deleteButton.enabled=NO;
        }else{
            self.deleteView.checkAllButton.enabled=YES;
            self.deleteView.deleteButton.enabled=YES;
        }
    } error:^(NSError *error) {
        
    }];

}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //更新列表
    if(self.isneedUpdateData){
        [self setContentState:CMTContentStateLoading moldel:@"1" height:CMTNavigationBarBottomGuide];

       [self AccessToLearningRecordList];
    }
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
      [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
    self.isneedUpdateData=YES;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  self.dataSourceArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CMTVideoCollectionViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(cell==nil){
        cell=[[CMTVideoCollectionViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
     }
    @weakify(self);
    cell.updateSelectState=^(CMTLivesRecord *record){
        @strongify(self);
        if(!tableView.editing){
            return ;
        }
        if(record.isSelected){
            record.isSelected=NO;
            [self.selectArray removeObject:record.dataId];
            self.isdeletall=NO;
            
        }else{
            record.isSelected=YES;
            [self.selectArray addObject:record.dataId];
        }
        if(self.selectArray.count!=self.dataSourceArray.count){
            self.isdeletall=NO;
            [self.deleteView.checkAllButton setTitle:@"全选" forState:UIControlStateNormal];
            
        }else{
            self.isdeletall=YES;
            [self.deleteView.checkAllButton setTitle:@"取消全选" forState:UIControlStateNormal];
        }
        [self.deleteView.deleteButton setTitle:self.selectArray.count==0?@"删除":[@"删除" stringByAppendingFormat:@"(%ld)",self.selectArray.count ] forState:UIControlStateNormal];
        
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    };

    [cell reloadCellWithdate:@"1" model:self.dataSourceArray[indexPath.row]];
    cell.tapSlectedView.hidden=!self.recordTableView.editing;
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=[self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.height;
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        CMTLivesRecord *Record=self.dataSourceArray[indexPath.row];
        self.selectArray=[@[Record.dataId] mutableCopy];
        [self DeleteLearningRecord:YES];
    }
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView.editing){
     return UITableViewCellEditingStyleNone;
    }
    return UITableViewCellEditingStyleDelete;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CMTLivesRecord *Record=[self.dataSourceArray objectAtIndex:indexPath.row];
    if([self getNetworkReachabilityStatus].integerValue==0){
        
        [self toastAnimation:@"无法连接到网络，请检查网络设置"];
        return;
    }else{
        if (Record.type.integerValue==1) {
            @weakify(self);
            CMTLightVideoViewController *lightVideoViewController = [[CMTLightVideoViewController alloc]init];
            //  播放网络
            lightVideoViewController.myliveParam = [Record copy];
            lightVideoViewController.updateReadNumber=^(CMTLivesRecord *live){
                @strongify(self);
                if(live==nil){
                    self.selectArray=[@[Record.dataId] mutableCopy];
                    [self DeleteLearningRecord:NO];
                }
            };
            [self.navigationController pushViewController:lightVideoViewController animated:YES];
            
        }else{
            CMTRecordedViewController *recordView=[[CMTRecordedViewController alloc]initWithRecordedParam:[Record copy]];
             @weakify(self);
            recordView.updateReadNumber=^(CMTLivesRecord *live){
                @strongify(self);
                if(live==nil){
                    self.selectArray=[@[Record.dataId] mutableCopy];
                    [self DeleteLearningRecord:NO];
                }

            };
            [self.navigationController pushViewController:recordView animated:YES];
            
        }
    }

}
-(void)animationFlash{
    [super animationFlash];
    [self setContentState:CMTContentStateLoading];
    [self AccessToLearningRecordList];
}
//获取学习记录列表
-(void)AccessToLearningRecordList{
   
    if(!CMTUSER.login){
        [self.dataSourceArray removeAllObjects];
        [self setContentState:CMTContentStateNormal];
        return;
    }
    @weakify(self);
    NSDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:CMTUSER.userInfo.userId forKey:@"userId"];
    [[[CMTCLIENT CMTPersonalLearningList:param]
      deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSArray *array) {
        self.dataSourceArray=[array mutableCopy];
        if(self.recordTableView.editing){
            if(self.dataSourceArray.count==0){
                [self editorAction:self.editButtonItem];
                self.isdeletall=NO;
            }
            [self.deleteView.deleteButton setTitle:@"删除" forState:UIControlStateNormal];
            [self.deleteView.checkAllButton setTitle:@"全选" forState:UIControlStateNormal];
        }
        [self.recordTableView reloadData];
        [self setContentState:CMTContentStateNormal];
    } error:^(NSError *error) {
        @strongify(self);
        if (error.code>=-1009&&error.code<=-1001) {
            [self toastAnimation:@"你的网络不给力"];
        }else{
            [self toastAnimation:[error.userInfo objectForKey:@"errmsg"]];
        }
         [self.recordTableView reloadData];
       [self setContentState:CMTContentStateNormal];
    }];
    
}
#pragma mark 删除学习记录方法
-(void)DeleteLearningRecord:(BOOL)isrefreshList{
    @weakify(self);
     [self setContentState:CMTContentStateLoading moldel:@"1" height:CMTNavigationBarBottomGuide];
    NSError *JSONSerializationError = nil;
    NSData *itemsJSONData = [NSJSONSerialization dataWithJSONObject:self.selectArray options:NSJSONWritingPrettyPrinted error:&JSONSerializationError];
    if (JSONSerializationError != nil) {
        CMTLogError(@"AppConfig Cached Theme Info JSONSerialization Error: %@", JSONSerializationError);
    }
    NSString *itemsJSONString = [[NSString alloc] initWithData:itemsJSONData encoding:NSUTF8StringEncoding];
    NSDictionary *param=@{ @"userId":CMTUSER.userInfo.userId?:@"0",
                           @"items":itemsJSONString?:@"",
                           @"delType":self.isdeletall?@"1":@"0"
                               };
    [self DeleteLearningRecord:param sucess:^(CMTObject *x) {
        @strongify(self);
        if(isrefreshList){
            [self AccessToLearningRecordList];
        }
    } error:^(NSError *error) {
          @strongify(self);
                if (error.code>=-1009&&error.code<=-1001) {
                    [self toastAnimation:@"你的网络不给力"];
                }else{
                    [self toastAnimation:[error.userInfo objectForKey:@"errmsg"]];
                }
                [self.recordTableView reloadData];
              [self setContentState:CMTContentStateNormal];
    }];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
