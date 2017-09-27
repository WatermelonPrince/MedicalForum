//
//  LDZMoviePlayerController.h
//  LDZMoviewPlayer_Xib
//
//  Created by rongxun02 on 15/11/24.
//  Copyright © 2015年 DongZe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
@interface LDZMoviePlayerController : CMTBaseViewController
@property (nonatomic, strong) NSString *networkReachabilityStatus;
@property (nonatomic, copy)NSString *postId;
@property(nonatomic,assign)CGFloat playtime;
@property(nonatomic,copy)void(^updateReadtime)(CGFloat time);
-(instancetype)initWithUrl:(NSURL*)url;
-(instancetype)initWithUrl:(NSURL*)url fromDownCenter:(BOOL)flag;
@end
