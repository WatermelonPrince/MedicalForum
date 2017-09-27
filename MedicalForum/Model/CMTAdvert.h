//
//  CMTAdvert.h
//  MedicalForum
//
//  Created by zhaohuan on 2017/2/28.
//  Copyright © 2017年 CMT. All rights reserved.
//

#import "CMTObject.h"

@interface CMTAdvert : CMTObject
@property(nonatomic,strong)NSString*picUrl;//广告图片地址;
@property(nonatomic,strong)NSString*jumpLinks;//跳转链接
@property(nonatomic,strong)NSString*position;//位置
@property(nonatomic,strong)NSString *adverId;//广告ID



@end
