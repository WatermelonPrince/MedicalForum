//
//  CMTAboutViewController.h
//  MedicalForum
//
//  Created by Bo Shen on 14/12/24.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTBaseViewController.h"

@interface CMTAboutViewController : CMTBaseViewController<UIGestureRecognizerDelegate>

@property (strong, nonatomic) UIImageView *mLogoImageView;
@property (strong, nonatomic) UILabel *mLbVersion;
@property (strong, nonatomic) UIImageView *mCharacterImageView;
@property (strong, nonatomic) UILabel *mLbCopyright;

@end
