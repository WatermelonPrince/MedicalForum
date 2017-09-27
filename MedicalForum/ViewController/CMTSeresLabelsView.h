//
//  CMTSeresLabelsView.h
//  MedicalForum
//
//  Created by guoyuanchao on 16/7/25.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CMTSeresLabelsView : UIView
@property(nonatomic,strong)NSArray *navigationArray;
@property(nonatomic,strong) void(^SeresLabelAction)(NSInteger index);
//创建标签
-(void)CreatSeresLable;
@end
