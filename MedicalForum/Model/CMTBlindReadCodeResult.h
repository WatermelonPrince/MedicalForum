//
//  CMTBlindReadCodeResult.h
//  MedicalForum
//
//  Created by zhaohuan on 15/12/25.
//  Copyright © 2015年 CMT. All rights reserved.
//

#import "CMTObject.h"

@interface CMTBlindReadCodeResult : CMTObject

@property (nonatomic, copy)NSString *decryptKey;//解密key

@property (nonatomic, copy)NSString *effectiveDate; //开始日期

@property (nonatomic, copy)NSString *expirationDate;//失效日期

@property (nonatomic, copy)NSString *rcodeState;//阅读码状态



@end
