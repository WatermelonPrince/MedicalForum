//
//  CMTDownCenterViewController.m
//  MedicalForum
//
//  Created by guoyuanchao on 2017/3/15.
//  Copyright © 2017年 CMT. All rights reserved.
//

#import "CMTDownCenterViewController.h"
#import "CMTVideoCollectionViewCell.h"
#import "CMTDeleteView.h"
#import "CMTDownloadingTableViewCell.h"
#import "CMTDownloadLightVedioViewController.h"
#import "LDZMoviePlayerController.h"
@interface CMTDownCenterViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong)UIView *switchBgView;
@property (nonatomic, strong)UIButton *haveDownloaded;//已经下载列表按钮
@property (nonatomic, strong)UIButton *downloadingButton;//下载列表按钮
@property (nonatomic, strong)UIView *lineView;//跳转线
@property (nonatomic, strong)UITableView *dataTableView;
@property (nonatomic, assign)BOOL ishaveDown;
@property (nonatomic, strong)NSMutableArray *selectArray;
@property(nonatomic,strong)CMTDeleteView *deleteView;//删除视图
@property(nonatomic,strong)UIBarButtonItem *editButtonItem;//编辑按钮
@property(nonatomic,assign)BOOL isdeletall;
@property(nonatomic,strong)NSMutableArray*dataSourceArray;
@property(nonatomic,strong)UILabel *equipmentStorage;
@property(nonatomic,strong)NSString *downNumber;
@end

@implementation CMTDownCenterViewController
-(UIBarButtonItem*)editButtonItem{
    if(_editButtonItem==nil){
        _editButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(editorAction:)];    }
    return _editButtonItem;
}
-(void)editorAction:(UIBarButtonItem*)button{
    [self.dataTableView setEditing:!self.dataTableView.editing animated:YES];
    if(self.dataTableView.editing){
        button.title=@"取消";
        self.deleteView.hidden=NO;
        
    }else{
        button.title=@"编辑";
        self.isdeletall=NO;
        self.deleteView.hidden=YES;
        [self.selectArray removeAllObjects];
        [_deleteView.checkAllButton setTitle:@"全选" forState:UIControlStateNormal];
        [_deleteView.deleteButton setTitle:@"删除" forState:UIControlStateNormal];
        for (CMTLivesRecord *live in (self.haveDownloaded?CMTAPPCONFIG.haveDownloadedList:CMTAPPCONFIG.downloadList)) {
            live.isSelected=NO;
        }
        
    }
    [self.dataTableView reloadData];
}
-(NSMutableArray*)selectArray{
    if(_selectArray==nil){
        _selectArray=[[NSMutableArray alloc]init];
    }
    return _selectArray;
}
-(NSMutableArray*)dataSourceArray{
    if(_dataSourceArray==nil){
        _dataSourceArray=[[NSMutableArray alloc]init];
    }
    return _dataSourceArray;
}

- (UIView *)switchBgView{
    if (!_switchBgView) {
        _switchBgView = [[UIView alloc]initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, 46)];
        _switchBgView.backgroundColor = COLOR(c_f5f5f5);
        [_switchBgView addSubview:self.haveDownloaded];
        [_switchBgView addSubview:self.downloadingButton];
        [_switchBgView addSubview:self.lineView];
    }
    return _switchBgView;
}
- (UIView *)lineView{
    if (!_lineView) {
        _lineView = [[UIView alloc]init];
        _lineView.backgroundColor = ColorWithHexStringIndex(c_32c7c2);
        _lineView.frame = CGRectMake(0, self.haveDownloaded.bottom, SCREEN_WIDTH/2, 2);
    }
    return _lineView;
}

- (UIButton *)haveDownloaded{
    if (!_haveDownloaded) {
        _haveDownloaded = [UIButton buttonWithType:UIButtonTypeCustom];
        _haveDownloaded.frame = CGRectMake(0, 0, SCREEN_WIDTH/2, 44);
        [_haveDownloaded setTitle:@"已下载" forState:UIControlStateNormal];
        _haveDownloaded.titleLabel.font=FONT(15);
        [_haveDownloaded setTitleColor:ColorWithHexStringIndex(c_32c7c2) forState:UIControlStateSelected];
        [_haveDownloaded setTitleColor:[UIColor colorWithHexString:@"9b9b9b"] forState:UIControlStateNormal];
        [_haveDownloaded addTarget:self action:@selector(switchHaveDownLoad) forControlEvents:UIControlEventTouchUpInside];
        _haveDownloaded.selected = YES;
        [MobClick event:@"B_MIne_Collection"];
        
    }
    return _haveDownloaded;
}
- (UIButton *)downloadingButton{
    if (!_downloadingButton) {
        _downloadingButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _downloadingButton.frame = CGRectMake(SCREEN_WIDTH/2, 0, SCREEN_WIDTH/2, 44);
        [_downloadingButton setTitle:@"正在下载" forState:UIControlStateNormal];
        _downloadingButton.titleLabel.font=FONT(15);
        [_downloadingButton setTitleColor:ColorWithHexStringIndex(c_32c7c2) forState:UIControlStateSelected];
        [_downloadingButton setTitleColor:[UIColor colorWithHexString:@"9b9b9b"] forState:UIControlStateNormal];
        [_downloadingButton addTarget:self action:@selector(switchDownLoading) forControlEvents:UIControlEventTouchUpInside];
    }
    return _downloadingButton;
}
-(UILabel *)equipmentStorage{
    if(_equipmentStorage==nil){
        _equipmentStorage=[[UILabel alloc]initWithFrame:CGRectMake(0, self.contentBaseView.height-50, self.contentBaseView.width, 50)];
        _equipmentStorage.backgroundColor=COLOR(c_f5f5f5);
        _equipmentStorage.textColor=COLOR(c_b9b9b9);
        _equipmentStorage.font=FONT(13);
        _equipmentStorage.numberOfLines=0;
        _equipmentStorage.lineBreakMode=NSLineBreakByCharWrapping;
        _equipmentStorage.textAlignment=NSTextAlignmentCenter;
    }
    return _equipmentStorage;
}

- (UITableView *)dataTableView
{
    if (!_dataTableView)
    {
        _dataTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 46+64, SCREEN_WIDTH, SCREEN_HEIGHT-46-64-50) style:UITableViewStylePlain];
        _dataTableView.delegate = self;
        _dataTableView.dataSource = self;
        _dataTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        UISwipeGestureRecognizer *Swipe=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(backAction)];
        Swipe.numberOfTouchesRequired=1;
        Swipe.direction=UISwipeGestureRecognizerDirectionRight;
        [Swipe setDelaysTouchesBegan:YES];
        [_dataTableView addGestureRecognizer:Swipe];
        _dataTableView.placeholderView=[self tableViewPlaceholderView:_dataTableView text:@"还没有下载完成的课程"];
        
        
    }
    return _dataTableView;
}
-(void)backAction{
    [self.navigationController popViewControllerAnimated:YES];
}
- (UIView *)tableViewPlaceholderView:(UITableView*)tableView text:(NSString*)text {
    UIView *placeholderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0,tableView.width, tableView.height)];
    placeholderView.backgroundColor = COLOR(c_clear);
    
    UILabel *placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 145, SCREEN_WIDTH, 30)];
    placeholderLabel.backgroundColor = COLOR(c_clear);
    placeholderLabel.textColor = [UIColor colorWithHexString:@"#c8c8c8"];
    placeholderLabel.font = FONT(16);
    placeholderLabel.textAlignment = NSTextAlignmentCenter;
    placeholderLabel.text =text;
    
    [placeholderView addSubview:placeholderLabel];
    
    
    return placeholderView;
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
                [self.dataTableView reloadData];
                
            }else{
                self.isdeletall=YES;
                [self.selectArray removeAllObjects];
                for (CMTLivesRecord *live in self.dataSourceArray) {
                    live.isSelected=YES;
                    [self.selectArray addObject:live.classRoomId];
                }
                [self.dataTableView reloadData];
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
                    for (NSString *classRoomId in self.selectArray) {
                        NSInteger index=[self findIndex:classRoomId];
                        if(index==-1){
                            continue;
                        }
                        CMTLivesRecord *live=self.dataSourceArray[index];
                        if(self.ishaveDown){
                            if(live.type.integerValue==2){
                              [CMTDownLoad deleteDownFile:live.studentJoinUrl];
                            }else{
                                [CMTDemandDownLoad doDeleteDownload:live.strDownloadID];
                            }
                            [self.dataSourceArray removeObjectAtIndex:index];
                            [CMTAPPCONFIG.haveDownloadedList removeObjectAtIndex:[CMTDownLoad findIndex:CMTAPPCONFIG.haveDownloadedList dic:live]];
                            [CMTAPPCONFIG saveHavedownLoadList];
                        }else{
                            if([CMTAPPCONFIG.downloadingLive.classRoomId isEqualToString:live.classRoomId]){
                                CMTAPPCONFIG.downloadingLive=nil;
                                if(live.type.integerValue==2){
                                    [CMTDownLoad cancel];
                                }else{
                                    [CMTDemandDownLoad doPauseDownload];
                                    [CMTDemandDownLoad doDeleteDownload:CMTAPPCONFIG.downloadingLive.strDownloadID];
                                }

                            }
                            [self.dataSourceArray removeObjectAtIndex:index];
                            [CMTAPPCONFIG.downloadList removeObjectAtIndex:[CMTDownLoad findIndex:CMTAPPCONFIG.downloadList dic:live]];
                            [CMTAPPCONFIG savedownloadList];
                        }
                    }
                    [self UpdateRemainingSpace:CMTAPPCONFIG.downloadingLive.fileSize];
                    [self.dataTableView reloadData];
                    if(!self.ishaveDown){
                        if(self.dataSourceArray.count>0&&CMTAPPCONFIG.downloadingLive==nil){
                            if(CMTAPPCONFIG.DownnetState.integerValue!=2){
                                [self toastAnimation:@"请切换至Wifi网络"];
                            }
                            CMTAPPCONFIG.downloadingLive=[self.dataSourceArray[0] copy];
                            [CMTAPPCONFIG savedownloadingLive];
                            if( CMTAPPCONFIG.downloadingLive.type.integerValue==2){
                                [CMTDownLoad resumeDownLoad];
                            }else{
                                [CMTDemandDownLoad doDownloader];
                            }

                        }
                    }
                }
            } error:^(NSError *error) {
                
            }];
            return [RACSignal empty];
        }];
        
        [self.contentBaseView addSubview:_deleteView];
    }
    return _deleteView;
}
-(NSInteger)findIndex:(NSString*)classRoomId{
    NSInteger index=-1;
    for (NSInteger i=0;i<self.dataSourceArray.count;i++) {
        CMTLivesRecord *live=self.dataSourceArray[i];
        if([live.classRoomId isEqualToString:classRoomId]){
            index=i;
            break;
        }
    }
    return index;
}
-(void)switchHaveDownLoad{
    self.haveDownloaded.selected=YES;
    self.downloadingButton.selected=NO;
    self.ishaveDown=YES;
    self.lineView.frame = CGRectMake(0, self.haveDownloaded.bottom, SCREEN_WIDTH/2, 2);
    self.dataTableView.editing=YES;
    [self editorAction:self.editButtonItem];
    self.dataSourceArray=[CMTAPPCONFIG.haveDownloadedList mutableCopy];
        [self.dataTableView reloadData];
     self.dataTableView.placeholderView=[self tableViewPlaceholderView:_dataTableView text:@"还没有下载完成的课程"];
}
-(void)switchDownLoading{
    self.downloadingButton.selected=YES;
    self.haveDownloaded.selected=NO;
    self.ishaveDown=NO;
    self.lineView.frame = CGRectMake(SCREEN_WIDTH/2, self.downloadingButton.bottom, SCREEN_WIDTH/2, 2);
     self.dataTableView.editing=YES;
    [self editorAction:self.editButtonItem];
    self.dataSourceArray=[CMTAPPCONFIG.downloadList mutableCopy];
    [self.dataTableView reloadData];
    self.dataTableView.placeholderView=[self tableViewPlaceholderView:_dataTableView text:@"没有正在下载的课程"];
}
-(instancetype)initWith:(BOOL)ishaveDown{
    self=[super init];
    if(self){
        self.ishaveDown=ishaveDown;
        self.dataSourceArray=self.ishaveDown?[CMTAPPCONFIG.haveDownloadedList mutableCopy]:[CMTAPPCONFIG.downloadList mutableCopy];
        if(self.ishaveDown){
             self.haveDownloaded.selected=YES;
             self.lineView.frame = CGRectMake(0, self.haveDownloaded.bottom, SCREEN_WIDTH/2, 2);
        }else{
              self.downloadingButton.selected=YES;
            self.lineView.frame = CGRectMake(SCREEN_WIDTH/2, self.downloadingButton.bottom, SCREEN_WIDTH/2, 2);
        }
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.rac_willDeallocSignal subscribeCompleted:^{
        CMTLog(@"CMTDigitalWebViewController willDeallocSignal");
    }];
    self.titleText=@"下载中心";
    self.navigationItem.rightBarButtonItem=self.editButtonItem;
    [self.contentBaseView addSubview:self.switchBgView];
    [self.contentBaseView addSubview:self.dataTableView];
    [self.contentBaseView addSubview:self.equipmentStorage];
    //开始网络监听
    if(CMTAPPCONFIG.DownnetState.integerValue==3){
        CMTDownLoad.downloadermanager;
    }
    self.downNumber=[@"已经下载了(" stringByAppendingFormat:@"%ld%@",CMTAPPCONFIG.haveDownloadedList.count,@")\r\n"];
    self.equipmentStorage.text=[ self.downNumber stringByAppendingFormat:@"%@%@",@"剩余",[CMTAPPCONFIG freeDiskSpaceInBytesStr]];
    @weakify(self);
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
    //监听展示互动下载完成
    [[[[RACObserve(CMTDemandDownLoad,downfinish) ignore:nil] distinctUntilChanged ]deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSNumber *x) {
        @strongify(self);
        if(x.boolValue){
            //如果不是
            if(!self.ishaveDown){
                CMTDemandDownLoad.downfinish=NO;
               self.dataSourceArray=[CMTAPPCONFIG.downloadList mutableCopy];
                [self.dataTableView reloadData];
            }else{
                CMTDemandDownLoad.downfinish=NO;
                self.dataSourceArray=[CMTAPPCONFIG.haveDownloadedList mutableCopy];
                [self.dataTableView reloadData];
            }
        }
      } error:^(NSError *error) {
        
    }];
    //监听阿里云下载完成
    [[[[RACObserve(CMTDownLoad,downfinish) ignore:nil] distinctUntilChanged ]deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSNumber *x) {
        @strongify(self);
        if(x.boolValue){
            //如果不是
            if(!self.ishaveDown){
                CMTDownLoad.downfinish=NO;
                self.dataSourceArray=[CMTAPPCONFIG.downloadList mutableCopy];
                [self.dataTableView reloadData];
            }else{
                CMTDownLoad.downfinish=NO;
                self.dataSourceArray=[CMTAPPCONFIG.haveDownloadedList mutableCopy];
                [self.dataTableView reloadData];
            }
        }
        [self UpdateRemainingSpace:CMTAPPCONFIG.downloadingLive.fileSize];
    } error:^(NSError *error) {
        
    }];
    //监听下载网络状态
    [[[RACObserve(CMTAPPCONFIG,DownnetState)distinctUntilChanged]deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSString *x) {
        @strongify(self);
        if(x.integerValue<2){
              CMTAPPCONFIG.downloadingLive.Downstate=6;
            if(!self.ishaveDown){
               [self changeClassData:CMTAPPCONFIG.downloadingLive];
               [self.dataTableView reloadData];
            }
            
          }else{
                 CMTAPPCONFIG.downloadingLive.Downstate=CMTAPPCONFIG.downloadingLive.Downstate==6?2:CMTAPPCONFIG.downloadingLive.Downstate;
                if(!self.ishaveDown){
                    [self changeClassData:CMTAPPCONFIG.downloadingLive];
                    [self.dataTableView reloadData];
                }
            }
    } error:^(NSError *error) {
        
    }];
    //监听文件下载大小
    [[[RACObserve(CMTAPPCONFIG,downloadingLive.fileSize)distinctUntilChanged]deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        @strongify(self);
        [self UpdateRemainingSpace:CMTAPPCONFIG.downloadingLive.fileSize];
        } error:^(NSError *error) {
        
    }];

    //刷新下载进度
    [self refreshUI];
}
-(void)UpdateRemainingSpace:(long)fileSize{
    self.downNumber=[@"已经下载了(" stringByAppendingFormat:@"%ld%@",CMTAPPCONFIG.haveDownloadedList.count,@")\r\n"];
    if(fileSize==0){
        self.equipmentStorage.text=[ self.downNumber stringByAppendingFormat:@"%@%@",@"剩余",[CMTAPPCONFIG freeDiskSpaceInBytesStr]];
    }else{
        self.equipmentStorage.text=[self.downNumber stringByAppendingFormat:@"%@%@%@%@",@"预计新增",[CMTDownLoad AccessFileSize: CMTAPPCONFIG.downloadingLive.fileSize],@",剩余",fileSize<[CMTAPPCONFIG freeDiskSpaceInBytes]?[CMTDownLoad AccessFileSize:[CMTAPPCONFIG freeDiskSpaceInBytes]-fileSize]:@"空间不足"];
    }

}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSourceArray.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=[self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.height;
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView.editing){
        return UITableViewCellEditingStyleNone;
    }
    return UITableViewCellEditingStyleDelete;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete){
        tableView.allowsSelection=NO;
        CMTLivesRecord *live=self.dataSourceArray[indexPath.row];
        if(self.ishaveDown){
            CMTLivesRecord *live=self.dataSourceArray[indexPath.row];
            if(live.type.integerValue==2){
               [CMTDownLoad deleteDownFile:live.studentJoinUrl];
            }else{
                [CMTDemandDownLoad doDeleteDownload:live.strDownloadID];
            }
            [self.dataSourceArray removeObjectAtIndex:indexPath.row];
            [CMTAPPCONFIG.haveDownloadedList removeObjectAtIndex:[CMTDownLoad findIndex:CMTAPPCONFIG.haveDownloadedList dic:live]];
            [CMTAPPCONFIG saveHavedownLoadList];
            [self UpdateRemainingSpace:CMTAPPCONFIG.downloadingLive.fileSize];
            
        }else{
            if([CMTAPPCONFIG.downloadingLive.classRoomId isEqualToString:live.classRoomId]){
                CMTAPPCONFIG.downloadingLive=nil;
                CMTDownLoad.indexPath=nil;
                if(live.type.integerValue==2){
                    [CMTDownLoad cancel];
                }else{
                    [CMTDemandDownLoad doPauseDownload];
                    [CMTDemandDownLoad doDeleteDownload:live.strDownloadID];
                }
            }
            [self.dataSourceArray removeObjectAtIndex:indexPath.row];
            [CMTAPPCONFIG.downloadList removeObjectAtIndex:[CMTDownLoad findIndex:CMTAPPCONFIG.downloadList dic:live]];
             [CMTAPPCONFIG savedownloadList];
        }
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];

        if(!self.ishaveDown){
            if(self.dataSourceArray.count>0&&CMTAPPCONFIG.downloadingLive==nil){
                if(CMTAPPCONFIG.DownnetState.integerValue!=2){
                    [self toastAnimation:@"请切换至Wifi网络"];
                }
                CMTAPPCONFIG.downloadingLive=[self.dataSourceArray[0] copy];
                CMTDownLoad.indexPath=[NSIndexPath indexPathForRow:0 inSection:0];
                [CMTAPPCONFIG savedownloadingLive];
                 [tableView reloadData];
                if( CMTAPPCONFIG.downloadingLive.type.integerValue==2){
                    [CMTDownLoad resumeDownLoad];
                }else{
                    [CMTDemandDownLoad doDownloader];
                }
                
           }
        }
         tableView.allowsSelection=YES;
       
        
    }
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
       if(self.ishaveDown){
        static NSString *identifer  = @"haveDownloadCell";
        CMTVideoCollectionViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifer];
        if (!cell) {
            cell = [[CMTVideoCollectionViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifer];
            
            
        }
        //视频删除单选
        @weakify(self);
        cell.updateSelectState=^(CMTLivesRecord *record){
            @strongify(self);
            [self changeSelectState:tableView liverecord:record];
            
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            
        };
        CMTLivesRecord *record =self.dataSourceArray [indexPath.row];
        [cell reloadCellWithdate:@"2" model:record];
        cell.tapSlectedView.hidden = !tableView.editing;
        
        return cell;

    }else{
        static NSString *identifer  = @"DownloadingCell";
        CMTDownloadingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifer];
        if (!cell) {
            cell = [[CMTDownloadingTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifer];
            
            
        }
         @weakify(self);
        cell.updateSelectState=^(CMTLivesRecord *record){
            @strongify(self);
            [self changeSelectState:tableView liverecord:record];
            
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            
        };
        [self changeClassData:CMTAPPCONFIG.downloadingLive];
        CMTLivesRecord *record =self.dataSourceArray [indexPath.row];
        if([CMTAPPCONFIG.downloadingLive.classRoomId isEqualToString:record.classRoomId]){
            if(record.type.integerValue==2){
               CMTDownLoad.indexPath=indexPath;
            }else{
                CMTDemandDownLoad.indexPath=indexPath;
            }
        }
        [cell reloadCell:record];
        cell.tapSlectedView.hidden=!self.dataTableView.editing;

        return cell;
    }
    return nil;
}
//处理下载切换
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
     CMTLivesRecord *live=self.dataSourceArray[indexPath.row];
    if(!self.ishaveDown){
        if(CMTAPPCONFIG.DownnetState.integerValue<2){
            [self toastAnimation:@"请切换到wifi网络"];
            return;
        }
        [self downLoadClass:indexPath live:live];
     }else{
        [self openClass:live];
    }
}
#pragma mark 下载课程
-(void)downLoadClass:(NSIndexPath*)indexPath live:(CMTLivesRecord*)live{
    if(CMTAPPCONFIG.downloadingLive!=nil&&[live.classRoomId isEqualToString:CMTAPPCONFIG.downloadingLive.classRoomId]){
        if(live.type.integerValue==2){
            if(CMTDownLoad.downloadtask==nil){
                [CMTDownLoad resumeDownLoad];
            }else{
                if(CMTAPPCONFIG.downloadingLive.Downstate==1||CMTAPPCONFIG.downloadingLive.Downstate==3){
                    [CMTDownLoad cancelDownLoad];
                }else{
                     [CMTDownLoad resumeDownLoad];
                }
                
            }
        }else{
            if(CMTAPPCONFIG.downloadingLive.Downstate==1 ||CMTAPPCONFIG.downloadingLive.Downstate==3){
                    [CMTDemandDownLoad doPauseDownload];
            }else{
                [CMTDemandDownLoad doDownloader];
            }
        }
    }else{
        if(CMTAPPCONFIG.downloadingLive.type.integerValue==2){
            if(CMTDownLoad.downloadtask!=nil){
                @weakify(self);
                [CMTDownLoad.downloadtask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
                    @strongify(self);
                    CMTAPPCONFIG.downloadingLive.downData=resumeData;
                    CMTAPPCONFIG.downloadingLive.Downstate=2;
                    [self changeClassData:CMTAPPCONFIG.downloadingLive];
                    CMTDownloadingTableViewCell *cell=[self.dataTableView cellForRowAtIndexPath:CMTDownLoad.indexPath];
                    if(cell!=nil){
                        cell.playStateimage.selected=NO;
                        [cell reloadCell:self.dataSourceArray[CMTDownLoad.indexPath.row]];
                    }
                    CMTDownLoad.downloadtask=nil;
                    [self ChangeDownloadProcess:live indexPath:indexPath];
                }];
            }else{
                if(CMTAPPCONFIG.downloadingLive.Downstate==3){
                    CMTAPPCONFIG.downloadingLive.Downstate=0;
                    if(CMTDownLoad.downloadtask!=nil){
                        [CMTDownLoad  cancel];
                    }
                    [self changeClassData:CMTAPPCONFIG.downloadingLive];
                    
                }
                CMTDownloadingTableViewCell *cell=[self.dataTableView cellForRowAtIndexPath:CMTDownLoad.indexPath];
                if(cell!=nil){
                    cell.playStateimage.selected=NO;
                    [cell reloadCell:self.dataSourceArray[CMTDownLoad.indexPath.row]];
                }
                CMTDownLoad.downloadtask=nil;
                
                [self ChangeDownloadProcess:live indexPath:indexPath];
            }
        }else{
            [CMTDemandDownLoad PauseDownload];
            if( CMTAPPCONFIG.downloadingLive.Downstate==1){
                CMTAPPCONFIG.downloadingLive.Downstate=2;
            }else{
                CMTAPPCONFIG.downloadingLive.Downstate=0;
            }
            [self changeClassData:CMTAPPCONFIG.downloadingLive];
            CMTDownloadingTableViewCell *cell=[self.dataTableView cellForRowAtIndexPath:CMTDemandDownLoad.indexPath];
            if(cell!=nil){
                cell.playStateimage.selected=NO;
                [cell reloadCell:self.dataSourceArray[CMTDemandDownLoad.indexPath.row]];
            }
            [self ChangeDownloadProcess:live indexPath:indexPath];
        }
    }
    [CMTAPPCONFIG savedownloadingLive];
    [CMTAPPCONFIG savedownloadList];
    [CMTAPPCONFIG savedownloadingLive];

}
//查看已经下载的课程
-(void)openClass:(CMTLivesRecord*)Record{
    CMTLivesRecord *downRecord=[CMTAPPCONFIG.haveDownloadedList objectAtIndex:[CMTDownLoad findIndex:CMTAPPCONFIG.haveDownloadedList dic:Record]];
    if (Record.type.integerValue==1) {
        CMTDownloadLightVedioViewController *lightVideoViewController = [[CMTDownloadLightVedioViewController alloc]init];
        lightVideoViewController.updateReadtime = ^(CGFloat time){
            Record.playDuration = [NSString stringWithFormat:@"%f",time];
            downRecord.playDuration=Record.playDuration;
            [CMTAPPCONFIG saveHavedownLoadList];
        };
        //  播放网络
        lightVideoViewController.myliveParam = [Record copy];
        [self.navigationController pushViewController:lightVideoViewController animated:YES];
        
    }else{
        NSString *filepath=[PATH_downLoad stringByAppendingPathComponent:Record.studentJoinUrl.lastPathComponent] ;
        LDZMoviePlayerController *recordView=[[LDZMoviePlayerController alloc]initWithUrl:[NSURL fileURLWithPath:filepath]fromDownCenter:YES];
        recordView.playtime=Record.playDuration.length>0?Record.playDuration.floatValue/1000:0;
        recordView.updateReadtime=^(CGFloat time){
            Record.playDuration=[NSString stringWithFormat:@"%f",time*1000];
            downRecord.playDuration=Record.playDuration;
            [CMTAPPCONFIG saveHavedownLoadList];
            
        };
        [self.navigationController pushViewController:recordView animated:YES];
        
    }

}
#pragma mark 更换下载进程
-(void)ChangeDownloadProcess:(CMTLivesRecord*)live indexPath:(NSIndexPath*)indexPath{
    CMTAPPCONFIG.downloadingLive=[live copy];
    if(live.type.integerValue==2){
        CMTDownLoad.indexPath=indexPath;
        [CMTDownLoad resumeDownLoad];
    }else{
        CMTDemandDownLoad.indexPath=indexPath;
        [CMTDemandDownLoad doDownloader];
    }

    
}
//刷新下载进度
-(void)refreshUI{
    @weakify(self);
    
    CMTDownLoad.updateDownstart=^{
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            if(CMTDownLoad.indexPath==nil||self.ishaveDown||(self.dataSourceArray.count<CMTDemandDownLoad.indexPath.row+1)){
                return ;
            }
            CMTDownloadingTableViewCell *cell=[self.dataTableView cellForRowAtIndexPath:CMTDownLoad.indexPath];
            if(cell!=nil){
                  [self changeClassData:CMTAPPCONFIG.downloadingLive];
                 [cell reloadCell:self.dataSourceArray[CMTDownLoad.indexPath.row]];
            }
        });
    };
    
    CMTDownLoad.updateDownpause=^{
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            if(CMTDownLoad.indexPath==nil||self.ishaveDown||(self.dataSourceArray.count<CMTDemandDownLoad.indexPath.row+1)){
                return ;
            }
            CMTDownloadingTableViewCell *cell=[self.dataTableView cellForRowAtIndexPath:CMTDownLoad.indexPath];
            if(cell!=nil){
                //更改数据
                [self changeClassData:CMTAPPCONFIG.downloadingLive];
               [cell reloadCell:self.dataSourceArray[CMTDownLoad.indexPath.row]];
            }
        });
    };
    CMTDownLoad.updateDownProgress=^(float downprogress,long size){
      dispatch_async(dispatch_get_main_queue(), ^{
          if(CMTDownLoad.indexPath==nil||self.ishaveDown||(self.dataSourceArray.count<CMTDemandDownLoad.indexPath.row+1)){
              return ;
          }
          CMTDownloadingTableViewCell *cell=[self.dataTableView cellForRowAtIndexPath:CMTDownLoad.indexPath];
          if(cell!=nil){
            [cell.ProgressView setProgress:downprogress animated:YES];
             cell.mlbdataSize.text=[CMTDownLoad AccessFileSize:size];
              float dataSizewith=[CMTGetStringWith_Height CMTGetLableTitleWith:[CMTDownLoad AccessFileSize:size] fontSize:11];
              cell.mlbdataSize.width=dataSizewith;
              cell.mlbdataSize.right=cell.mLbTitle.right;
          }
        });
    };
    CMTDemandDownLoad.updateDemanDownstart=^(){
        NSLog(@"开始下载");
            if(CMTDemandDownLoad.indexPath==nil||self.ishaveDown||(self.dataSourceArray.count<CMTDemandDownLoad.indexPath.row+1)){
                return ;
            }
            CMTDownloadingTableViewCell *cell=[self.dataTableView cellForRowAtIndexPath:CMTDemandDownLoad.indexPath];
            if(cell!=nil){
                  [self changeClassData:CMTAPPCONFIG.downloadingLive];
                [cell reloadCell:self.dataSourceArray[CMTDemandDownLoad.indexPath.row]];
            }
    };
    CMTDemandDownLoad.updateDemanDownpause=^(){
          NSLog(@"暂停下载");
            if(CMTDemandDownLoad.indexPath==nil||self.ishaveDown||(self.dataSourceArray.count<CMTDemandDownLoad.indexPath.row+1)){
                return ;
            }

            CMTDownloadingTableViewCell *cell=[self.dataTableView cellForRowAtIndexPath:CMTDemandDownLoad.indexPath];
            if(cell!=nil){
                [self changeClassData:CMTAPPCONFIG.downloadingLive];
                [cell reloadCell:self.dataSourceArray[CMTDemandDownLoad.indexPath.row]];
            }
    };

    CMTDemandDownLoad.updateDemanDownProgress=^(float downprogress,long size){
           if(CMTDemandDownLoad.downfinish){
                return ;
           }
            if(CMTDemandDownLoad.indexPath==nil||self.ishaveDown||(self.dataSourceArray.count<CMTDemandDownLoad.indexPath.row+1)){
                return ;
            }


            CMTDownloadingTableViewCell *cell=[self.dataTableView cellForRowAtIndexPath:CMTDemandDownLoad.indexPath];
            if(cell!=nil){
                [cell.ProgressView setProgress:downprogress animated:YES];
                cell.mlbdataSize.text=[CMTDownLoad AccessFileSize:size];
                float dataSizewith=[CMTGetStringWith_Height CMTGetLableTitleWith:[CMTDownLoad AccessFileSize:size] fontSize:11];
                cell.mlbdataSize.width=dataSizewith;
                cell.mlbdataSize.right=cell.mLbTitle.right;

            }
    };


}
-(void)changeSelectState:(UITableView*)tableView liverecord:(CMTLivesRecord*)record{
    if(!tableView.editing){
        return ;
    }
    if(record.isSelected){
        record.isSelected=NO;
        [self.selectArray removeObject:record.classRoomId];
        self.isdeletall=NO;
        
    }else{
        record.isSelected=YES;
        [self.selectArray addObject:record.classRoomId];
    }
    if(self.selectArray.count!=self.dataSourceArray.count){
        self.isdeletall=NO;
        [self.deleteView.checkAllButton setTitle:@"全选" forState:UIControlStateNormal];
        
    }else{
        self.isdeletall=YES;
        [self.deleteView.checkAllButton setTitle:@"取消全选" forState:UIControlStateNormal];
    }
    [self.deleteView.deleteButton setTitle:self.selectArray.count==0?@"删除":[@"删除" stringByAppendingFormat:@"(%ld)",self.selectArray.count ] forState:UIControlStateNormal];
}
//进行改变赋值
-(void)changeClassData:(CMTLivesRecord*)live{
    if(self.ishaveDown){
        return;
    }
    for (CMTLivesRecord *class in self.dataSourceArray) {
        if([class.classRoomId isEqualToString:live.classRoomId]){
            class.downData=live.downData;
            class.Downstate=live.Downstate;
            class.downloadProgress=live.downloadProgress;
            class.haveDownLength=live.haveDownLength;
            class.strDownloadID=live.strDownloadID;
            break;
        }
        
    }
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
     [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[AFNetworkReachabilityManager sharedManager] stopMonitoring];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
