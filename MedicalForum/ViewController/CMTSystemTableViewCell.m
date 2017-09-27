//
//  CMTSystemTableViewCell.m
//  MedicalForum
//
//  Created by guoyuanchao on 16/11/1.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import "CMTSystemTableViewCell.h"
@interface CMTSystemTableViewCell()
@property(nonatomic,strong)UILabel *nameLable;
@property(nonatomic,strong)UITextField *textfield;
@property(nonatomic,strong)UILabel *textLable;
@property(nonatomic,strong)UIView *line;
@property(nonatomic,strong)UIImageView *rightimageView;
@end

@implementation CMTSystemTableViewCell
-(UIImageView*)rightimageView{
    if(_rightimageView==nil){
        _rightimageView=[[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-15-9, 58/2-(13/2), 9, 13 )];
        _rightimageView.image=[UIImage imageNamed:@"acc"];
  
    }
    return _rightimageView;
}
-(UILabel*)nameLable{
    if(_nameLable==nil){
        _nameLable=[[UILabel alloc]init];
        _nameLable.font=FONT(16);
        _nameLable.textColor=[UIColor colorWithHexString:@"#151515"];

    }
    return _nameLable;
}
-(UILabel*)textLable{
    if(_textLable==nil){
        _textLable=[[UILabel alloc]init];
        _textLable.font=FONT(16);
        _textLable.textColor=[UIColor blackColor];
        _textLable.textAlignment=NSTextAlignmentRight;
        _textLable.textColor=COLOR(c_ababab);
        
    }
    return _textLable;
}
-(UITextField*)textfield{
    if(_textfield==nil){
        _textfield=[[UITextField alloc]init];
        _textfield.font=FONT(16);
        _textfield.textColor=[UIColor blackColor];
        _textfield.textAlignment=NSTextAlignmentRight;
        _textfield.textColor=COLOR(c_ababab);
        _textfield.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [_textfield setValue:COLOR(c_ababab) forKeyPath:@"_placeholderLabel.textColor"];
        _textfield.hidden=YES;
    }
    return _textfield;
}
-(UIView*)line{
    if(_line==nil){
        _line=[[UIView alloc]init];
        _line.backgroundColor=[UIColor colorWithHexString:@"#f7f7f7"];
    }
    return _line;
}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        [self.contentView addSubview:self.nameLable];
        [self.contentView addSubview:self.textLable];
        [self.contentView addSubview:self.textfield];
        [self.contentView addSubview:self.line];
        [self.contentView addSubview:self.rightimageView];
    }
    return  self;
}
-(void)reloadCell:(NSString*)info text:(NSString*)text index:(NSIndexPath*)index{
    float with=[CMTGetStringWith_Height CMTGetLableTitleWith:info fontSize:16];
    self.nameLable.frame=CGRectMake(15,0, with, 58);
    self.nameLable.text=info;
    if(self.textWith>self.rightimageView.left-self.nameLable.right-20){
        self.textWith=self.rightimageView.left-self.nameLable.right;
    }
    self.textLable.frame=CGRectMake(self.rightimageView.left-self.textWith-10, 0,self.textWith, 58);
    self.textfield.frame=CGRectMake(self.rightimageView.left-self.textWith-10, 0,self.rightimageView.left-self.nameLable.right-20, 58);
    self.textfield.hidden=![info isEqualToString:@"邀请码"];
    self.textLable.hidden=[info isEqualToString:@"邀请码"];
    self.textfield.placeholder=[info isEqualToString:@"邀请码"]?@"选填":@"";
    self.textLable.text=text;
    self.line.frame=CGRectMake(0,57, SCREEN_WIDTH, 1);
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
