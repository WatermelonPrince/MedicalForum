//
//  ChartTableViewCell.m
//  MedicalForum
//
//  Created by guoyuanchao on 16/6/6.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import "ChartTableViewCell.h"
@interface ChartTableViewCell()
@property(nonatomic,strong)UILabel *nicklable;
@property(nonatomic,strong)UILabel*timelable;
@property(nonatomic,strong)UILabel *contentlalbe;
@property(nonatomic,strong)UIView*line;
@end
@implementation ChartTableViewCell
-(UILabel*)nicklable{
    if (_nicklable==nil) {
        _nicklable=[[UILabel alloc]init];
        _nicklable.textColor=ColorWithHexStringIndex(c_4acbb5);
        _nicklable.font=[UIFont systemFontOfSize:15];
    }
    return _nicklable;
}
-(UILabel*)timelable{
    if (_timelable==nil) {
        _timelable=[[UILabel alloc]init];
        _timelable.textColor=[UIColor colorWithHexString:@"#bbbbbb"];
        _timelable.font=[UIFont systemFontOfSize:13];
        _timelable.textAlignment=NSTextAlignmentRight;
    }
    return _timelable;
}
-(UILabel*)contentlalbe{
    if (_contentlalbe==nil) {
         _contentlalbe=[[UILabel alloc]init];
        _contentlalbe.textColor=ColorWithHexStringIndex(c_000000);
        _contentlalbe.font=[UIFont systemFontOfSize:17];
        _contentlalbe.numberOfLines=0;
        _contentlalbe.lineBreakMode=NSLineBreakByWordWrapping;

    }
    return _contentlalbe;
   
    
}
-(UIView*)line{
    if (_line==nil) {
        _line=[[UIView alloc]init];
        _line.backgroundColor=ColorWithHexStringIndex(c_f6f6f6);
    }
    return _line;
}
- (void)awakeFromNib {
    [super awakeFromNib];
   }

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView setBackgroundColor:ColorWithHexStringIndex(c_ffffff)];
        [self.contentView addSubview:self.nicklable];
        [self.contentView addSubview:self.timelable];
        [self.contentView addSubview:self.contentlalbe];
        [self.contentView addSubview:self.line];
    }
    return self;
}
-(void)reloadCell:(GSPQaData*)live{


     NSString *dateString=[NSDate dateFormatPattern:@"HH:mm:ss" TimeStamp:[NSString stringWithFormat:@"%lld",live.time/1000]];
    float datewith=ceilf([CMTGetStringWith_Height CMTGetLableTitleWith:dateString fontSize:13]);
    
    NSString *nickName=((live.ownnerID==CMTUSERINFO.userId.integerValue+1000000000)&&live.isQuestion)?@"我":live .ownerName;
    float nicklableheight=ceilf([CMTGetStringWith_Height getTextheight:nickName fontsize:17 width:SCREEN_WIDTH-20-datewith-10 ])+10;
    self.nicklable.frame=CGRectMake(10, 0, SCREEN_WIDTH-20-datewith-10, nicklableheight);
    self.nicklable.text=nickName;
    
    
    self.timelable.frame=CGRectMake(self.nicklable.right+10,10,datewith, 20);
    self.timelable.text=[NSDate dateFormatPattern:@"HH:mm:ss" TimeStamp:[NSString stringWithFormat:@"%lld",live.time/1000]];
    float height=ceilf([CMTGetStringWith_Height getTextheight:live.content fontsize:17 width:SCREEN_WIDTH-20 ])+10;
    self.contentlalbe.frame=CGRectMake(10, self.timelable.bottom, SCREEN_WIDTH-20, height);
    NSLog(@"jsjjjjsjsjsjsj%@",live.content);
    self.contentlalbe.text=live.content;
    self.line.frame=CGRectMake(0, self.contentlalbe.bottom+5, SCREEN_WIDTH,1);
    self.frame=CGRectMake(self.frame.origin.x,self.frame.origin.y,SCREEN_WIDTH, self.line.bottom);
}
@end
