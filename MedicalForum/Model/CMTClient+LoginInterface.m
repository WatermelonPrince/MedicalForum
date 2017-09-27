//
//  CMTClient+VerifyAuthCode.m
//  MedicalForum
//
//  Created by guanyx on 14/12/11.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTClient+LoginInterface.h"
@implementation CMTClient(LoginInterface)
- (RACSignal *)getAuthCode:(NSDictionary *) parameters {
    
    return [self GET:@"app/user/get_authcode.json" parameters:parameters resultClass:[CMTAuthCode class] withStore:NO];
}

- (RACSignal *)verifyAuthCode:(NSDictionary *) parameters {
    
    NSMutableDictionary *parametersHandle = [NSMutableDictionary dictionaryWithDictionary:parameters];
    [parametersHandle removeObjectForKey:@"picture"];
    
    return [self POST:@"app/user/verify_authcode.json" parameters:parametersHandle resultClass:[CMTUserInfo class] dataBlock:^(id<AFMultipartFormData> formData) {
        if ([parameters[@"picture"] isKindOfClass:[UIImage class]]) {
            NSString *filePath = [PATH_CACHE_IMAGES stringByAppendingPathComponent:@"name"];
            UIImage *pImage = parameters[@"picture"];
            NSData *pData = UIImageJPEGRepresentation(pImage,0.5);
            [pData writeToFile:filePath atomically:YES];
            NSURL *pUrl = [NSURL fileURLWithPath:filePath];

            [formData appendPartWithFileURL:pUrl name:@"picture" fileName:@"picture.png" mimeType:@"image/png" error:nil];
        }
    }];
}

- (RACSignal *)logout:(NSDictionary *) parameters{
    return [self GET:@"app/user/logout.json" parameters:parameters resultClass:[CMTUserInfo class] withStore:NO];
}

- (RACSignal *) modifyPicture:(NSDictionary *) parameters {
    
    NSMutableDictionary *parametersHandle = [NSMutableDictionary dictionaryWithDictionary:parameters];
    [parametersHandle removeObjectForKey:@"picture"];
    
    return [self POST:@"app/user/modify_info.json" parameters:parametersHandle resultClass:[CMTPicture class] dataBlock:^(id<AFMultipartFormData> formData)
            {
                
                
                if ([parameters[@"picture"] isKindOfClass:[UIImage class]])
                {
                    NSString *filePath = [PATH_CACHE_IMAGES stringByAppendingPathComponent:@"name"];
                    UIImage *pImage = parameters[@"picture"];
                    NSData *pData = UIImageJPEGRepresentation(pImage,0.5);
                    [pData writeToFile:filePath atomically:YES];
                    NSURL *pUrl = [NSURL fileURLWithPath:filePath];
                    //NSData *pFileData = [[NSData alloc]initWithContentsOfFile:filePath];
                    [formData appendPartWithFileURL:pUrl name:@"picture" fileName:@"123.PNG" mimeType:@"image/jpeg" error:nil];
                    
                    
                    
                }
            }];
}
- (RACSignal *) getUserInfo:(NSDictionary *)parameters {
    
    return [self GET:@"app/user/get_info.json" parameters:parameters resultClass:[CMTUserInfo class] withStore:NO];
    
}
-(RACSignal *) promoteVip:(NSDictionary *)parameters {
    NSMutableDictionary *parametersHandle = [NSMutableDictionary dictionaryWithDictionary:parameters];
    [parametersHandle removeObjectForKey:@"licensePic"];
    
    return [self POST:@"app/user/auth_vip.json" parameters:parametersHandle resultClass:[CMTScore class] dataBlock:^(id<AFMultipartFormData> formData) {
        NSString *filePath = parameters[@"licensePic"];
        if (filePath.length > 0) {
            NSURL *pUrl = [NSURL fileURLWithPath:filePath];
            [formData appendPartWithFileURL:pUrl name:@"licensePic" fileName:@"123.PNG" mimeType:@"image/jpeg" error:nil];
        }
        
    }];
}
//149 保存用户收货地址
-(RACSignal *)saveShippingaddress:(NSDictionary *) parameters{
    
    return [self GET:@"app/user/save_shippingaddress.json" parameters:parameters resultClass:[CMTReceiverAddress class] withStore:NO];
    
}

@end
