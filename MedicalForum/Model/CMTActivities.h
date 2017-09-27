//
//  Activities.h
//  MedicalForum
//
//  Created by jiahongfei on 15/8/28.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTObject.h"
#import "CMTPicture.h"

@interface CMTActivities : CMTObject

@property(nonatomic, strong)CMTPicture * picture; //	活动图 		object
@property(nonatomic, strong)NSString * link ;//	链接 	打开链接 	url 	根据isHTML确定跳转类型

@property(nonatomic, strong)NSString * activityId ;//	活动ID 		long
@property(nonatomic, strong)NSString * title ;//	标题 		string
@property(nonatomic, strong)NSString * desc ;//	描述 		string
@property(nonatomic, strong)CMTPicture * sharePic ;//	分享活动图 		object

@end
