//
//  CMTLiveNoticeCell.m
//  MedicalForum
//
//  Created by jiahongfei on 15/8/27.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTLiveNoticeCell.h"

#import "CMTBadgePoint.h"
@interface CMTLiveNoticeCell()
@property (nonatomic, strong) UIImageView *picture;
@property (nonatomic, strong) UILabel *nicknameLabel;
@property (nonatomic, strong) UILabel *createTimeLabel;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UIImageView *postSmallpic;
@property (nonatomic, strong) UILabel *postTitleLabel;
@property (nonatomic, strong) UIImageView *postTitleView;
@property(nonatomic,strong)CMTBadgePoint *point;


@property (nonatomic, strong) UIView *bottomLine;
@end
@implementation CMTLiveNoticeCell
#pragma mark Initializers

- (UIImageView *)picture {
    if (_picture == nil) {
        _picture = [[UIImageView alloc] init];
        _picture.backgroundColor = COLOR(c_clear);
        _picture.layer.masksToBounds = YES;
    }
    
    return _picture;
}

- (UILabel *)nicknameLabel {
    if (_nicknameLabel == nil) {
        _nicknameLabel = [[UILabel alloc] init];
        _nicknameLabel.backgroundColor = COLOR(c_clear);
        _nicknameLabel.textColor = COLOR(c_9e9e9e);
        _nicknameLabel.font = FONT(15);
        _nicknameLabel.numberOfLines=0;
        _nicknameLabel.lineBreakMode = NSLineBreakByWordWrapping;
    }
    
    return _nicknameLabel;
}
-(CMTBadgePoint*)point{
    if (_point==nil) {
        _point=[[CMTBadgePoint alloc]init];
    }
    return _point;
}

- (UILabel *)createTimeLabel {
    if (_createTimeLabel == nil) {
        _createTimeLabel = [[UILabel alloc] init];
        _createTimeLabel.backgroundColor = COLOR(c_clear);
        _createTimeLabel.textColor = COLOR(c_9e9e9e);
        _createTimeLabel.font = FONT(13.0);
    }
    
    return _createTimeLabel;
}

- (UILabel *)contentLabel {
    if (_contentLabel == nil) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.backgroundColor = COLOR(c_clear);
        _contentLabel.textColor = COLOR(c_151515);
        _contentLabel.font = FONT(16);
        _contentLabel.numberOfLines = 0;
        _contentLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    
    return _contentLabel;
}

- (UIImageView *)postSmallpic {
    if (_postSmallpic == nil) {
        _postSmallpic = [[UIImageView alloc] init];
        _postSmallpic.backgroundColor = COLOR(c_f5f5f5);
        _postSmallpic.layer.borderWidth = PIXEL;
        _postSmallpic.layer.borderColor = COLOR(c_dcdcdc).CGColor;
        _postSmallpic.contentMode=UIViewContentModeScaleAspectFill;
        _postSmallpic.clipsToBounds=YES;
    }
    
    return _postSmallpic;
}

- (UILabel *)postTitleLabel {
    if (_postTitleLabel == nil) {
        _postTitleLabel = [[UILabel alloc] init];
        _postTitleLabel.backgroundColor = COLOR(c_clear);
        _postTitleLabel.textColor = COLOR(c_151515);
        _postTitleLabel.font = FONT(16);
        _postTitleLabel.numberOfLines = 2;
        _postTitleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    
    return _postTitleLabel;
}

- (UIView *)bottomLine {
    if (_bottomLine == nil) {
        _bottomLine = [[UIView alloc] init];
        _bottomLine.backgroundColor = COLOR(c_dcdcdc);
    }
    
    return _bottomLine;
}
- (UIImageView *)postTitleView {
    if (_postTitleView == nil) {
        _postTitleView = [[UIImageView alloc] init];
        _postTitleView.backgroundColor = COLOR(c_f5f5f5);
        _postTitleView.layer.borderWidth = PIXEL;
        _postTitleView.layer.borderColor = COLOR(c_dcdcdc).CGColor;
    }
    
    return _postTitleView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIView *background = [[UIView alloc] init];
        background.backgroundColor = COLOR(c_ffffff);
        self.backgroundView = background;
        [self.contentView addSubview:self.postTitleView];
        
        [self.contentView addSubview:self.picture];
        [self.contentView addSubview:self.point];
        [self.contentView addSubview:self.nicknameLabel];
        [self.contentView addSubview:self.createTimeLabel];
        [self.contentView addSubview:self.contentLabel];
        [self.contentView addSubview:self.postTitleLabel];
        [self.contentView addSubview:self.postTitleLabel];
        [self.contentView addSubview:self.bottomLine];
        [self.contentView addSubview:self.postSmallpic];
        
        
    }
    return self;
}
-(void)reloadCell:(CMTLiveNotice*)notice{
    self.picture.frame=CGRectMake(10, 10, 40, 40);
    [self.picture setImageURL:notice.userPic placeholderImage:IMAGE(@"ic_default_head") contentSize:CGSizeMake(40, 40)];
    self.picture.layer.cornerRadius = self.picture.width / 2.0;
    
    self.point.frame=CGRectMake(self.picture.right-CMTBadgePointWidth/2, self.picture.top, CMTBadgePointWidth, CMTBadgePointWidth);
    self.point.hidden=notice.status.boolValue;
    
    
    //创建时间
    
    float CreatetimeWith=[CMTGetStringWith_Height CMTGetLableTitleWith:DATE(notice.createTime) fontSize:13];
    float Createtimeheight=[self getTextheight:DATE(notice.createTime)fontsize:13 width:CreatetimeWith];
    self.createTimeLabel.frame=CGRectMake(SCREEN_WIDTH-CreatetimeWith-20, self.picture.top, CreatetimeWith, Createtimeheight);
    self.createTimeLabel.text=DATE(notice.createTime);
    
    //nickname
    [self getnicknameLableText:notice];
    float nickwidth=SCREEN_WIDTH-self.picture.right-40-self.createTimeLabel.width;
    self.nicknameLabel.frame=CGRectMake(self.picture.right+10, self.picture.top
                                        ,nickwidth ,[self getTextheight:notice.sendUserNickname fontsize:15 width:nickwidth]);
    self.nicknameLabel.text=notice.sendUserNickname;
    
    //评论内容
    float contentWith=SCREEN_WIDTH-self.picture.right-20;
    self.contentLabel.frame=CGRectMake(self.picture.right+10, self.nicknameLabel.bottom+10, contentWith,[self getTextheight:notice.content fontsize:16 width:contentWith]);
    self.contentLabel.text=notice.content;
    
    //文章缩略图
    if(notice.content.length>0){
        self.postSmallpic.frame=CGRectMake(self.picture.right+10, self.contentLabel.bottom+10,60, 60);
    }else{
        self.postSmallpic.frame=CGRectMake(self.picture.right+10, self.nicknameLabel.bottom+10,60, 60);
    }
    NSString *pic = nil;
//    if([notice.noticeType isEqualToString:@"0"] || [notice.noticeType isEqualToString:@"2"]){
        pic = notice.liveBroadcastMessagePic;
//    }else if([notice.noticeType isEqualToString:@"1"]){
//        pic = notice.receiveUserPic;
//    }
    [self.postSmallpic setImageURL:pic placeholderImage:IMAGE(@"ic_live_item_default") contentSize:CGSizeMake(60, 60)];
    //标题
    self.postTitleLabel.frame=CGRectMake(self.postSmallpic.right+10, self.postSmallpic.top, SCREEN_WIDTH-self.postSmallpic.right-20, 60);
    self.postTitleLabel.text=notice.beContent;
    self.postTitleView.frame=CGRectMake(self.picture.right+10,self.postSmallpic.top,SCREEN_WIDTH-self.picture.right-15, self.postTitleLabel.height);
    
    self.bottomLine.frame=CGRectMake(0, self.postTitleLabel.bottom+10,SCREEN_WIDTH, 1);
    self.frame=CGRectMake(self.frame.origin.x, self.frame.origin.y, self.width,self.bottomLine.bottom);
}
-(void)getnicknameLableText:(CMTLiveNotice*)notice{
    notice.sendUserNickname=[notice.sendUserNickname stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    switch (notice.noticeType.integerValue) {
        case 0:
            notice.sendUserNickname=[notice.sendUserNickname stringByAppendingString:@"  评论了 你的直播"];
            break;
        case 1:
            notice.sendUserNickname=[notice.sendUserNickname stringByAppendingString:@"  回复了 你的评论"];
            break;
        case 2:
            notice.sendUserNickname=[notice.sendUserNickname stringByAppendingString:@"  赞了 你的直播"];
            break;
        default:
            break;
    }
    
}
-(float)getTextheight:(NSString*)text fontsize:(float)size width:(float) width{
    //回复内容
    CGSize titleSize = [text boundingRectWithSize:CGSizeMake(width,MAXFLOAT)
                                          options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine
                                       attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:size]}
                                          context:nil].size;
    return titleSize.height;
}
@end

