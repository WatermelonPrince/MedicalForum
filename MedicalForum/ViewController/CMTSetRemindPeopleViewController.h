//
//  CMTSetRemindPeopleViewController.h
//  MedicalForum
//
//  Created by guoyuanchao on 15/11/23.
//  Copyright © 2015年 CMT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CMTSetRemindPeopleViewController : CMTBaseViewController
-(instancetype)initWithGroupID:(NSString*)groupID;
-(instancetype)initWithGroupID:(NSString*)groupID remindArray:(NSArray*)array model:(NSString*)model;
@property(nonatomic,copy)void(^updatedata)();
@property(nonatomic,copy)void(^updateRemind)(NSArray*);


@end
