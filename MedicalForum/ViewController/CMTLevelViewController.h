//
//  CMTLevelViewController.h
//  MedicalForum
//
//  Created by zhaohuan on 16/4/1.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CMTLevelViewController : CMTBaseViewController
@property(nonatomic,copy)void(^updateLeve)(NSString *Leve);
@end
