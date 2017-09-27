//
//  CMTCommentCount.h
//  MedicalForum
//
//  Created by guanyx on 14/12/11.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTObject.h"

@interface CMTCommentCount : CMTObject

//count	新评论数	收到的新评论数
@property(nonatomic, copy, readonly) NSString *count;

@end
