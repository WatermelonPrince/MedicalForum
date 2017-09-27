//
//  CMTLableMangeView.h
//  MedicalForum
//
//  Created by CMT on 15/6/1.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol CMTTagMarkerDelegte <NSObject>
@optional
-(void)CMTGotoGuidePostListView:(CMTDisease*)Disease;
-(void)CmtAddTagAction;
@end
@interface CMTTagMarker : UIView
@property(nonatomic,weak)id<CMTTagMarkerDelegte>delegate;
//判断是否显示气泡
@property(nonatomic,assign)BOOL isShowBubble;
//0 文章 1，小组，2 指南
@property(nonatomic,strong)NSString *model;
-(void)DrawTagMakerMangeView:(NSMutableArray*)lableArray;
//是否隐藏AddTagButton
-(void)setIsLive : (BOOL) isLive;
@end


