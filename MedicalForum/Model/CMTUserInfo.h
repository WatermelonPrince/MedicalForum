//
//  CMTUserInfo.h
//  MedicalForum
//
//  Created by guanyx on 14/12/11.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTObject.h"
#import "CMTFollow.h"
#import "CMTHospitalInformation.h"
@interface CMTUserInfo : CMTObject

/// userId	用户ID	用户唯一标识
@property (nonatomic, copy, readwrite) NSString *userId;
/// nickname	昵称
@property (nonatomic, copy, readwrite) NSString *nickname;
/// picture	头像
@property (nonatomic, copy, readwrite) NSString *picture;
/// 订阅科室 list
@property (nonatomic, copy, readwrite) NSArray *follows;
/// roleId	用户角色	0 普通用户；1 认证用户；2 自媒体作者；3 科室作者；4 官方帐号；5 管理员；6 超级管理员	int
@property (nonatomic, copy, readwrite) NSString *roleId;
/// realName	姓名	roleId=0时，该字段为空
@property (nonatomic, copy, readwrite) NSString *realName;
/// hospital	医院	roleId=0时，该字段为空
@property (nonatomic, copy, readwrite) NSString *hospital;
/// hospitalId	医院Id	roleId=0时，该字段为空
@property (nonatomic, copy, readwrite) NSString *hospitalId;
/// subDepartment	从属科室	roleId=0时，该字段为空
@property (nonatomic, copy, readwrite) NSString *subDepartment;
//级别
@property (nonatomic, copy, readwrite) NSString *level;
//证件照网络路径
@property (nonatomic, copy, readwrite) NSString *licensePic;
//证件照本地路径
@property (nonatomic, copy, readwrite) NSString *licensePicFilepath;


/// doctorNumber	执业医师号	roleId=0时，该字段为空
@property (nonatomic, copy, readwrite) NSString *doctorNumber;
/* authStatus认证状态: 0默认未认证；1认证中；2 首次认证失败；3 第二次认证失败，不能再发起认证；4人工认证通过；5完善信息认证申请审核中；
      6完善信息认证申请审核未通过；7完善信息认证申请审核通过
 */
@property (nonatomic, copy, readwrite) NSString *authStatus;
//认证文案
@property (nonatomic, copy, readwrite) NSString *authMessage;
//认证描述详情
@property (nonatomic, copy, readwrite) NSString *authDesc;

///	用户唯一标识			用以服务端校验用户真实性
@property (nonatomic, copy, readwrite) NSString *userUuid;
//0:不能阅读 1.能阅读，表示已经绑定过阅读码
@property(nonatomic,copy,readwrite)NSString *canRead;
//阅读码状态
@property (nonatomic, copy)NSString *rcodeState;
//解密串
@property(nonatomic,copy,readwrite)NSString *decryptKey;

//上次活动时间
@property (nonatomic, copy)NSString *preActiveTime;
//学科
@property(nonatomic,strong)CMTSubDepart *subDepart;
//完善状态
@property (nonatomic, copy)NSString *improveStatus;
@property(nonatomic,strong)CMTUserInfo *epaperSubjectResult;//数字报状态返回结果
@property(nonatomic,strong)NSString *authPic;//认证图片
@property(nonatomic,strong)NSString *scores;//我的壹贝数量
@property(nonatomic,strong)NSString *rank;//级别
@property(nonatomic,strong)NSString *inviteUrl;//邀请好友地址
@property(nonatomic,strong)NSString *inviteCode;//推荐码
@property(nonatomic,strong)NSString *signUrl;//签到地址
@property(nonatomic,strong)NSString *showInviteCode;//是否填写邀请码 0 不显示:1 显示
@property(nonatomic,strong)NSString* recommendedCode;//用户注册的推荐码
@property (nonatomic, copy)NSArray *addresses;//收货地址

/**
 * 当前用户是不是作者
 * @return
 */
-(BOOL) isAuthor;

@end
