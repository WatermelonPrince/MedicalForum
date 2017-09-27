//
//  CMTCasefilterView.h
//  MedicalForum
//
//  Created by guoyuanchao on 15/7/16.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, CMTCasefilterViewType) {
    CMTCasefilterViewTypeUndefined = 0,
    CMTCasefilterViewTypeCaseListFilter,
    CMTCasefilterViewTypeAppendDetailFilter,
};


@protocol CMTCasefilterViewDelegate <NSObject>
//过滤函数
-(void)filterData:(NSInteger)index;
@end

@interface CMTCasefilterView : UIView

- (instancetype)initWithFrame:(CGRect)frame
                       titles:(NSArray *)titles
           casefilterViewType:(CMTCasefilterViewType)casefilterViewType;

//代理
@property(nonatomic,weak)id<CMTCasefilterViewDelegate>delegate;

- (void)showInView:(UIView *)view;
- (void)showInView:(UIView *)view withOrigin:(CGPoint)origin;
- (void)hideFilter;

@end
