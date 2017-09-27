//
//  CMTSeriesNavigation.h
//  MedicalForum
//
//  Created by guoyuanchao on 16/7/22.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import "CMTObject.h"

@interface CMTSeriesNavigation : CMTObject
@property(nonatomic,strong)NSString *themeUuid;
@property(nonatomic,strong)NSString *navigationId;
@property(nonatomic,strong)NSString *navigationName;
@property(nonatomic,strong)NSArray *video;
@property(nonatomic,strong)NSString *seriesName;
@end
