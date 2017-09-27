//
//  CMTSystemNoticeCell.m
//  MedicalForum
//
//  Created by zhaohuan on 15/11/25.
//  Copyright © 2015年 CMT. All rights reserved.
//

#import "CMTSystemNoticeCell.h"
#import "CMTBadgePoint.h"
static NSString *replaceStr1 = @"群主";//拼接用
static NSString *replaceStr = @"您";//拼接用

@interface CMTSystemNoticeCell ()
@property (nonatomic, strong)UIImageView *picImageView;//头像
@property (nonatomic, strong)UILabel *contentLable;//通知内容
@property (nonatomic, strong)UILabel *refuseContentLabel;//拒绝原因label  noticeType为9时有效
@property (nonatomic, strong)UILabel *creatTimeLabel;//创建时间;
@property (nonatomic, strong)CMTBadgePoint *point;
@property(nonatomic,strong)UIView *bottomline;

@end

@implementation CMTSystemNoticeCell

/**
 *  配置model对应的cell
 *
 *  @param model 数据
 */
- (void)configureCellWithModel:(CMTCaseSystemNoticeModel *)model{
    self.refuseContentLabel.hidden = YES;
    self.point.frame=CGRectMake(self.picImageView.right-8/2, self.picImageView.top, 8, 8);
    self.point.hidden=model.state.boolValue;
    
    [self.picImageView setImageURL:model.userPic placeholderImage:IMAGE(@"ic_default_head") contentSize:CGSizeMake(self.picImageView.width, self.picImageView.height)];
    if (model.noticeType.integerValue == 2) {
        
        if (![model.receiveUserId isEqual:CMTUSERINFO.userId]) {
            self.contentLable.text = [[CMTUSERINFO.userId isEqual:model.opUserName]?@"":model.opUserName stringByAppendingFormat:@"已同意 %@ 申请加入 %@",model.receiveUserName,model.groupName];
        }else{
            self.contentLable.text = [model.sendUserName stringByAppendingString:@"通过了你的申请"];
        }
        
    }else if (model.noticeType.integerValue == 3){
        if (![model.receiveUserId isEqual:CMTUSERINFO.userId]) {
            self.contentLable.text = [[CMTUSERINFO.userId isEqual:model.opUserName]?@"":model.opUserName stringByAppendingFormat:@"已拒绝 %@ 申请加入 %@ ",model.receiveUserName,model.groupName];
        }else{
            self.contentLable.text = [model.sendUserName stringByAppendingString:@"拒绝了你的申请"];
        }

        
    }else if (model.noticeType.integerValue == 4){
        if (![model.receiveUserId isEqual:CMTUSERINFO.userId]) {
            self.contentLable.text = [model.receiveUserName stringByAppendingFormat:@"被移除 %@",model.groupName];
        }else{
            self.contentLable.text = [@"你被" stringByAppendingFormat:@"%@移除 %@",model.sendUserName,model.groupName];
        }

    }else if (model.noticeType.integerValue == 5){

        self.contentLable.text = [@"你被" stringByAppendingFormat:@" %@ 升为 %@ 组长",model.sendUserName, model.groupName];
    }else if (model.noticeType.integerValue == 1){
        if ([CMTUSERINFO.userId isEqual:model.opUserId]) {
            if (model.step.integerValue == 1) {
                self.contentLable.text = [@"" stringByAppendingFormat:@"已同意 %@ 申请加入 %@",model.sendUserName,model.groupName];
            }else{
                self.contentLable.text = [@"" stringByAppendingFormat:@"已拒绝 %@ 申请加入 %@",model.sendUserName,model.groupName];
            }
            
        }else{
            if (model.step.integerValue == 1) {
                self.contentLable.text = [model.opUserName stringByAppendingFormat:@" 同意 %@ 加入 %@ ",model.sendUserName,model.groupName];
            }else{
                self.contentLable.text = [model.opUserName stringByAppendingFormat:@" 拒绝 %@ 加入 %@ ",model.sendUserName,model.groupName];
            }
            
        }
        
    }else if(model.noticeType.integerValue==6){
        self.contentLable.text = [@"你" stringByAppendingFormat:@"被 %@ 取消 %@ 组长身份",model.opUserName,model.groupName];
    }else if(model.noticeType.integerValue==7){
        self.contentLable.text = [model.groupName stringByAppendingString:@"小组被解散"];
    }else if(model.noticeType.integerValue==8){
        self.contentLable.text = [@"你的个人信息已通过审核" stringByAppendingFormat:@"%@",(isEmptyObject(model.message)?@"":model.message)];
    }
    else if(model.noticeType.integerValue==9){
        if (model.message.length > 0) {
            self.refuseContentLabel.hidden = NO;
        }
        self.contentLable.text = @"你的个人信息未审核通过";
        CGFloat messageHeight = ceilf([[self class] getTextheight:model.message fontsize:12 width:SCREEN_WIDTH - self.contentLable.left - 10]);
        
        self.refuseContentLabel.frame = CGRectMake(self.contentLable.left - 10, self.contentLable.bottom, SCREEN_WIDTH - self.contentLable.left, messageHeight + 20);
        self.refuseContentLabel.text = model.message;
        
        
        
    }
    
    self.creatTimeLabel.text = DATE(model.createTime);
}
    


- (UILabel *)refuseContentLabel{
    if (_refuseContentLabel == nil) {
        _refuseContentLabel = [[UILabel alloc]init];
        _refuseContentLabel.backgroundColor = [UIColor colorWithHexString:@"F7F7F6"];
        _refuseContentLabel.font = FONT(12);
        _refuseContentLabel.textAlignment = NSTextAlignmentLeft;
        _refuseContentLabel.numberOfLines = 0;
        _refuseContentLabel.hidden = YES;
    }
    return _refuseContentLabel;
}

-(CMTBadgePoint*)point{
    if (_point==nil) {
        _point=[[CMTBadgePoint alloc]init];
    }
    return _point;
}


- (UIImageView *)picImageView{
    if (_picImageView == nil) {
        _picImageView = [[UIImageView alloc]init];
        _picImageView.frame = CGRectMake(10, 50/3, 40, 40);
        _picImageView.image = IMAGE(@"ic_default_head");
        _picImageView.layer.borderWidth = 1;
        _picImageView.layer.borderColor = [UIColor grayColor].CGColor;
        _picImageView.layer.cornerRadius = _picImageView.width/2;
        _picImageView.contentMode = UIViewContentModeScaleAspectFill;
        _picImageView.layer.masksToBounds = YES;
        
    }
    return _picImageView;
}

- (UILabel *)creatTimeLabel{
    if (_creatTimeLabel == nil) {
        _creatTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 212/3 - 10, _contentLable.top, 212/3, 40)];
        //_creatTimeLabel.backgroundColor = [UIColor greenColor];
        _creatTimeLabel.text = @"2015-11-19";
        _creatTimeLabel.font = [UIFont systemFontOfSize:11];
        _creatTimeLabel.textColor = [UIColor colorWithHexString:@"A5A5A5"];
    }
    return _creatTimeLabel;
}


- (UILabel *)contentLable{
    if (_contentLable == nil) {
        _contentLable = [[UILabel alloc]init];
        _contentLable.frame = CGRectMake(_picImageView.right + 10, _picImageView.top, SCREEN_WIDTH - _picImageView.right - 15 - 212/3 - 30, 223/3 - 50/3*2);
        //_contentLable.backgroundColor = [UIColor redColor];
        _contentLable.font = [UIFont systemFontOfSize:14];
        _contentLable.textColor = [UIColor colorWithHexString:@"A5A5A5"];
        _contentLable.numberOfLines = 2;
        _contentLable.text = @"赵";

    }
    return _contentLable;
}

-(UIView*)bottomline{
    if (_bottomline==nil) {
        _bottomline=[[UIView alloc]initWithFrame:CGRectMake(0,0, SCREEN_WIDTH,1)];
        _bottomline.backgroundColor = [UIColor colorWithHexString:@"f0f2f2"];
        [self.contentView addSubview:_bottomline];
        
        
    }
    return _bottomline;
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.picImageView];
        [self.contentView addSubview:self.contentLable];
        [self.contentView addSubview:self.creatTimeLabel];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.contentView addSubview:self.point];
        [self.contentView addSubview:self.bottomline];
        [self.contentView addSubview:self.refuseContentLabel];

        
    }
    return self;
}

+(float)getTextheight:(NSString*)text fontsize:(float)size width:(float) width{
    //回复内容
    CGSize titleSize = [text boundingRectWithSize:CGSizeMake(width,MAXFLOAT)
                                          options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine
                                       attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:size]}
                                          context:nil].size;
    return titleSize.height;
}



- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
