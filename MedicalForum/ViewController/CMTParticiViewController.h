//
//  CMTParticiViewController.h
//  MedicalForum
//
//  Created by guoyuanchao on 15/7/21.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTBaseViewController.h"
#import "CMTPartcell.h"

@interface CMTParticiViewController : CMTBaseViewController<UITableViewDataSource,UITableViewDelegate>
-(instancetype)initWithId:(NSString*)cellId;
@end
