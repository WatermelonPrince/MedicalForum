//
//  MypageTableViewCell.h
//  MedicalForum
//
//  Created by guoyuanchao on 2017/4/12.
//  Copyright © 2017年 CMT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MypageTableViewCell : UITableViewCell
@property(nonatomic,strong)UIImageView *leftImageView;
@property(nonatomic,strong)UIImageView *rightImageView;
@property(nonatomic,strong)UILabel *titleLable;

-(void)reloadData:(NSString*)str;
@end
