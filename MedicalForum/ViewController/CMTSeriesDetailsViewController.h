//
//  CMTSeriesDetailsViewController.h
//  MedicalForum
//
//  Created by guoyuanchao on 16/7/22.
//  Copyright © 2016年 CMT. All rights reserved.
//
#import "CMTBaseViewController.h"
@interface CMTSeriesDetailsViewController : CMTBaseViewController
@property (nonatomic, copy) void(^updatevideoList)(NSString *themUuid);
-(instancetype)initWithParam:(CMTSeriesDetails*)SeriesDetails;
@end
