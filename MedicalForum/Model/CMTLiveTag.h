//
//  CMTLiveTag.h
//  MedicalForum
//
//  Created by guoyuanchao on 15/8/31.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTObject.h"

@interface CMTLiveTag : CMTObject
//agId	直播标签id
@property(nonatomic,copy,readwrite)NSString *liveBroadcastTagId;
//直播标签名称
@property(nonatomic,copy,readwrite)NSString *name;

@end
