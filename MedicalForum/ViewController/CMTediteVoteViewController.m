//
//  CMTediteVoteViewController.m
//  MedicalForum
//
//  Created by guoyuanchao on 15/11/24.
//  Copyright © 2015年 CMT. All rights reserved.
//

#import "CMTediteVoteViewController.h"
#import "UITextView+Placeholder.h"
#import <QuartzCore/QuartzCore.h>
@interface CMTediteVoteViewController ()<UITextViewDelegate>
@property (nonatomic, strong, readwrite) UITextView *contentTextView;               // 正文输入区
@property (nonatomic,strong)  UIView *numberlableView;
@property (nonatomic,strong)  UILabel *numberlable;
@property (nonatomic, strong) UIBarButtonItem *cancelItem;                          // 取消按钮
@property (nonatomic, strong) UIBarButtonItem *sendItem;                            // 确定按钮
@property(nonatomic,assign)NSInteger maxnumber;
@end

@implementation CMTediteVoteViewController
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
-(UIView*)numberlableView{
    if (_numberlableView == nil) {
        _numberlableView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
        _numberlableView.backgroundColor = COLOR(c_ffffff);
        self.numberlable.frame=CGRectMake(0, 0, SCREEN_WIDTH-20, 30);
        [self.numberlableView addSubview:self.numberlable];
    }
    return _numberlableView;
    
}
- (UILabel *)numberlable {
    if (_numberlable == nil) {
        _numberlable = [[UILabel alloc] init];
        _numberlable.backgroundColor = COLOR(c_ffffff);
        _numberlable.textColor = [UIColor colorWithHexString:@"#C4C4C4"];
        _numberlable.textAlignment=NSTextAlignmentRight;
        _numberlable.font = FONT(13);
    }
    
    return _numberlable;
}
- (UITextView *)contentTextView {
    if (_contentTextView == nil) {
        _contentTextView = [[UITextView alloc] init];
        _contentTextView.backgroundColor = COLOR(c_clear);
        _contentTextView.textColor = COLOR(c_151515);
        _contentTextView.showsHorizontalScrollIndicator = NO;
        _contentTextView.showsVerticalScrollIndicator = NO;
        _contentTextView.font = FONT(15.0);
        _contentTextView.layoutManager.allowsNonContiguousLayout = NO;
        _contentTextView.delegate = self;
        _contentTextView.placeholder=@"请输入内容";
   }
    
    return _contentTextView;
}

-(instancetype)initWithtext:(NSString*)text maxnumber:(NSInteger)maxNumber{
    self=[super init];
    if (self) {
        self.maxnumber=maxNumber;
        self.contentTextView.text=text;
        self.numberlable.text=[@"" stringByAppendingFormat:@"还可以输入%ld字",(long)maxNumber-text.length];
        
    }
    return self;
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.contentTextView becomeFirstResponder];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.contentTextView resignFirstResponder];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleText=self.maxnumber==300?@"标题":@"编辑投票";
    [self setContentState:CMTContentStateNormal];
    self.contentBaseView.backgroundColor=COLOR(c_ffffff);
    self.navigationItem.leftBarButtonItem=self.cancelItem;
    self.navigationItem.rightBarButtonItem=self.sendItem;
    @weakify(self);
    self.cancelItem.rac_command=[[RACCommand alloc]initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self);
        [self dismissViewControllerAnimated:YES completion:nil];
        return [RACSignal empty];
    }];
    self.sendItem.rac_command=[[RACCommand alloc]initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self);
        [self.contentTextView resignFirstResponder];
        NSString *str=[self.contentTextView.text stringByReplacingOccurrencesOfString:@" " withString:@""];
        if (str.length==0) {
            [self toastAnimation:@"内容不能为空"];
            return [RACSignal empty];
        }
        if (self.contentTextView.text.length>self.maxnumber) {
            str=[self.contentTextView.text substringToIndex:self.maxnumber];
        }else{
            str=self.contentTextView.text;
        }
        if (self.updatedata!=nil) {
            self.updatedata(str);
        }
        [self dismissViewControllerAnimated:YES completion:nil];
        return [RACSignal empty];
    }];
    // 正文输入区
    self.contentTextView.frame=CGRectMake(10,CMTNavigationBarBottomGuide+1, SCREEN_WIDTH-20, 180);
    [self.contentBaseView addSubview:self.contentTextView];
    
    self.numberlableView.frame=CGRectMake(10, self.contentTextView.bottom, SCREEN_WIDTH-20, 30);
    [self.contentBaseView addSubview:self.numberlableView];
    
    UIView *buttomLine=[[UIView alloc]initWithFrame:CGRectMake(0,  self.numberlableView.bottom, SCREEN_WIDTH, 1)];
    buttomLine.backgroundColor=[UIColor colorWithHexString:@"#F2F3F5"];
    [self.contentBaseView addSubview:buttomLine];
    
    


}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    NSString *str=[self.contentTextView.text stringByAppendingString:text];
    if (str.length>self.maxnumber) {
        
        str=[str substringToIndex:self.maxnumber];
        textView.text=str;
        self.numberlable.text=[@"" stringByAppendingFormat:@"还可输入%ld个字", (long)(self.maxnumber-str.length)];
        
        return NO;
    }else{
        if([text isEqualToString:@"\n"]){
            [textView resignFirstResponder];
            return NO;
    }
           self.numberlable.text=[@"" stringByAppendingFormat:@"还可输入%ld个字", (long)(self.maxnumber-str.length)];
        return YES;
       
    }
    return NO;
}
- (void)textViewDidChange:(UITextView *)textView{
    if (textView.text.length>self.maxnumber) {
        textView.text=[textView.text substringToIndex:self.maxnumber];

    }
    self.numberlable.text=[@"" stringByAppendingFormat:@"还可输入%ld个字", (long)(self.maxnumber-textView.text.length)];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
