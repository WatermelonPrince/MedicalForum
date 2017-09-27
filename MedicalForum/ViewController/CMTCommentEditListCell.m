//
//  CMTCommentEditListCell.m
//  MedicalForum
//
//  Created by fenglei on 14/12/28.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTCommentEditListCell.h"

static const CGFloat kCMTCommentEditListCellMargen = 10.0;
static const CGFloat kCMTCommentEditListCellGap = 5.0;
static const CGFloat kCMTCommentEditListCellVerticalGap = 10.0;
static const CGFloat kCMTCommentEditListCellPostTitleMargen = 7.5;
static const CGFloat kCMTCommentEditListCellPictureTop = 13.0;
static const CGFloat kCMTCommentEditListCellPictureWidth = 47.0;
static const CGFloat kCMTCommentEditListCellNicknameLabelTop = 14.5;
static const CGFloat kCMTCommentEditListCellCreateTimeLabelTop = 14.5;
static const CGFloat kCMTCommentEditListCellCreateTimeLabelMaxWidth = 75.0;
static const CGFloat kCMTCommentEditListCellCreateTimeLabelHeight = 15.0;

static const CGFloat kCMTCommentEditListCellNicknameLabelFontSize = 15.0;
static const CGFloat kCMTCommentEditListCellContentLabelFontSize = 15.0;
static const CGFloat kCMTCommentEditListCellPostTitleLabelFontSize = 15.0;

@interface CMTCommentEditListCell ()

@property (nonatomic, strong, readwrite) CMTCommentEditListCellModel *cellModel;

@property (nonatomic, strong) UIImageView *picture;
@property (nonatomic, strong) UILabel *nicknameLabel;
@property (nonatomic, strong) UILabel *createTimeLabel;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UIImageView *postTitleView;
@property (nonatomic, strong) UILabel *postTitleLabel;
@property (nonatomic, strong) UIView *bottomLine;

@end

@implementation CMTCommentEditListCell

#pragma mark Initializers

- (UIImageView *)picture {
    if (_picture == nil) {
        _picture = [[UIImageView alloc] init];
        _picture.backgroundColor = COLOR(c_clear);
        _picture.layer.masksToBounds = YES;
        _picture.layer.cornerRadius = kCMTCommentEditListCellPictureWidth / 2.0;
    }
    
    return _picture;
}

- (UILabel *)nicknameLabel {
    if (_nicknameLabel == nil) {
        _nicknameLabel = [[UILabel alloc] init];
        _nicknameLabel.backgroundColor = COLOR(c_clear);
        _nicknameLabel.textColor = COLOR(c_32c7c2);
        _nicknameLabel.font = FONT(kCMTCommentEditListCellNicknameLabelFontSize);
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
        _createTimeLabel.font = FONT(13.0);
    }
    
    return _createTimeLabel;
}

- (UILabel *)contentLabel {
    if (_contentLabel == nil) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.backgroundColor = COLOR(c_clear);
        _contentLabel.textColor = COLOR(c_151515);
        _contentLabel.font = FONT(kCMTCommentEditListCellContentLabelFontSize);
        _contentLabel.numberOfLines = 0;
        _contentLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    
    return _contentLabel;
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

- (UILabel *)postTitleLabel {
    if (_postTitleLabel == nil) {
        _postTitleLabel = [[UILabel alloc] init];
        _postTitleLabel.backgroundColor = COLOR(c_clear);
        _postTitleLabel.textColor = COLOR(c_9e9e9e);
        _postTitleLabel.font = FONT(kCMTCommentEditListCellPostTitleLabelFontSize);
        _postTitleLabel.numberOfLines = 0;
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

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self == nil) return nil;
    
    UIView *background = [[UIView alloc] init];
    background.backgroundColor = COLOR(c_ffffff);
    self.backgroundView = background;
    
    [self.contentView addSubview:self.picture];
    [self.contentView addSubview:self.nicknameLabel];
    [self.contentView addSubview:self.createTimeLabel];
    [self.contentView addSubview:self.contentLabel];
    [self.contentView addSubview:self.postTitleView];
    [self.postTitleView addSubview:self.postTitleLabel];
    [self.contentView addSubview:self.bottomLine];
    
    self.cellModel = [[CMTCommentEditListCellModel alloc] init];
    
    return self;
}

#pragma mark LifeCycle

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

+ (CGFloat)cellHeightFromComment:(CMTObject *)comment tableView:(UITableView *)tableView {
    CGFloat cellWidth = tableView.width;
    CMTCommentEditListCellModel *cellModel = [[CMTCommentEditListCellModel alloc] initWithComment:comment indexPath:nil];
    
    // picture
    CGFloat pictureRight = kCMTCommentEditListCellMargen*RATIO + kCMTCommentEditListCellPictureWidth;
    
    CGFloat commentLeftGuide = pictureRight + kCMTCommentEditListCellGap*RATIO;
    CGFloat commentRightGuide = cellWidth - kCMTCommentEditListCellMargen*RATIO;
    CGFloat commentWidth = commentRightGuide - commentLeftGuide;
    
    // nicknameLabel
    CGFloat nicknameMaxWidth = commentWidth - kCMTCommentEditListCellCreateTimeLabelMaxWidth*RATIO - kCMTCommentEditListCellGap*RATIO;
    CGSize nicknameSize = [cellModel.nickname boundingRectWithSize:CGSizeMake(nicknameMaxWidth, CGFLOAT_MAX)
                                                           options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine
                                                        attributes:@{NSFontAttributeName:FONT(kCMTCommentEditListCellNicknameLabelFontSize)}
                                                           context:nil].size;
    CGFloat nicknameLabelBottom = kCMTCommentEditListCellNicknameLabelTop + ceil(nicknameSize.height);
    
    // contentLabel
    CGSize contentSize = [cellModel.content boundingRectWithSize:CGSizeMake(commentWidth, CGFLOAT_MAX)
                                                         options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine
                                                      attributes:@{NSFontAttributeName:FONT(kCMTCommentEditListCellContentLabelFontSize)}
                                                         context:nil].size;
    CGFloat contentLabelBottom = nicknameLabelBottom + kCMTCommentEditListCellVerticalGap + ceil(contentSize.height);
    
    // postTitleView
    CGFloat postTitleMaxWidth = commentWidth - 2.0*kCMTCommentEditListCellPostTitleMargen;
    CGSize postTitleSize = [cellModel.postTitle boundingRectWithSize:CGSizeMake(postTitleMaxWidth, CGFLOAT_MAX)
                                                             options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine
                                                          attributes:@{NSFontAttributeName:FONT(kCMTCommentEditListCellPostTitleLabelFontSize)}
                                                             context:nil].size;
    CGFloat postTitleViewBottom = contentLabelBottom + kCMTCommentEditListCellVerticalGap + ceil(postTitleSize.height) + 2.0*kCMTCommentEditListCellPostTitleMargen;
    
    // cellHeight
    CGFloat cellHeight = postTitleViewBottom + kCMTCommentEditListCellVerticalGap;
    
    return cellHeight;
}

- (void)reloadComment:(CMTObject *)comment tableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
    
    // data
    [self.cellModel reloadComment:comment indexPath:indexPath];
    [self.picture setImageURL:self.cellModel.picture placeholderImage:IMAGE(@"comment_defaultPicture") contentSize:CGSizeMake(kCMTCommentEditListCellPictureWidth, kCMTCommentEditListCellPictureWidth)];
    self.nicknameLabel.text = self.cellModel.nickname;
    self.createTimeLabel.text = self.cellModel.createTime;
    self.contentLabel.text = self.cellModel.content;
    self.postTitleLabel.text = self.cellModel.postTitle;
    
    // layout
    CGFloat cellWidth = tableView.width;
    CGFloat cellHeight = [CMTCommentEditListCell cellHeightFromComment:comment tableView:tableView];
    [self layoutWithCellWidth:cellWidth cellHeight:cellHeight];
}

- (BOOL)layoutWithCellWidth:(CGFloat)cellWidth cellHeight:(CGFloat)cellHeight {
    
    // picture
    self.picture.frame = CGRectMake(kCMTCommentEditListCellMargen*RATIO,
                                    kCMTCommentEditListCellPictureTop,
                                    kCMTCommentEditListCellPictureWidth,
                                    kCMTCommentEditListCellPictureWidth);
    
    CGFloat commentLeftGuide = self.picture.right + kCMTCommentEditListCellGap*RATIO;
    CGFloat commentRightGuide = cellWidth - kCMTCommentEditListCellMargen*RATIO;
    CGFloat commentWidth = commentRightGuide - commentLeftGuide;
    
    // nicknameLabel
    CGFloat nicknameMaxWidth = commentWidth - kCMTCommentEditListCellCreateTimeLabelMaxWidth*RATIO - kCMTCommentEditListCellGap*RATIO;
    CGSize nicknameSize = [self.nicknameLabel.text boundingRectWithSize:CGSizeMake(nicknameMaxWidth, CGFLOAT_MAX)
                                                                options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine
                                                             attributes:@{NSFontAttributeName:self.nicknameLabel.font}
                                                                context:nil].size;
    self.nicknameLabel.frame = CGRectMake(commentLeftGuide,
                                          kCMTCommentEditListCellNicknameLabelTop,
                                          nicknameMaxWidth,
                                          ceil(nicknameSize.height));
    
    // createTimeLabel
    CGSize createTimeSize = [self.createTimeLabel.text boundingRectWithSize:CGSizeMake(kCMTCommentEditListCellCreateTimeLabelMaxWidth*RATIO, CGFLOAT_MAX)
                                                                    options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine
                                                                 attributes:@{NSFontAttributeName:self.createTimeLabel.font}
                                                                    context:nil].size;
    CGFloat createTimeWidth = ceil(createTimeSize.width);
    self.createTimeLabel.frame = CGRectMake(commentRightGuide - createTimeWidth,
                                            kCMTCommentEditListCellCreateTimeLabelTop,
                                            createTimeWidth,
                                            kCMTCommentEditListCellCreateTimeLabelHeight);
    
    // contentLabel
    CGSize contentSize = [self.contentLabel.text boundingRectWithSize:CGSizeMake(commentWidth, CGFLOAT_MAX)
                                                              options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine
                                                           attributes:@{NSFontAttributeName:self.contentLabel.font}
                                                              context:nil].size;
    self.contentLabel.frame = CGRectMake(commentLeftGuide,
                                         self.nicknameLabel.bottom + kCMTCommentEditListCellVerticalGap,
                                         commentWidth,
                                         ceil(contentSize.height));
    
    // postTitleView
    CGFloat postTitleMaxWidth = commentWidth - 2.0*kCMTCommentEditListCellPostTitleMargen;
    CGSize postTitleSize = [self.postTitleLabel.text boundingRectWithSize:CGSizeMake(postTitleMaxWidth, CGFLOAT_MAX)
                                                                  options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine
                                                               attributes:@{NSFontAttributeName:self.postTitleLabel.font}
                                                                  context:nil].size;
    CGFloat postTitleHeight = ceil(postTitleSize.height);
    self.postTitleView.frame = CGRectMake(commentLeftGuide,
                                          self.contentLabel.bottom + kCMTCommentEditListCellVerticalGap,
                                          commentWidth,
                                          postTitleHeight + 2.0*kCMTCommentEditListCellPostTitleMargen);
    self.postTitleLabel.frame = CGRectMake(kCMTCommentEditListCellPostTitleMargen,
                                           kCMTCommentEditListCellPostTitleMargen,
                                           postTitleMaxWidth,
                                           postTitleHeight);
    
    // bottomLine
    self.bottomLine.frame = CGRectMake(0, cellHeight - PIXEL, cellWidth, PIXEL);
    
    return YES;
}

@end
