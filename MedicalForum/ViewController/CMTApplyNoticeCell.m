//
//  CMTApplyNoticeCell.m
//  MedicalForum
//
//  Created by zhaohuan on 15/11/25.
//  Copyright © 2015年 CMT. All rights reserved.
//

#import "CMTApplyNoticeCell.h"
#import "CMTBadgePoint.h"
@interface CMTApplyNoticeCell ()
@property (nonatomic, strong)UIImageView *picImageView;//头像
@property (nonatomic, copy)UILabel *nickNameLabel;//昵称
@property (nonatomic, copy)UIView *personInformationView;//个人信息底部视图
@property (nonatomic, copy)UILabel *realNameLabel;//真实姓名
@property (nonatomic, copy)UILabel *hospitalLabel;//医院
@property (nonatomic, copy)UILabel *subjectLabel;//科室
@property (nonatomic, copy)UILabel *doctorNumberLabel;//医师号
@property (nonatomic, strong)UILabel *creatTimeLabel;//消息时间
@property (nonatomic, strong)CMTBadgePoint *point;
@property(nonatomic,strong)UIView *bottomline;
@end

@implementation CMTApplyNoticeCell

-(CMTBadgePoint*)point{
    if (_point==nil) {
        _point=[[CMTBadgePoint alloc]init];
    }
    return _point;
}

- (UIImageView *)picImageView{
    if (_picImageView == nil) {
        _picImageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 50/3, 40, 40)];
        _picImageView.image = IMAGE(@"ic_default_head");
        _picImageView.contentMode = UIViewContentModeScaleAspectFill;
        _picImageView.layer.borderWidth = 1;
        _picImageView.layer.borderColor = [UIColor colorWithHexString:@"CECECE"].CGColor;
        _picImageView.layer.cornerRadius = _picImageView.width/2;
        _picImageView.layer.masksToBounds = YES;
    }
    return _picImageView;
}
//

- (UILabel *)nickNameLabel{
    if (_nickNameLabel == nil) {
        _nickNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(_picImageView.right + 10, _picImageView.top, SCREEN_WIDTH - _picImageView.right - 15 - 212/3 - 30,40)];
        _nickNameLabel.numberOfLines = 2;
        _nickNameLabel.textColor = [UIColor colorWithHexString:@"A5A5A5"];
        _nickNameLabel.font = [UIFont systemFontOfSize:14];
        
    }
    return _nickNameLabel;
}
//消息时间

- (UILabel *)creatTimeLabel{
    if (_creatTimeLabel == nil) {
        _creatTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 212/3 - 10, _picImageView.top, 212/3, 40)];
        _creatTimeLabel.textColor = [UIColor colorWithHexString:@"A5A5A5"];
        _creatTimeLabel.font = [UIFont systemFontOfSize:11];
    }
    return _creatTimeLabel;
}
//个人信息视图

- (UIView *)personInformationView{
    if (_personInformationView == nil) {
        _personInformationView = [[UIView alloc]initWithFrame:CGRectMake(_picImageView.right + 5, _picImageView.bottom, SCREEN_WIDTH - _picImageView.right - 10, 110-90/4)];
        _personInformationView.backgroundColor = [UIColor colorWithHexString:@"F7F7F6"];
    }
    return _personInformationView;
}
//真实姓名

- (UILabel *)realNameLabel{
    if (_realNameLabel == nil) {
        _realNameLabel = [[UILabel alloc]init];
        _realNameLabel.frame = CGRectMake(20/3, 10, _personInformationView.width - 20,90/4);
        _realNameLabel.font = [UIFont systemFontOfSize:13];
        
    }
                                                                  
    return _realNameLabel;
}
//医院

- (UILabel *)hospitalLabel{
    if (_hospitalLabel == nil) {
        _hospitalLabel = [[UILabel alloc]init];
        _hospitalLabel.frame = CGRectMake(_realNameLabel.left, _realNameLabel.bottom, _realNameLabel.width, _realNameLabel.height);
         _hospitalLabel.font = [UIFont systemFontOfSize:13];
    }
    return _hospitalLabel;
}
//科室

- (UILabel *)subjectLabel{
    if (_subjectLabel == nil) {
        _subjectLabel = [[UILabel alloc]init];
        _subjectLabel.frame = CGRectMake(_realNameLabel.left, self.hospitalLabel.bottom, _realNameLabel.width, _realNameLabel.height);
        _subjectLabel.font = [UIFont systemFontOfSize:13];

    }
    return _subjectLabel;
}
//医师号

- (UILabel *)doctorNumberLabel{
    if (_doctorNumberLabel == nil) {
        _doctorNumberLabel = [[UILabel alloc]init];
        _doctorNumberLabel.frame = CGRectMake(_realNameLabel.left, self.subjectLabel.bottom, _realNameLabel.width, _realNameLabel.height);
        _doctorNumberLabel.font = [UIFont systemFontOfSize:13];

    }
    return _doctorNumberLabel;
}
//同意button

- (UIButton *)aceeptButton{
    if (_aceeptButton == nil) {
        _aceeptButton = [[UIButton alloc]initWithFrame:CGRectMake(189/3, _personInformationView.bottom + 15, 242/3, 108/3)];
        _aceeptButton.backgroundColor = [UIColor colorWithHexString:@"3CC6C1"];
        _aceeptButton.layer.cornerRadius = 5;
        [_aceeptButton setTitle:@"同意" forState:UIControlStateNormal];
        [_aceeptButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    return _aceeptButton;
}
//拒绝button
- (UIButton *)refuseButton{
    if (_refuseButton == nil) {
        _refuseButton = [[UIButton alloc]initWithFrame:CGRectMake(_aceeptButton.right + 108/3, _aceeptButton.top, 242/3, 108/3)];
        _refuseButton.backgroundColor = [UIColor colorWithHexString:@"FFFFFF"];
        _refuseButton.layer.borderWidth = 1;
        _refuseButton.layer.cornerRadius = 5;
        _refuseButton.layer.borderColor = [UIColor colorWithHexString:@"CECECE"].CGColor;
        [_refuseButton setTitle:@"拒绝" forState:UIControlStateNormal];
        [_refuseButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }
    return _refuseButton;

}
//初始化cell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.picImageView];
        [self.contentView addSubview:self.nickNameLabel];
        [self.contentView addSubview:self.personInformationView];
        [self.personInformationView addSubview:self.realNameLabel];
        [self.personInformationView addSubview:self.hospitalLabel];
        [self.personInformationView addSubview:self.subjectLabel];
//        [self.personInformationView addSubview:self.doctorNumberLabel];
        [self.contentView addSubview:self.aceeptButton];
        [self.contentView addSubview:self.refuseButton];
        [self.contentView addSubview:self.creatTimeLabel];
        [self.contentView addSubview:self.point];
        [self.contentView addSubview:self.bottomline];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

-(UIView*)bottomline{
    if (_bottomline==nil) {
        _bottomline=[[UIView alloc]initWithFrame:CGRectMake(0,0, SCREEN_WIDTH,1)];
        _bottomline.backgroundColor = [UIColor colorWithHexString:@"f0f2f2"];
        [self.contentView addSubview:_bottomline];
        
        
    }
    return _bottomline;
}

/**
 *  配置cell
 *
 *  @param model 对应的cell的数据
 */
- (void)configureCellWithModel:(CMTCaseSystemNoticeModel *)model{
    if (model.noticeType.integerValue == 1) {
        self.point.frame=CGRectMake(self.picImageView.right-8/2, self.picImageView.top, 8, 8);
        self.point.hidden=model.state.boolValue;
        self.creatTimeLabel.text = DATE(model.createTime);
        [self.picImageView setImageURL:model.userPic placeholderImage:IMAGE(@"ic_default_head") contentSize:CGSizeMake(self.picImageView.width, self.picImageView.height)];
        self.nickNameLabel.text = [model.sendUserName stringByAppendingFormat:@"申请加入 %@",model.groupName];
        if (model.groupLimit.integerValue == 3) {
            self.realNameLabel.text = [@"真实姓名：" stringByAppendingFormat:@"%@",model.userAuthInfo.realName];
            self.hospitalLabel.text = [@"医院：" stringByAppendingFormat:@"%@",model.userAuthInfo.hospital];
            self.subjectLabel.text = [@"科室：" stringByAppendingFormat:@"%@",model.userAuthInfo.subDepartment];
//            self.doctorNumberLabel.text = [@"职业医师号：" stringByAppendingFormat:@"%@", model.userAuthInfo.doctorNumber];

        }else{
            self.personInformationView.hidden = YES;
             self.aceeptButton.frame = CGRectMake(189/3, self.contentView.centerY, 242/3, 108/3);
             self.refuseButton.frame = CGRectMake(_aceeptButton.right + 108/3, self.contentView.centerY, 242/3, 108/3);
            
        }
    }
   
    
}

@end
