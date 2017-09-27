//
//  CMTAutPromptView.h
//  MedicalForum
//
//  Created by Bo Shen on 14/12/26.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CMTAutPromptView : UIView

@property (strong, nonatomic) UIImageView *mImageView;
@property (strong, nonatomic) UILabel *mLbContent;
- (void)setContentText:(NSString *)str;
@end
