//
//  CMTClient+AddPost.m
//  MedicalForum
//
//  Created by fenglei on 15/8/4.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTClient+AddPost.h"
#import "CMTAddPost.h"

@implementation CMTClient (AddPost)

/// 63. 追加描述/添加结论接口
- (RACSignal *)addPostAdditional:(NSDictionary *)parameters {
    NSMutableDictionary *parametersHandle = [NSMutableDictionary dictionaryWithDictionary:parameters];
    [parametersHandle removeObjectForKey:@"pictureFilePaths"];
    
    return [self POST:@"app/group/add_desc_conclusion.json" parameters:parametersHandle resultClass:[CMTAddPost class] dataBlock:^(id<AFMultipartFormData> formData) {
        
        NSInteger index = 0;
        for (CMTPicture *picture in parameters[@"pictureFilePaths"]) {
            NSURL *pictureFileURL = [NSURL fileURLWithPath:picture.pictureFilePath];
            [formData appendPartWithFileURL:pictureFileURL
                                       name:[NSString stringWithFormat:@"picture%ld", (long)index]
                                   fileName:[NSString stringWithFormat:@"%ld.PNG", (long)index]
                                   mimeType:@"image/jpeg" error:nil];
            index++;
        }
    }];
}

/// 65. 发表病例接口
- (RACSignal *)addPost:(NSDictionary *)parameters {
    NSMutableDictionary *parametersHandle = [NSMutableDictionary dictionaryWithDictionary:parameters];
    [parametersHandle removeObjectForKey:@"pictureFilePaths"];
    
    return [self POST:@"app/group/add_post.json" parameters:parametersHandle resultClass:[CMTAddPost class] dataBlock:^(id<AFMultipartFormData> formData) {
        
        NSInteger index = 0;
        for (CMTPicture *picture in parameters[@"pictureFilePaths"]) {
            NSURL *pictureFileURL = [NSURL fileURLWithPath:picture.pictureFilePath];
            [formData appendPartWithFileURL:pictureFileURL
                                       name:[NSString stringWithFormat:@"picture%ld", (long)index]
                                   fileName:[NSString stringWithFormat:@"%ld.PNG", (long)index]
                                   mimeType:@"image/jpeg" error:nil];
            index++;
        }
    }];
}

/// 81 发布直播消息接口
- (RACSignal *)addLivemessage:(NSDictionary *)parameters {
    NSMutableDictionary *parametersHandle = [NSMutableDictionary dictionaryWithDictionary:parameters];
    [parametersHandle removeObjectForKey:@"pictureFilePaths"];
    
    return [self POST:@"app/live/post_message.json" parameters:parametersHandle resultClass:[CMTAddPost class] dataBlock:^(id<AFMultipartFormData> formData) {
        
        NSInteger index = 0;
        for (CMTPicture *picture in parameters[@"pictureFilePaths"]) {
            NSURL *pictureFileURL = [NSURL fileURLWithPath:picture.pictureFilePath];
            [formData appendPartWithFileURL:pictureFileURL
                                       name:[NSString stringWithFormat:@"picture%ld", (long)index]
                                   fileName:[NSString stringWithFormat:@"%ld.PNG", (long)index]
                                   mimeType:@"image/jpeg" error:nil];
            index++;
        }
    }];
}

@end
