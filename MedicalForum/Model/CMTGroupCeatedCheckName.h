//
//  CMTGroupCeatedCheckName.h
//  MedicalForum
//
//  Created by zhaohuan on 16/3/18.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import "CMTObject.h"

@interface CMTGroupCeatedCheckName : CMTObject
@property (nonatomic, copy)NSString *isDuplicated;//0表示可用不重复1表示不可用存在重名

@end
