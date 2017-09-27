//
//  CMTIntroPage.m
//  MedicalForum
//
//  Created by fenglei on 15/3/13.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

static const CGFloat CMTIntroPageRatioMax = 1.29375;

#import "CMTIntroPage.h"

@interface CMTIntroPage ()

/* view */
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subTitleLabel;
@property (nonatomic, strong) UIImageView *descriptionImageView;
@property (nonatomic, strong) UIImageView *mTitleImageView;
@property (nonatomic, strong) UIImageView *indexImageView;
@property (nonatomic, strong) UIButton *actionButton;
@property (nonatomic, strong) UIImageView *actionImageView;


/* output */
@property (nonatomic, strong, readwrite) RACSignal *actionButtonSignal;     /// 点击按钮

@end

@implementation CMTIntroPage

#pragma mark Initializers

- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        CGFloat top = SCREEN_MODEL ? 40.0 : 48.5*RATIO;
        CGFloat height = SCREEN_MODEL ? 30.0 : 38.5*RATIO;
        CGFloat fontSize = SCREEN_MODEL ? 30.0 : 41.0*RATIO;
        [_titleLabel builtinContainer:self WithLeft:0.0 Top:top Width:self.width Height:height];
        _titleLabel.backgroundColor = COLOR(c_clear);
        _titleLabel.textColor = COLOR(c_ffffff);
        _titleLabel.font = FONT(fontSize);
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    return _titleLabel;
}

- (UILabel *)subTitleLabel {
    if (_subTitleLabel == nil) {
        _subTitleLabel = [[UILabel alloc] init];
        CGFloat top = self.titleLabel.bottom + (SCREEN_MODEL ? 10.0 : 25.0*RATIO);
        CGFloat height = SCREEN_MODEL ? 13.0 : 17.0*RATIO;
        CGFloat fontSize = SCREEN_MODEL ? 12.0 : 17.0*RATIO;
        [_subTitleLabel builtinContainer:self WithLeft:0.0 Top:top Width:self.width Height:height];
        _subTitleLabel.backgroundColor = COLOR(c_clear);
        _subTitleLabel.textColor = COLOR(c_ffffff);
        _subTitleLabel.font = FONT(fontSize);
        _subTitleLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    return _subTitleLabel;
}

-(UIImageView *)titleImageView:(UIImage *)titleImage{
    if(nil == self.mTitleImageView){
        self.mTitleImageView = [[UIImageView alloc] initWithImage:titleImage];
        self.mTitleImageView.backgroundColor = COLOR(c_clear);
        CGFloat top = SCREEN_MODEL ? 14 : 14*RATIO;
        CGFloat height = titleImage.size.height*(2.0/3.0)*(RATIO/CMTIntroPageRatioMax)*(SCREEN_MODEL ? 1.0/1.09 : 1.0);
        [_mTitleImageView builtinContainer:self WithLeft:0.0 Top:top Width:self.width Height:height];
    }
    return  self.mTitleImageView;
}

- (UIImageView *)descriptionImageView {
    if (_descriptionImageView == nil) {
        _descriptionImageView = [[UIImageView alloc] init];
//        CGFloat top = self.mTitleImageView.bottom + (SCREEN_MODEL ? 14.0 : 14*RATIO);
        [_descriptionImageView builtinContainer:self WithLeft:0.0 Top:0 Width:0.0 Height:0.0];
        _descriptionImageView.backgroundColor = COLOR(c_clear);
    }
    
    return _descriptionImageView;
}

- (UIImageView *)indexImageView {
    if (_indexImageView == nil) {
        _indexImageView = [[UIImageView alloc] init];
        CGFloat top = 9.5*RATIO;
        [_indexImageView builtinContainer:self WithLeft:0.0 Top:top Width:0.0 Height:0.0];
        _indexImageView.backgroundColor = COLOR(c_clear);
    }
    
    return _indexImageView;
}

- (UIButton *)actionButton {
    if (_actionButton == nil) {
        _actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        CGFloat top = self.height - (SCREEN_MODEL ? 36 : 49*RATIO)-110/3*RATIO;
        CGFloat width = SCREEN_MODEL ? 137.5 : 152.5*RATIO;
        CGFloat height = SCREEN_MODEL ? 36.0 : 39.0*RATIO;
        CGFloat fontSize = SCREEN_MODEL ? 15.5 : 16.5*RATIO;
        CGFloat borderWidth =0.0;
        [_actionButton builtinContainer:self WithLeft:0.0 Top:top Width:width Height:height];
        [_actionButton setBackgroundColor:COLOR(c_clear)];
        [_actionButton setTitleColor:ColorWithHexStringIndex(c_ffffff) forState:UIControlStateNormal];
        [_actionButton setTitleColor:ColorWithHexStringIndex(c_ffffff) forState:UIControlStateHighlighted];
        [_actionButton setBackgroundImage:IMAGE(@"start_app") forState:UIControlStateNormal];
        _actionButton.titleLabel.font = SCREEN_MODEL ? [UIFont boldSystemFontOfSize:fontSize] : FONT(fontSize);
        _actionButton.layer.masksToBounds = YES;
        _actionButton.layer.borderColor = [UIColor colorWithHexString:@"#e0341f"].CGColor;
        _actionButton.layer.borderWidth = borderWidth;
        _actionButton.layer.cornerRadius = 5.0*RATIO;
    }
    
    return _actionButton;
}

- (UIImageView *)actionImageView {
    if (_actionImageView == nil) {
        _actionImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"start_app"]];
        CGFloat top = self.height - (SCREEN_MODEL ? 64.0 : 68.5*RATIO);
        CGFloat width = SCREEN_MODEL ? 137.5 : 152.5*RATIO;
        CGFloat height = SCREEN_MODEL ? 36.0 : 39.0*RATIO;
        CGFloat borderWidth = 1.0;
        [_actionImageView builtinContainer:self WithLeft:0.0 Top:top Width:width Height:height];
        [_actionImageView setBackgroundColor:COLOR(c_clear)];
        _actionImageView.layer.masksToBounds = YES;
        _actionImageView.layer.borderColor = COLOR(c_ffffff).CGColor;
        _actionImageView.layer.borderWidth = borderWidth;
        _actionImageView.layer.cornerRadius = 5.0*RATIO;
        _actionImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer*tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(startButton:)];
        [_actionImageView addGestureRecognizer:tapGesture];

    }
    
    return _actionImageView;
}


+ (instancetype)pageWithFrame:(CGRect)frame
                        title:(NSString *)title
                     subTitle:(NSString *)subTitle
             descriptionImage:(UIImage *)descriptionImage
                   indexImage:(UIImage *)indexImage
            actionButtonTitle:(NSString *)actionButtonTitle {
    
    CMTIntroPage *page = [[CMTIntroPage alloc] initWithFrame:frame];
    CMTLog(@"%s", __FUNCTION__);
    [page.rac_willDeallocSignal subscribeCompleted:^{
        CMTLog(@"IntroPage willDeallocSignal");
    }];
    
    page.backgroundColor = COLOR(c_53ae93);
    page.titleLabel.text = title;
    page.subTitleLabel.text = subTitle;
    //titleImage
    // descriptionImage
    page.descriptionImageView.image = descriptionImage;
    CGSize descriptionImageSize = CGSizeMake(descriptionImage.size.width*(2.0/3.0)*(RATIO/CMTIntroPageRatioMax)*(SCREEN_MODEL ? 1.0/1.09 : 1.0),
                                             descriptionImage.size.height*(2.0/3.0)*(RATIO/CMTIntroPageRatioMax)*(SCREEN_MODEL ? 1.0/1.09 : 1.0));
    page.descriptionImageView.size = descriptionImageSize;
    page.descriptionImageView.centerX = page.centerX;
    // indexImage
    page.indexImageView.image = indexImage;
    CGSize indexImageSize = CGSizeMake(indexImage.size.width*(2.0/3.0)*(RATIO/CMTIntroPageRatioMax),
                                       indexImage.size.height*(2.0/3.0)*(RATIO/CMTIntroPageRatioMax));
    page.indexImageView.size = indexImageSize;
    page.indexImageView.centerX = page.centerX;
    if (actionButtonTitle != nil) {
        [page.actionButton setTitle:actionButtonTitle forState:UIControlStateNormal];
        page.actionButtonSignal = [page.actionButton rac_signalForControlEvents:UIControlEventTouchUpInside];
        page.actionButton.centerX = page.centerX;
        [page.actionButton setTitle:actionButtonTitle forState:UIControlStateNormal];
    }
    
    return page;
}

+ (instancetype)pageWithFrame:(CGRect)frame
                        title:(UIImage *)title
             descriptionImage:(UIImage *)descriptionImage
                   indexImage:(UIImage *)indexImage
            actionButtonTitle:(NSString *)actionButtonTitle {
    
    CMTIntroPage *page = [[CMTIntroPage alloc] initWithFrame:frame];
    CMTLog(@"%s", __FUNCTION__);
    [page.rac_willDeallocSignal subscribeCompleted:^{
        CMTLog(@"IntroPage willDeallocSignal");
    }];
    
    page.backgroundColor = [UIColor whiteColor];
    page.descriptionImageView.image = descriptionImage;
    CGSize descriptionImageSize = CGSizeMake(SCREEN_WIDTH,
                                             SCREEN_HEIGHT);
    page.descriptionImageView.size = descriptionImageSize;
    page.descriptionImageView.centerX = page.width/2;
    // indexImage
    page.indexImageView.image = indexImage;
    CGSize indexImageSize = CGSizeMake(indexImage.size.width*(2.0/3.0)*(RATIO/CMTIntroPageRatioMax),
                                       indexImage.size.height*(2.0/3.0)*(RATIO/CMTIntroPageRatioMax));
    page.indexImageView.size = indexImageSize;
    page.indexImageView.centerX = page.width/2;
    if (actionButtonTitle != nil) {
        [page.actionButton setTitle:actionButtonTitle forState:UIControlStateNormal];
        page.actionButtonSignal = [page.actionButton rac_signalForControlEvents:UIControlEventTouchUpInside];
        page.actionButton.centerX = page.width/2;
        [page.actionButton setTitle:actionButtonTitle forState:UIControlStateNormal];
        
    }
    
    return page;
}


-(void)startButton:(UIGestureRecognizer *)gestureRecognizer{
    if(nil != self.startActionDelegate){
        [self.startActionDelegate onStartAction];
    }
}

@end
