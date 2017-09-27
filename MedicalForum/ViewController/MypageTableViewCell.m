//
//  MypageTableViewCell.m
//  MedicalForum
//
//  Created by guoyuanchao on 2017/4/12.
//  Copyright © 2017年 CMT. All rights reserved.
//

#import "MypageTableViewCell.h"
@interface MypageTableViewCell()
@property(nonatomic,strong)UIView *line;
@property(nonatomic,strong)UILabel *rightlable;
@end
@implementation MypageTableViewCell
#define Cell_HEIGHT 50
-(UIImageView *)leftImageView{
    if(_leftImageView==nil){
        _leftImageView=[[UIImageView alloc] initWithFrame:CGRectMake(10, Cell_HEIGHT/2-(20/2), 20, 20)];
    }
    return _leftImageView;
}
-(UILabel*)titleLable{
    if(_titleLable==nil){
        _titleLable=[[UILabel alloc] initWithFrame:CGRectMake(10+20+10, Cell_HEIGHT/2-(20/2), 170, 20)];
        _titleLable.textColor=COLOR(c_151515);
        _titleLable.font=FONT(16);
    }
    return _titleLable;
}
-(UIImageView*)rightImageView{
    if(_rightImageView==nil){
        _rightImageView=[[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-10-9, Cell_HEIGHT/2-(13/2), 9, 13 )];
        _rightImageView.image=[UIImage imageNamed:@"acc"];
    }
    return _rightImageView;
}
-(UILabel*)rightlable{
    if(_rightlable==nil){
        _rightlable=[[UILabel alloc]initWithFrame:CGRectMake(self.rightImageView.left-100, 0, 100, Cell_HEIGHT)];
        _rightlable.font=FONT(14);
        _rightlable.hidden=YES;
        _rightlable.textColor=COLOR(c_ababab);
    }
    return _rightlable;
}
-(UIView*)line{
    if(_line==nil){
        _line=[[UIView alloc]initWithFrame:CGRectMake(0,49, SCREEN_WIDTH, PIXEL)];
        _line.backgroundColor=COLOR(c_eaeaea);
        
    }
    return _line;
}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        [self.contentView addSubview:self.leftImageView];
        [self.contentView addSubview:self.titleLable];
        [self.contentView addSubview:self.rightImageView];
        [self.contentView addSubview:self.rightlable];
        [self.contentView addSubview:self.line];
    }
    return self;
}
-(void)reloadData:(NSString*)str{
    self.titleLable.text=str;
    self.leftImageView.image=[self getImage:str];
    self.rightImageView.image=IMAGE(@"acc");
    self.rightImageView.frame=CGRectMake(SCREEN_WIDTH-10*RATIO-9, Cell_HEIGHT/2-(13/2), 9, 13 );
    self.selectionStyle=UITableViewCellSelectionStyleDefault;
    if([str isEqualToString:@"壹贝商城"]){
        NSString *scoreString=CMTUSERINFO.scores;
        scoreString=[CMTUSERINFO.scores stringByAppendingString:@"壹贝"];
        float with=[CMTGetStringWith_Height CMTGetLableTitleWith:scoreString fontSize:14]+5;
        self.rightlable.left=self.rightImageView.left-with;
        self.rightlable.width=with;
        self.rightlable.textColor=[UIColor colorWithHexString:@"#ea8010"];
        self.rightlable.text=scoreString;
        self.rightlable.hidden=NO;
    }else if([str isEqualToString:@"升级为认证用户"]){
        if(CMTUSERINFO.authStatus.integerValue==0){
            self.rightlable.hidden=YES;
        }else{
             self.rightlable.hidden=NO;
             self.rightlable.textColor=COLOR(c_ababab);
            if(CMTUSERINFO.authStatus.integerValue==5){
                self.selectionStyle=UITableViewCellSelectionStyleNone;
            }else if(CMTUSERINFO.authStatus.integerValue==6){
                self.rightlable.textColor=[UIColor redColor];
            }else if(CMTUSERINFO.authStatus.integerValue==7){
                self.rightImageView.image=IMAGE(@"right");
                self.rightlable.hidden=YES;
                self.rightImageView.frame=CGRectMake(SCREEN_WIDTH-25, Cell_HEIGHT/2-(15/2), 15, 15 );
            }
            float with=[CMTGetStringWith_Height CMTGetLableTitleWith:CMTUSERINFO.authMessage fontSize:14]+5;
            self.rightlable.left=self.rightImageView.left-with;
            self.rightlable.width=with;
            self.rightlable.text=CMTUSERINFO.authMessage;

        }
        
        
    }else{
        self.rightlable.hidden=YES;
    }
}
-(UIImage*)getImage:(NSString*)str{
    if([str isEqualToString:@"下载中心"]){
        return IMAGE(@"Ic_down");
    }else if([str isEqualToString:@"我的收藏"]){
        return IMAGE(@"ic_mine_left_fav");
    }else if([str isEqualToString:@"壹贝商城"]){
        return IMAGE(@"Onebaymall");
    }else if([str isEqualToString:@"邀请好友赢壹贝"]){
        return IMAGE(@"InviteFriends");
    }else if([str isEqualToString:@"签到赢壹贝"]){
        return IMAGE(@"SignInImage");
    }else if([str isEqualToString:@"升级为认证用户"]){
        return IMAGE(@"upgrade");
    }
    return nil;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end
