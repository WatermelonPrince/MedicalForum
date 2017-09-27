//
//  CMTTableSectionFooter.h
//  MedicalForum
//
//  Created by Bo Shen on 14/12/19.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CMTTableSectionFooter : UIView

@property (strong, nonatomic) UIImageView *mImageView;
@property (strong, nonatomic) UIButton *mBtnMore;


- (UIButton *)mBtnMore;

- (UIImageView *)mImageView;

- (void)setImage:(NSString *)imageName;
- (void)setBtnTitle:(NSString *)btnTitle;

+ (instancetype)footerForTableView:(UITableView *)tableView indexPatx:(NSInteger)section;

@end
