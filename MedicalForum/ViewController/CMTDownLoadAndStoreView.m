//
//  CMTDownLoadAndStoreView.m
//  MedicalForum
//
//  Created by zhaohuan on 2017/2/16.
//  Copyright © 2017年 CMT. All rights reserved.
//

#import "CMTDownLoadAndStoreView.h"

@implementation CMTDownLoadAndStoreView
-(UIControl*)downContorl{
    if(_downContorl==nil){
        _downContorl=[[UIControl alloc]initWithFrame:CGRectMake(0, 0, self.width/2-0.5, self.height)];
        self.downLoadBtn.frame = CGRectMake((_downContorl.size.width-20)/2, (_downContorl.size.height - 20 - 13)/2, 20, 20);
        self.downlabel.frame = CGRectMake(self.downLoadBtn.left -20, self.downLoadBtn.bottom + 3, self.downLoadBtn.width +40, 10);
        [_downContorl addSubview:self.downlabel];
        [_downContorl addSubview:self.downLoadBtn];
        
    }
    return _downContorl;
}
-(UIControl*)storeContorl{
    if(_storeContorl==nil){
        _storeContorl=[[UIControl alloc]initWithFrame:CGRectMake(self.width/2+0.5, 0, self.width/2-0.5, self.height)];
        self.storeBtn.frame = CGRectMake((_storeContorl.size.width-20)/2, (_storeContorl.size.height - 20 - 13)/2, 20, 20);
        self.storelabel.frame = CGRectMake(self.storeBtn.left -  5, self.storeBtn.bottom + 3, self.storeBtn.width + 10, 10);
        [_storeContorl addSubview:self.storelabel];
        [_storeContorl addSubview:self.storeBtn];
    }
    return _storeContorl;
}
- (UIButton *)storeBtn{
    if (!_storeBtn) {
        _storeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_storeBtn setImage:IMAGE(@"ic_unstore") forState:UIControlStateNormal];
        [_storeBtn setImage:IMAGE(@"ic_mine_left_fav") forState:UIControlStateSelected];
    }
    return _storeBtn;
}
- (UIButton *)downLoadBtn{
    if (!_downLoadBtn) {
        _downLoadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_downLoadBtn setImage:IMAGE(@"Ic_down") forState:UIControlStateNormal];
        [_downLoadBtn setImage:IMAGE(@"Ic_down") forState:UIControlStateSelected];
        _downLoadBtn.adjustsImageWhenHighlighted=NO;
    }
    return _downLoadBtn;
}
- (UILabel *)storelabel{
    if (!_storelabel) {
        _storelabel = [[UILabel alloc]init];
        _storelabel.textAlignment = NSTextAlignmentCenter;
        _storelabel.font = FONT(10);
        _storelabel.textColor = ColorWithHexStringIndex(c_32c7c2);
        _storelabel.text = @"收藏";
    }
    return _storelabel;
}
-(UIView*)line{
    if(_line==nil){
        _line=[[UIView alloc]initWithFrame:CGRectMake(self.width/2-1, 7, 1, 30)];
        _line.backgroundColor=[UIColor colorWithHexString:@"#dddddd"];
    }
    return _line;
}

- (UILabel *)downlabel{
    if (!_downlabel) {
        _downlabel = [[UILabel alloc]init];
        _downlabel.textAlignment = NSTextAlignmentCenter;
        _downlabel.font = FONT(10);
        _downlabel.textColor = ColorWithHexStringIndex(c_32c7c2);
        _downlabel.text = @"下载";
    }
    return _downlabel;
}
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor=COLOR(c_ffffff);
        [self addSubview:self.downContorl];
        [self addSubview:self.storeContorl];
        [self addSubview:self.line];
    }
    return self;
}

@end
