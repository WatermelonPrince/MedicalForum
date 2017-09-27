//
//  CMTInitObject.h
//  MedicalForum
//
//  Created by guoyuanchao on 15/12/14.
//  Copyright © 2015年 CMT. All rights reserved.
//

#import <Foundation/Foundation.h>
//广告实体类
@interface CMTAdverObject : CMTObject
@property(nonatomic,strong)NSString*picUrl;//广告图片地址;
@property(nonatomic,strong)NSString*startType;//启动类型
@property(nonatomic,strong)NSString*jumpLinks;//跳转链接
@property(nonatomic,strong)NSString *adverId;//广告ID
@property(nonatomic,strong)NSString*advertisingTime;//广告时长
@end
@interface CMTTouchme : CMTObject
@property(nonatomic,strong)NSString *imgUrl;
@property(nonatomic,strong)NSString *des;
@end
//推荐给友
@interface CMTRecommend : CMTObject
@property(nonatomic,strong)NSString *shareUrl;
@property(nonatomic,strong)NSString *shareTitle;
@property(nonatomic,strong)NSString *shareBrief;
@property(nonatomic,strong)NSString *shareImg;
@end
//联系我们
@interface CMTContact :CMTObject
@property(nonatomic,strong)CMTTouchme *touchme;//联系我们
@property(nonatomic,strong)CMTRecommend *recommend;//推荐
@property(nonatomic,strong)CMTTouchme *readcode;//购买阅读码
@end
//获取手机状态
@interface CMTAuthCode : CMTObject

// 该手机号注册状态: 1 该手机号已经注册过；2 该手机号初次注册
@property (nonatomic, copy, readonly) NSNumber *regStatus;

@end
//启动对象
@interface CMTInitObject : CMTObject
@property(nonatomic,strong)NSArray *items;//活动数组
@property(nonatomic,strong)NSString *type;//活动类型
@property(nonatomic,strong)NSString *val;//活动链接
@property(nonatomic,strong)NSString *version;//版本号
@property(nonatomic,strong)NSString *desc;//升级描述
@property(nonatomic,strong)CMTAdverObject *adver;//开机广告
@property(nonatomic,strong)NSString*updateStatus;//1 强制更新 0 非强制更新
@property(nonatomic,strong)NSString *sysDate;//系统时间
@property(nonatomic,strong)CMTTouchme *touchme;//联系我们
@property(nonatomic,strong)CMTTouchme *readcode;//购买阅读码
@property(nonatomic,strong)CMTRecommend *recommend;//推荐
@property(nonatomic,copy)NSString *areaUpdateTime;//全国地区更新时间



@end
