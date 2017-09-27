//
//  CMTDiseaseListViewController.h
//  MedicalForum
//
//  Created by CMT on 15/6/8.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTBaseViewController.h"
#import "CMTSubject.h"
@interface CMTDiseaseListViewController : CMTBaseViewController<UITableViewDataSource,UITableViewDelegate>
-(instancetype)initWithSuject:(CMTSubject*)subject isFromDic:(BOOL)isfromDic;
@end
