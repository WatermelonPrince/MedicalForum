//
//  CMTTableSectionFooter.m
//  MedicalForum
//
//  Created by Bo Shen on 14/12/19.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTTableSectionFooter.h"

@implementation CMTTableSectionFooter

+ (instancetype)footerForTableView:(UITableView *)tableView indexPatx:(NSInteger)section
{
    return [[[CMTTableSectionFooter alloc]init]footerForTableView:tableView indexPatx:section];
}

- (instancetype)footerForTableView:(UITableView *)tableView indexPatx:(NSInteger)section
{
    CGFloat footWidth = tableView.width;
    CGFloat footerHeight = 20.0;
    CMTCALL(
            footerHeight = [tableView.delegate tableView:tableView heightForFooterInSection:section];
            )
    
    UIView *pView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, footWidth, footerHeight)];
    //pView.backgroundColor =  [tableView.delegate tableView:tableView viewForHeaderInSection:section].backgroundColor;
    pView.backgroundColor = tableView.backgroundColor;
    [self addSubview:pView];

    
    self.mImageView.frame = CGRectMake(16*RATIO, 9, 13, 13);
    [self addSubview:self.mImageView];
    
    self.mBtnMore.frame = CGRectMake(42*RATIO, 9, 100*RATIO, 13);
    //self.mBtnMore.tintColor = COLOR(c_32c7c2);
    [self.mBtnMore setTitleColor:COLOR(c_4766a8) forState:UIControlStateNormal];
    self.mBtnMore.titleLabel.font = [UIFont systemFontOfSize:25/2];
   
    //[pView addSubview:self.mBtnMore];
    [self addSubview:self.mBtnMore];
    
    
    
    return self;
}


- (UIImageView *)mImageView
{
    if (nil == _mImageView)
    {
        _mImageView = [[UIImageView alloc]init];
    }
    return _mImageView;
}
//- (void)set_MImageView:(UIImageView *)mImageView
//{}


- (UIButton *)mBtnMore
{
    if (nil == _mBtnMore)
    {
        _mBtnMore = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    return _mBtnMore;
}

- (void)setImage:(NSString *)imageName
{
    _mImageView.image = [UIImage imageNamed:imageName];
}
- (void)setBtnTitle:(NSString *)btnTitle
{
    [_mBtnMore setTitle:btnTitle forState:UIControlStateNormal];

}






@end
