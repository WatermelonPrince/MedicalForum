//
//  CMTPromptView.h
//  MedicalForum
//
//  Created by Bo Shen on 14/12/24.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CMTPromptView : UIView

@property (strong, nonatomic) UIActivityIndicatorView *mActivityView;
@property (strong, nonatomic) UILabel *mLbContent;

- (void)setlbContent:(NSString *)content;

@end
