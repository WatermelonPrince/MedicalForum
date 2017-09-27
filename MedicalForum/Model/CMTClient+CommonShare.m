//
//  CMTClient+CommonShare.m
//  MedicalForum
//
//  Created by jiahongfei on 15/9/10.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTClient+CommonShare.h"

@implementation CMTClient (CommonShare)

///78业务分享接口
- (RACSignal *)commonShare:(NSDictionary *)parameters {
    
    return [self POST:@"/app/common/share.json" parameters:parameters resultClass:[CMTObject class] withStore:NO];
}

//阅读码绑定
- (RACSignal *)readCodeBlind:(NSDictionary *)parameters{
    return [self POST:@"/app/user/verify_epapercode.json" parameters:parameters resultClass:[CMTBlindReadCodeResult class] withStore:NO];
}


@end
