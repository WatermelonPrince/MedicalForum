//
//  LightVideolistCell.m
//  MedicalForum
//
//  Created by zhaohuan on 16/6/2.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import "LightVideolistCell.h"

@interface LightVideolistCell ()

@property (nonatomic, strong) UIView      *m_backgroundView;
@property (nonatomic, strong) UILabel     *m_titleLabel;
@property (nonatomic, strong) UILabel     *m_timeLabel;
@property (nonatomic, strong) UIImageView *m_liveimageView;
@property (nonatomic, strong) UIView      *m_lineView;//分割线
@property (nonatomic, strong) UILabel     *m_userNameLabel;//姓名
@property (nonatomic, strong) UILabel     *m_levelLabel;//职称等级
@property (nonatomic, strong) UILabel     *m_hospitalLabel;//医院
@property (nonatomic, strong) UILabel     *m_departmentLabel;//科室
@property (nonatomic, strong) UILabel     *m_watchLabel;//观看



@property (nonatomic, weak)   CMTLivesRecord* m_data;
@property (nonatomic, weak)   NSIndexPath *m_tmpIndexPath;


@end

@implementation LightVideolistCell

- (void)defaultConfig {
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.2];
    
}

- (void)buildViews {
    
    self.m_backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 179.5)];
    [self addSubview:_m_backgroundView];
    
    _m_backgroundView.backgroundColor = [UIColor whiteColor];
    
    // 标题
    self.m_titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 15, SCREEN_WIDTH-20, 20)];
    
    
    _m_titleLabel.textColor = ColorWithHexStringIndex(c_151515);
    _m_titleLabel.font      = FONT(18);
    
 
       //点播列表图片
    _m_liveimageView = [[UIImageView alloc]initWithFrame:CGRectMake(self.m_titleLabel.left, self.m_titleLabel.bottom + 10, 100, 100)];
    _m_liveimageView.backgroundColor = ColorWithHexStringIndex(c_9e9e9e);
    _m_liveimageView.contentMode = UIViewContentModeScaleAspectFill;
    _m_liveimageView.clipsToBounds = YES;

    
    //userNameLabel
    _m_userNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(_m_liveimageView.right + 10, _m_liveimageView.top, SCREEN_WIDTH - 200/2 - 100 - 25, 20)];
    _m_userNameLabel.font = FONT(18);
   
    _m_userNameLabel.textColor = ColorWithHexStringIndex(c_151515);
    
    //levelLabel
    _m_levelLabel = [[UILabel alloc]initWithFrame:CGRectMake(_m_userNameLabel.right + 5, _m_liveimageView.top, 200/2, 20)];
    
    _m_levelLabel.font = FONT(18);
    _m_levelLabel.textColor = ColorWithHexStringIndex(c_151515);
    
    //科室
    _m_departmentLabel = [[UILabel alloc]initWithFrame:CGRectMake(_m_userNameLabel.left, _m_userNameLabel.bottom + 7.5, SCREEN_WIDTH - 140, 15)];
    
    _m_departmentLabel.textColor = ColorWithHexStringIndex(c_9e9e9e);
    
    //医院
    _m_hospitalLabel = [[UILabel alloc]initWithFrame:CGRectMake(_m_userNameLabel.left, _m_departmentLabel.bottom + 5, SCREEN_WIDTH - 140, 15)];
    
    
    _m_hospitalLabel.textColor = ColorWithHexStringIndex(c_9e9e9e);
    
    if (SCREEN_WIDTH <= 320) {
        _m_departmentLabel.font = FONT(13);
        _m_hospitalLabel.font = FONT(13);
        _m_userNameLabel.frame = CGRectMake(_m_liveimageView.right + 10, _m_liveimageView.top, SCREEN_WIDTH - _m_liveimageView.right - 10, 20);
        _m_levelLabel.frame = CGRectMake(_m_userNameLabel.right + 10, _m_liveimageView.top, 70, 20);
        _m_levelLabel.font = FONT(14);
        _m_userNameLabel.font = FONT(14);
        
    }else{
        _m_departmentLabel.font = FONT(14);
        _m_hospitalLabel.font = FONT(14);
        _m_userNameLabel.frame = CGRectMake(_m_liveimageView.right + 10, _m_liveimageView.top, SCREEN_WIDTH - _m_liveimageView.right - 20, 20);
        _m_levelLabel.frame = CGRectMake(_m_userNameLabel.right + 10, _m_liveimageView.top, 90, 20);
        _m_levelLabel.font = FONT(18);
        _m_userNameLabel.font = FONT(18);
        
    }
    //观看按钮
    _m_watchLabel = [[UILabel alloc]init];
    _m_watchLabel.frame = CGRectMake(_m_userNameLabel.left, _m_hospitalLabel.bottom + 7.5, 100, 30);
    _m_watchLabel.text = @"点击观看";
    _m_watchLabel.font = FONT(15);
    _m_watchLabel.textColor = [UIColor whiteColor];
    _m_watchLabel.textAlignment = NSTextAlignmentCenter;
    _m_watchLabel.layer.cornerRadius = 8;
    _m_watchLabel.layer.masksToBounds = YES;
//    _m_registrationButton.layer.borderWidth = 1;
//    _m_registrationButton.layer.borderColor = [UIColor blackColor].CGColor;
    _m_watchLabel.backgroundColor = [UIColor colorWithHexString:@"#ffa320"];
    
    
    
    //分割线
    _m_lineView = [[UIView alloc]initWithFrame:CGRectMake(0,169, SCREEN_WIDTH, 1)];
    _m_lineView.backgroundColor = ColorWithHexStringIndex(c_f6f6f6);
    
    [_m_backgroundView addSubview:_m_titleLabel];
    [_m_backgroundView addSubview:_m_liveimageView];
    [_m_backgroundView addSubview:_m_lineView];
    [_m_backgroundView addSubview:_m_userNameLabel];
//    [_m_backgroundView addSubview:_m_levelLabel];
    [_m_backgroundView addSubview:_m_departmentLabel];
    [_m_backgroundView addSubview:_m_hospitalLabel];
    [_m_backgroundView addSubview:_m_watchLabel];
    
    
}

- (void)loadData:(id)data indexPath:(NSIndexPath *)indexPath currentDate:(NSString *)date{
    
    if ([data isMemberOfClass:[CMTLivesRecord class]]) {
        CMTLivesRecord *model = (CMTLivesRecord*)data;
        //标题
        self.m_titleLabel.text = model.title;
        //图片
        [self.m_liveimageView setImageURL:model.roomPic placeholderImage:nil contentSize:CGSizeMake(100, 100)];
         NSString *userNameLevelStr = [NSString stringWithFormat:@"%@  %@",model.userName,model.level];
        //医师
        self.m_userNameLabel.text = userNameLevelStr;
       

        //级别
        self.m_levelLabel.text = model.level;
        //医院
        self.m_hospitalLabel.text = model.hospital;
        //科室
        self.m_departmentLabel.text = model.subDepartment;
    }
}



- (void)dealloc {

}






@end
