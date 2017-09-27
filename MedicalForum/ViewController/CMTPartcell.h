//
//  CMTPartcell.h
//  MedicalForum
//
//  Created by guoyuanchao on 15/7/21.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CMTPartcell : UITableViewCell
//参与者名字
@property (nonatomic, strong) UILabel *partLabel;
@property(nonatomic,assign)BOOL isMulti_select;
@property(nonatomic,strong)   UIImageView *rightimage;

-(void)reloadCell:(CMTParticiPators*)part;
@end
