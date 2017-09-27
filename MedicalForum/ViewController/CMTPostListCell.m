//
//  CMTPostListCell.m
//  MedicalForum
//
//  Created by fenglei on 14/12/19.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTPostListCell.h"             // header file
#import "CMTTextMarker.h"               // 文字标注
#import "CMTImageMarker.h"              // 图片标注

static const CGFloat CMTPostListCellDefaultHeight = 87.5;

typedef NS_OPTIONS(NSUInteger, CMTPostListCellStyle) {
    CMTPostListCellStyleDefault             = 0,
    CMTPostListCellStyleNoHeat              = 1 << 0,
    CMTPostListCellStyleNoSmallPic          = 1 << 1,
    CMTPostListCellStyleWithTextMarker      = 1 << 2,
    CMTPostListCellStyleWithImageMarker     = 1 << 3,
    CMTPostListCellStyleWithImageAnswer     = 1 << 4,
    CMTPostListCellStyleWithImageVote       = 1 << 5,
    CMTPostListCellStyleWithVideoMarker     = 1 << 6,
};

@interface CMTPostListCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) CMTTextMarker *textMarker;
@property (nonatomic, strong) CMTTextMarker *topMarker;
@property (nonatomic, strong) UIImageView *heatIcon;
@property (nonatomic, strong) UILabel *heatLabel;
@property (nonatomic, strong) UILabel *authorLabel;
@property (nonatomic, strong) UILabel *postTypeLabel;
@property (nonatomic, strong) CMTImageMarker *imageMarker;
@property (nonatomic, strong) CMTImageMarker *answerImageMarker;
@property (nonatomic, strong) CMTImageMarker *voteImageMarker;
@property (nonatomic, strong) CMTImageMarker *videoImageMarker;
@property (nonatomic, strong) UIImageView *smallPic;
@property (nonatomic, strong) UIView *separatorLine;
@property (nonatomic, strong) UIView *bottomLine;

@end

@implementation CMTPostListCell

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

- (CMTTextMarker *)textMarker {
    if (_textMarker == nil) {
        _textMarker = [[CMTTextMarker alloc] init];
        _textMarker.markerType=CMTTextMarkerTypeTheme;
        _textMarker.backgroundColor = COLOR(c_clear);
    }
    
    return _textMarker;
}
- (CMTTextMarker *)topMarker {
    if (_topMarker == nil) {
        _topMarker = [[CMTTextMarker alloc] init];
        _topMarker.markerType=CMTTextMarkerTypeTop;
        _topMarker.backgroundColor =[UIColor colorWithHexString:@"#30c2a9"];
    }
    return _topMarker;
}

- (UIImageView *)heatIcon {
    if (_heatIcon == nil) {
        _heatIcon = [[UIImageView alloc] init];
        _heatIcon.backgroundColor = COLOR(c_clear);
        _heatIcon.image = IMAGE(@"hot_icon");
    }
    
    return _heatIcon;
}

- (UILabel *)heatLabel {
    if (_heatLabel == nil) {
        _heatLabel = [[UILabel alloc] init];
        _heatLabel.backgroundColor = COLOR(c_clear);
        _heatLabel.textColor = COLOR(c_9e9e9e);
        _heatLabel.font = FONT(13.0);
    }
    
    return _heatLabel;
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

- (CMTImageMarker *)imageMarker {
    if (_imageMarker == nil) {
        _imageMarker = [[CMTImageMarker alloc] init];
        _imageMarker.markerType = CMTImageMarkerTypePDF;
        _imageMarker.backgroundColor = COLOR(c_clear);
    }
    
    return _imageMarker;
}

- (CMTImageMarker *)videoImageMarker{
    if (_videoImageMarker == nil) {
        self.videoImageMarker = [[CMTImageMarker alloc]init];
        self.videoImageMarker.markerType = CMTImageMarkerTypeVideo;
        self.videoImageMarker.backgroundColor = COLOR(c_clear);
    }
    return _videoImageMarker;
}

- (CMTImageMarker *)getAnswerImageView {
    if (self.answerImageMarker == nil) {
        self.answerImageMarker = [[CMTImageMarker alloc] init];
        self.answerImageMarker.markerType = CMTImageMarkerTypeAnswer;
        self.answerImageMarker.backgroundColor = COLOR(c_clear);
    }
    
    return self.answerImageMarker;
}

- (CMTImageMarker *)getVoteImageView {
    if (self.voteImageMarker == nil) {
        self.voteImageMarker = [[CMTImageMarker alloc] init];
        self.voteImageMarker.markerType = CMTImageMarkerTypeVote;
        self.voteImageMarker.backgroundColor = COLOR(c_clear);
    }
    return self.voteImageMarker;
}

- (UIImageView *)smallPic {
    if (_smallPic == nil) {
        _smallPic = [[UIImageView alloc] init];
        _smallPic.backgroundColor = COLOR(c_clear);
        _smallPic.clipsToBounds = YES;
        _smallPic.contentMode = UIViewContentModeScaleAspectFill;
    }
    
    return _smallPic;
}

- (UIView *)separatorLine {
    if (_separatorLine == nil) {
        _separatorLine = [[UIView alloc] init];
        _separatorLine.backgroundColor = COLOR(c_eaeaea);
    }
    return _separatorLine;
}

- (UIView *)bottomLine {
    if (_bottomLine == nil) {
        _bottomLine = [[UIView alloc] init];
        _bottomLine.backgroundColor = COLOR(c_9e9e9e);
    }
    
    return _bottomLine;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self == nil) return nil;
    
    UIView *background = [[UIView alloc] init];
    background.backgroundColor = COLOR(c_ffffff);
    self.backgroundView = background;
    
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.textMarker];
    [self.contentView addSubview:self.topMarker];
    [self.contentView addSubview:self.heatIcon];
    [self.contentView addSubview:self.heatLabel];
    [self.contentView addSubview:self.authorLabel];
    [self.contentView addSubview:self.postTypeLabel];
    [self.contentView addSubview:self.imageMarker];
    [self.contentView addSubview:[self getAnswerImageView]];
    [self.contentView addSubview:[self getVoteImageView]];
    [self.contentView addSubview:self.videoImageMarker];
    [self.contentView addSubview:self.smallPic];
    [self.contentView addSubview:self.separatorLine];
    [self.contentView addSubview:self.bottomLine];
    self.textMarker.hidden = YES;
    self.topMarker.hidden=YES;
    self.imageMarker.hidden = YES;
    self.answerImageMarker.hidden = YES;
    self.voteImageMarker.hidden = YES;
    self.bottomLine.hidden = YES;
    self.authorLabel.hidden = YES;
    
    return self;
}

#pragma mark LifeCycle

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)reloadPost:(CMTPost *)post tableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
    if (post == nil) return;
     // data
    self.post = post;
    self.indexPath = indexPath;
    
    // 标题
    self.titleLabel.text = post.title;
    // 专题
    if ([post.themeStatus isEqual:@"2"]) {
        self.textMarker.markerType = CMTTextMarkerTypeTheme;
    }
    // 热度
    self.heatLabel.text = post.heat;
    // 作者
    self.authorLabel.text = post.author;
    // 文章类型
    self.postTypeLabel.text =self.post.module.isPostModuleCase?@"":post.postType;
    // 缩略图
    UIImage *placeholderImage = BEMPTY(post.smallPic) ? IMAGE(@"placeholder_list_none") : IMAGE(@"placeholder_list_loading");
    [self.smallPic setImageURL:post.smallPic placeholderImage:placeholderImage contentSize:CGSizeMake(80.0, 60.0)];
    
    // style
    CMTPostListCellStyle cellStyle = CMTPostListCellStyleDefault;
    //
    // 是否为专题
    if ([post.themeStatus isEqual:@"2"]) {
        cellStyle = cellStyle | CMTPostListCellStyleWithTextMarker;
    }
    // 是否有PDF
    if([post.postAttr isPostAttrPDF]){
         cellStyle = cellStyle | CMTPostListCellStyleWithImageMarker;
    }
    // 是否有问答
    if([post.postAttr isPostAttrAnswer]){
        cellStyle = cellStyle | CMTPostListCellStyleWithImageAnswer;
    }
    // 是否有投票
    if([post.postAttr isPostAttrVote]){
        cellStyle = cellStyle | CMTPostListCellStyleWithImageVote;
    }
    // 是否有video
    if([post.postAttr isPostAttrVideo]){
        cellStyle = cellStyle | CMTPostListCellStyleWithVideoMarker;
    }
    // 是否有缩略图
    // 目前版本所有文章都有缩略图
    // 无大图文章 缩略图用IMAGE(@"placeholder_list_none")
//    if (BEMPTY(post.smallPic)) {
//        cellStyle = cellStyle | CMTPostListCellStyleNoSmallPic;
//    }
    
    // layout
    CGFloat cellWidth = tableView.width;
    [self layoutWithCellWidth:cellWidth cellHeight:CMTPostListCellDefaultHeight cellStyle:cellStyle];
    
    // bottomLine
    BOOL lastRowInSection = NO;
    BOOL lastRowInTableView = NO;
    CMTCALL(
            NSInteger sections = [tableView.dataSource numberOfSectionsInTableView:tableView];
            NSInteger rows = [tableView.dataSource tableView:tableView numberOfRowsInSection:indexPath.section];
            lastRowInSection = (indexPath.row == rows - 1);
            lastRowInTableView = (indexPath.section == sections - 1) && lastRowInSection;
            )
    self.separatorLine.hidden = lastRowInSection;
    self.bottomLine.hidden = !lastRowInSection;
    if (lastRowInTableView) {
        self.separatorLine.hidden = NO;
        self.bottomLine.hidden = YES;
    }
}

- (BOOL)layoutWithCellWidth:(CGFloat)cellWidth
                 cellHeight:(CGFloat)cellHeight
                  cellStyle:(CMTPostListCellStyle)cellStyle {
    BOOL noImage = (CMTPostListCellStyleNoSmallPic & cellStyle) != 0;
    BOOL withTextMarker = (CMTPostListCellStyleWithTextMarker & cellStyle) != 0;
    BOOL withImageMarker = (CMTPostListCellStyleWithImageMarker & cellStyle) != 0;
    BOOL answerBool = (CMTPostListCellStyleWithImageAnswer & cellStyle) != 0;
    BOOL voteBool = (CMTPostListCellStyleWithImageVote & cellStyle) != 0;
    BOOL videoBool = (CMTPostListCellStyleWithVideoMarker & cellStyle)!= 0;
    
    // titleLabel
    CGFloat titleWidth =SCREEN_WIDTH-14.0-100-14.0;
    if (noImage == YES) {
        self.titleLabel.frame = CGRectMake(14.0, 10.0, titleWidth+100, 42.0);
    }
    else {
        self.titleLabel.frame = CGRectMake(14.0, 10.0, titleWidth, 42.0);
    }
    
    // leftGuide
    CGFloat leftGuide = 15.0;
    
    // textMarker
    self.topMarker.hidden=!self.post.istop.boolValue;
    if(self.post.istop.boolValue){
        self.topMarker.frame = CGRectMake(leftGuide, 61.5, self.topMarker.markerSize.width, self.topMarker.markerSize.height);
        leftGuide = self.topMarker.right + 7.0;
    }
     self.textMarker.hidden = !withTextMarker;
    if (withTextMarker == YES) {
        self.textMarker.frame = CGRectMake(leftGuide, 61.5, self.textMarker.markerSize.width, self.textMarker.markerSize.height);
        leftGuide = self.textMarker.right + 7.0;
    }
    
    // heat
    // heatIcon
    self.heatIcon.frame = CGRectMake(leftGuide, 61.0 + (13.5/2 - 5), 20, 10);
    // heatLabel
    self.heatLabel.frame = CGRectMake(self.heatIcon.right + 2.0, 62.0,88.0, 12.0);
    //self.heatIcon.centerY = self.textMarker.centerY;
    self.heatLabel.centerY = self.heatIcon.centerY;
    
    // authorLabel
    self.authorLabel.frame = CGRectMake(self.heatLabel.right + 1.0, 62.0, 58.0, 13.0);
    
    // postTypeLabel
    CGSize postTypeSize = [self.post.postType boundingRectWithSize:CGSizeMake(40.0, CGFLOAT_MAX)
                                                           options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine
                                                        attributes:@{NSFontAttributeName:self.postTypeLabel.font}
                                                           context:nil].size;
    CGFloat postTypeWidth =self.post.module.isPostModuleCase?0:ceil(postTypeSize.width);
    self.postTypeLabel.frame = CGRectMake((14.0 + titleWidth) - postTypeWidth, 62.0, postTypeWidth, 13.0);
    
    // imageMarker
    self.imageMarker.hidden = !withImageMarker;
    self.imageMarker.frame = CGRectMake(self.postTypeLabel.left - 5.5 - self.imageMarker.markerSize.width, 59.5, self.imageMarker.markerSize.width, self.imageMarker.markerSize.height);
    
    //问答
    self.answerImageMarker.hidden = !answerBool;
    CGFloat x = 0.0f;
    if(withImageMarker){
        //显示pdf
        x = self.postTypeLabel.left - 5.5 - self.imageMarker.markerSize.width - 5.5- self.answerImageMarker.markerSize.width;
    }else{
        //不显示pdf
        x = self.postTypeLabel.left - 5.5 - self.answerImageMarker.markerSize.width;
    }
    self.answerImageMarker.markerType = CMTImageMarkerTypeAnswer;
    self.answerImageMarker.frame = CGRectMake(x, 59.5, self.answerImageMarker.markerSize.width, self.answerImageMarker.markerSize.height);
    
    //投票
    self.voteImageMarker.hidden = !voteBool;
    x = 0.0f;
    if(withImageMarker){
        //显示pdf
        x = self.postTypeLabel.left - 5.5 - self.imageMarker.markerSize.width - 5.5- self.voteImageMarker.markerSize.width;
    }else{
        //不显示pdf
        x = self.postTypeLabel.left - 5.5 - self.voteImageMarker.markerSize.width;
    }
    self.voteImageMarker.markerType = CMTImageMarkerTypeVote;
    self.voteImageMarker.frame = CGRectMake(x, 59.5, self.voteImageMarker.markerSize.width, self.voteImageMarker.markerSize.height);
    //视频
    self.videoImageMarker.hidden = !videoBool;
    x = 0.0f;
    if (withImageMarker) {
        if (answerBool||voteBool) {
            x = self.postTypeLabel.left - 5.5*3 - self.imageMarker.markerSize.width*3;
        }else{
            x = self.postTypeLabel.left - 5.5*2 - self.imageMarker.markerSize.width*2;
        }
    }else{
        if (answerBool || voteBool) {
            x = self.postTypeLabel.left - 5.5*2 - self.imageMarker.markerSize.width*2;
        }else{
            x = self.postTypeLabel.left - 5.5 - self.imageMarker.markerSize.width;
        }
    }
    if((![self.post.postAttr isPostAttrOnlyVideo]&&[self.post.postAttr isPostAttrAudio])){
        self.videoImageMarker.markerType=CMTImageMarkerTypeAudio;
    }else{
        self.videoImageMarker.markerType=CMTImageMarkerTypeVideo;
    }
    self.videoImageMarker.frame = CGRectMake(x, 59.5, self.voteImageMarker.markerSize.width, self.voteImageMarker.markerSize.height);
    // smallPic
    self.smallPic.frame = CGRectMake(self.titleLabel.right+20, 13.5, 80, 60);
    self.smallPic.hidden = noImage;
    
    // separatorLine
    self.separatorLine.frame = CGRectMake(10.0, 87.0 - PIXEL, cellWidth - 10.0, PIXEL);
    
    // bottomLine
    self.bottomLine.frame = CGRectMake(0.0, cellHeight - PIXEL, cellWidth, PIXEL);
    
    return YES;
}

@end
