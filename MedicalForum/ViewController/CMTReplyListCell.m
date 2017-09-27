//
//  CMTReplyListCell.m
//  MedicalForum
//
//  Created by fenglei on 14/12/25.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTReplyListCell.h"
#import"CMTBindingViewController.h"

static const CGFloat kCMTReplyListCellMargen = 10.0;
static const CGFloat kCMTReplyListCellGap = 5.0;
static const CGFloat kCMTReplyListCellContentGap = 6.5;
static const CGFloat kCMTReplyListCellContentBottomGap = 6.5;
static const CGFloat kCMTReplyListCellNicknameLabelTop = 8.0;
static const CGFloat kCMTReplyListCellpriseWith = 20;

static const CGFloat kCMTReplyListCellCreateTimeLabelMaxWidth = 75.0;
static const CGFloat kCMTReplyListCellCreateTimeLabelHeight = 15.0;

static const CGFloat kCMTReplyListCellNicknameLabelFontSize = 15;
static const CGFloat kCMTReplyListCellContentLabelFontSize = 15;

@interface CMTReplyListCell ()

@property (nonatomic, copy) CMTReply *reply;
@property (nonatomic, copy) CMTComment *comment;

@property (nonatomic, strong) UILabel *nicknameLabel;
@property (nonatomic, strong) UILabel *createTimeLabel;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UIView *separatorLine;
@property (nonatomic,strong)UIImageView *priaseView;
@property(nonatomic,strong)UILabel *priaseNumber;
@property(nonatomic,strong)UIControl *priseControl;

@end

@implementation CMTReplyListCell

#pragma mark Initializers
-(UIImageView*)priaseView{
    if (_priaseView==nil) {
        _priaseView = [[UIImageView alloc] init];
        _priaseView.backgroundColor = COLOR(c_clear);
        _priaseView.userInteractionEnabled=YES;
    }
    return _priaseView;
}

- (UIControl *)priseControl {
    if (_priseControl == nil) {
        _priseControl = [[UIControl alloc] init];
        _priseControl.backgroundColor = COLOR(c_clear);
        [_priseControl addTarget:self action:@selector(CMTSomePraise) forControlEvents:UIControlEventTouchUpInside];
        _priseControl.userInteractionEnabled=YES;
    }
    
    return _priseControl;
}

- (UILabel *)priaseNumber {
    if (_priaseNumber == nil) {
        _priaseNumber = [[UILabel alloc] init];
        _priaseNumber.backgroundColor =COLOR(c_clear);
        _priaseNumber.textColor = COLOR(c_9e9e9e);
        _priaseNumber.font = FONT(11);
        _priaseNumber.numberOfLines = 1;
    }
    
    return _priaseNumber;
}


- (UILabel *)nicknameLabel {
    if (_nicknameLabel == nil) {
        _nicknameLabel = [[UILabel alloc] init];
        _nicknameLabel.backgroundColor =COLOR(c_clear);
        _nicknameLabel.textColor = COLOR(c_9e9e9e);
        _nicknameLabel.font = FONT(kCMTReplyListCellNicknameLabelFontSize);
        _nicknameLabel.numberOfLines = 0;
        _nicknameLabel.lineBreakMode = NSLineBreakByCharWrapping;
    }
    
    return _nicknameLabel;
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
        _contentLabel.font = FONT(kCMTReplyListCellContentLabelFontSize);
        _contentLabel.numberOfLines = 0;
        _contentLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    
    return _contentLabel;
}

- (UIView *)separatorLine {
    if (_separatorLine == nil) {
        _separatorLine = [[UIView alloc] init];
        _separatorLine.backgroundColor = COLOR(c_dcdcdc);
    }
    
    return _separatorLine;
}
-(void)CMTSomePraise{
    if (self.delegate!=nil&&[self.delegate respondsToSelector:@selector(ReplyListCellPraise:)]) {
        [self.delegate ReplyListCellPraise:self.reply];
    }
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self == nil) return nil;
    
    UIView *background = [[UIView alloc] init];
    background.backgroundColor = COLOR(c_F5F5F8);
    self.backgroundView = background;
    [self.contentView addSubview:self.priaseView];
    [self.contentView addSubview:self.priaseNumber];
    [self.contentView addSubview:self.priseControl];
    [self.contentView addSubview:self.nicknameLabel];
    [self.contentView addSubview:self.createTimeLabel];
    [self.contentView addSubview:self.contentLabel];
    [self.contentView addSubview:self.separatorLine];
    
    return self;
}

#pragma mark LifeCycle

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

+ (CGFloat)cellHeightFromReply:(CMTReply *)reply comment:(CMTComment *)comment cellWidth:(CGFloat)cellWidth {
    CGFloat praiseNumberwith=[CMTGetStringWith_Height CMTGetLableTitleWith:isEmptyString(reply.praiseCount)?@"0":reply.praiseCount fontSize:11]+5;
    CGFloat praiseWith=kCMTReplyListCellMargen+kCMTReplyListCellpriseWith+praiseNumberwith;
    
    // nicknameLabel
    NSString *nicknameText = [NSString stringWithFormat:@"%@ 回复 %@:", reply.nickname, !BEMPTY(reply.beNickname) ? reply.beNickname : comment.nickname];
    CGFloat nicknameMaxWidth = cellWidth-praiseWith-kCMTReplyListCellMargen*2;
    CGSize nicknameSize = [nicknameText boundingRectWithSize:CGSizeMake(nicknameMaxWidth, CGFLOAT_MAX)
                                                     options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine
                                                  attributes:@{NSFontAttributeName:FONT(kCMTReplyListCellNicknameLabelFontSize)}
                                                     context:nil].size;
    CGFloat nicknameLabelBottom = kCMTReplyListCellNicknameLabelTop + ceil(nicknameSize.height);
    
    CGSize timeNamelablesize=[DATE(reply.createTime) boundingRectWithSize:CGSizeMake(nicknameMaxWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingTruncatesLastVisibleLine
                                                                 attributes:@{NSFontAttributeName:FONT(13)}
                                                                    context:nil].size;
    CGFloat timeNamelableBottom=nicknameLabelBottom+kCMTReplyListCellGap*RATIO+ceil(timeNamelablesize.height);
    

    
    // contentLabel
    CGSize contentSize = [reply.content boundingRectWithSize:CGSizeMake(cellWidth-kCMTReplyListCellMargen*2, CGFLOAT_MAX)
                                                     options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine
                                                  attributes:@{NSFontAttributeName:FONT(kCMTReplyListCellContentLabelFontSize)}
                                                     context:nil].size;
    CGFloat contentLabelBottom = timeNamelableBottom+ kCMTReplyListCellContentGap + ceil(contentSize.height);
    
    CGFloat commentBottomGuide = contentLabelBottom + kCMTReplyListCellContentBottomGap;
    
    return commentBottomGuide;
}

- (void)reloadReply:(CMTReply *)reply comment:(CMTComment *)comment cellWidth:(CGFloat)cellWidth cellHeight:(CGFloat)cellHeight last:(BOOL)last {
    self.reply = reply;
    self.comment = comment;
    
    // data
    self.nicknameLabel.text = [NSString stringWithFormat:@"%@ 回复 %@:", reply.nickname, !BEMPTY(reply.beNickname) ? reply.beNickname : comment.nickname];
    self.createTimeLabel.text = DATE(reply.createTime);
    self.contentLabel.text = reply.content;
    self.priaseNumber.text=isEmptyObject(reply.praiseCount)?@"0":reply.praiseCount;
    if (reply.isPraise.boolValue) {
        self.priaseView.image=[UIImage imageNamed:@"praise"];
    }else{
        self.priaseView.image=[UIImage imageNamed:@"unpraise"];
        
    }

    // layout
    [self layoutWithCellWidth:cellWidth cellHeight:cellHeight last:last];
}


- (BOOL)layoutWithCellWidth:(CGFloat)cellWidth cellHeight:(CGFloat)cellHeight last:(BOOL)last {
    CGFloat praiseNumberwith=[CMTGetStringWith_Height CMTGetLableTitleWith:isEmptyObject(self.reply.praiseCount)?@"0":self.reply.praiseCount fontSize:11]+5;
    CGFloat praiseWith=kCMTReplyListCellMargen+kCMTReplyListCellpriseWith+praiseNumberwith;
    
    self.priaseView.frame=CGRectMake(cellWidth-praiseWith, kCMTReplyListCellNicknameLabelTop, kCMTReplyListCellpriseWith, 17);
    self.priaseNumber.frame=CGRectMake(cellWidth-praiseNumberwith, kCMTReplyListCellNicknameLabelTop , praiseNumberwith, 17);
    self.priseControl.frame=CGRectMake(self.priaseView.left, 0,self.priaseNumber.right-self.priaseView.left, 18+10);
    
    // nicknameLabel
    CGFloat nicknameMaxWidth = cellWidth - praiseWith-kCMTReplyListCellMargen*2;
    CGSize nicknameSize = [self.nicknameLabel.text boundingRectWithSize:CGSizeMake(nicknameMaxWidth, CGFLOAT_MAX)
                                                                options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine
                                                             attributes:@{NSFontAttributeName:self.nicknameLabel.font}
                                                                context:nil].size;
    self.nicknameLabel.frame = CGRectMake(kCMTReplyListCellMargen,
                                          kCMTReplyListCellNicknameLabelTop,
                                          nicknameMaxWidth,
                                          ceil(nicknameSize.height));
    
    // createTimeLabel
    CGSize createTimeSize = [self.createTimeLabel.text boundingRectWithSize:CGSizeMake(kCMTReplyListCellCreateTimeLabelMaxWidth*RATIO, CGFLOAT_MAX)
                                                                    options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine
                                                                 attributes:@{NSFontAttributeName:self.createTimeLabel.font}
                                                                    context:nil].size;
    CGFloat createTimeWidth = ceil(createTimeSize.width);
    self.createTimeLabel.frame = CGRectMake(self.nicknameLabel.left,
                                            self.nicknameLabel.bottom,
                                            createTimeWidth,
                                            kCMTReplyListCellCreateTimeLabelHeight);
    
    // contentLabel
    CGSize contentSize = [self.contentLabel.text boundingRectWithSize:CGSizeMake(cellWidth-kCMTReplyListCellMargen*2, CGFLOAT_MAX)
                                                              options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine
                                                           attributes:@{NSFontAttributeName:self.contentLabel.font}
                                                              context:nil].size;
    self.contentLabel.frame = CGRectMake(kCMTReplyListCellMargen,
                                         self.createTimeLabel.bottom>self.priaseView.bottom?self.createTimeLabel.bottom:self.priaseView.bottom + kCMTReplyListCellContentGap,
                                         cellWidth-kCMTReplyListCellMargen*2,
                                         ceil(contentSize.height));
    
    // separatorLine
    self.separatorLine.frame = CGRectMake(kCMTReplyListCellMargen*RATIO, cellHeight - PIXEL, cellWidth - 2.0*kCMTReplyListCellMargen*RATIO, PIXEL);
    self.separatorLine.hidden = last;
    
    return YES;
}

@end
