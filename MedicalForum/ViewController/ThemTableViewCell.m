//
//  ThemTableViewCell.m
//  MedicalForum
//
//  Created by guoyuanchao on 16/9/13.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import "ThemTableViewCell.h"
@interface ThemTableViewCell()
@property(nonatomic,strong)UILabel *mlable;//专题名称
@property(nonatomic,strong)UIImageView *picimageView;//专题图片
@property(nonatomic,strong)UIView *buttomline;//下边线（）
@property(strong,nonatomic)UIButton *FocusonButton;//订阅按钮
@property(strong,nonatomic)NSMutableArray *fouceThemeArray;
@property(strong,nonatomic)CMTTheme *mytheme;
@property(strong,nonatomic)UILabel *systimelable;//更新时间
@end
@implementation ThemTableViewCell
-(UIImageView*)picimageView{
    if (_picimageView==nil) {
        _picimageView=[[UIImageView alloc]init];
        _picimageView.contentMode=UIViewContentModeScaleAspectFill;
        _picimageView.clipsToBounds=YES;
    }
    return _picimageView;
}
-(UILabel*)mlable{
    if (_mlable==nil) {
        _mlable=[[UILabel alloc]init];
        _mlable.font=[UIFont systemFontOfSize:16];
        _mlable.textColor=[UIColor blackColor];
        _mlable.lineBreakMode=NSLineBreakByTruncatingTail;
        _mlable.numberOfLines=2;
    }
    return _mlable;
}
-(UILabel*)systimelable{
    if (_systimelable==nil) {
        _systimelable=[[UILabel alloc]init];
        _systimelable.font=[UIFont systemFontOfSize:13*XXXRATIO];
        _systimelable.textColor=COLOR(c_9e9e9e);
    }
    return _systimelable;
}

-(UIView*)buttomline{
    if (_buttomline==nil) {
        _buttomline=[[UIView alloc]init];
        _buttomline.backgroundColor=COLOR(c_f8f8f9);
    }
    return _buttomline;
}
-(UIButton*)FocusonButton{
    if(_FocusonButton==nil){
        _FocusonButton=[[UIButton alloc]init];
        _FocusonButton.layer.cornerRadius = 6.0;
        _FocusonButton.titleLabel.font=FONT(16);
    }
    return _FocusonButton;
}
-(NSMutableArray*)fouceThemeArray{
    if (_fouceThemeArray==nil) {
        _fouceThemeArray=[[NSMutableArray alloc]init];
    }
    return _fouceThemeArray;
}
-(CMTTheme*)mytheme{
    if (_mytheme==nil) {
        _mytheme=[[CMTTheme alloc]init];
    }
    return _mytheme;
}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor=COLOR(c_ffffff);
        [self.contentView addSubview:self.picimageView];
        [self.contentView addSubview:self.buttomline];
        [self.contentView addSubview:self.systimelable];
        [self.contentView addSubview:self.mlable];
        [self.contentView addSubview:self.FocusonButton];
    }
    return self;
}
-(void)reloadCell:(CMTTheme*)theme{
     [self CMTgetAllFouceTheme];
    if ([theme isKindOfClass:[CMTTheme class]]) {
        self.mytheme=theme;
        self.picimageView.frame=CGRectMake(10, 10,100*XXXRATIO, 70*XXXRATIO);
        [self.picimageView setQuadrateScaledImageURL:theme.picture placeholderImage:IMAGE(@"Placeholderdefault") width:90];
        float height=[CMTGetStringWith_Height getTextheight:@"中国" fontsize:16 width:SCREEN_WIDTH-self.picimageView.width-20-100]*2;
        self.mlable.frame=CGRectMake(self.picimageView.right+10, self.picimageView.top, SCREEN_WIDTH-self.picimageView.width-20-100, height);
        self.mlable.text=theme.title;
        self.FocusonButton.frame=CGRectMake(SCREEN_WIDTH-82,  (self.picimageView.height+20-28)/2, 72, 28);
        if (![self CMTjudgeIsFouce] ) {
            [self.FocusonButton setBackgroundColor:[UIColor clearColor]];
            self.FocusonButton.layer.borderColor = COLOR(c_32c7c2).CGColor;
            self.FocusonButton.layer.borderWidth = PIXEL;
            [self.FocusonButton setTitle:@"+订阅" forState:UIControlStateNormal];
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
        float height2=[CMTGetStringWith_Height getTextheight:@"中国" fontsize:13 width:self.mlable.width];
        self.systimelable.frame=CGRectMake(self.picimageView.right+10, self.picimageView.bottom-20*XXXRATIO, self.mlable.width, height2) ;
        self.systimelable.text=[NSString stringWithFormat:@"更新日期: %@",DATE(theme.opTime)];
        self.frame=CGRectMake(self.left, self.top, SCREEN_WIDTH,self.picimageView.bottom+10);
        self.buttomline.frame=CGRectMake(self.picimageView.left, self.height-1, SCREEN_WIDTH-self.picimageView.left, 1);
        
    }
}
//获取关注专题的数据
-(void)CMTgetAllFouceTheme{
    if([[NSFileManager defaultManager] fileExistsAtPath:[PATH_USERS stringByAppendingPathComponent:@"focusList"]]){
        self.fouceThemeArray=[[NSKeyedUnarchiver unarchiveObjectWithFile:[PATH_USERS stringByAppendingPathComponent:@"focusList"]]mutableCopy];
    }else{
        [self.fouceThemeArray removeAllObjects];
    }
}
//订阅
-(void)fouceAction:(UIButton*)button{
    if (CMTAPPCONFIG.currentVersionThemeFocused == NO) {
        // 显示提示
        [[[UIAlertView alloc] initWithTitle:@"提示" message:@"你可以在左侧导航的“专题”中，查看已订阅的全部专题。" delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles:nil] show];
        // 记录强制订阅版本
        CMTAPPCONFIG.themeFocusedRecordedVersion = APP_VERSION;
    }

    [self CMTgetAllFouceTheme];
    [self.fouceThemeArray addObject:self.mytheme];
    [NSKeyedArchiver archiveRootObject:self.fouceThemeArray toFile:[PATH_USERS stringByAppendingPathComponent:@"focusList"]];
    [self.FocusonButton setTitle:@"已订阅" forState:UIControlStateNormal];
    [self.FocusonButton setTitleColor:COLOR(c_9e9e9e) forState:UIControlStateNormal];
    [self.FocusonButton setBackgroundColor:COLOR(c_dfdfdf)];
    self.FocusonButton.layer.borderColor = COLOR(c_ababab).CGColor;
    self.FocusonButton.layer.borderWidth = PIXEL;
    [self.FocusonButton removeTarget:self action:@selector(fouceAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.FocusonButton addTarget:self action:@selector(cancelfouceAction:) forControlEvents:UIControlEventTouchUpInside];
     NSDictionary *dic=@{@"userId":CMTUSER.login?CMTUSER.userInfo.userId:@"0",@"themeId":self.mytheme.themeId,@"cancelFlag":@"0"};
             CMTLog(@"sssssss%@",dic);
     @weakify(self);
    [[[CMTCLIENT fetchTheme:dic]deliverOn:[RACScheduler scheduler]]subscribeNext:^(CMTTheme *theme) {
        @strongify(self);
            CMTLog(@"hfhhfhfhfhffh11111111111%@",theme);
        self.fouceThemeArray=[[NSKeyedUnarchiver unarchiveObjectWithFile:PATH_FOUSTAG] mutableCopy];
        [self.fouceThemeArray removeObject:self.mytheme];
        self.mytheme.opTime=theme.opTime;
        self.mytheme.viewTime=theme.opTime;
        [NSKeyedArchiver archiveRootObject:[self.fouceThemeArray mutableCopy] toFile:PATH_FOUSTAG];
    } error:^(NSError *error) {
        NSLog(@"订阅失败");
    } completed:^{
        CMTLog(@"完成");
        
    }];
    
    
}
//取消关注
-(void)cancelfouceAction:(UIButton*)button{
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"确定不再订阅该专题吗？" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert show];
    
}
//判断是否已经关注
-(BOOL)CMTjudgeIsFouce{
    BOOL isfouce=NO;
    for (CMTTheme * theme in self.fouceThemeArray) {
        if ([theme.themeId isEqualToString:self.mytheme.themeId]) {
            isfouce=YES;
            return isfouce;
        }
    }
    return isfouce;
}
//删除专题关注对象
-(void)CMTRemoveDuplicateTheme{
    NSMutableArray *mutableArray=[[NSMutableArray alloc]initWithArray:self.fouceThemeArray];
    for (CMTTheme *theme in self.fouceThemeArray) {
        if ([theme.themeId isEqualToString:self.mytheme.themeId]) {
            [mutableArray removeObject:theme];
        }
    }
    self.fouceThemeArray=[mutableArray mutableCopy];
}

//alertView 代理
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex==1){
        [self CMTgetAllFouceTheme];
        [self CMTRemoveDuplicateTheme];
        [NSKeyedArchiver archiveRootObject:self.fouceThemeArray toFile:[PATH_USERS stringByAppendingPathComponent:@"focusList"]];
        self.FocusonButton.layer.borderColor = COLOR(c_32c7c2).CGColor;
        self.FocusonButton.layer.borderWidth = PIXEL;
        self.FocusonButton.layer.cornerRadius = 6.0;
        [self.FocusonButton setTitle:@"+ 订阅" forState:UIControlStateNormal];
        [self.FocusonButton setBackgroundColor:[UIColor clearColor]];
        [self.FocusonButton setTitleColor:COLOR(c_32c7c2) forState:UIControlStateNormal];
        [self.FocusonButton removeTarget:self action:@selector(cancelfouceAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.FocusonButton addTarget:self action:@selector(fouceAction:) forControlEvents:UIControlEventTouchUpInside];
        NSDictionary *dic=@{@"userId":CMTUSER.login?CMTUSER.userInfo.userId:@"0",@"themeId":self.mytheme.themeId,@"cancelFlag":@"1"};
        //调用全局的删除接口
        [CMTFOCUSMANAGER asyneTheme:dic];

     }
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
