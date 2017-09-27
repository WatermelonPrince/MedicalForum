//
//  CMTPartcell.m
//  MedicalForum
//
//  Created by guoyuanchao on 15/7/21.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTPartcell.h"


@interface CMTPartcell()

//参与者头像
@property(nonatomic,strong)UIImageView *partImageView;
@property(nonatomic,strong)UIView *bottomline;
@property(nonatomic,strong)UIImageView *managerImageView;//管理者头像
@end
@implementation CMTPartcell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (UIImageView *)managerImageView{
    if (_managerImageView == nil) {
        _managerImageView = [[UIImageView alloc]init];
        _managerImageView.frame = CGRectMake(25, 35, 20, 20);
        //_managerImageView.image = IMAGE(@"ic_default_head");
        _managerImageView.layer.masksToBounds = YES;
        [_managerImageView setContentMode:UIViewContentModeScaleAspectFill];
        [_managerImageView setClipsToBounds:YES];

    }
    return _managerImageView;
}
- (UILabel *)partLabel {
    if (_partLabel == nil) {
        _partLabel = [[UILabel alloc] init];
        _partLabel.backgroundColor = COLOR(c_clear);
        _partLabel.textColor = COLOR(c_9e9e9e);
        _partLabel.font = FONT(16);
    }
    
    return _partLabel;
}
-(UIImageView*)partImageView{
    if (_partImageView==nil) {
        _partImageView=[[UIImageView alloc]init];
        _partImageView.image=IMAGE(@"ic_default_head");
        _partImageView.layer.masksToBounds = YES;
        [_partImageView setContentMode:UIViewContentModeScaleAspectFill];
        [_partImageView setClipsToBounds:YES];
        
    }
    return _partImageView;
}
-(UIImageView*)rightimage{
    if (_rightimage==nil) {
        _rightimage=[[UIImageView alloc]init];
         _rightimage.hidden=YES;
    }
    return _rightimage;
}

-(UIView*)bottomline{
    if (_bottomline==nil) {
        _bottomline=[[UIView alloc]initWithFrame:CGRectMake(0,0, SCREEN_WIDTH,1)];
        _bottomline.backgroundColor = [UIColor colorWithHexString:@"#F8F8F8"];
        [self.contentView addSubview:_bottomline];
        

    }
    return _bottomline;
}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.partLabel];
        [self.contentView addSubview:self.partImageView];
        [self.contentView addSubview:self.managerImageView];
        [self.contentView addSubview:self.rightimage];
    }
    return self;
}

-(void)reloadCell:(CMTParticiPators*)part{
    if (part.memberGrade.integerValue == 0) {
        _managerImageView.image = IMAGE(@"creater");
    }else if (part.memberGrade.integerValue ==1){
        _managerImageView.image = IMAGE(@"manager");
    }
    
    
    
    self.partImageView.frame=CGRectMake(5, 10, 40, 40);
    self.partImageView.layer.cornerRadius=self.partImageView.width/2;
    if (part.userType.integerValue==1) {
         [self.partImageView setImageURL:part.picture placeholderImage:IMAGE(@"ic_default_head") contentSize:CGSizeZero];
    }else{
         [self.partImageView setQuadrateScaledImageURL:part.picture placeholderImage:IMAGE(@"ic_default_head") width:40.0];
    }
    self.partLabel.frame=CGRectMake(self.partImageView.right+10, 0,self.isMulti_select? SCREEN_WIDTH-self.partImageView.right-10-50:SCREEN_WIDTH-self.partImageView.right-10, self.partImageView.height+20);
    self.partLabel.text=part.nickname;
    self.partLabel.font=[UIFont systemFontOfSize:16];
    self.rightimage.frame=CGRectMake(self.partLabel.right+10, 15, 30, 30);
    self.rightimage.image=IMAGE(@"selectTag");
    self.bottomline.frame=CGRectMake(0, self.partLabel.bottom,SCREEN_WIDTH, 1);
    self.frame=CGRectMake(self.frame.origin.x, self.frame.origin.y,SCREEN_WIDTH,self.bottomline.bottom);
   }


@end
