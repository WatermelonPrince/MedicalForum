//
//  CMTCaseGroupTableViewCell.m
//  MedicalForum
//
//  Created by guoyuanchao on 15/9/24.
//  Copyright © 2015年 CMT. All rights reserved.
//

#import "CMTCaseGroupTableViewCell.h"
#import "CMTBadge.h"
@interface CMTCaseGroupTableViewCell()
//小组图片
@property(nonatomic,strong)UIImageView *groupPic;

//小组描述
@property(nonatomic,strong)UILabel *groupDec;
//小组成员数量
@property(nonatomic,strong)UILabel *memberlable;
//cell距离边框的距离
@property(nonatomic,assign)UIEdgeInsets cellInset;
//cell 下分割线
@property (nonatomic, strong) UIView *bottomLine;
@property(nonatomic,strong)CMTBadge *badge;
@property(nonatomic,strong)UIView *stateView;
@property(nonatomic,strong)UIImageView *closeImageView;//关闭状态图片
@property(nonatomic,strong)UIImageView *OpenImageView;//关闭状态图片
@property(nonatomic,strong)UILabel *auditLable;

@end
@implementation CMTCaseGroupTableViewCell
-(UIImageView*)groupPic{
    if (_groupPic==nil) {
        _groupPic=[[UIImageView alloc]init];
    }
    return _groupPic;
}
-(UILabel*)groupName{
    if (_groupName==nil) {
        _groupName=[[UILabel alloc]init];
        //_groupName.textColor=[UIColor colorWithHexString:@"#494949"];
        _groupName.font=[UIFont systemFontOfSize:16];
        _groupName.numberOfLines=0;
        _groupName.lineBreakMode=NSLineBreakByWordWrapping;
    }
    return _groupName;
}
-(UILabel*)groupDec{
    if (_groupDec==nil) {
        _groupDec=[[UILabel alloc]init];
        _groupDec.textColor=[UIColor colorWithHexString:@"#C0C0C0"];
        _groupDec.font=[UIFont systemFontOfSize:14];
    }
    return _groupDec;
}
-(UILabel*)memberlable{
    if (_memberlable==nil) {
        _memberlable=[[UILabel alloc]init];
        _memberlable.textColor=[UIColor colorWithHexString:@"#C0C0C0"];
        _memberlable.font=[UIFont systemFontOfSize:12];
    }
    return _memberlable;
}
-(CMTBadge*)badge{
    if (_badge==nil) {
        _badge=[[CMTBadge alloc]init];
    }
    return _badge;
}
- (UIView *)bottomLine {
    if (_bottomLine == nil) {
        _bottomLine = [[UIView alloc] init];
        _bottomLine.backgroundColor = COLOR(c_EBEBEE);
        
    }
    
    return _bottomLine;
}
-(UIImageView*)closeImageView{
    if (_closeImageView==nil) {
        _closeImageView=[[UIImageView alloc]init];
        _closeImageView.image=IMAGE(@"lockGroup");
    }
    return _closeImageView;
}
-(UIImageView*)OpenImageView{
    if(_OpenImageView==nil){
        _OpenImageView=[[UIImageView alloc]init];
        _OpenImageView.image=IMAGE(@"unlockGroup");
    }
    return _OpenImageView;
}
-(UILabel*)auditLable{
    if (_auditLable==nil) {
        _auditLable=[[UILabel alloc]init];
        _auditLable.text=@"审核中";
        _auditLable.textColor=COLOR(c_ffffff);
        _auditLable.font=FONT(16);
        _auditLable.textAlignment=NSTextAlignmentCenter;
    }
    return _auditLable;
}
-(UIView *)stateView{
    if (_stateView==nil) {
        _stateView=[[UIView alloc]init];
        _stateView.backgroundColor=[UIColor colorWithHexString:@"#b2b2b2"];
        _stateView.alpha=0.65;
    }
    return _stateView;
}


//初始化UItableViewCell
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.cellInset=UIEdgeInsetsMake(0,0,0,0);
        self.backgroundColor=[UIColor colorWithHexString:@"ffffff"];
        [self.contentView addSubview:self.groupPic];
        [self.groupPic addSubview:self.stateView];
        [self.stateView addSubview:self.auditLable];
        [self.stateView addSubview:self.closeImageView];
        [self.groupPic addSubview:self.OpenImageView];
        [self.contentView addSubview:self.groupName];
        [self.contentView addSubview:self.groupDec];
        [self.contentView addSubview:self.memberlable];
        [self.contentView addSubview:self.bottomLine];
        [self.contentView addSubview:self.badge];

       
        
        
        
    }
    return self;
}
//刷新cell
-(void)reloadCell:(CMTGroup*)group{
    self.groupDec.hidden=NO;
    self.memberlable.hidden=NO;
    self.mgroup=group;
    self.badge.hidden=YES;
    //小组头像
    self.groupPic.frame=CGRectMake(self.cellInset.left+10,10, 70, 70);
    self.groupPic.contentMode=UIViewContentModeScaleAspectFill;
    self.groupPic.clipsToBounds=YES;
    self.stateView.frame=CGRectMake(0, 0, 70, 70);
    [self.groupPic setImageURL:group.groupLogo.picFilepath
              placeholderImage:IMAGE(@"placeholder_list_loading") contentSize:CGSizeMake(70, 70)];
    if(group.groupType.integerValue>=1){
        if (group.isJoinIn.integerValue==0||!CMTUSER.login) {
            self.closeImageView.frame=CGRectMake((self.groupPic.width-17.5)/2, (self.groupPic.height-27)/2, 17.5, 27);
            self.auditLable.hidden=YES;
            self.OpenImageView.hidden=YES;
            self.closeImageView.hidden=NO;
            self.stateView.hidden=NO;
        }else if(group.isJoinIn.integerValue==2&&CMTUSER.login){
            self.auditLable.frame=CGRectMake(0, 0, 70, 70);
            self.auditLable.hidden=NO;
            self.OpenImageView.hidden=YES;
            self.closeImageView.hidden=YES;
             self.stateView.hidden=NO;

        }
    }else{
        self.OpenImageView.hidden=YES;
        self.auditLable.hidden=YES;
        self.closeImageView.hidden=YES;
        self.stateView.hidden=YES;
    }
    //参与者的数目
  
    float groupNameheight=[CMTGetStringWith_Height getTextheight:self.mgroup.groupName fontsize:16 width:SCREEN_WIDTH-self.groupPic.right-10-20-kCMTBadgeWidth];
    
    //小组名称
    self.groupName.frame=CGRectMake(self.groupPic.right+10, self.groupPic.top,SCREEN_WIDTH-self.groupPic.right-10-20-kCMTBadgeWidth, groupNameheight>30?groupNameheight:30);
    self.groupName.text=self.mgroup.groupName;
    
    self.memberlable.frame=CGRectMake(self.groupPic.right+10, self.groupName.bottom,self.groupName.width,20);
    self.memberlable.text=self.mgroup.postCount.integerValue==0?[@"有" stringByAppendingFormat:@"%@人参与过讨论",self.mgroup.memNum]:[@"有" stringByAppendingFormat:@"%@人参与过讨论   共有%@篇病例",self.mgroup.memNum,self.mgroup.postCount];
    
    self.groupDec.frame=CGRectMake(self.groupPic.right+10, self.memberlable.bottom,self.groupName.width,30);
    self.groupDec.text=self.mgroup.groupDesc;
    if(self.isSearch){
        NSRange range2 = [ self.groupName.text rangeOfString:self.searchkey];
        NSMutableAttributedString *pStr = [[NSMutableAttributedString alloc]initWithString:self.groupName.text];
        [pStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"#3bc6c1"] range:range2];
        self.groupName.attributedText = pStr;
    }

    self.bottomLine.frame=CGRectMake(0, self.groupDec.bottom+10,SCREEN_WIDTH, 1);
    
    self.badge.frame=CGRectMake(SCREEN_WIDTH-30,(self.bottomLine.bottom-kCMTBadgeWidth)/2, kCMTBadgeWidth,kCMTBadgeWidth);
    if (CMTUSER.login) {
         self.badge.text=group.noticeCount;
    }
      self.frame=CGRectMake(self.frame.origin.x,self.frame.origin.y, SCREEN_WIDTH, self.bottomLine.bottom);

}
-(void)reloadSelectGroupCell:(CMTGroup*)group{
    self.groupDec.hidden=YES;
    self.memberlable.hidden=YES;
    self.mgroup=group;
    self.badge.hidden=YES;
    //小组头像
    self.stateView.frame=CGRectMake(0, 0, 70, 70);
    self.groupPic.frame=CGRectMake(10,10, 70, 70);
    self.groupPic.contentMode=UIViewContentModeScaleAspectFill;
    self.groupPic.clipsToBounds=YES;
    [self.groupPic setImageURL:group.groupLogo.picFilepath
              placeholderImage:IMAGE(@"placeholder_list_loading") contentSize:CGSizeMake(70, 70)];
    if(group.groupType.integerValue>=1){
        if (group.isJoinIn.integerValue==0) {
            self.closeImageView.frame=CGRectMake((self.groupPic.width-17.5)/2, (self.groupPic.height-27)/2, 17.5, 27);
            self.auditLable.hidden=YES;
            self.OpenImageView.hidden=YES;
            self.closeImageView.hidden=NO;
            self.stateView.hidden=NO;
        }else if(group.isJoinIn.integerValue==2){
            self.auditLable.frame=CGRectMake(0, 0, 70, 70);
            self.auditLable.hidden=NO;
            self.OpenImageView.hidden=YES;
            self.closeImageView.hidden=YES;
            self.stateView.hidden=NO;
            
        }else{
            self.OpenImageView.frame=CGRectMake(self.groupPic.width-20, self.groupPic.height-20, 20, 20);
            self.auditLable.hidden=YES;
            self.OpenImageView.hidden=NO;
            self.closeImageView.hidden=YES;
            self.stateView.hidden=YES;
        }
        
        
    }else{
        self.OpenImageView.hidden=YES;
        self.auditLable.hidden=YES;
        self.closeImageView.hidden=YES;
        self.stateView.hidden=YES;
    }

    //小组名称
    self.groupName.frame=CGRectMake(self.groupPic.right+10, self.groupPic.top,SCREEN_WIDTH-self.groupPic.right-10-20-kCMTBadgeWidth,70);
     self.groupName.text=self.mgroup.groupName;
    if(self.isSearch){
        NSRange range2 = [ self.groupName.text rangeOfString:self.searchkey];
        NSMutableAttributedString *pStr = [[NSMutableAttributedString alloc]initWithString:self.groupName.text];
        [pStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"#3bc6c1"] range:range2];
        self.groupName.attributedText = pStr;
    }
   
    self.bottomLine.frame=CGRectMake(0, self.groupPic.bottom+10,SCREEN_WIDTH, 1);
    self.badge.frame=CGRectMake(SCREEN_WIDTH-30,(self.bottomLine.bottom-kCMTBadgeWidth)/2, kCMTBadgeWidth,kCMTBadgeWidth);
    if (CMTUSER.login) {
        self.badge.text=group.noticeCount;
    }
    self.frame=CGRectMake(self.frame.origin.x,self.frame.origin.y, SCREEN_WIDTH, self.bottomLine.bottom);
 
    }

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
}
@end
