//
//  CMTVoteTableViewCell.m
//  MedicalForum
//
//  Created by guoyuanchao on 15/11/24.
//  Copyright © 2015年 CMT. All rights reserved.
//

#import "CMTVoteTableViewCell.h"
@interface CMTVoteTableViewCell()
@property(nonatomic,strong)UITextField *votelable;
@property(nonatomic,strong)UIButton* actionbutton;
@property(nonatomic,strong)NSIndexPath *index;
@property(nonatomic,strong)UIView *buttomline;
@end

@implementation CMTVoteTableViewCell
-(UITextField*)votelable{
    if (_votelable==nil) {
        _votelable=[[UITextField alloc]init];
        _votelable.textColor=COLOR(c_151515);
        _votelable.userInteractionEnabled=NO;
        _votelable.font=FONT(15);
    }
    return _votelable;
}
-(UIButton*)actionbutton{
    if (_actionbutton==nil) {
        _actionbutton=[[UIButton alloc]init];
        [_actionbutton addTarget:self action:@selector(buttonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _actionbutton;
}
-(UIView*)buttomline{
    if (_buttomline==nil) {
        _buttomline=[[UIView alloc]init];
        _buttomline.backgroundColor=COLOR(c_f5f5f5);
    }
    return _buttomline;
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
        [self.contentView addSubview:self.votelable];
        [self.contentView addSubview:self.actionbutton];
        [self.contentView addSubview:self.buttomline];
    }
    return self;
}
-(void)reloadCell:(CMTVoteObject*)vote indexPath:(NSIndexPath *)indexpath{
   NSArray*array=@[@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z"];
    self.index=indexpath;
    self.votelable.frame=CGRectMake(10, 0,SCREEN_WIDTH-80, 50);
    self.votelable.placeholder= [@"选项" stringByAppendingString:array[indexpath.row]];
    vote.placelhold=[@"选项" stringByAppendingString:array[indexpath.row]];
    self.votelable.text=isEmptyString(vote.text)?@"":vote.text;
    self.actionbutton.frame=CGRectMake(SCREEN_WIDTH-60, 0, 40, 50);
    if (vote.isaddAction.boolValue) {
        [self.actionbutton setImage:IMAGE(@"addVote") forState:UIControlStateNormal];
        self.actionbutton.userInteractionEnabled=NO;
    }else{
        [self.actionbutton setImage:IMAGE(@"deleteVote") forState:UIControlStateNormal];
        self.actionbutton.userInteractionEnabled=YES;

    }
    self.buttomline.frame=CGRectMake(0,50, SCREEN_WIDTH, 1);
    }
-(void)buttonAction{
    if (self.addAction!=nil) {
        self.addAction(self.index);
    }
}
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    [super setHighlighted:highlighted animated:animated];
    
    if(highlighted) {
        [self.votelable setHighlighted:NO];
        [self.actionbutton setHighlighted:NO];
    }
}

@end
