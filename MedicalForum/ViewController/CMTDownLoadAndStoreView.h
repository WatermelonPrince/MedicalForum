//
//  CMTDownLoadAndStoreView.h
//  MedicalForum
//
//  Created by zhaohuan on 2017/2/16.
//  Copyright © 2017年 CMT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CMTDownLoadAndStoreView : UIView

@property (nonatomic, strong)UIButton *downLoadBtn;
@property (nonatomic, strong)UIButton *storeBtn;
@property (nonatomic, strong)UILabel *storelabel;
@property (nonatomic, strong)UILabel *downlabel;
@property (nonatomic,strong)UIControl*downContorl;
@property(nonatomic,strong)UIControl *storeContorl;
@property(nonatomic,strong)UIView *line;


- (instancetype)initWithFrame:(CGRect)frame;

@end
