//  CMTTagButton.m
//  MedicalForum
//
//  Created by CMT on 15/6/9.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTTagButton.h"

@implementation CMTTagButton
-(UILabel*)mlabe{
    if (_mlabe==nil) {
        _mlabe=[[UILabel alloc]init];
    }
    return _mlabe;
}
-(CMTBadge*)badge{
    if (_badge==nil) {
        _badge=[[CMTBadge alloc]init];
        _badge.hidden=YES;
    }
    return _badge;
}
-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor colorWithHexString:@"#94BFDF"]];
        self.layer.cornerRadius=5;
        [self addSubview:self.mlabe];
        [self addSubview:self.badge];
    }
    return self;
    
}
-(void)setTagelayout:(CMTDisease*)disease{
    self.disease=disease;
    self.mlabe.frame=CGRectMake(0, 0, self.width, self.height);
    self.mlabe.text=disease.disease;
    self.mlabe.textColor=COLOR(c_ffffff);
    [self.mlabe setTextAlignment:NSTextAlignmentCenter];
    self.mlabe.font=[UIFont systemFontOfSize:self.fontsize];
    self.badge.frame=CGRectMake(self.width-kCMTBadgeWidth/2-2.5,-kCMTBadgeWidth/2,kCMTBadgeWidth , kCMTBadgeWidth);
    switch (self.model.integerValue) {
        case 0:
            if (!isEmptyString(disease.postCount)&&[CMTAPPCONFIG.UnreadPostNumber_Slide integerValue]>0) {
                if ([disease.postCount integerValue]>0) {
                    self.badge.hidden=NO;
                    self.badge.text=self.disease.postCount;
                }
            }

            break;
        case 1:
            CMTLog(@"ssssssssss%@",CMTAPPCONFIG.UnreadCaseNumber_Slide);
            if (!isEmptyString(disease.caseCout)&&[CMTAPPCONFIG.UnreadCaseNumber_Slide integerValue]>0) {
                if ([disease.caseCout integerValue]>0) {
                    self.badge.hidden=NO;
                    self.badge.text=self.disease.caseCout;
                }
            }

            
            break;
        case 2:
            if (!isEmptyString(disease.count)&&[CMTAPPCONFIG.GuideUnreadNumber integerValue]>0) {
                if ([disease.count integerValue]>0) {
                    self.badge.hidden=NO;
                    self.badge.text=self.disease.count;
                }
            }

            break;
            
            
        default:
            break;
    }
}

@end
