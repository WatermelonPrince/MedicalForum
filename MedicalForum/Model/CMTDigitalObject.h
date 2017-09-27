//
//  CMTDigitalObject.h
//  MedicalForum
//
//  Created by guoyuanchao on 15/12/24.
//  Copyright © 2015年 CMT. All rights reserved.
//

#import "CMTObject.h"

@interface CMTDigitalObject : CMTObject
//学科列表
@property(nonatomic,strong)NSArray *subjectList;
//0:不能阅读 1.能阅读，表示已经绑定过阅读码
@property(nonatomic,strong)NSString *canRead;
//解密key
@property(nonatomic,strong)NSString *decryptKey;
//报文
@property(nonatomic,strong)NSString*html;
//是否加密
@property(nonatomic,strong)NSString *encrypt;
//阅读码状态
@property(nonatomic,strong)NSString *rcodeState;

//购买电子报商城地址
@property (nonatomic, copy)NSString *epaperStoreUrl;

@end
