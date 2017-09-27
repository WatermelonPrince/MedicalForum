//
//  CMTCollegeDetail.h
//  MedicalForum
//
//  Created by zhaohuan on 16/7/25.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import "CMTObject.h"
#import "CMTAssortments.h"

@interface CMTCollegeDetail : CMTObject

@property (nonatomic, copy)NSString *collegeId;//学院id
@property (nonatomic, copy)NSString *collegeName;//学院name;
@property (nonatomic, copy)NSString *picUrl;//图片url
@property (nonatomic, strong)NSArray *assortmentArray;//分类信息;
@property(nonatomic,strong)NSString *shareUrl;//分享链接
@property(nonatomic,strong)CMTPicture *sharePic;//分享图片
@property(nonatomic,strong)NSString *shareDesc;//分享简介
@property(nonatomic,strong)NSString*collegeHeadPicUrl;//学院列表PIC
@property(nonatomic,strong)NSString*collgeNewHeadPicUrl;//学院列表PIC
@end
