//
//  CMTCline+getOpen_list.m
//  MedicalForum
//
//  Created by guoyuanchao on 15/7/15.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTClinet+getOpenGroupList.h"

@implementation CMTClient(getOpenGroupList)
// 58.全部公开小组列表接口
- (RACSignal *)getOpenGroupList:(NSDictionary *)parameters {
    
    return [self GET:@"app/group/open_list.json" parameters:parameters resultClass:[CMTGroup class] withStore:NO];
}
//109小组搜索
- (RACSignal *)searchTeam:(NSDictionary *)parameters {
    
    return [self GET:@"app/group/search_group.json" parameters:parameters resultClass:[CMTSearchGroupObject class] withStore:NO];
}

//112验证小组名是否重复
- (RACSignal *)groupCheckName:(NSDictionary *)parameters {
    
    return [self GET:@"/app/group/check_name_unique.json" parameters:parameters resultClass:[CMTGroupCeatedCheckName class] withStore:NO];
}
//创建小组 106
- (RACSignal *) modifyCreatGroup:(NSDictionary *) parameters{
    NSMutableDictionary *parametersHandle = [NSMutableDictionary dictionaryWithDictionary:parameters];
    [parametersHandle removeObjectForKey:@"groupLogo"];
    
    return [self POST:@"/app/group/create.json" parameters:parametersHandle resultClass:[CMTGroup class] dataBlock:^(id<AFMultipartFormData> formData)
            {
                
                
                if ([parameters[@"groupLogo"] isKindOfClass:[UIImage class]])
                {
                    NSString *filePath = [PATH_CACHE_IMAGES stringByAppendingPathComponent:@"groupLogo"];
                    UIImage *pImage = parameters[@"groupLogo"];
                    NSData *pData = UIImageJPEGRepresentation(pImage,0.5);
                    [pData writeToFile:filePath atomically:YES];
                    NSURL *pUrl = [NSURL fileURLWithPath:filePath];
                    //NSData *pFileData = [[NSData alloc]initWithContentsOfFile:filePath];
                    [formData appendPartWithFileURL:pUrl name:@"groupLogo" fileName:@"123.PNG" mimeType:@"image/jpeg" error:nil];
                    
                    
                    
                }
            }];
    
}
//修改小组 108
- (RACSignal *)modifUpdateGroup:(NSDictionary *) parameters{
    NSMutableDictionary *parametersHandle = [NSMutableDictionary dictionaryWithDictionary:parameters];
    [parametersHandle removeObjectForKey:@"groupLogo"];
    
    return [self POST:@"app/group/card/update.json" parameters:parametersHandle resultClass:[CMTGroup class] dataBlock:^(id<AFMultipartFormData> formData)
            {
                
                
                if (!isEmptyObject([parameters objectForKey:@"groupLogo"]))
                {
                    NSString *filePath =[parameters objectForKey:@"groupLogo"];
                    NSURL *pUrl = [NSURL fileURLWithPath:filePath];
                    [formData appendPartWithFileURL:pUrl name:@"groupLogo" fileName:@"123.PNG" mimeType:@"image/jpeg" error:nil];
                    
                    
                    
                }
            }];
    
}

@end
