//
//  TimeCell.m
//  CountDownTimerForTableView
//
//  Created by FrankLiu on 15/9/14.
//  Copyright (c) 2015年 FrankLiu. All rights reserved.
//

#import "TimeCell.h"
@interface TimeCell ()

@property (nonatomic, strong) UIView      *m_backgroundView;
@property (nonatomic, strong) UILabel     *m_timeLabel;
@property (nonatomic, strong) UILabel     *m_start_endLabel;
@property (nonatomic, strong) UIImageView *m_liveimageView;
@property (nonatomic, strong) UIView      *m_lineView;//分割线
@property (nonatomic, strong) UILabel     *m_levelLabel;//职称等级
@property (nonatomic, strong) UILabel     *m_departmentLabel;//科室
@property (nonatomic, weak)   CMTLivesRecord* m_data;
@property (nonatomic, weak)   NSIndexPath *m_tmpIndexPath;

@property (nonatomic,strong) UIImageView *IslivingImage;

@end

@implementation TimeCell

- (void)defaultConfig {

    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.2];
    
}

- (void)buildViews {

    self.m_backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH * 9/16 +200/3)];
    [self addSubview:_m_backgroundView];
    _m_backgroundView.backgroundColor = [UIColor whiteColor];
    
    //直播列表图片
    _m_liveimageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH *9/16)];
    _m_liveimageView.backgroundColor = ColorWithHexStringIndex(c_9e9e9e);
    _m_liveimageView.contentMode = UIViewContentModeScaleAspectFill;
    _m_liveimageView.clipsToBounds=YES;
    
    // 标题
    self.m_titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(8 * XXXRATIO,  _m_liveimageView.height+ 10, SCREEN_WIDTH-20 * XXXRATIO, 200/3/2-15)];
    
    
    _m_titleLabel.textColor = ColorWithHexStringIndex(c_151515);
    _m_titleLabel.font      = FONT(17);
    
    //开始结束时间
    _m_start_endLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.m_titleLabel.left, self.m_titleLabel.bottom + 4, SCREEN_WIDTH, 200/3/2-15)];
    _m_start_endLabel.textColor = ColorWithHexStringIndex(c_9e9e9e);
    if (SCREEN_WIDTH <= 320) {
        _m_start_endLabel.font = FONT(13);
    }else{
        _m_start_endLabel.font = FONT(14);

    }
    
    self.IslivingImage = [[UIImageView alloc]initWithImage:IMAGE(@"isLivingImage")];
    self.IslivingImage.frame = CGRectMake(0, 0, 65 * XXXRATIO, 65 * XXXRATIO);
    self.IslivingImage.hidden = YES;
    
    
    
    
    
    
    //分割线
    _m_lineView = [[UIView alloc]initWithFrame:CGRectMake(0,SCREEN_WIDTH *9/16 + 200/3 - 1, SCREEN_WIDTH, 1)];
    _m_lineView.backgroundColor = ColorWithHexStringIndex(c_f6f6f6);
    
    [_m_backgroundView addSubview:_m_liveimageView];

    [_m_backgroundView addSubview:_m_titleLabel];
    [_m_backgroundView addSubview:_m_start_endLabel];
    [_m_backgroundView addSubview:_m_lineView];
    [_m_backgroundView addSubview:self.IslivingImage];
    
    
}

- (void)loadData:(id)data indexPath:(NSIndexPath *)indexPath currentDate:(NSString *)date{
    
    if ([data isMemberOfClass:[CMTLivesRecord class]]) {
        
        
        CMTLivesRecord *model = (CMTLivesRecord*)data;
        
        //标题
        self.m_titleLabel.text = model.title;
        //图片
        [self.m_liveimageView setImageURL:model.roomPic placeholderImage:nil contentSize:CGSizeMake(self.m_liveimageView.width, self.m_liveimageView.height)];
        
        
        NSString *toStartTime;
        
        if (model.startDate.longLongValue - date.longLongValue < 0 && model.endDate.longLongValue - date.longLongValue > 0) {
            toStartTime = @"直播进行中";
            self.m_start_endLabel.text = [NSString stringWithFormat:@"%@， %@",[model startDateAndEndDateformattNSString],toStartTime];
            self.IslivingImage.hidden = NO;

        }else if (model.endDate.longLongValue - date.longLongValue < 0){
            toStartTime = @"直播已结束";
             self.m_start_endLabel.text = [NSString stringWithFormat:@"%@， %@",[model startDateAndEndDateformattNSString],toStartTime];
            self.IslivingImage.hidden = YES;

        }else{
            toStartTime = [model toStartTimeformattNSStringWithCurrentTime:date];
            self.m_start_endLabel.text = [NSString stringWithFormat:@"%@，距直播：%@",[model startDateAndEndDateformattNSString],toStartTime];
            self.IslivingImage.hidden = YES;
        }
        
        //改变倒计时颜色
        NSRange range = [self.m_start_endLabel.text rangeOfString:toStartTime];
        NSMutableAttributedString *pStr = [[NSMutableAttributedString alloc]initWithString:self.m_start_endLabel.text];
        [pStr addAttribute:NSForegroundColorAttributeName value:COLOR(c_32c7c2) range:range];
        self.m_start_endLabel.attributedText = pStr;
        
    }
    
}







@end
