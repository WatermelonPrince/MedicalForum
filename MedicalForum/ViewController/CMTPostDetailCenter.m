//
//  CMTPostDetailCenter.m
//  MedicalForum
//
//  Created by fenglei on 15/7/30.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

// controller
#import "CMTPostDetailCenter.h"
#import "CMTPostDetailViewController.h"                     // 文章详情
#import "CMTCaseDetailViewController.h"                     // 病例详情

@interface CMTPostDetailCenter ()<UIGestureRecognizerDelegate>

@end

@implementation CMTPostDetailCenter

#pragma mark - Initializers
+ (instancetype)postDetailWithPostId:(NSString *)postId
                              isHTML:(NSString *)isHTML
                             postURL:(NSString *)postURL
                             group:(CMTGroup *)group
                          postModule:(NSString *)postModule
                      postDetailType:(CMTPostDetailType)postDetailType{
    // 病例详情
    if (postModule.isPostModuleCase) {
        return [[CMTCaseDetailViewController alloc] initWithPostId:postId
                                                            isHTML:isHTML
                                                           postURL:postURL
                                                         group:group
                                                        postModule:postModule
                                                    postDetailType:postDetailType];
    }
    // 文章详情
    else {
        return [[CMTPostDetailViewController alloc] initWithPostId:postId
                                                            isHTML:isHTML
                                                           postURL:postURL
                                                        postModule:postModule
                                                    postDetailType:postDetailType];
    }

}
+ (instancetype)postDetailWithPostId:(NSString *)postId
                              isHTML:(NSString *)isHTML
                             postURL:(NSString *)postURL
                             group:(CMTGroup *)group
                          postModule:(NSString *)postModule
                  toDisplayedComment:(CMTObject *)toDisplayedComment {
    
    // 病例详情
    if (postModule.isPostModuleCase) {
        return [[CMTCaseDetailViewController alloc] initWithPostId:postId
                                                            isHTML:isHTML
                                                           postURL:postURL
                                                          group:group
                                                        postModule:postModule
                                                toDisplayedComment:toDisplayedComment];
    }
    // 文章详情
    else {
        return [[CMTPostDetailViewController alloc] initWithPostId:postId
                                                            isHTML:isHTML
                                                           postURL:postURL
                                                        postModule:postModule
                                                toDisplayedComment:toDisplayedComment];
    }
}


+ (instancetype)postDetailWithPostId:(NSString *)postId
                              isHTML:(NSString *)isHTML
                             postURL:(NSString *)postURL
                          postModule:(NSString *)postModule
                      postDetailType:(CMTPostDetailType)postDetailType {
    
    // 病例详情
    if (postModule.isPostModuleCase) {
        return [[CMTCaseDetailViewController alloc] initWithPostId:postId
                                                            isHTML:isHTML
                                                           postURL:postURL
                                                        postModule:postModule
                                                    postDetailType:postDetailType];
    }
    // 文章详情
    else {
        return [[CMTPostDetailViewController alloc] initWithPostId:postId
                                                            isHTML:isHTML
                                                           postURL:postURL
                                                        postModule:postModule
                                                    postDetailType:postDetailType];
    }
}

+ (instancetype)postDetailWithPostId:(NSString *)postId
                              isHTML:(NSString *)isHTML
                             postURL:(NSString *)postURL
                          postModule:(NSString *)postModule
                               group:(CMTGroup *)group
                          iscanShare:(BOOL)iscanShare
                      postDetailType:(CMTPostDetailType)postDetailType {
    
    // 病例详情
    if (postModule.isPostModuleCase) {
        if (group == nil) {
           group = [[CMTGroup alloc]init];
        }
        group.groupType=iscanShare?@"1":@"0";
        CMTCaseDetailViewController *caseDetail=[[CMTCaseDetailViewController alloc] initWithPostId:postId
                                                                                             isHTML:isHTML
                                                                                            postURL:postURL
                                                                                          group:group
                                                                                         postModule:postModule
                                                                                     postDetailType:postDetailType];
        return caseDetail;
    }
    // 文章详情
    else {
        return [[CMTPostDetailViewController alloc] initWithPostId:postId
                                                           isHTML:isHTML
                                                          postURL:postURL
                                                       postModule:postModule
                                                   postDetailType:postDetailType];

    }
}



+ (instancetype)postDetailWithPostId:(NSString *)postId
                              isHTML:(NSString *)isHTML
                             postURL:(NSString *)postURL
                          postModule:(NSString *)postModule
                  toDisplayedComment:(CMTObject *)toDisplayedComment {
    
    // 病例详情
    if (postModule.isPostModuleCase) {
        CMTCaseDetailViewController *caseDetail=[[CMTCaseDetailViewController alloc] initWithPostId:postId
                                                                                       isHTML:isHTML
                                                                                      postURL:postURL
                                                                                   postModule:postModule
                                                                           toDisplayedComment:toDisplayedComment];
       
        
        return caseDetail;
    }
    // 文章详情
    else {
        return [[CMTPostDetailViewController alloc] initWithPostId:postId
                                                            isHTML:isHTML
                                                           postURL:postURL
                                                        postModule:postModule
                                                toDisplayedComment:toDisplayedComment];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
}







- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
