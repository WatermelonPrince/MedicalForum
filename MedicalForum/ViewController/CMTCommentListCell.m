//
//  CMTCommentListCell.m
//  MedicalForum
//
//  Created by fenglei on 14/12/23.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTCommentListCell.h"
#import "CMTReply.h"
#import "CMTBindingViewController.h"
#import "NSString+CMTExtension_HTMLString.h"
#import "MWPhoto.h"
#import "MWPhotoBrowser.h"

static const CGFloat kCMTCommentListCellMargen = 10.0;
static const CGFloat kCMTCommentListCellGap = 5.0;
static const CGFloat kCMTCommentListCellContentGap = 7.0;
static const CGFloat kCMTCommentListCellContentBottomGap = 8.0;
static const CGFloat kCMTCommentListCellPictureTop = 13.0;
static const CGFloat kCMTCommentListCellLiveCommentPictureTop = 10.0;
static const CGFloat kCMTCommentListCellpriseWith = 20.0;
static const CGFloat kCMTCommentListCellPictureWidth = 47.0;
static const CGFloat kCMTCommentListCellLiveCommentPictureWidth = 40.0;
static const CGFloat kCMTCommentListCellNicknameLabelTop = 14.5;
static const CGFloat kCMTCommentListCellCreateTimeLabelMaxWidth = 75.0;
static const CGFloat kCMTCommentListCellCreateTimeLabelHeight = 15.0;
static const CGFloat kCMTCommentListCellListArrowWidth = 5;

static const CGFloat kCMTCommentListCellCreateTimeLabelFontSize = 11;
static const CGFloat kCMTCommentListCellLiveCommentCreateTimeLabelFontSize = 11.0;
static const CGFloat kCMTCommentListCellNicknameLabelFontSize = 15;
static const CGFloat kCMTCommentListCellLiveCommentNicknameLabelFontSize = 15;
static const CGFloat kCMTCommentListCellContentLabelFontSize =15;
static const CGFloat kCMTCommentListCellRemindLabelFontSize = 13;
static const CGFloat kCMTCommentListCellLiveCommentContentLabelFontSize = 15;

@interface CMTCommentListCell ()<MWPhotoBrowserDelegate>

@property (nonatomic, copy, readwrite) CMTComment *comment;
@property (nonatomic, copy, readwrite) NSIndexPath *indexPath;

@property (nonatomic, strong) UIImageView *picture;
@property (nonatomic, strong) UILabel *nicknameLabel;
@property (nonatomic, strong) UILabel *createTimeLabel;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UIImageView *listArrow;
@property (nonatomic, strong) UIView *bottomLine;
@property (nonatomic,strong)UIImageView *priaseView;
@property(nonatomic,strong)UILabel *priaseNumber;
@property(nonatomic,strong)UIControl *priseControl;
@property(nonatomic,strong)UIControl *comentPicControl;
@property(nonatomic,strong)UIImageView *comemtimageView;
@property(nonatomic,strong)UILabel *atUserslable;
@property(nonatomic,strong)NSArray *imageArray;

@end

@implementation CMTCommentListCell

#pragma mark Initializers
-(UIImageView*)comemtimageView{
    if (_comemtimageView==nil) {
        _comemtimageView = [[UIImageView alloc] init];
        _comemtimageView.backgroundColor = COLOR(c_clear);
        _comemtimageView.userInteractionEnabled=YES;
        _comemtimageView.contentMode=UIViewContentModeScaleAspectFill;
        _comemtimageView.clipsToBounds=YES;
    }
    return _comemtimageView;
}
-(UIControl*)comentPicControl{
    if (_comentPicControl==nil) {
        _comentPicControl = [[UIControl alloc] init];
        _comentPicControl.backgroundColor = COLOR(c_clear);
        [_comentPicControl addTarget:self action:@selector(showPIc) forControlEvents:UIControlEventTouchUpInside];
        _comentPicControl.userInteractionEnabled=YES;
    }
    return _comentPicControl;
}
- (UILabel *)atUserslable {
    if (_atUserslable == nil) {
        _atUserslable = [[UILabel alloc] init];
        _atUserslable.backgroundColor = COLOR(c_clear);
        _atUserslable.textColor = COLOR(c_9e9e9e);
        _atUserslable.font = FONT(kCMTCommentListCellRemindLabelFontSize);
        _atUserslable.numberOfLines = 0;
       _atUserslable.lineBreakMode = NSLineBreakByWordWrapping;
    }
    
    return _atUserslable;
}

-(UIImageView*)priaseView{
    if (_priaseView==nil) {
        _priaseView = [[UIImageView alloc] init];
        _priaseView.backgroundColor = COLOR(c_clear);
        _priaseView.userInteractionEnabled=YES;
    }
    return _priaseView;
}
- (UIImageView *)picture {
    if (_picture == nil) {
        _picture = [[UIImageView alloc] init];
        _picture.backgroundColor = COLOR(c_clear);
        _picture.layer.masksToBounds = YES;
        _picture.contentMode=UIViewContentModeScaleAspectFill;
        _picture.clipsToBounds=YES;
        _picture.layer.cornerRadius = kCMTCommentListCellPictureWidth / 2.0;
    }
    
    return _picture;
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
-(void)CMTSomePraise{
    if (self.delegate!=nil&&[self.delegate respondsToSelector:@selector(CommentListCellPraise:index:)]) {
        [self.delegate CommentListCellPraise:self.comment index:self.indexPath];
    }
}
- (UILabel *)priaseNumber {
    if (_priaseNumber == nil) {
        _priaseNumber = [[UILabel alloc] init];
        _priaseNumber.backgroundColor = COLOR(c_clear);
        _priaseNumber.textColor = COLOR(c_9e9e9e);
        _priaseNumber.font = FONT(11);
        _priaseNumber.numberOfLines = 1;
    }
    
    return _priaseNumber;
}

- (UILabel *)nicknameLabel {
    if (_nicknameLabel == nil) {
        _nicknameLabel = [[UILabel alloc] init];
        _nicknameLabel.backgroundColor = COLOR(c_clear);
        _nicknameLabel.textColor = COLOR(c_9e9e9e);
        _nicknameLabel.font = FONT(kCMTCommentListCellNicknameLabelFontSize);
        _nicknameLabel.numberOfLines = 0;
        _nicknameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    
    return _nicknameLabel;
}

- (UILabel *)createTimeLabel {
    if (_createTimeLabel == nil) {
        _createTimeLabel = [[UILabel alloc] init];
        _createTimeLabel.backgroundColor = COLOR(c_clear);
        _createTimeLabel.textColor = COLOR(c_9e9e9e);
        _createTimeLabel.font = FONT(kCMTCommentListCellCreateTimeLabelFontSize);
    }
    
    return _createTimeLabel;
}

- (UILabel *)contentLabel {
    if (_contentLabel == nil) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.backgroundColor = COLOR(c_clear);
        _contentLabel.textColor = COLOR(c_151515);
        _contentLabel.font = FONT(kCMTCommentListCellContentLabelFontSize);
        _contentLabel.numberOfLines = 0;
        _contentLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    
    return _contentLabel;
}

- (UIImageView *)listArrow {
    if (_listArrow == nil) {
        _listArrow = [[UIImageView alloc] initWithImage:IMAGE(@"comment_listArrow")];
        _listArrow.backgroundColor = COLOR(c_clear);
    }
    
    return _listArrow;
}

- (UIView *)bottomLine {
    if (_bottomLine == nil) {
        _bottomLine = [[UIView alloc] init];
        _bottomLine.backgroundColor = COLOR(c_dcdcdc);
    }
    
    return _bottomLine;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self == nil) return nil;
    
    UIView *background = [[UIView alloc] init];
    background.backgroundColor = COLOR(c_ffffff);
    self.backgroundView = background;
    
    [self.contentView addSubview:self.picture];
    [self.contentView addSubview:self.priaseView];
    [self.contentView addSubview:self.priaseNumber];
    [self.contentView addSubview:self.priseControl];
    [self.contentView addSubview:self.nicknameLabel];
    [self.contentView addSubview:self.createTimeLabel];
    [self.contentView addSubview:self.contentLabel];
     [self.contentView addSubview:self.comemtimageView];
    [self.contentView addSubview:self.comentPicControl];
   
    [self.contentView addSubview:self.atUserslable];
    [self.contentView addSubview:self.listArrow];
    [self.contentView addSubview:self.bottomLine];
    self.listArrow.hidden = YES;
    
    return self;
}

#pragma mark LifeCycle

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

+ (CGFloat)cellHeightFromComment:(CMTComment *)comment cellWidth:(CGFloat)cellWidth {
    BOOL isHavepicpath=comment.commentPic.picFilepath.length>0;
    BOOL ishaveAtusers=comment.atUsers.length>0;
    // picture
    CGFloat pictureRight = kCMTCommentListCellMargen*RATIO + kCMTCommentListCellPictureWidth;
    CGFloat pictureBottom = kCMTCommentListCellPictureTop + kCMTCommentListCellPictureWidth;
    CGFloat praiseNumberwith=kCMTCommentListCellMargen+[CMTGetStringWith_Height CMTGetLableTitleWith:isEmptyObject(comment.praiseCount)?@"0":comment.praiseCount fontSize:11]+5;
    CGFloat praiseWith=kCMTCommentListCellMargen+kCMTCommentListCellpriseWith+praiseNumberwith;
    
    CGFloat commentLeftGuide = pictureRight + kCMTCommentListCellGap*RATIO;
    CGFloat commentRightGuide = cellWidth - praiseWith;
    CGFloat commentWidth = commentRightGuide - commentLeftGuide;

    // nicknameLabel
    CGFloat nicknameMaxWidth = commentWidth- kCMTCommentListCellMargen;
    CGSize nicknameSize = [comment.nickname boundingRectWithSize:CGSizeMake(nicknameMaxWidth, CGFLOAT_MAX)
                                                         options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine
                                                      attributes:@{NSFontAttributeName:FONT(kCMTCommentListCellNicknameLabelFontSize)}
                                                         context:nil].size;
    CGFloat nicknameLabelBottom = kCMTCommentListCellNicknameLabelTop + ceil(nicknameSize.height)+kCMTCommentListCellMargen;
    
    CGSize timeNamelablesize=[DATE(comment.createTime) boundingRectWithSize:CGSizeMake(commentWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingTruncatesLastVisibleLine
                                                          attributes:@{NSFontAttributeName:FONT(kCMTCommentListCellCreateTimeLabelFontSize)}
                                                             context:nil].size;
    CGFloat timeNamelableBottom=nicknameLabelBottom+kCMTCommentListCellGap+ceil(timeNamelablesize.height);

    
    // contentLabel
    CGSize contentSize = [comment.content boundingRectWithSize:CGSizeMake(commentWidth, CGFLOAT_MAX)
                                                       options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine
                                                    attributes:@{NSFontAttributeName:FONT(kCMTCommentListCellContentLabelFontSize)}
                                                       context:nil].size;
    CGFloat contentLabelBottom =timeNamelableBottom + kCMTCommentListCellContentGap + ceil(contentSize.height);
    CGFloat commtpicBottom=contentLabelBottom+(isHavepicpath?(SCREEN_WIDTH-50)/4+kCMTCommentListCellContentGap:0);
    CGSize remindSize = [[NSString replacedremindPeople:comment.atUsers?:@""]  boundingRectWithSize:CGSizeMake(commentWidth, CGFLOAT_MAX)options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine
                                                    attributes:@{NSFontAttributeName:FONT(kCMTCommentListCellRemindLabelFontSize)}
                                                       context:nil].size;

   CGFloat remindButtom=commtpicBottom+(ishaveAtusers?ceil(remindSize.height)+kCMTCommentListCellContentGap:0);
//    CGFloat commentBottomGuide = pictureBottom > remindButtom ?
//    (pictureBottom + kCMTCommentListCellContentGap) : (remindButtom + kCMTCommentListCellContentGap);
   
    NSLog(@"++++%f,____%f,####%f,^^^^%f,%f",remindButtom,contentLabelBottom,pictureBottom,nicknameLabelBottom,nicknameMaxWidth);
    return remindButtom;
}

- (void)reloadComment:(CMTComment *)comment cellWidth:(CGFloat)cellWidth indexPath:(NSIndexPath *)indexPath {
    self.comment = comment;
    self.indexPath = indexPath;
    // data
    if (comment.userType.integerValue == 1) {
        [self.picture setImageURL:comment.picture placeholderImage:IMAGE(@"comment_defaultPicture") contentSize:CGSizeZero];
    }
    else {
        [self.picture setImageURL:comment.picture placeholderImage:IMAGE(@"comment_defaultPicture") contentSize:CGSizeMake(kCMTCommentListCellPictureWidth, kCMTCommentListCellPictureWidth)];
    }
    self.nicknameLabel.text = comment.nickname;
    self.createTimeLabel.text = DATE(comment.createTime);
    self.contentLabel.text = comment.content;
    self.priaseNumber.text=isEmptyObject(comment.praiseCount)?@"0":comment.praiseCount;
    if (comment.isPraise.boolValue) {
            self.priaseView.image=[UIImage imageNamed:@"praise"];
        }else{
            self.priaseView.image=[UIImage imageNamed:@"unpraise"];
            
        }
    [self.comemtimageView  setImageURL:self.comment.commentPic.picFilepath placeholderImage:IMAGE(@"placeholder_list_loading") contentSize:CGSizeMake((SCREEN_WIDTH-50)/4, (SCREEN_WIDTH-50)/4)];
    self.atUserslable.text=[NSString replacedremindPeople:comment.atUsers?:@""];
    // layout
    CGFloat cellHeight = [CMTCommentListCell cellHeightFromComment:comment cellWidth:cellWidth];
    [self layoutWithCellWidth:cellWidth cellHeight:cellHeight];
}

- (BOOL)layoutWithCellWidth:(CGFloat)cellWidth cellHeight:(CGFloat)cellHeight {
    
    BOOL isHavepicpath=self.comment.commentPic.picFilepath.length>0;
    BOOL ishaveAtusers=self.comment.atUsers.length>0;

    BOOL emptyReplyList = (self.comment.replyList.count == 0);
    
    // picture
    self.picture.frame = CGRectMake(kCMTCommentListCellMargen*RATIO,
                                    kCMTCommentListCellPictureTop,
                                    kCMTCommentListCellPictureWidth,
                                    kCMTCommentListCellPictureWidth);
    CGFloat praiseNumberwith=kCMTCommentListCellMargen+[CMTGetStringWith_Height CMTGetLableTitleWith:_comment.praiseCount fontSize:11]+5;
    CGFloat praiseWith=kCMTCommentListCellMargen+kCMTCommentListCellpriseWith+praiseNumberwith;

    self.priaseView.frame=CGRectMake(cellWidth-praiseWith, kCMTCommentListCellPictureTop, kCMTCommentListCellpriseWith, 17);
    self.priaseNumber.frame=CGRectMake(cellWidth-praiseNumberwith, kCMTCommentListCellPictureTop , praiseNumberwith-kCMTCommentListCellMargen, 17);
    self.priseControl.frame=CGRectMake(self.priaseView.left, kCMTCommentListCellPictureTop,self.priaseNumber.right-self.priaseView.left, 18+10);
    
    CGFloat commentLeftGuide = self.picture.right + kCMTCommentListCellGap*RATIO;
    CGFloat commentRightGuide = cellWidth - praiseWith;
    CGFloat commentWidth = commentRightGuide - commentLeftGuide;
    
    // nicknameLabel
    CGFloat nicknameMaxWidth = commentWidth -kCMTCommentListCellMargen;
    CGSize nicknameSize = [self.nicknameLabel.text boundingRectWithSize:CGSizeMake(nicknameMaxWidth, CGFLOAT_MAX)
                                                                options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine
                                                             attributes:@{NSFontAttributeName:self.nicknameLabel.font}
                                                                context:nil].size;
    self.nicknameLabel.frame = CGRectMake(commentLeftGuide,
                                          kCMTCommentListCellNicknameLabelTop,
                                          nicknameMaxWidth,
                                          ceil(nicknameSize.height));
    
    // createTimeLabel
    CGSize createTimeSize = [self.createTimeLabel.text boundingRectWithSize:CGSizeMake(kCMTCommentListCellCreateTimeLabelMaxWidth*RATIO, CGFLOAT_MAX)
                                                                    options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine
                                                                 attributes:@{NSFontAttributeName:self.createTimeLabel.font}
                                                                    context:nil].size;
    CGFloat createTimeWidth = ceil(createTimeSize.width);
    self.createTimeLabel.frame = CGRectMake(self.nicknameLabel.left,
                                            self.nicknameLabel.bottom+kCMTCommentListCellGap*RATIO,
                                            createTimeWidth,
                                            kCMTCommentListCellCreateTimeLabelHeight);
    
    // contentLabel
    CGSize contentSize = [self.contentLabel.text boundingRectWithSize:CGSizeMake(commentWidth, CGFLOAT_MAX)
                                                              options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine
                                                           attributes:@{NSFontAttributeName:self.contentLabel.font}
                                                              context:nil].size;
    self.contentLabel.frame = CGRectMake(commentLeftGuide,
                                         self.createTimeLabel.bottom + kCMTCommentListCellContentGap,
                                         commentWidth,
                                         ceil(contentSize.height));
    
    self.comentPicControl.frame=CGRectMake(commentLeftGuide, isHavepicpath?self.contentLabel.bottom + kCMTCommentListCellContentGap:self.contentLabel.bottom,(SCREEN_WIDTH-50)/4,self.comment.commentPic.picFilepath.length>0?(SCREEN_WIDTH-50)/4:0);
    self.comemtimageView.frame=self.comentPicControl.frame;
    
    CGSize remindSize = [[NSString replacedremindPeople:self.comment.atUsers?:@""]  boundingRectWithSize:CGSizeMake(commentWidth, CGFLOAT_MAX)
                                                                                       options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine
                                                                                    attributes:@{NSFontAttributeName:FONT(kCMTCommentListCellRemindLabelFontSize)}
                                                                                       context:nil].size;
    self.atUserslable.frame=CGRectMake(commentLeftGuide,ishaveAtusers? self.comentPicControl.bottom + kCMTCommentListCellContentGap:self.comentPicControl.bottom, commentWidth, ishaveAtusers?ceil(remindSize.height):0);
    
    CGFloat commentBottomGuide = self.picture.bottom > self.atUserslable.bottom ?
    self.picture.bottom + kCMTCommentListCellContentGap :
    self.atUserslable.bottom + kCMTCommentListCellContentGap;
    
    
    
    // listArrow
    self.listArrow.frame = CGRectMake(self.picture.centerX - kCMTCommentListCellListArrowWidth / 2.0,
                                      commentBottomGuide - kCMTCommentListCellListArrowWidth,
                                      kCMTCommentListCellListArrowWidth,
                                      kCMTCommentListCellListArrowWidth);
    self.listArrow.hidden = YES;
    
    // bottomLine
    self.bottomLine.frame = CGRectMake(0, cellHeight - PIXEL, cellWidth, PIXEL);
    self.bottomLine.hidden = !emptyReplyList;
    
    return YES;
}

+ (CGFloat)cellHeightFromLiveComment:(CMTLiveComment *)liveComment cellWidth:(CGFloat)cellWidth {
    
    // picture
    CGFloat pictureRight = kCMTCommentListCellMargen*RATIO + kCMTCommentListCellLiveCommentPictureWidth;
    
    // createTimeLabel
    CGSize createTimeSize = [DATE(liveComment.createTime) boundingRectWithSize:CGSizeMake(kCMTCommentListCellCreateTimeLabelMaxWidth*RATIO, CGFLOAT_MAX)
                                                                       options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine
                                                                    attributes:@{NSFontAttributeName:FONT(kCMTCommentListCellLiveCommentCreateTimeLabelFontSize)}
                                                                       context:nil].size;
    CGFloat createTimeWidth = ceil(createTimeSize.width);

    CGFloat commentLeftGuide = pictureRight + kCMTCommentListCellGap*2.0*RATIO;
    CGFloat commentRightGuide = cellWidth - kCMTCommentListCellMargen*RATIO;
    CGFloat commentWidth = commentRightGuide - commentLeftGuide;
    
    // nicknameLabel
    CGFloat nicknameMaxWidth = commentWidth - createTimeWidth - kCMTCommentListCellGap*RATIO;
    NSString *nickName = liveComment.userNickname;
    if ([liveComment.type isEqual:@"1"]) {
        nickName = [NSString stringWithFormat:@"%@ 回复 %@", liveComment.userNickname, liveComment.beUserNickname];
    }
    CGSize nicknameSize = [nickName boundingRectWithSize:CGSizeMake(nicknameMaxWidth, CGFLOAT_MAX)
                                                 options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine
                                              attributes:@{NSFontAttributeName:FONT(kCMTCommentListCellLiveCommentNicknameLabelFontSize)}
                                                 context:nil].size;
    CGFloat nicknameLabelBottom = kCMTCommentListCellNicknameLabelTop + ceil(nicknameSize.height);
    
    // contentLabel
    CGSize contentSize = [liveComment.content boundingRectWithSize:CGSizeMake(commentWidth, CGFLOAT_MAX)
                                                           options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine
                                                        attributes:@{NSFontAttributeName:FONT(kCMTCommentListCellLiveCommentContentLabelFontSize)}
                                                           context:nil].size;
    CGFloat contentLabelBottom = nicknameLabelBottom + kCMTCommentListCellContentGap + ceil(contentSize.height);
    
    CGFloat commentBottomGuide = contentLabelBottom + kCMTCommentListCellContentBottomGap + 4.0;
    
    return commentBottomGuide;
}

- (void)reloadLiveComment:(CMTLiveComment *)liveComment cellWidth:(CGFloat)cellWidth indexPath:(NSIndexPath *)indexPath {
    self.indexPath = indexPath;
    
    // view
    self.picture.layer.cornerRadius = kCMTCommentListCellLiveCommentPictureWidth / 2.0;
    self.createTimeLabel.font = FONT(kCMTCommentListCellLiveCommentCreateTimeLabelFontSize);
    self.nicknameLabel.font = FONT(kCMTCommentListCellLiveCommentNicknameLabelFontSize);
    self.contentLabel.font = FONT(kCMTCommentListCellLiveCommentContentLabelFontSize);
    
    // data
    if (liveComment.userType.integerValue == 1) {
        [self.picture setImageURL:liveComment.userPic placeholderImage:IMAGE(@"comment_defaultPicture") contentSize:CGSizeZero];
    }
    else {
        [self.picture setImageURL:liveComment.userPic placeholderImage:IMAGE(@"comment_defaultPicture") contentSize:CGSizeMake(kCMTCommentListCellLiveCommentPictureWidth, kCMTCommentListCellLiveCommentPictureWidth)];
    }
    NSString *nickName = liveComment.userNickname;
    if ([liveComment.type isEqual:@"1"]) {
        nickName = [NSString stringWithFormat:@"%@ 回复 %@", liveComment.userNickname, liveComment.beUserNickname];
    }
    self.nicknameLabel.text = nickName;
    self.createTimeLabel.text = DATE(liveComment.createTime);
    self.contentLabel.text = liveComment.content;
    self.priaseView.hidden = YES;
    self.priaseNumber.hidden = YES;
    self.priseControl.hidden = YES;
    
    // layout
    CGFloat cellHeight = [CMTCommentListCell cellHeightFromLiveComment:liveComment cellWidth:cellWidth];
    [self layoutLiveCommentWithCellWidth:cellWidth cellHeight:cellHeight];
}

- (BOOL)layoutLiveCommentWithCellWidth:(CGFloat)cellWidth cellHeight:(CGFloat)cellHeight {
    
    // picture
    self.picture.frame = CGRectMake(kCMTCommentListCellMargen*RATIO,
                                    kCMTCommentListCellLiveCommentPictureTop,
                                    kCMTCommentListCellLiveCommentPictureWidth,
                                    kCMTCommentListCellLiveCommentPictureWidth);
    
    // createTimeLabel
    CGSize createTimeSize = [self.createTimeLabel.text boundingRectWithSize:CGSizeMake(kCMTCommentListCellCreateTimeLabelMaxWidth*RATIO, CGFLOAT_MAX)
                                                                    options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine
                                                                 attributes:@{NSFontAttributeName:self.createTimeLabel.font}
                                                                    context:nil].size;
    CGFloat createTimeWidth = ceil(createTimeSize.width);
    self.createTimeLabel.frame = CGRectMake(cellWidth - kCMTCommentListCellMargen*RATIO - createTimeWidth,
                                            kCMTCommentListCellLiveCommentPictureTop + 5.5,
                                            createTimeWidth,
                                            kCMTCommentListCellCreateTimeLabelHeight);
    
    CGFloat commentLeftGuide = self.picture.right + kCMTCommentListCellGap*2.0*RATIO;
    CGFloat commentRightGuide = cellWidth - kCMTCommentListCellMargen*RATIO;
    CGFloat commentWidth = commentRightGuide - commentLeftGuide;
    
    // nicknameLabel
    CGFloat nicknameMaxWidth = commentWidth - createTimeWidth - kCMTCommentListCellGap*RATIO;
    CGSize nicknameSize = [self.nicknameLabel.text boundingRectWithSize:CGSizeMake(nicknameMaxWidth, CGFLOAT_MAX)
                                                                options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine
                                                             attributes:@{NSFontAttributeName:self.nicknameLabel.font}
                                                                context:nil].size;
    self.nicknameLabel.frame = CGRectMake(commentLeftGuide,
                                          kCMTCommentListCellNicknameLabelTop,
                                          nicknameMaxWidth,
                                          ceil(nicknameSize.height));
    // contentLabel
    CGSize contentSize = [self.contentLabel.text boundingRectWithSize:CGSizeMake(commentWidth, CGFLOAT_MAX)
                                                              options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine
                                                           attributes:@{NSFontAttributeName:self.contentLabel.font}
                                                              context:nil].size;
    self.contentLabel.frame = CGRectMake(commentLeftGuide,
                                         self.nicknameLabel.bottom + kCMTCommentListCellContentGap,
                                         commentWidth,
                                         ceil(contentSize.height));
    
    // bottomLine
    self.bottomLine.frame = CGRectMake(0, cellHeight - PIXEL, cellWidth, PIXEL);
    self.bottomLine.hidden = NO;
    
    return YES;
}
/**
 *  展示图片
 */
-(void)showPIc{
    NSMutableArray *array=[[NSMutableArray alloc]initWithObjects:self.comment.commentPic.picFilepath, nil];
    [self openPhotoBrowserWithCurrentImageURL:self.comment.commentPic.picFilepath totalImageURLs:[array copy]];
}
/**
 *  放大图片
 *
 *  @param imageURL       当前图片地址
 *  @param totalImageURLs 所有图片数组
 */
- (void)openPhotoBrowserWithCurrentImageURL:(NSString *)imageURL
                             totalImageURLs:(NSArray *)totalImageURLs {
    // Photos
    if ( self.imageArray.count == 0) {
        NSMutableArray *photos = [NSMutableArray array];
        for (NSInteger index = 0; index < totalImageURLs.count; index++) {
            // 原始图片URL
            NSString *imageURLString = [UIImage fullQualityImageURLWithURL:totalImageURLs[index]];
            MWPhoto *photo = [MWPhoto photoWithURL:[NSURL URLWithString:imageURLString]];
            photo.caption = [NSString stringWithFormat:@"%ld/%ld", (long)(index + 1), (long)totalImageURLs.count];
            [photos addObject:photo];
        }
        self.imageArray = photos;
    }
    
    // PhotoBrowser
    MWPhotoBrowser *photoBrowser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    photoBrowser.zoomPhotosToFill = YES;
    photoBrowser.enableSwipeToDismiss = NO;
    [photoBrowser setCurrentPhotoIndex:[totalImageURLs indexOfObject:imageURL]];
    
    // Show
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:photoBrowser];
    navigationController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [[CMTAPPCONFIG  getCurrentVC] presentViewController:navigationController animated:YES completion:nil];
}

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return  [self.imageArray count];
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index <  self.imageArray.count) {
        return  self.imageArray[index];
    }
    return nil;
}

@end
