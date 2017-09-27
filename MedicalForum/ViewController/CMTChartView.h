//
//  CMTChartView.h
//  MedicalForum
//
//  Created by guoyuanchao on 16/6/6.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITableView+CMTExtension_PlaceholderView.h"
@interface CMTChartView : UIView<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)UITableView *chartTableView;//直播聊天列表
@property(nonatomic,strong)NSArray *dataSourceArray;
@end
