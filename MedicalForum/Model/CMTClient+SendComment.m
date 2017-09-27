//
//  CMTClient+SendComment.m
//  MedicalForum
//
//  Created by guanyx on 14/12/13.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTClient+SendComment.h"
#import "CMTComment.h"

@implementation CMTClient(SendComment)

- (RACSignal *)sendComment:(NSDictionary *)parameters {
    NSMutableDictionary *parametersHandle = [NSMutableDictionary dictionaryWithDictionary:parameters];
    [parametersHandle removeObjectForKey:@"picture"];

    NSString *picString=[parameters objectForKey:@"picture"];
    if (picString.length==0) {
        // to do 为何返回值是CMTComment? 看下接口文档
        return [self POST:@"app/comment/post.json" parameters:parametersHandle resultClass:[CMTComment class] withStore:NO];

    }else{
        return [self POST:@"app/comment/post.json" parameters:parameters resultClass:[CMTComment class] dataBlock:^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFileURL:[[NSURL alloc]initFileURLWithPath:picString ] name:@"1" fileName:@"1.png" mimeType:@"image/jpeg" error:nil];
        }];
    }
 }

@end
