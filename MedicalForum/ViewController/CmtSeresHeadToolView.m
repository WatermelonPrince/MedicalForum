//
//  CmtSeresToolView.m
//  MedicalForum
//
//  Created by guoyuanchao on 16/9/12.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import "CmtSeresHeadToolView.h"
static const CGFloat CMTSeresHeadToolBarHeight = 40.0;
static const CGFloat CMTSeresHeadToolBarSeparatorMargenVertical = 3.5;
static const CGFloat CMTSeresHeadToolBarImageHeight = 20.0;
static const CGFloat CMTSeresHeadToolBarImageGap = 11.0;
static const CGFloat CMTSeresHeadToolBarButtonWidth = 100.0;
@implementation CmtSeresHeadToolView
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
        [_shareButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 11*3.0, 0.0, 0.0)];
        [_shareButton setTitle:@"分享" forState:UIControlStateNormal];
    }
    
    return _shareButton;
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
        [_focusButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0, CMTSeresHeadToolBarImageGap*3.0, 0.0, 0.0)];
        [_focusButton setTitle:@"订阅" forState:UIControlStateNormal];
        [_focusButton addTarget:self action:@selector(focusButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _focusButton;
}

-(instancetype)initWithFrame:(CGRect)frame CMTSeriesDetails:(CMTSeriesDetails*)mySeriesDetails{
    self=[super initWithFrame:frame];
    if (self) {
        [self.toolBar builtinContainer:self
                              WithLeft:0.0
                                   Top:0
                                 Width:self.width
                                Height:CMTSeresHeadToolBarHeight];
        // toolBarShadow
        [self.toolBarShadow builtinContainer:self.toolBar
                                    WithLeft:0.0
                                         Top:0.0
                                       Width:self.toolBar.width
                                      Height:self.toolBar.height];
        // toolBarSeparator
        CGFloat toolBarSeparatorHeight = self.toolBarShadow.height - 2.0*CMTSeresHeadToolBarSeparatorMargenVertical;
        [self.toolBarSeparator builtinContainer:self.toolBarShadow
                                       WithLeft:0.0
                                            Top:CMTSeresHeadToolBarSeparatorMargenVertical
                                          Width:PIXEL
                                         Height:toolBarSeparatorHeight];
        self.toolBarSeparator.centerX = self.toolBarShadow.width/2.0;

        CGFloat shareButtonLeft = (self.width/2.0 - CMTSeresHeadToolBarButtonWidth)/2.0;
        [self.shareButton builtinContainer:self.toolBar
                                  WithLeft:shareButtonLeft
                                       Top:0.0
                                     Width:CMTSeresHeadToolBarButtonWidth
                                    Height:self.toolBar.height];
        // shareImage
        [self.shareImage builtinContainer:self.toolBar
                                 WithLeft:self.shareButton.left + CMTSeresHeadToolBarImageGap
                                      Top:0.0
                                    Width:CMTSeresHeadToolBarImageHeight
                                   Height:CMTSeresHeadToolBarImageHeight];
        self.shareImage.centerY = self.toolBar.height/2.0;
        
        CGFloat focusButtonLeft = self.width/2.0 + (self.width/2.0 - CMTSeresHeadToolBarButtonWidth)/2.0;
        [self.focusButton builtinContainer:self.toolBar
                                  WithLeft:focusButtonLeft
                                       Top:0.0
                                     Width:CMTSeresHeadToolBarButtonWidth
                                    Height:self.toolBar.height];
        // focusImage
        [self.focusImage builtinContainer:self.toolBar
                                 WithLeft:self.focusButton.left + CMTSeresHeadToolBarImageGap
                                      Top:0.0
                                    Width:CMTSeresHeadToolBarImageHeight
                                   Height:CMTSeresHeadToolBarImageHeight];
        self.focusImage.centerY = self.toolBar.height/2.0;
        [self reloadWithSeresDetail:mySeriesDetails];

    }
    return self;
}
//添加订阅逻辑
-(void)focusButtonTouched:(UIButton*)sender{
    NSLog(@"ssssssssssss");
    if (self.delegate && [self.delegate respondsToSelector:@selector(subscribeAction:)]) {
        [self.delegate subscribeAction:sender];
    }
}
//添加订阅成功刷新按钮文字逻辑
-(void)reloadWithSeresDetail:(CMTSeriesDetails *)seresDetail{
    NSMutableArray *cachArr = [NSMutableArray array];
    BOOL subscribe = NO;
    if ([[NSFileManager defaultManager] fileExistsAtPath:[PATH_USERS stringByAppendingPathComponent:@"subscribeSeriesList"]]) {
        cachArr = [NSKeyedUnarchiver unarchiveObjectWithFile:[PATH_USERS stringByAppendingPathComponent:@"subscribeSeriesList"]];
        for (CMTSeriesDetails *seriesDetailCach in cachArr) {
            if ([seriesDetailCach.themeUuid isEqual:seresDetail.themeUuid]) {
                subscribe = YES;
                //更新阅读时间和消息数
                seriesDetailCach.viewTime = TIMESTAMP;
                if (CMTAPPCONFIG.seriesDtlUnreadNumber.integerValue >0) {
                     CMTAPPCONFIG.seriesDtlUnreadNumber  = [NSString stringWithFormat:@"%ld",CMTAPPCONFIG.seriesDtlUnreadNumber.integerValue - seriesDetailCach.newrecordCount.integerValue];
                }else{
                    CMTAPPCONFIG.seriesDtlUnreadNumber = @"0";
                }
                seriesDetailCach.newrecordCount = @"0";

                break;
            }
        }
        BOOL sucess = [NSKeyedArchiver archiveRootObject:cachArr toFile:[PATH_USERS stringByAppendingPathComponent:@"subscribeSeriesList"]];
        if (sucess) {
            CMTLog(@"阅读时间同步成功");
        }else{
            CMTLog(@"阅读时间同步失败");

        }
    }
    if (subscribe) {
        self.focusImage.image = IMAGE(@"theme_focused");
        [self.focusButton setTitle:@"已订阅" forState:UIControlStateNormal];
    }else{
        self.focusImage.image = IMAGE(@"theme_focus");
        [self.focusButton setTitle:@"订阅" forState:UIControlStateNormal];
    }
}
@end
