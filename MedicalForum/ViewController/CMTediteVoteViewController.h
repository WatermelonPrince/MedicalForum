//
//  CMTediteVoteViewController.h
//  MedicalForum
//
//  Created by guoyuanchao on 15/11/24.
//  Copyright © 2015年 CMT. All rights reserved.
//

#import "CMTBaseViewController.h"

@interface CMTediteVoteViewController : CMTBaseViewController
@property(nonatomic,copy)void(^updatedata)(NSString*);
-(instancetype)initWithtext:(NSString*)text maxnumber:(NSInteger)maxNumber;
@end
