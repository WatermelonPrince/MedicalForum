//
//  CMTGuidePostListCell.m
//  MedicalForum
//
//  Created by fenglei on 15/6/25.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTGuidePostListCell.h"
#import "CMTImageMarker.h"              // 图片标注

static const CGFloat CMTGuidePostListCellDefaultHeight = 87.5;

typedef NS_OPTIONS(NSUInteger, CMTGuidePostListCellStyle) {
    CMTGuidePostListCellStyleDefault            = 0,
    CMTGuidePostListCellStyleContainPDF         = 1 << 0,
    CMTGuidePostListCellStyleContainAnswer      = 1 << 1,
    CMTGuidePostListCellStyleContainVote        = 1 << 2,
};

@interface CMTGuidePostListCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *authorLabel;
@property (nonatomic, strong) UILabel *postTypeLabel;
@property (nonatomic, strong) UIView *separatorLine;
@property (nonatomic, strong) CMTImageMarker *PDFImageMarker;
@property (nonatomic, strong) CMTImageMarker *answerImageMarker;
@property (nonatomic, strong) CMTImageMarker *voteImageMarker;

@end

@implementation CMTGuidePostListCell

#pragma mark Initializers

- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = COLOR(c_clear);
        _titleLabel.textColor = COLOR(c_151515);
        _titleLabel.font = FONT(17.0);
        _titleLabel.numberOfLines = 2;
    }
    
    return _titleLabel;
}

- (UILabel *)authorLabel {
    if (_authorLabel == nil) {
        _authorLabel = [[UILabel alloc] init];
        _authorLabel.backgroundColor = COLOR(c_clear);
        _authorLabel.textColor = COLOR(c_9e9e9e);
        _authorLabel.font = FONT(12.0);
    }
    
    return _authorLabel;
}

- (UILabel *)postTypeLabel {
    if (_postTypeLabel == nil) {
        _postTypeLabel = [[UILabel alloc] init];
        _postTypeLabel.backgroundColor = COLOR(c_clear);
        _postTypeLabel.textColor = COLOR(c_9e9e9e);
        _postTypeLabel.font = FONT(12.0);
    }
    
    return _postTypeLabel;
}

- (UIView *)separatorLine {
    if (_separatorLine == nil) {
        _separatorLine = [[UIView alloc] init];
        _separatorLine.backgroundColor = COLOR(c_eaeaea);
    }
    
    return _separatorLine;
}

- (CMTImageMarker *)PDFImageMarker {
    if (_PDFImageMarker == nil) {
        _PDFImageMarker = [[CMTImageMarker alloc] init];
        _PDFImageMarker.markerType = CMTImageMarkerTypePDF;
        _PDFImageMarker.backgroundColor = COLOR(c_clear);
    }
    
    return _PDFImageMarker;
}

- (CMTImageMarker *)answerImageMarker {
    if (_answerImageMarker == nil) {
        _answerImageMarker = [[CMTImageMarker alloc] init];
        _answerImageMarker.markerType = CMTImageMarkerTypeAnswer;
        _answerImageMarker.backgroundColor = COLOR(c_clear);
    }
    
    return _answerImageMarker;
}

- (CMTImageMarker *)voteImageMarker {
    if (_voteImageMarker == nil) {
        _voteImageMarker = [[CMTImageMarker alloc] init];
        _voteImageMarker.markerType = CMTImageMarkerTypeVote;
        _voteImageMarker.backgroundColor = COLOR(c_clear);
    }
    
    return _voteImageMarker;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self == nil) return nil;
    
    for (UIView *subView in self.contentView.subviews) {
        [subView removeFromSuperview];
    }
    
    UIView *background = [[UIView alloc] init];
    background.backgroundColor = COLOR(c_ffffff);
    self.backgroundView = background;
    
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.authorLabel];
    [self.contentView addSubview:self.postTypeLabel];
    [self.contentView addSubview:self.separatorLine];
    [self.contentView addSubview:self.PDFImageMarker];
    [self.contentView addSubview:self.answerImageMarker];
    [self.contentView addSubview:self.voteImageMarker];
    self.titleLabel.hidden = NO;
    self.authorLabel.hidden = NO;
    self.postTypeLabel.hidden = NO;
    self.separatorLine.hidden = NO;
    self.PDFImageMarker.hidden = YES;
    self.answerImageMarker.hidden = YES;
    self.voteImageMarker.hidden = YES;

    return self;
}

- (void)reloadPost:(CMTPost *)post tableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
    if (post == nil) return;
    
    // data
    self.post = post;
    self.indexPath = indexPath;
    
    // 标题
    self.titleLabel.text = post.title;
    // 作者
    self.authorLabel.text = post.issuingAgency;
    // 文章类型
    self.postTypeLabel.text = post.postType;
    
    // style
    CMTGuidePostListCellStyle cellStyle = CMTGuidePostListCellStyleDefault;
    // 是否有PDF
    if([post.postAttr isPostAttrPDF]){
        cellStyle = cellStyle | CMTGuidePostListCellStyleContainPDF;
    }
    // 是否有问答
    if([post.postAttr isPostAttrAnswer]){
        cellStyle = cellStyle | CMTGuidePostListCellStyleContainAnswer;
    }
    // 是否有投票
    if([post.postAttr isPostAttrVote]){
        cellStyle = cellStyle | CMTGuidePostListCellStyleContainVote;
    }

    // layout
    [self layoutWithCellWidth:tableView.width
                   cellHeight:CMTGuidePostListCellDefaultHeight
                    cellStyle:cellStyle];
}

- (BOOL)layoutWithCellWidth:(CGFloat)cellWidth
                 cellHeight:(CGFloat)cellHeight
                  cellStyle:(CMTGuidePostListCellStyle)cellStyle {
    BOOL containPDF = (CMTGuidePostListCellStyleContainPDF & cellStyle) != 0;
    BOOL containAnswer = (CMTGuidePostListCellStyleContainAnswer & cellStyle) != 0;
    BOOL containVote = (CMTGuidePostListCellStyleContainVote & cellStyle) != 0;
    
    // titleLabel
    self.titleLabel.frame = CGRectMake(10.0*RATIO,
                                       10.0,
                                       cellWidth - 10.0*RATIO*2.0,
                                       42.0);
    
    // leftGuide
    CGFloat leftGuide = 10.0*RATIO;
    // rightGuide
    CGFloat rightGuide = 40.0*RATIO;
    
    // postTypeLabel
    self.postTypeLabel.frame = CGRectMake(cellWidth - rightGuide,
                                          62.0,
                                          rightGuide - 2.0*RATIO,
                                          13.0);
    
    // PDF
    if (containPDF) {
        rightGuide += 5.5*RATIO + self.PDFImageMarker.markerSize.width;
    }
    self.PDFImageMarker.visible = containPDF;
    self.PDFImageMarker.frame = CGRectMake(cellWidth - rightGuide,
                                           59.5,
                                           self.PDFImageMarker.markerSize.width,
                                           self.PDFImageMarker.markerSize.height);
    
    // Answer
    if (containAnswer) {
        rightGuide += 5.5*RATIO + self.answerImageMarker.markerSize.width;
    }
    self.answerImageMarker.visible = containAnswer;
    self.answerImageMarker.frame = CGRectMake(cellWidth - rightGuide,
                                              59.5,
                                              self.answerImageMarker.markerSize.width,
                                              self.answerImageMarker.markerSize.height);
    
    // Vote
    if (containVote) {
        rightGuide += 5.5*RATIO + self.voteImageMarker.markerSize.width;
    }
    self.voteImageMarker.visible = containVote;
    self.voteImageMarker.frame = CGRectMake(cellWidth - rightGuide,
                                            59.5,
                                            self.voteImageMarker.markerSize.width,
                                            self.voteImageMarker.markerSize.height);
    
    // authorLabel
    self.authorLabel.frame = CGRectMake(leftGuide,
                                        62.0,
                                        cellWidth - leftGuide - rightGuide - 5.5*RATIO,
                                        13.0);
    
    // separatorLine
    self.separatorLine.frame = CGRectMake(0.0, 87.0 - PIXEL, cellWidth, PIXEL);
    
    return YES;
}

@end
