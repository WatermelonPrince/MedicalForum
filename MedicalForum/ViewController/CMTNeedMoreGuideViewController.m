 //
//  CMTNeedMoreGuideViewController.m
//  MedicalForum
//
//  Created by CMT on 15/6/11.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTNeedMoreGuideViewController.h"
#import "CMTBindingViewController.h"
#import "CMTDisease.h"
@interface CMTNeedMoreGuideViewController()<UITableViewDataSource,UITableViewDelegate,UITextViewDelegate,UITextFieldDelegate>
@property(nonatomic,strong)UITableView *needMoreTableView;//需要更多列表
@property(nonatomic,strong)UITextView *feedtextView;//反馈列表
@property(nonatomic,strong)UITextField *diseaseName;//疾病名称
@property(nonatomic,strong)UITextField *DiseaseAutort;//指南发布机构
@property(nonatomic,strong)UITextField *year;//年份
@property(nonatomic,strong)UILabel *tipsLable;
@property(nonatomic,strong)UIView *footView;
@property(nonatomic,strong)UIBarButtonItem *leftButtonItem;
@property (nonatomic, strong) NSArray *leftItems;
@property(nonatomic,strong)CMTDisease *mdisease;
@property(nonatomic,assign)BOOL iscommit;
@end
@implementation CMTNeedMoreGuideViewController

-(instancetype)initDisease:(CMTDisease*)disease{
    self=[super init];
    if (self) {
        self.mdisease=disease;
        self.iscommit=NO;
    }
    return self;
}
-(UITextField*)DiseaseAutort{
    if (_DiseaseAutort==nil) {
        _DiseaseAutort=[[UITextField alloc]init];
        [_DiseaseAutort addTarget:self action:@selector(changeCommit) forControlEvents:UIControlEventEditingChanged];
        _DiseaseAutort.delegate=self;
    }
    return _DiseaseAutort;
}
-(UITextField*)diseaseName{
    if (_diseaseName==nil) {
        _diseaseName=[[UITextField alloc]init];
        
        _diseaseName.delegate=self;
    }
    return _diseaseName;
}
-(UITextField*)year{
    if (_year==nil) {
        _year=[[UITextField alloc]init];
        _year.placeholder=@"2015";
        _year.delegate=self;
    }
    return _year;
}
-(UITextView*)feedtextView{
    if (_feedtextView==nil) {
        _feedtextView=[[UITextView alloc]initWithFrame:CGRectMake(0,0, SCREEN_WIDTH, 150)];
        _feedtextView.layer.borderWidth=1;
        _feedtextView.delegate=self;
        _feedtextView.layoutManager.allowsNonContiguousLayout = NO;
        _feedtextView.font=[UIFont systemFontOfSize:17];
        _feedtextView.layer.borderColor=COLOR(c_f8f8f9).CGColor;
        [self.feedtextView addSubview:self.tipsLable];
    }
    return _feedtextView;
}
-(UILabel*)tipsLable{
    if (_tipsLable==nil) {
        _tipsLable=[[UILabel alloc]initWithFrame:CGRectMake(10, 10, SCREEN_WIDTH-20, 50)];
        _tipsLable.text=@"添加其他描述信息 （我们优先提供该机构的最新指南）";
        _tipsLable.font=[UIFont systemFontOfSize:14];
        _tipsLable.numberOfLines=0;
        [_tipsLable setLineBreakMode:NSLineBreakByWordWrapping];
        _tipsLable.textColor=[UIColor colorWithHexString:@"#D1D1D1"];
    }
    return _tipsLable;
}
-(UITableView*)needMoreTableView{
    if (_needMoreTableView==nil) {
         _needMoreTableView=[[UITableView alloc]initWithFrame:CGRectMake(0, CMTNavigationBarBottomGuide,SCREEN_WIDTH,self.contentBaseView.height-CMTNavigationBarBottomGuide)];
         [_needMoreTableView setAllowsSelection:NO];
         _needMoreTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
        _needMoreTableView.backgroundColor=[UIColor colorWithHexString:@"#EFEFF4"];
        _needMoreTableView.scrollEnabled=NO;
         _needMoreTableView.delegate=self;
         _needMoreTableView.dataSource=self;
    }
    return _needMoreTableView;
}
-(UIView*)footView{
    if (_footView==nil) {
        _footView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 70)];
        UIButton *button=[UIButton  buttonWithType:UIButtonTypeRoundedRect];
        [button setBackgroundColor:COLOR(c_3CC6C1)];
        [button setTitle:@"提交" forState:UIControlStateNormal];
        [button setTitleColor:COLOR(c_ffffff) forState:UIControlStateNormal];
        [button addTarget:self action:@selector(needCommitAction) forControlEvents:UIControlEventTouchUpInside];
        button.titleLabel.font=FONT(16);

        button.frame=CGRectMake(10, 20, SCREEN_WIDTH-20, 50);
        button.layer.cornerRadius=5;
        [_footView addSubview:button];
    }
    return _footView;
}
- (UIBarButtonItem *)leftButtonItem {
    if (_leftButtonItem == nil) {
        _leftButtonItem = [[UIBarButtonItem alloc]initWithImage:IMAGE(@"naviBar_back") style:UIBarButtonItemStyleDone target:self action:@selector(GobackAction)];
        [_leftButtonItem setBackgroundVerticalPositionAdjustment:-2.0 forBarMetrics:UIBarMetricsDefault];
    }
    return _leftButtonItem;
}
- (NSArray *)leftItems {
    if (_leftItems == nil) {
        UIBarButtonItem *leftFixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        leftFixedSpace.width = -7.5 + (RATIO - 1.0)*(CGFloat)12.0;
        _leftItems = @[leftFixedSpace, self.leftButtonItem];
    }
    
    return _leftItems;
}
//是查看指南机构是否修改
-(void)changeCommit{
    self.iscommit=NO;
}
//错误输入抖动
-(void)lockAnimationForView:(UIView*)view
{
    CALayer *lbl = [view layer];
    CGPoint posLbl = [lbl position];
    CGPoint y = CGPointMake(posLbl.x-10, posLbl.y);
    CGPoint x = CGPointMake(posLbl.x+10, posLbl.y);
    CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:@"position"];
    [animation setTimingFunction:[CAMediaTimingFunction
                                  functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [animation setFromValue:[NSValue valueWithCGPoint:x]];
    [animation setToValue:[NSValue valueWithCGPoint:y]];
    [animation setAutoreverses:YES];
    [animation setDuration:0.08];
    [animation setRepeatCount:3];
    [lbl addAnimation:animation forKey:nil];
}

//返回
-(void)GobackAction{
    [self.navigationController popViewControllerAnimated:YES];
    if (!self.iscommit&&!isEmptyString(self.DiseaseAutort.text)) {
        [self CMTCommitGuideRequestMessage];
    }
}
//文本框代理
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
//文本区域代理
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}



#pragma viewController 生命周期
-(void)viewDidLoad{
    [super viewDidLoad];
    [self setContentState:CMTContentStateNormal];
    self.contentBaseView.backgroundColor=[UIColor colorWithHexString:@"#EFEFF4"];
    [self.contentBaseView addSubview:self.needMoreTableView];
    self.titleText=@"求助";
    self.navigationItem.leftBarButtonItems=self.leftItems;
}

//视图呈现
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self addKeyboardObserver];
}

//视图消失
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

//添加键盘监听
-(void)addKeyboardObserver{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    }
- (void)keyboardWillShow:(NSNotification *)notif {
    CGRect rect = [[notif.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    if (rect.origin.y<400) {
        self.needMoreTableView.scrollEnabled=YES;
        if ([self.feedtextView isFirstResponder]) {
            [self.needMoreTableView setContentOffset:CGPointMake(0, 400-rect.origin.y)];
            self.needMoreTableView.contentSize=CGSizeMake(self.view.width,self.needMoreTableView.height+100);
        }else{
            [self.needMoreTableView setContentOffset:CGPointMake(0, 0)];
        }
        
    }
}
- (void)keyboardWillHide:(NSNotification *)notif {
         self.needMoreTableView.scrollEnabled=NO;
        [self.needMoreTableView setContentOffset:CGPointMake(0, 0)];
  }


//需求提交
-(void)needCommitAction{
    if(isEmptyString(self.DiseaseAutort.text)){
        UIColor *color = [UIColor redColor];
        _DiseaseAutort.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入机构名称" attributes:@{NSForegroundColorAttributeName: color}];
        
        [self lockAnimationForView:self.DiseaseAutort];
    }else{
        if (!CMTUSER.login) {
            CMTBindingViewController *loginVC = [CMTBindingViewController shareBindVC];
            loginVC.nextvc = kComment;
            [self.navigationController pushViewController:loginVC animated:YES];
        }else{
            [self buttonCommitGuideRequestMessage];
        }
    }
}
//返回时提交指南我需要信息
-(void)CMTCommitGuideRequestMessage{
    NSDictionary *Dic=@{@"userId":CMTUSER.login?CMTUSER.userInfo.userId:@"0",@"diseaseId":self.mdisease.diseaseId,@"issuingAgency":self.DiseaseAutort.text,@"description":self.feedtextView.text};
    [[[CMTCLIENT SentGuideRequire:Dic] deliverOn:[RACScheduler scheduler]]subscribeNext:^(id x) {
        CMTLog(@"反馈成功%@",x);
    } error:^(NSError *error) {
        CMTLog(@"返回失败%@",error);
    } completed:^{
         CMTLog(@"完成");
    }];
}

//按钮提交指南我需要信息
-(void)buttonCommitGuideRequestMessage{
    NSDictionary *Dic=@{@"userId":CMTUSER.login?CMTUSER.userInfo.userId:@"0",@"diseaseId":self.mdisease.diseaseId,@"issuingAgency":self.DiseaseAutort.text,@"description":self.feedtextView.text};
    [[[CMTCLIENT SentGuideRequire:Dic] deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(id x) {
        CMTLog(@"反馈成功");
         self.iscommit=YES;
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"反馈成功" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
    } error:^(NSError *error) {
         CMTLog(@"返回失败%@",error);
    } completed:^{
        CMTLog(@"完成");
    }];
}


#pragma UItextView 代理

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    [self.tipsLable removeFromSuperview];
    self.tipsLable=nil;
    return YES;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
#pragma tableView 代理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section==0) {
          return 2;
    }else{
        return 1;
    }
  
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
     static NSString *idenfiner=@"needmore";
     UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:idenfiner];
    if(cell==nil){
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"needmore"];
    }
    for (UIView *view in [cell.contentView subviews]) {
        [view removeFromSuperview];
    }
    if (indexPath.section==0) {
        
        UILabel *lable=[[UILabel alloc]initWithFrame:CGRectMake(10, 0,100,50)];
        lable.textColor=[UIColor blackColor];
        [cell.contentView addSubview:lable];
        cell.contentView.layer.borderWidth=0.7;
        cell.contentView.layer.borderColor=COLOR(c_f8f8f9).CGColor;
        switch (indexPath.row) {
            case 0:
                lable.text=@"疾病名称";
                
                self.diseaseName.frame=CGRectMake(110, 0,SCREEN_WIDTH-110, 50);
                self.diseaseName.text=self.mdisease.disease;
                [cell.contentView addSubview:self.diseaseName];
                break;
            case 1:
                lable.text=@"发布机构";
                self.DiseaseAutort.frame=CGRectMake(110, 0,SCREEN_WIDTH-110, 50);
                [cell.contentView addSubview:self.DiseaseAutort];
                break;
            default:
                break;
           }
    }else{
        [cell.contentView addSubview:self.feedtextView];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==0) {
         return 50;
    }else{
        return 150;
    }
   
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (section==1) {
        return self.footView;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section==1) {
        return 80;
    }else{
        return 0;
    }
}

@end
