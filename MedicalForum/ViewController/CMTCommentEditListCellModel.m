//
//  CMTCommentEditListCellModel.m
//  MedicalForum
//
//  Created by fenglei on 15/1/5.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTCommentEditListCellModel.h"
#import "CMTReceivedComment.h"
#import "CMTSendComment.h"

@interface CMTCommentEditListCellModel ()

// output
@property (nonatomic, copy, readwrite) CMTObject *comment;
@property (nonatomic, copy, readwrite) NSIndexPath *indexPath;

@property(nonatomic, copy, readwrite) NSString *nickname;
@property(nonatomic, copy, readwrite) NSString *picture;
@property(nonatomic, copy, readwrite) NSString *content;
@property(nonatomic, copy, readwrite) NSString *postTitle;
@property(nonatomic, copy, readwrite) NSString *createTime;

@end

@implementation CMTCommentEditListCellModel

- (instancetype)initWithComment:(CMTObject *)comment indexPath:(NSIndexPath *)indexPath {
    self = [super init];
    if (self == nil) return nil;
    
    [self reloadComment:comment indexPath:indexPath];
    
    return self;
}

- (void)reloadComment:(CMTObject *)comment indexPath:(NSIndexPath *)indexPath {
    self.comment = comment;
    self.indexPath = indexPath;
    NSString *userNickname = CMTUSERINFO.nickname ?: @"";
    
    if ([comment isKindOfClass:[CMTReceivedComment class]]) {
        CMTReceivedComment *receivedComment = (CMTReceivedComment *)comment;
        self.picture = receivedComment.picture;
        self.nickname = [NSString stringWithFormat:@"%@ 回复 %@", receivedComment.nickname, userNickname];
        self.createTime = DATE(receivedComment.createTime);
        self.content = receivedComment.content;
        self.postTitle = receivedComment.postTitle;
        
    }
    else if ([comment isKindOfClass:[CMTSendComment class]]) {
        CMTSendComment *sendComment = (CMTSendComment *)comment;
        self.picture = CMTUSERINFO.picture;
        if ([sendComment.noticeType isEqual:@"1"]) {
            self.nickname = userNickname;
        }
        else {
            self.nickname = [NSString stringWithFormat:@"%@ 回复 %@", userNickname ?: @"", sendComment.beNickname ?: @""];
        }
        self.createTime = DATE(sendComment.createTime);
        self.content = sendComment.content;
        self.postTitle = sendComment.postTitle;
    }
}

@end
