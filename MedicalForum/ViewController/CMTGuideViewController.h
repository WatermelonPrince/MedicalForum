//
//  CMTGuideViewController.h
//  MedicalForum
//
//  Created by CMT on 15/6/1.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTBaseViewController.h"

@interface CMTGuideViewController : CMTBaseViewController<UITableViewDataSource,UITableViewDelegate>
//重新绘制tag标签
-(void)CMTGetTagArray;
@end
