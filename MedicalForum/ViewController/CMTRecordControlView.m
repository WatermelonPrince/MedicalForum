//
//  CMTRecordControlView.m
//  VodSDKDemo 
//
//  Created by zhaohuan on 16/6/5.
//  Copyright © 2016年 Gensee. All rights reserved.
//

#import "CMTRecordControlView.h"
@interface CMTRecordControlView ()

@end
@implementation CMTRecordControlView

- (UIView *)topLineView {
    if (!_topLineView) {
        self.topLineView = [[UIView alloc]init];
        _topLineView.backgroundColor = ColorWithHexStringIndex(c_000000);
    }
    return _topLineView;
}
- (UIView *)bottomLineView {
    if (!_bottomLineView) {
        self.bottomLineView = [[UIView alloc]init];
        _bottomLineView.backgroundColor = ColorWithHexStringIndex(c_000000);
    }
    return _bottomLineView;
}

- (BBFlashCtntLabel *)livetitle{
    if (!_livetitle) {
        self.livetitle=[[BBFlashCtntLabel alloc]initWithFrame:CGRectMake(70, self.topView.bottom - 44, self.topView.frame.size.width - 140, 44)];
        self.livetitle.speed=BBFlashCtntSpeedMild;
        self.livetitle.textColor=[UIColor blackColor];
        self.livetitle.font = FONT(18.5);
        [self.livetitle setBackgroundColor:[UIColor clearColor]];
    }
    return _livetitle;
}

- (UILabel *)havePlay{
    if (_havePlay ==nil) {
        _havePlay = [[UILabel alloc]init];
        _havePlay.frame = CGRectMake(42, 10, 48, 20);
        _havePlay.text = @"00:00:00";
        _havePlay.font = FONT(10);
//        _havePlay.backgroundColor = [UIColor cyanColor];
        _havePlay.textColor = [UIColor whiteColor];
    }
    return _havePlay;
}

- (UILabel *)remainPlay{
    if (_remainPlay == nil) {
        _remainPlay = [[UILabel alloc]init];
        _remainPlay.frame = CGRectMake(self.bottomView.frame.size.width - 88 , 10, 48, 20);
        _remainPlay.text = @"00:00:00";
        _remainPlay.font = FONT(10);
        _remainPlay.textAlignment = NSTextAlignmentRight;
//        _remainPlay.backgroundColor = [UIColor cyanColor];
        _remainPlay.textColor = [UIColor whiteColor];
    }
    return _remainPlay;
}

- (UIImageView *)left_seprationImage{
    if (_left_seprationImage == nil) {
        _left_seprationImage = [[UIImageView alloc]init];
//        _left_seprationImage.image = IMAGE(@"seprationImage");
        _left_seprationImage.frame = CGRectMake(self.controlButton.right + 7, 5, 3, 20);
    }
    return _left_seprationImage;
}
- (UIImageView *)right_seprationImage{
    if (_right_seprationImage == nil) {
        _right_seprationImage = [[UIImageView alloc]init];
//        _right_seprationImage.image = IMAGE(@"seprationImage");
        _right_seprationImage.frame = CGRectMake(self.fullModeButton.left - 7, 5, 3, 20);
    }
    return _right_seprationImage;
}


- (UIView *)topView{
    if (!_topView) {
        _topView = [[UIView alloc]init];
        _topView.backgroundColor = [UIColor clearColor];
    }
    return _topView;
}
- (UIView *)bottomView{
    if (!_bottomView) {
        _bottomView = [[UIView alloc]init];
        _bottomView.backgroundColor = [[UIColor colorWithHexString:@"#030303"] colorWithAlphaComponent:0.7];
    }
    return _bottomView;
}

- (UIButton *)returnButton{
    if (!_returnButton) {
        _returnButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _returnButton.hidden = YES;
        _returnButton.frame = CGRectMake(10, 10, 110/3, 110/3);
        [_returnButton setBackgroundImage:IMAGE(@"livebackImage") forState:UIControlStateNormal] ;
        [_returnButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    return _returnButton;
}


- (UIButton *)switchButton{
    if (!_switchButton) {
        _switchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _switchButton.frame = CGRectMake(self.topView.frame.size.width - 10 - 110/3, 10 , 110/3, 110/3);
        _switchButton.titleLabel.font = FONT(15);
        [_switchButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _switchButton.enabled = NO;
    }
    return _switchButton;
}

- (UIButton *)shareButton{
    if (!_shareButton) {
        _shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _shareButton.frame = CGRectMake(self.switchButton.left - 10 - 110/3, 10, 110/3, 110/3);
        [_shareButton setImage:IMAGE(@"liveShareImage") forState:UIControlStateNormal];
    }
    return _shareButton;
}


- (UIButton *)controlButton{
    if (!_controlButton) {
        _controlButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _controlButton.frame = CGRectMake(7, 17/2, 23, 23);
        [_controlButton setBackgroundImage:IMAGE(@"replayImage") forState:UIControlStateNormal];
        [_controlButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    return _controlButton;
    
}
- (UISlider *)progress{
    if (!_progress) {
        _progress = [[UISlider alloc]initWithFrame:CGRectMake(90, 15, self.bottomView.frame.size.width - 180, 10)];
        [_progress setMinimumTrackImage:IMAGE(@"progressImage") forState:UIControlStateNormal];
        [_progress setMaximumTrackImage:IMAGE(@"progressRightImage") forState:UIControlStateNormal];
        //注意这里要加UIControlStateHightlighted的状态，否则当拖动滑块时滑块将变成原生的控件
        [_progress setThumbImage:IMAGE(@"progressControlImage") forState:UIControlStateNormal];
    }
    return _progress;
}

- (UIButton *)fullModeButton{
    if (!_fullModeButton) {
        _fullModeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _fullModeButton.frame = CGRectMake(self.bottomView.frame.size.width - 30, 17/2, 23, 23);
//        _fullModeButton.backgroundColor = [UIColor cyanColor];
        [_fullModeButton setBackgroundImage:IMAGE(@"fullModeImage") forState:UIControlStateNormal];
    }
    return _fullModeButton;
}

- (UIView *)touchView{
    if (!_touchView) {
        _touchView = [[UIView alloc]init];
    }
    return _touchView;
}

- (instancetype)initWithFrame:(CGRect)frame
                 isfullScreen:(BOOL)fullScreen{
    self = [super initWithFrame:frame];
    if (self) {
        if (!fullScreen) {
            self.topView.frame = CGRectMake(0, 0, frame.size.width, 50);
            self.topLineView.frame = CGRectMake(0, 50,frame.size.width , 2.5);
            self.bottomLineView.frame = CGRectMake(0, frame.size.height - 2, frame.size.width, 2);
            [_fullModeButton setBackgroundImage:IMAGE(@"fullModeImage") forState:UIControlStateNormal];

        }else{
            [_fullModeButton setBackgroundImage:IMAGE(@"zoombutton") forState:UIControlStateNormal];
            
            self.topView.frame = CGRectMake(0, 0, frame.size.width, 50);
        }
        self.bottomView.frame = CGRectMake(0, frame.size.height - 40, frame.size.width, 40);
        self.touchView.frame = CGRectMake(0, self.topView.bottom, frame.size.width, frame.size.height - self.topView.height - self.bottomView.height);
        [self.livetitle reloadView];

        [self.topView addSubview:self.returnButton];
        [self.topView addSubview:self.switchButton];
        [self.topView addSubview:self.shareButton];
//        [self.topView addSubview:self.livetitle];
        [self.bottomView addSubview:self.controlButton];
        [self.bottomView addSubview:self.progress];
        [self.bottomView addSubview:self.fullModeButton];
        [self.bottomView addSubview:self.left_seprationImage];
        [self.bottomView addSubview:self.right_seprationImage];
        [self.bottomView addSubview:self.havePlay];
        [self.bottomView addSubview:self.remainPlay];
        
        
        [self addSubview:self.topView];
        [self addSubview:self.bottomView];
        [self addSubview:self.touchView];
    }
    return self;
}

- (void)resetFrame:(CGRect)frame
        isFullMode:(BOOL)fullMode{
    if (!fullMode) {
        self.topView.frame = CGRectMake(0, 0, frame.size.width, 50);
        self.topLineView.frame = CGRectMake(0, 50,frame.size.width , 2.5);
        self.bottomLineView.frame = CGRectMake(0, frame.size.height - 2, frame.size.width, 2);
        [_fullModeButton setBackgroundImage:IMAGE(@"fullModeImage") forState:UIControlStateNormal];
        

    }else{
        self.topView.frame = CGRectMake(0, 0, frame.size.width, 50);
        self.topLineView.frame = CGRectZero;
        self.bottomLineView.frame = CGRectZero;
         [_fullModeButton setBackgroundImage:IMAGE(@"zoombutton") forState:UIControlStateNormal];
    }
    self.bottomView.frame = CGRectMake(0, frame.size.height - 40, frame.size.width, 40);
    self.touchView.frame = CGRectMake(0, self.topView.bottom, frame.size.width, frame.size.height - self.topView.height - self.bottomView.height);
    _returnButton.frame = CGRectMake(10, 10, 110/3, 110/3);
    _switchButton.frame = CGRectMake(self.topView.frame.size.width - 10-110/3, 10 , 110/3, 110/3);
    _shareButton.frame = CGRectMake(self.switchButton.left - 10 - 110/3, 10, 110/3, 110/3);
    self.livetitle.frame = CGRectMake(70, self.topView.bottom - 44, self.topView.frame.size.width - 140, 44);
    _controlButton.frame = CGRectMake(7, 17/2, 23, 23);
    self.progress.frame = CGRectMake(90, 15, self.bottomView.frame.size.width - 180, 10);
    _fullModeButton.frame = CGRectMake(self.bottomView.frame.size.width - 30, 17/2, 23, 23);
    _left_seprationImage.frame = CGRectMake(self.controlButton.right + 7, 5, 3, 20);
    _right_seprationImage.frame = CGRectMake(self.fullModeButton.left - 7, 5, 3, 20);
    _havePlay.frame = CGRectMake(42, 10, 48, 20);
    _remainPlay.frame = CGRectMake(self.bottomView.frame.size.width - 88 , 10, 48, 20);
    [self.livetitle reloadView];
    self.frame = frame;
    
}

@end
