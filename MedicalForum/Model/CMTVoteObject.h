//
//  CMTVoteObject.h
//  MedicalForum
//
//  Created by guoyuanchao on 15/11/24.
//  Copyright © 2015年 CMT. All rights reserved.
//

#import "CMTObject.h"

@interface CMTVoteObject : CMTObject
//投票文本
@property(nonatomic,strong)NSString *text;
//是否是增加事件
@property(nonatomic,strong)NSString *isaddAction;
//描述
@property(nonatomic,strong)NSString *placelhold;
@end
