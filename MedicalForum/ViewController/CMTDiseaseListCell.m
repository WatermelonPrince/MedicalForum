//
//  CMTDiseaseListCell.m
//  MedicalForum
//
//  Created by CMT on 15/6/9.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTDiseaseListCell.h"
#import "CMTBadgePoint.h"
@interface CMTDiseaseListCell()
@property(nonatomic,strong)UILabel *mlable;//疾病名称标签
@property(nonatomic,strong)UIImageView *nextimage;//下一级指示标签
@property(nonatomic,strong)UIView *topline;//上边线（未使用）
@property(nonatomic,strong)UIView *buttomline;//下边线（未使用）
@property(strong,nonatomic)CMTBadgePoint *badgePoint;//更新显示
@property(strong,nonatomic)UIButton *FocusonButton;//订阅按钮
@property(strong,nonatomic)NSMutableArray *fouceTagArray;
@property(strong,nonatomic)CMTDisease *mDisease;

@end
@implementation CMTDiseaseListCell
-(UILabel*)mlable{
    if (_mlable==nil) {
        _mlable=[[UILabel alloc]init];
    }
    return _mlable;
}
-(UIImageView*)nextimage{
    if (_nextimage==nil) {
        _nextimage=[[UIImageView alloc]init];
        _nextimage.image=IMAGE(@"Guide_forward");
    }
    return _nextimage;
}
-(UIView*)topline{
    if (_topline==nil) {
        _topline=[[UIView alloc]initWithFrame:CGRectZero];
        _topline.backgroundColor=COLOR(c_f8f8f9);
    }
    return _topline;
}
-(UIView*)buttomline{
    if (_buttomline==nil) {
        _buttomline=[[UIView alloc]init];
        _topline.backgroundColor=COLOR(c_f8f8f9);
    }
    return _buttomline;
}
- (CMTBadgePoint *)badgePoint {
    if (_badgePoint == nil) {
        _badgePoint = [[CMTBadgePoint alloc] init];
        _badgePoint.hidden = YES;
    }
    
    return _badgePoint;
}
-(UIButton*)FocusonButton{
    if(_FocusonButton==nil){
        _FocusonButton=[[UIButton alloc]init];
          _FocusonButton.layer.cornerRadius = 6.0;
        _FocusonButton.hidden=YES;
    }
    return _FocusonButton;
}
-(NSMutableArray*)fouceTagArray{
    if (_fouceTagArray==nil) {
        _fouceTagArray=[[NSMutableArray alloc]init];
    }
    return _fouceTagArray;
}
-(CMTDisease*)mDisease{
    if (_mDisease==nil) {
        _mDisease=[[CMTDisease alloc]init];
    }
    return _mDisease;
}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor=COLOR(c_ffffff);
        self.layer.borderWidth=0.5;
        self.layer.borderColor=COLOR(c_f8f8f9).CGColor;
        [self.contentView addSubview:self.mlable];
        [self.contentView addSubview:self.nextimage];
        [self.contentView addSubview:self.FocusonButton];
    }
    return self;
}
//刷新列表cell数据
-(void)reloadCellData:(CMTDisease*)Disease index:(NSInteger)index{
    [self CMTgetAllFouceTag];
    self.mDisease=Disease;
    self.mlable.frame=CGRectMake(10,0, SCREEN_WIDTH-80-10, 50);
    self.mlable.text=Disease.disease;
    [self.mlable setFont:FONT(16)];
    self.badgePoint.frame=CGRectMake(200,15, 10, 10);
    if (self.isShowFocusButton) {
        self.nextimage.hidden=YES;
        self.FocusonButton.hidden=NO;
        self.FocusonButton.frame=CGRectMake(SCREEN_WIDTH- 80-10, 10, 80, 30);
        [self.FocusonButton.titleLabel setFont:FONT(16)];
        if (![self CMTjudgeIsFouce] ) {
            [self.FocusonButton setBackgroundColor:[UIColor clearColor]];
            self.FocusonButton.layer.borderColor = COLOR(c_32c7c2).CGColor;
            self.FocusonButton.layer.borderWidth = PIXEL;
            [self.FocusonButton setTitle:@"+ 订阅" forState:UIControlStateNormal];
            [self.FocusonButton setTitleColor:COLOR(c_32c7c2) forState:UIControlStateNormal];
            [self.FocusonButton removeTarget:self action:@selector(cancelfouceAction:) forControlEvents:UIControlEventTouchUpInside];
            [self.FocusonButton addTarget:self action:@selector(fouceAction:) forControlEvents:UIControlEventTouchUpInside];
        }else{
             [self.FocusonButton setBackgroundColor:COLOR(c_dfdfdf)];
            [self.FocusonButton setTitle:@"已订阅" forState:UIControlStateNormal];
            [self.FocusonButton setTitleColor:COLOR(c_9e9e9e) forState:UIControlStateNormal];
            [self.FocusonButton setBackgroundColor:COLOR(c_dfdfdf)];
            self.FocusonButton.layer.borderColor = COLOR(c_ababab).CGColor;
            self.FocusonButton.layer.borderWidth = PIXEL;
            [self.FocusonButton removeTarget:self action:@selector(fouceAction:) forControlEvents:UIControlEventTouchUpInside];
             [self.FocusonButton addTarget:self action:@selector(cancelfouceAction:) forControlEvents:UIControlEventTouchUpInside];

        }
    }else{
        self.FocusonButton.hidden=YES;
        self.nextimage.hidden=NO;
          self.nextimage.frame=CGRectMake(SCREEN_WIDTH-21-10, (50-21)/2, 21, 21);
    }
  
    
    self.frame=CGRectMake(self.frame.origin.x, self.frame.origin.y, SCREEN_WIDTH,50);
}
//获取关注标签的数据
-(void)CMTgetAllFouceTag{
    if([[NSFileManager defaultManager] fileExistsAtPath:PATH_FOUSTAG]){
        self.fouceTagArray=[[NSKeyedUnarchiver unarchiveObjectWithFile:PATH_FOUSTAG]mutableCopy];
    }else{
        [self.fouceTagArray removeAllObjects];
    }
}
//订阅
-(void)fouceAction:(UIButton*)button{
    [self CMTgetAllFouceTag];
    self.mDisease.opTime=TIMESTAMP;
     self.mDisease.count=@"0";
    [self.fouceTagArray addObject:self.mDisease];
    [NSKeyedArchiver archiveRootObject:self.fouceTagArray toFile:PATH_FOUSTAG];
    [self.FocusonButton setTitle:@"已订阅" forState:UIControlStateNormal];
    [self.FocusonButton setTitleColor:COLOR(c_9e9e9e) forState:UIControlStateNormal];
    [self.FocusonButton setBackgroundColor:COLOR(c_dfdfdf)];
    self.FocusonButton.layer.borderColor = COLOR(c_ababab).CGColor;
    self.FocusonButton.layer.borderWidth = PIXEL;
    [self.FocusonButton removeTarget:self action:@selector(fouceAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.FocusonButton addTarget:self action:@selector(cancelfouceAction:) forControlEvents:UIControlEventTouchUpInside];
    NSDictionary *dic=@{@"userId":CMTUSER.login?CMTUSER.userInfo.userId:@"0",@"diseaseId":self.mDisease.diseaseId,@"cancelFlag":@"0"};
    CMTLog(@"sssssss%@",dic);
    @weakify(self);
    [[[CMTCLIENT FollowDisease:dic]deliverOn:[RACScheduler scheduler]]subscribeNext:^(CMTDisease *dis) {
        @strongify(self);
        CMTLog(@"hfhhfhfhfhffh11111111111%@",dis);
            self.fouceTagArray=[[NSKeyedUnarchiver unarchiveObjectWithFile:PATH_FOUSTAG] mutableCopy];
           [self.fouceTagArray removeObject:self.mDisease];
            self.mDisease.opTime=dis.opTime;
            self.mDisease.readTime=TIMESTAMP;
            self.mDisease.postReadtime=TIMESTAMP;
            self.mDisease.caseReadtime=TIMESTAMP;
            self.mDisease.count=@"0";
            self.mDisease.postCount=@"0";
            self.mDisease.caseCout=@"0";
            [self.fouceTagArray addObject:self.mDisease];
        [self.fouceTagArray sortUsingComparator:^NSComparisonResult(CMTDisease *obj1, CMTDisease *obj2) {
            NSComparisonResult result = [obj1.opTime compare:obj2.opTime] ;
            return  result;
        }];
    [NSKeyedArchiver archiveRootObject:[self.fouceTagArray mutableCopy] toFile:PATH_FOUSTAG];
    } error:^(NSError *error) {
        CMTLog(@"订阅失败%@",error);
    } completed:^{
        CMTLog(@"完成");
        
    }];

    
}
//取消关注
-(void)cancelfouceAction:(UIButton*)button{
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"确定不再订阅该疾病标签" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert show];

}
//判断是否已经关注
-(BOOL)CMTjudgeIsFouce{
    BOOL isfouce=NO;
    for (CMTDisease * diseaa in self.fouceTagArray) {
        if ([diseaa.diseaseId isEqualToString:self.mDisease.diseaseId]) {
            isfouce=YES;
            return isfouce;
        }
    }
    return isfouce;
}
//删除疾病关注对象
-(void)CMTRemoveDuplicateDisease{
    NSMutableArray *mutableArray=[[NSMutableArray alloc]initWithArray:self.fouceTagArray];
    for (CMTDisease *dis in self.fouceTagArray) {
        if ([dis.diseaseId isEqualToString:self.mDisease.diseaseId]) {
            [mutableArray removeObject:dis];
            //更改未读文章数目            
            CMTAPPCONFIG.GuideUnreadNumber=[@"" stringByAppendingFormat:@"%ld",(long)[CMTAPPCONFIG.GuideUnreadNumber integerValue]-[dis.count integerValue]];

        }
    }
    self.fouceTagArray=[mutableArray mutableCopy];
}

//alertView 代理
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex==1){
        [self CMTgetAllFouceTag];
        [self CMTRemoveDuplicateDisease];
        [NSKeyedArchiver archiveRootObject:self.fouceTagArray toFile:PATH_FOUSTAG];
        self.FocusonButton.layer.borderColor = COLOR(c_32c7c2).CGColor;
        self.FocusonButton.layer.borderWidth = PIXEL;
        self.FocusonButton.layer.cornerRadius = 6.0;
        [self.FocusonButton setTitle:@"+ 订阅" forState:UIControlStateNormal];
        [self.FocusonButton setBackgroundColor:[UIColor clearColor]];
        [self.FocusonButton setTitleColor:COLOR(c_32c7c2) forState:UIControlStateNormal];
        [self.FocusonButton removeTarget:self action:@selector(cancelfouceAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.FocusonButton addTarget:self action:@selector(fouceAction:) forControlEvents:UIControlEventTouchUpInside];
        NSDictionary *dic=@{@"userId":CMTUSER.login?CMTUSER.userInfo.userId:@"0",@"diseaseId":self.mDisease.diseaseId,@"cancelFlag":@"1"};
        [[[CMTCLIENT FollowDisease:dic]deliverOn:[RACScheduler scheduler]]subscribeNext:^(id x) {
            
        } error:^(NSError *error) {
            CMTLog(@"删除失败%@",error);
        } completed:^{
             CMTLog(@"完成");
            
        }];
    }
}

@end
