//
//  CMTPersonalCell.h
//  MedicalForum
//
//  Created by zhaohuan on 2017/4/12.
//  Copyright © 2017年 CMT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CMTPersonalCell : UITableViewCell

@property (nonatomic, strong)UIImageView *headImageView;//个人头像
@property (nonatomic, strong)UILabel *leftLabel;//左边label
@property(nonatomic, strong)UILabel *rightLabel;//右边label
@property (nonatomic, strong)UIView *lineView;//cell下边的线


- (void)reloadWithLeftString:(NSString *)lString
                 rightString:(NSString *)rString
                   WithImage:(BOOL)haveImage;


@end
