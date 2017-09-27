//
//  CMTFocusCaption.m
//  MedicalForum
//
//  Created by fenglei on 15/4/8.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

// view
#import "CMTFocusCaption.h"         // header file
#import "CMTTextMarker.h"           // 文字标注
#import "CMTImageMarker.h"          // 图片标注

const CGFloat CMTFocusCaptionDefaultHeight = 40.5;

typedef NS_OPTIONS(NSUInteger, CMTFocusCaptionStyle) {
    CMTFocusCaptionStyleDefault             = 0,
    CMTFocusCaptionStyleWithTextMarker      = 1 << 0,
    CMTFocusCaptionStyleWithImageMarker     = 1 << 1,
    CMTPostListCellStyleWithImageAnswer     = 1 << 2,
    CMTPostListCellStyleWithImageVote       = 1 << 3,
    CMTPostListCellStyleWithImageVideo      = 1 << 4,
    CMTFocusCaptionStyleWithImageAudio      = 1 << 5,
};

@interface CMTFocusCaption ()

// view
@property (nonatomic, strong) CMTTextMarker *textMarker;        // 文字标注
@property (nonatomic, strong) CMTImageMarker *imageMarker;      // 图片标注
@property (nonatomic, strong) CMTImageMarker *answerImageMarker; //问答
@property (nonatomic, strong) CMTImageMarker *voteImageMarker;   //投票
@property (nonatomic, strong) CMTImageMarker *videoImageMarker; //视频
@property (nonatomic, strong) UILabel *titleLabel;              // 标题

@end

@implementation CMTFocusCaption

#pragma mark Initializers

- (CMTImageMarker *)videoImageMarker{
    if (_videoImageMarker == nil) {
        _videoImageMarker = [[CMTImageMarker alloc]init];
        _videoImageMarker.backgroundColor = COLOR(c_clear);
    }
    return _videoImageMarker;
}

- (CMTTextMarker *)textMarker {
    if (_textMarker == nil) {
        _textMarker = [[CMTTextMarker alloc] init];
        _textMarker.backgroundColor = COLOR(c_clear);
    }
    
    return _textMarker;
}

- (CMTImageMarker *)imageMarker {
    if (_imageMarker == nil) {
        _imageMarker = [[CMTImageMarker alloc] init];
        _imageMarker.backgroundColor = COLOR(c_clear);
    }
    
    return _imageMarker;
}

- (CMTImageMarker *)getAnswerImageView {
    if (self.answerImageMarker == nil) {
        self.answerImageMarker = [[CMTImageMarker alloc] init];
        self.answerImageMarker.backgroundColor = COLOR(c_clear);
    }
    
    return self.answerImageMarker;
}
- (CMTImageMarker *)getVoteImageView {
    if (self.voteImageMarker == nil) {
        self.voteImageMarker = [[CMTImageMarker alloc] init];
        self.voteImageMarker.backgroundColor = COLOR(c_clear);
    }
    return self.voteImageMarker;
}


- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = COLOR(c_clear);
        _titleLabel.textColor = COLOR(c_151515);
        _titleLabel.font = FONT(17.0);
    }
    
    return _titleLabel;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self == nil) return nil;
    
    CMTLog(@"%s", __FUNCTION__);
    [self.rac_willDeallocSignal subscribeCompleted:^{
        CMTLog(@"FocusCaption willDeallocSignal");
    }];
    
    self.backgroundColor = COLOR(c_ffffff);
    [self addSubview:self.textMarker];
    [self addSubview:self.imageMarker];
    [self addSubview:[self getAnswerImageView]];
    [self addSubview:[self getVoteImageView]];
    [self addSubview:self.titleLabel];
    [self addSubview:self.videoImageMarker];
    
    return self;
}

#pragma mark LifeCycle

- (void)setFocus:(CMTFocus *)focus {
    if (_focus == focus) return;
    
    _focus = [focus copy];
    
    [self reloadData];
}

// 刷新焦点图说明
- (void)reloadData {
    // data
    if (self.focus == nil) {
        self.hidden = YES;
        return;
    }
    else {
        self.hidden = NO;
    }
    
    // 焦点图说明style
    CMTFocusCaptionStyle focusCaptionStyle = CMTFocusCaptionStyleDefault;
    
    // 是专题
    if ([self.focus.themeStatus isEqual:@"2"]) {
        // 焦点图说明style添加文字标注
        focusCaptionStyle = focusCaptionStyle | CMTFocusCaptionStyleWithTextMarker;
        // 文字标注设置为专题类型
        self.textMarker.markerType = CMTTextMarkerTypeTheme;
    }
    // 不是专题
    else {
//        // 包含PDF
//        if ([self.focus.postAttr isEqual:@"1"]) {
//            // 焦点图说明style添加图片标注
//            focusCaptionStyle = focusCaptionStyle | CMTFocusCaptionStyleWithImageMarker;
//            // 图片标注设置为PDF类型
//            self.imageMarker.markerType = CMTImageMarkerTypePDF;
//        }
        self.imageMarker.hidden = YES;
        self.answerImageMarker.hidden = YES;
        self.voteImageMarker.hidden = YES;
        self.videoImageMarker.hidden = YES;
        // PDF
        if ([self.focus.postAttr isPostAttrPDF]) {
            // 焦点图说明style添加图片标注
            focusCaptionStyle = focusCaptionStyle | CMTFocusCaptionStyleWithImageMarker;
            // 图片标注设置为PDF类型
            self.imageMarker.markerType = CMTImageMarkerTypePDF;
        }
        // 问答
        if ([self.focus.postAttr isPostAttrAnswer]) {
            // 焦点图说明style添加图片标注
            focusCaptionStyle = focusCaptionStyle | CMTPostListCellStyleWithImageAnswer;
             self.answerImageMarker.markerType = CMTImageMarkerTypeAnswer;
        }
        // 投票
        if ([self.focus.postAttr isPostAttrVote]) {
            // 焦点图说明style添加图片标注
            focusCaptionStyle = focusCaptionStyle | CMTPostListCellStyleWithImageVote;
            self.voteImageMarker.markerType = CMTImageMarkerTypeVote;
        }
        // 视频
        if ([self.focus.postAttr isPostAttrVideo]) {
            focusCaptionStyle = focusCaptionStyle | CMTPostListCellStyleWithImageVideo;
        }
        // 音频
        if ([self.focus.postAttr isPostAttrAudio]) {
            focusCaptionStyle = focusCaptionStyle | CMTFocusCaptionStyleWithImageAudio;
        }

        
    }
    
    // 标题
    self.titleLabel.text = self.focus.title;
    
    [self layoutWithFocusCaptionStyle:focusCaptionStyle];
}

- (BOOL)layoutWithFocusCaptionStyle:(CMTFocusCaptionStyle)focusCaptionStyle {
    BOOL withTextMarker = (CMTFocusCaptionStyleWithTextMarker & focusCaptionStyle) != 0;
    BOOL withImageMarker = (CMTFocusCaptionStyleWithImageMarker & focusCaptionStyle) != 0;
    BOOL answerBool = (CMTPostListCellStyleWithImageAnswer & focusCaptionStyle) != 0;
    BOOL voteBool = (CMTPostListCellStyleWithImageVote & focusCaptionStyle) != 0;
    BOOL videoBool = (CMTPostListCellStyleWithImageVideo & focusCaptionStyle) != 0;
    // leftGuide rightGuide
    CGFloat leftGuide = 12.5;
    CGFloat rightGuide = self.width - 12.5;
    
    // textMarker
    self.textMarker.hidden = !withTextMarker;
    if (withTextMarker == YES) {
        self.textMarker.frame = CGRectMake(leftGuide, 13.5, self.textMarker.markerSize.width, self.textMarker.markerSize.height);
        leftGuide = leftGuide + self.textMarker.size.width + 7.0;
    }
    if(withTextMarker){
        self.imageMarker.hidden = YES;
        self.answerImageMarker.hidden = YES;
        self.voteImageMarker.hidden = YES;
        self.videoImageMarker.hidden = YES;
    }else{
        
    //视频
    self.videoImageMarker.hidden = !videoBool;
    if (videoBool) {
            if((![self.focus.postAttr isPostAttrOnlyVideo]&&[self.focus.postAttr isPostAttrAudio])){
                self.videoImageMarker.markerType=CMTImageMarkerTypeAudio;
            }else{
                self.videoImageMarker.markerType=CMTImageMarkerTypeVideo;
            }
            self.videoImageMarker.frame = CGRectMake(leftGuide, 11.0, self.videoImageMarker.markerSize.width, self.videoImageMarker.markerSize.height);
            leftGuide = leftGuide + self.videoImageMarker.width + 7.0;
            
        }
    //问答
    self.answerImageMarker.hidden = !answerBool;
    if(answerBool){
        self.answerImageMarker.frame = CGRectMake(leftGuide, 11.0, self.answerImageMarker.markerSize.width, self.answerImageMarker.markerSize.height);
        leftGuide = leftGuide + self.answerImageMarker.markerSize.width + 7.0;
    }
    //投票
    self.voteImageMarker.hidden = !voteBool;
    if(voteBool){
        
        self.voteImageMarker.markerType = CMTImageMarkerTypeVote;
        self.voteImageMarker.frame = CGRectMake(leftGuide, 11.0, self.voteImageMarker.markerSize.width, self.voteImageMarker.markerSize.height);
        leftGuide =leftGuide + self.voteImageMarker.markerSize.width  + 7.0;
    }
    // imageMarker
    self.imageMarker.hidden = !withImageMarker;
    if (withImageMarker == YES) {
        self.imageMarker.frame = CGRectMake(leftGuide, 11.0, self.imageMarker.markerSize.width, self.imageMarker.markerSize.height);
        leftGuide = leftGuide + self.imageMarker.markerSize.width + 7.0;
    }
   
    }
    
    // titleLabel
    self.titleLabel.frame = CGRectMake(leftGuide, 0.0, rightGuide - leftGuide, self.height);
    
    return YES;
}

@end
