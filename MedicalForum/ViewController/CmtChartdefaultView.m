//
//  CmtChartdefaultView.m
//  MedicalForum
//
//  Created by guoyuanchao on 16/6/7.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import "CmtChartdefaultView.h"

@implementation CmtChartdefaultView
-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        self.tipLable=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 60)];
        self.tipLable.textColor=COLOR(c_d2d2d2);
        self.tipLable.font=[UIFont boldSystemFontOfSize:15.0];
        self.tipLable.textAlignment=NSTextAlignmentCenter;
        self.tipLable.text=@"直播未开始，还不能提问哦！";
        [self addSubview:self.tipLable];
        self.tipLable.center=self.center;
    }
    return self;
}
@end
