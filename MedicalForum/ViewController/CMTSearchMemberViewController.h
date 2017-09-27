//
//  CMTSearchMemberViewController.h
//  MedicalForum
//
//  Created by zhaohuan on 16/3/14.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import "CMTBaseViewController.h"

@interface CMTSearchMemberViewController : CMTBaseViewController

@property (copy) void(^reloadBlock)(NSString *,CMTParticiPators *) ;

- (instancetype)initWithGroup:(CMTGroup *)group
                 managerCount:(NSInteger)managerCount
                     showType:(NSString *)showType
                  reloadblock:(void(^)(NSString *,CMTParticiPators *))reloadBlock;



@end
