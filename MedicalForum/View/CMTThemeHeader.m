//
//  CMTThemeHeader.m
//  MedicalForum
//
//  Created by fenglei on 15/4/18.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

// view
#import "CMTThemeHeader.h"          // header file

static const CGFloat CMTThemeHeaderHeightWidthRatio = 9.0 / 16.0;
static const CGFloat CMTThemeHeaderContentTitleHeight = 27.0;
static const CGFloat CMTThemeHeaderToolBarHeight = 40.0;
static const CGFloat CMTThemeHeaderToolBarSeparatorMargenVertical = 3.5;
static const CGFloat CMTThemeHeaderToolBarImageHeight = 20.0;
static const CGFloat CMTThemeHeaderToolBarImageGap = 11.0;
static const CGFloat CMTThemeHeaderToolBarButtonWidth = 100.0;
static const CGFloat CMTThemeHeaderDescriptionMargenVertical = 11.0;
static const CGFloat CMTThemeHeaderDescriptionMargenHorizontal = 12.0;
static const CGFloat CMTThemeHeaderShowContentButtonWidth = 87.0;
static const CGFloat CMTThemeHeaderShowContentButtonHeight = 25.0;
static const CGFloat CMTThemeHeaderShowContentButtonGapBottom = 11.0;
static const CGFloat CMTThemeHeaderBottomBlankHeight = 6.0;
static const CGFloat CMTThemeHeaderShadowHeight = 5.0 / 3.0;

@interface CMTThemeHeader ()

// view
// content
@property (nonatomic, strong) UIImageView *pictureView;
@property (nonatomic, strong) UILabel *contentTitle;

// toolBar
@property (nonatomic, strong) UIView *toolBar;
@property (nonatomic, strong) UIView *toolBarShadow;
@property (nonatomic, strong) UIView *toolBarSeparator;
// share
@property (nonatomic, strong) UIImageView *shareImage;
@property (nonatomic, strong) UIButton *shareButton;
// help
@property (nonatomic, strong) UIImageView *helpImage;
@property (nonatomic, strong) UIButton *helpButton;
// focus
@property (nonatomic, strong, readwrite) UIImageView *focusImage;
@property (nonatomic, strong, readwrite) UIButton *focusButton;

// description
@property (nonatomic, strong) UIView *descriptionView;
@property (nonatomic, strong) UILabel *descriptionLabel;
@property (nonatomic, strong) UIButton *showContentButton;

// shadow & blank
@property (nonatomic, strong) UIView *bottomBlank;
@property (nonatomic, strong) UIImageView *bottomShadow;
@property (nonatomic, strong) UIView *bottomLine;

// data
@property (nonatomic, copy, readwrite) CMTTheme *theme;
@property (nonatomic, copy, readwrite) NSString *disease;
@property (nonatomic, copy, readwrite) NSString *module;

@property (nonatomic, assign) BOOL initialization;
@property (nonatomic, assign) CGFloat descriptionHeight;
@property (nonatomic, assign) CGFloat descriptionLabelWidth;
@property (nonatomic, assign) CGFloat descriptionLabelHeight;
@property (nonatomic, assign) CGFloat descriptionViewHeight;
@property (nonatomic, assign) BOOL needShowContentButton;

@end

@implementation CMTThemeHeader

#pragma mark Initializers

- (UIImageView *)pictureView {
    if (_pictureView == nil) {
        _pictureView = [[UIImageView alloc] init];
        _pictureView.backgroundColor = COLOR(c_clear);
        _pictureView.clipsToBounds = YES;
        _pictureView.contentMode = UIViewContentModeScaleAspectFill;
    }
    
    return _pictureView;
}

- (UILabel *)contentTitle {
    if (_contentTitle == nil) {
        _contentTitle = [[UILabel alloc] init];
        _contentTitle.backgroundColor = COLOR(c_clear);
        _contentTitle.textColor = COLOR(c_ffffff);
        _contentTitle.font = FONT(26.0);
        _contentTitle.shadowColor = COLOR(c_1515157F);
        _contentTitle.shadowOffset = CGSizeMake(0.0, 0.5);
        _contentTitle.textAlignment = NSTextAlignmentCenter;
    }
    
    return _contentTitle;
}

- (UIView *)toolBar {
    if (_toolBar == nil) {
        _toolBar = [[UIView alloc] init];
        _toolBar.backgroundColor = COLOR(c_clear);
    }
    
    return _toolBar;
}

- (UIView *)toolBarShadow {
    if (_toolBarShadow == nil) {
        _toolBarShadow = [[UIView alloc] init];
        _toolBarShadow.backgroundColor = COLOR(c_151515);
        _toolBarShadow.alpha = 0.35;
    }
    
    return _toolBarShadow;
}


- (UIView *)toolBarSeparator {
    if (_toolBarSeparator == nil) {
        _toolBarSeparator = [[UIView alloc] init];
        _toolBarSeparator.backgroundColor = COLOR(c_ffffff);
        _toolBarSeparator.alpha = 1.0;
    }
    
    return _toolBarSeparator;
}

- (UIImageView *)shareImage {
    if (_shareImage == nil) {
        _shareImage = [[UIImageView alloc] init];
        _shareImage.backgroundColor = COLOR(c_clear);
        _shareImage.image = IMAGE(@"theme_share");
    }
    
    return _shareImage;
}

- (UIButton *)shareButton {
    if (_shareButton == nil) {
        _shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _shareButton.backgroundColor = COLOR(c_clear);
        [_shareButton setTitleColor:COLOR(c_ffffff) forState:UIControlStateNormal];
        [_shareButton setTitleColor:COLOR(c_ffffff) forState:UIControlStateHighlighted];
        _shareButton.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
        [_shareButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0, CMTThemeHeaderToolBarImageGap*3.0, 0.0, 0.0)];
        [_shareButton setTitle:@"分享" forState:UIControlStateNormal];
        [_shareButton addTarget:self action:@selector(shareButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _shareButton;
}

- (UIImageView *)helpImage {
    if (_helpImage == nil) {
        _helpImage = [[UIImageView alloc] init];
        _helpImage.backgroundColor = COLOR(c_clear);
        _helpImage.image = IMAGE(@"theme_help");
    }
    
    return _helpImage;
}

- (UIButton *)helpButton {
    if (_helpButton == nil) {
        _helpButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _helpButton.backgroundColor = COLOR(c_clear);
        [_helpButton setTitleColor:COLOR(c_ffffff) forState:UIControlStateNormal];
        [_helpButton setTitleColor:COLOR(c_ffffff) forState:UIControlStateHighlighted];
        _helpButton.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
        [_helpButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0, CMTThemeHeaderToolBarImageGap*3.0, 0.0, 0.0)];
        [_helpButton setTitle:@"求助" forState:UIControlStateNormal];
        [_helpButton addTarget:self action:@selector(helpButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _helpButton;
}

- (UIImageView *)focusImage {
    if (_focusImage == nil) {
        _focusImage = [[UIImageView alloc] init];
        _focusImage.backgroundColor = COLOR(c_clear);
        _focusImage.image = IMAGE(@"theme_focus");
    }
    
    return _focusImage;
}

- (UIButton *)focusButton {
    if (_focusButton == nil) {
        _focusButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _focusButton.backgroundColor = COLOR(c_clear);
        [_focusButton setTitleColor:COLOR(c_ffffff) forState:UIControlStateNormal];
        [_focusButton setTitleColor:COLOR(c_ffffff) forState:UIControlStateHighlighted];
        _focusButton.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
        [_focusButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0, CMTThemeHeaderToolBarImageGap*3.0, 0.0, 0.0)];
        [_focusButton setTitle:@"订阅" forState:UIControlStateNormal];
        [_focusButton addTarget:self action:@selector(focusButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _focusButton;
}

- (UIView *)descriptionView {
    if (_descriptionView == nil) {
        _descriptionView = [[UIView alloc] init];
        _descriptionView.backgroundColor = COLOR(c_ffffff);
    }
    
    return _descriptionView;
}

- (UILabel *)descriptionLabel {
    if (_descriptionLabel == nil) {
        _descriptionLabel = [[UILabel alloc] init];
        _descriptionLabel.backgroundColor = COLOR(c_clear);
        _descriptionLabel.textColor = COLOR(c_151515);
        _descriptionLabel.font = FONT(13.5);
        _descriptionLabel.numberOfLines = 3;
    }
    
    return _descriptionLabel;
}

- (UIButton *)showContentButton {
    if (_showContentButton == nil) {
        _showContentButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _showContentButton.backgroundColor = COLOR(c_clear);
        [_showContentButton setTitleColor:COLOR(c_ababab) forState:UIControlStateNormal];
        [_showContentButton setTitleColor:COLOR(c_ababab) forState:UIControlStateHighlighted];
        [_showContentButton setTitle:@"全文" forState:UIControlStateNormal];
        [_showContentButton setTitle:@"全文" forState:UIControlStateHighlighted];
        _showContentButton.titleLabel.font = FONT(12.0);
        _showContentButton.layer.borderColor = COLOR(c_ababab).CGColor;
        _showContentButton.layer.borderWidth = PIXEL;
        _showContentButton.layer.cornerRadius = 2.5;
        _showContentButton.layer.masksToBounds = YES;
    }
    
    return _showContentButton;
}

- (UIView *)bottomBlank {
    if (_bottomBlank == nil) {
        _bottomBlank = [[UIView alloc] init];
        _bottomBlank.backgroundColor = COLOR(c_e7e7e7);
    }
    
    return _bottomBlank;
}

- (UIImageView *)bottomShadow {
    if (_bottomShadow == nil) {
        _bottomShadow = [[UIImageView alloc] init];
        _bottomShadow.backgroundColor = COLOR(c_clear);
        _bottomShadow.image = IMAGE(@"shadow_bottom");
    }
    
    return _bottomShadow;
}

- (UIView *)bottomLine {
    if (_bottomLine == nil) {
        _bottomLine = [[UIView alloc] init];
        _bottomLine.backgroundColor = COLOR(c_eaeaea);
    }
    
    return _bottomLine;
}

// 专题顶部图片宽高比为16:9
// 通过屏幕宽 计算出专题顶部图片高 并以此得专题顶部总高
- (CGFloat)heightForWidth:(CGFloat)width andDescription:(NSString *)description {
    
    // descriptionHeight
    self.descriptionLabelWidth = width - CMTThemeHeaderDescriptionMargenHorizontal*RATIO*2.0;
    CGSize descriptionSize = [description boundingRectWithSize:CGSizeMake(self.descriptionLabelWidth, CGFLOAT_MAX)
                                                       options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine
                                                    attributes:@{NSFontAttributeName:self.descriptionLabel.font}
                                                       context:nil].size;
    self.descriptionHeight = ceil(descriptionSize.height);
    
    // descriptionViewHeight
    if (self.descriptionHeight > 49.0) {
        self.descriptionLabelHeight = 49.0;
        self.descriptionViewHeight = self.descriptionLabelHeight + CMTThemeHeaderDescriptionMargenVertical*2.0 + CMTThemeHeaderShowContentButtonHeight + CMTThemeHeaderShowContentButtonGapBottom;
        self.needShowContentButton = YES;
    }
    else {
        self.descriptionLabelHeight = self.descriptionHeight;
        self.descriptionViewHeight = self.descriptionLabelHeight + CMTThemeHeaderDescriptionMargenVertical*2.0;
        self.needShowContentButton = NO;
    }
    
    return width * CMTThemeHeaderHeightWidthRatio + self.descriptionViewHeight + CMTThemeHeaderBottomBlankHeight;
}

// '单个疾病标签'背景宽高比为16:9
- (CGFloat)heightForWidth:(CGFloat)width andDisease:(NSString *)disease {
    
    // descriptionHeight
    self.descriptionLabelWidth = 0.0;
    self.descriptionHeight = 0.0;
    
    // descriptionViewHeight
    self.descriptionLabelHeight = 0.0;
    self.descriptionViewHeight = 0.0;
    self.needShowContentButton = NO;
    
    return width * CMTThemeHeaderHeightWidthRatio;
}

- (instancetype)initWithTheme:(CMTTheme *)theme
              andLimitedWidth:(CGFloat)limitedWidth {
    
    self = [super init];
    if (self == nil) return nil;
    CMTLog(@"%s", __FUNCTION__);
    
    self.theme = theme;
    self.frame = CGRectMake(0.0, 0.0, limitedWidth, [self heightForWidth:limitedWidth
                                                          andDescription:self.theme.descriptionString]);
    self.backgroundColor = COLOR(c_clear);
    [self reloadData];
    
    return self;
}

- (instancetype)initWithDisease:(NSString *)disease
                         module:(NSString *)module
                andLimitedWidth:(CGFloat)limitedWidth {
    
    self = [super init];
    if (self == nil) return nil;
    CMTLog(@"%s", __FUNCTION__);
    
    self.disease = disease;
    self.module = module;
    self.frame = CGRectMake(0.0, 0.0, limitedWidth, [self heightForWidth:limitedWidth
                                                              andDisease:self.disease]);
    self.backgroundColor = COLOR(c_6ABAB8);
    [self reloadData];
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self == nil) return nil;
    
    CMTLog(@"%s", __FUNCTION__);
    @weakify(self);
    [self.rac_willDeallocSignal subscribeCompleted:^{
        CMTLog(@"ThemeHeader willDeallocSignal");
    }];
    
    // 初始化frame
    [[RACObserve(self, frame)
      deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        @strongify(self);
        if (self.frame.size.height > 0 && !self.initialization) {
            self.initialization = [self initializeWithSize:self.frame.size];
        }
    }];
    
    // 点击全文
    [[self.showContentButton
      rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        
        // 显示全文 隐藏按钮
        self.descriptionLabelHeight = self.descriptionHeight;
        self.descriptionViewHeight = self.descriptionLabelHeight + CMTThemeHeaderDescriptionMargenVertical*2.0;
        self.needShowContentButton = NO;
        
        // descriptionView
        self.descriptionView.height = self.descriptionViewHeight;
        
        // descriptionLabel
        self.descriptionLabel.height = self.descriptionLabelHeight;
        self.descriptionLabel.numberOfLines = 0;
        
        // showContentButton
        self.showContentButton.hidden = YES;
        
        // bottomBlank
        self.bottomBlank.top = self.descriptionView.bottom;
        
        // self
        self.height = self.bottomBlank.bottom;
        
        // delegate
        if ([self.delegate respondsToSelector:@selector(themeHeaderShowContentButtonTouched:)]) {
            [self.delegate themeHeaderShowContentButtonTouched:self];
        }
    }];

    return self;
}

- (BOOL)initializeWithSize:(CGSize)size {
    CMTLog(@"%s", __FUNCTION__);
    
    // pictureView
    CGFloat pictureViewHeight = self.width * CMTThemeHeaderHeightWidthRatio;
    CGFloat pictureViewBottom = 0.0 + pictureViewHeight;
    if (self.theme != nil) {
        [self.pictureView builtinContainer:self
                                  WithLeft:0.0
                                       Top:0.0
                                     Width:self.width
                                    Height:pictureViewHeight];
    }
    
    // contentTitle
    if (self.disease != nil) {
        CGFloat contentTitleTop = (pictureViewHeight - CMTThemeHeaderToolBarHeight - CMTThemeHeaderContentTitleHeight)/2.0;
        [self.contentTitle builtinContainer:self
                                   WithLeft:0.0
                                        Top:contentTitleTop
                                      Width:self.width
                                     Height:CMTThemeHeaderContentTitleHeight];
    }
    
    // toolBar
    CGFloat toolBarTop = pictureViewBottom - CMTThemeHeaderToolBarHeight;
    [self.toolBar builtinContainer:self
                          WithLeft:0.0
                               Top:toolBarTop
                             Width:self.width
                            Height:CMTThemeHeaderToolBarHeight];
    // toolBarShadow
    [self.toolBarShadow builtinContainer:self.toolBar
                                WithLeft:0.0
                                     Top:0.0
                                   Width:self.toolBar.width
                                  Height:self.toolBar.height];
    // toolBarSeparator
    CGFloat toolBarSeparatorHeight = self.toolBarShadow.height - 2.0*CMTThemeHeaderToolBarSeparatorMargenVertical;
    [self.toolBarSeparator builtinContainer:self.toolBarShadow
                                   WithLeft:0.0
                                        Top:CMTThemeHeaderToolBarSeparatorMargenVertical
                                      Width:PIXEL
                                     Height:toolBarSeparatorHeight];
    self.toolBarSeparator.centerX = self.toolBarShadow.width/2.0;
    
    // share
    if (self.theme != nil) {
        // shareButton
        CGFloat shareButtonLeft = (self.width/2.0 - CMTThemeHeaderToolBarButtonWidth)/2.0;
        [self.shareButton builtinContainer:self.toolBar
                                  WithLeft:shareButtonLeft
                                       Top:0.0
                                     Width:CMTThemeHeaderToolBarButtonWidth
                                    Height:self.toolBar.height];
        // shareImage
        [self.shareImage builtinContainer:self.toolBar
                                 WithLeft:self.shareButton.left + CMTThemeHeaderToolBarImageGap
                                      Top:0.0
                                    Width:CMTThemeHeaderToolBarImageHeight
                                   Height:CMTThemeHeaderToolBarImageHeight];
        self.shareImage.centerY = self.toolBar.height/2.0;
    }
    
    // help
    if (self.disease != nil && self.module.isPostModuleGuide) {
        // helpButton
        CGFloat helpButtonLeft = (self.width/2.0 - CMTThemeHeaderToolBarButtonWidth)/2.0;
        [self.helpButton builtinContainer:self.toolBar
                                 WithLeft:helpButtonLeft
                                      Top:0.0
                                    Width:CMTThemeHeaderToolBarButtonWidth
                                   Height:self.toolBar.height];
        // helpImage
        [self.helpImage builtinContainer:self.toolBar
                                WithLeft:self.helpButton.left + CMTThemeHeaderToolBarImageGap
                                     Top:0.0
                                   Width:CMTThemeHeaderToolBarImageHeight
                                  Height:CMTThemeHeaderToolBarImageHeight];
        self.helpImage.centerY = self.toolBar.height/2.0;
    }
    
    // focus
    // focusButton
    CGFloat focusButtonLeft = self.width/2.0 + (self.width/2.0 - CMTThemeHeaderToolBarButtonWidth)/2.0;
    [self.focusButton builtinContainer:self.toolBar
                              WithLeft:focusButtonLeft
                                   Top:0.0
                                 Width:CMTThemeHeaderToolBarButtonWidth
                                Height:self.toolBar.height];
    // focusImage
    [self.focusImage builtinContainer:self.toolBar
                             WithLeft:self.focusButton.left + CMTThemeHeaderToolBarImageGap
                                  Top:0.0
                                Width:CMTThemeHeaderToolBarImageHeight
                               Height:CMTThemeHeaderToolBarImageHeight];
    self.focusImage.centerY = self.toolBar.height/2.0;
    if (self.disease != nil && !self.module.isPostModuleGuide) {
        self.focusButton.left = (self.width - CMTThemeHeaderToolBarButtonWidth)/2.0;
        self.focusImage.left = self.focusButton.left + CMTThemeHeaderToolBarImageGap;
        self.toolBarSeparator.hidden = YES;
    }
    
    // description
    if (self.theme != nil) {
        // descriptionView
        [self.descriptionView builtinContainer:self
                                      WithLeft:0.0
                                           Top:pictureViewBottom
                                         Width:self.width
                                        Height:self.descriptionViewHeight];
        // descriptionLabel
        [self.descriptionLabel builtinContainer:self.descriptionView
                                       WithLeft:CMTThemeHeaderDescriptionMargenHorizontal*RATIO
                                            Top:CMTThemeHeaderDescriptionMargenVertical
                                          Width:self.descriptionLabelWidth
                                         Height:self.descriptionLabelHeight];
        // showContentButton
        if (self.needShowContentButton == YES) {
            CGFloat showContentButtonTop = self.descriptionLabel.bottom + CMTThemeHeaderDescriptionMargenVertical;
            [self.showContentButton builtinContainer:self.descriptionView
                                            WithLeft:0.0
                                                 Top:showContentButtonTop
                                               Width:CMTThemeHeaderShowContentButtonWidth
                                              Height:CMTThemeHeaderShowContentButtonHeight];
            self.showContentButton.centerX = self.descriptionView.width/2.0;
        }
    }
    
    // shadow & blank
    if (self.theme != nil) {
        // bottomBlank
        [self.bottomBlank builtinContainer:self
                                  WithLeft:0.0
                                       Top:self.descriptionView.bottom
                                     Width:self.width
                                    Height:CMTThemeHeaderBottomBlankHeight];
        // bottomShadow
        [self.bottomShadow builtinContainer:self.bottomBlank
                                   WithLeft:0.0
                                        Top:0.0
                                      Width:self.bottomBlank.width
                                     Height:CMTThemeHeaderShadowHeight];
        // bottomLine
        [self.bottomLine builtinContainer:self.bottomBlank
                                 WithLeft:0.0
                                      Top:self.bottomBlank.height - PIXEL
                                    Width:self.bottomBlank.width
                                   Height:PIXEL];
    }
    
    return YES;
}

#pragma mark LifeCycle

// 刷新顶部视图
- (void)reloadData {
    BOOL focused = NO;
    
    // 专题
    if (self.theme != nil) {
        
        // 刷新专题大图
        [self.pictureView setLimitedImageURL:self.theme.picture placeholderImage:IMAGE(@"focus_default")];
        
        // 刷新专题简介
        self.descriptionLabel.text = self.theme.descriptionString;
        
        // 遍历本地库 查询是否已订阅该专题
        NSMutableArray *focusedThemes = [NSKeyedUnarchiver unarchiveObjectWithFile:[PATH_USERS stringByAppendingPathComponent:@"focusList"]];
        for (CMTTheme *focusedTheme in focusedThemes) {
            if ([focusedTheme.themeId isEqual:self.theme.themeId]) {
                focused = YES;
                break;
            }
        }
    }
    
    // '单个疾病标签'
    if (self.disease != nil) {
        
        // 刷新疾病名
        self.contentTitle.text = self.disease;
        
        // 遍历本地库 查询是否已订阅该疾病标签
        NSMutableArray *focusedDiseaseArray = [NSKeyedUnarchiver unarchiveObjectWithFile:PATH_FOUSTAG];
        for (CMTDisease *focusedDisease in focusedDiseaseArray) {
            if ([focusedDisease.disease isEqual:self.disease]) {
                focused = YES;
                break;
            }
        }
    }
    
    // focus
    if (focused == YES) {
        self.focusImage.image = IMAGE(@"theme_focused");
        [self.focusButton setTitle:@"已订阅" forState:UIControlStateNormal];
    }
    else {
        self.focusImage.image = IMAGE(@"theme_focus");
        [self.focusButton setTitle:@"订阅" forState:UIControlStateNormal];
    }
}

// 点击分享
- (void)shareButtonTouched:(id)sender {
    if ([self.delegate respondsToSelector:@selector(themeHeaderShareButtonTouched:)]) {
        [self.delegate themeHeaderShareButtonTouched:self];
    }
}

// 点击求助
- (void)helpButtonTouched:(id)sender {
    if ([self.delegate respondsToSelector:@selector(themeHeaderHelpButtonTouched:)]) {
        [self.delegate themeHeaderHelpButtonTouched:self];
    }
}

// 点击订阅
- (void)focusButtonTouched:(id)sender {
    if ([self.delegate respondsToSelector:@selector(themeHeaderFocusButtonTouched:)]) {
        [self.delegate themeHeaderFocusButtonTouched:self];
    }
}

@end
