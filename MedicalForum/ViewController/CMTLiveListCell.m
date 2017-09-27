//
//  CMTLiveListCell.m
//  MedicalForum
//
//  Created by guoyuanchao on 15/8/20.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTLiveListCell.h"
#import "CMTBadge.h"
@interface CMTLiveListCell()
@property(nonatomic,strong)UIImageView *livePic;
@property(nonatomic,strong)UILabel *Livetitle;
@property(nonatomic,strong)UILabel *liveDesc;
@property(nonatomic,strong)UIView *topline;
@property(nonatomic,strong)UIView *buttomline;
@property(nonatomic,strong)CMTBadge *badge;
@end
@implementation CMTLiveListCell
- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

   
}
-(CMTBadge*)badge{
    if(_badge==nil){
        _badge=[[CMTBadge alloc]init];
    }
    return _badge;
}
-(UILabel*)Livetitle{
    if (_Livetitle==nil) {
        _Livetitle=[[UILabel alloc]init];
        _Livetitle.textColor=COLOR(c_151515);
        _Livetitle.font=[UIFont systemFontOfSize:16];
    }
    return _Livetitle;
}
-(UIImageView*)livePic{
    if (_livePic==nil) {
        _livePic=[[UIImageView alloc]init];
    }
    return _livePic;
}
-(UILabel*)liveDesc{
    if (_liveDesc==nil) {
        _liveDesc=[[UILabel alloc]init];
        _liveDesc.textColor=COLOR(c_9e9e9e);
        _liveDesc.font=[UIFont systemFontOfSize:14];

    }
    return _liveDesc;
}
-(UIView*)topline{
    if (_topline==nil) {
        _topline=[[UIView alloc]init];
         _topline.backgroundColor=[UIColor colorWithHexString:@"#E2E2E2"];
    }
    return _topline;
}
-(UIView*)buttomline{
    if (_buttomline==nil) {
        _buttomline=[[UIView alloc]init];
        _buttomline.backgroundColor=[UIColor colorWithHexString:@"#E2E2E2"];
    }
    return _buttomline;
}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIView *background = [[UIView alloc] init];
        background.backgroundColor = COLOR(c_ffffff);
        self.backgroundView = background;
        [self.contentView addSubview:self.livePic];
        [self.contentView addSubview:self.liveDesc];
        [self.contentView addSubview:self.Livetitle];
        [self.contentView addSubview:self.topline];
        [self.contentView addSubview:self.buttomline];
        [self.contentView addSubview:self.badge];
    }
    return self;
}
-(void)reloadCell:(CMTLive*)live index:(NSIndexPath*)index{
    if (index.row==0) {
        self.topline.frame=CGRectMake(0, 0, SCREEN_WIDTH, 1);
    }else{
          self.topline.frame=CGRectMake(0, 0, SCREEN_WIDTH, 0);
    }
    self.livePic.frame=CGRectMake(5, 5, 50,50);
    [self.livePic setImageURL:((CMTPicture*)live.sharePic).picFilepath placeholderImage:IMAGE(@"notiices_post_image") contentSize:CGSizeMake(50, 50)];
    self.Livetitle.frame=CGRectMake(self.livePic.right+10, 0, SCREEN_WIDTH-self.livePic.right-43, 30);
    self.Livetitle.text=live.name;
    self.badge.frame=CGRectMake(self.Livetitle.right+5, (60-kCMTBadgeWidth)/2, kCMTBadgeWidth, kCMTBadgeWidth);
    self.badge.hidden=live.noticeCount.integerValue==0;
    self.badge.text=live.noticeCount;
    
    self.liveDesc.frame=CGRectMake(self.livePic.right+10, self.Livetitle.bottom, SCREEN_WIDTH-self.livePic.right-43,29);
    self.liveDesc.text=!isEmptyString(live.latestMessage)?[live.latestMessageSendUser stringByAppendingFormat:@" : %@",live.latestMessage]:live.liveDesc;
    self.buttomline.frame=CGRectMake(0, self.liveDesc.bottom, SCREEN_WIDTH, 1);
    self.frame=CGRectMake(self.left, self.top, self.width, self.buttomline.bottom);
}
@end
