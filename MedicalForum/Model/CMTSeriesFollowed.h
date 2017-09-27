//
//  CMTSeriesFollowed.h
//  MedicalForum
//
//  Created by zhaohuan on 16/9/13.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import "CMTObject.h"

@interface CMTSeriesFollowed : CMTObject

@property (nonatomic, strong)NSString *themeUuid;
@property (nonatomic, strong)NSString *seriesName;
@property (nonatomic, strong)NSString *picAttr;
@property (nonatomic, strong)NSString *picUrl;
@property (nonatomic, strong)NSString * newrecordCount;

@end
