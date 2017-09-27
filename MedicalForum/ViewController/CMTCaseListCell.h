//
//  CMTCaseCell.h
//  MedicalForum
//
//  Created by CMT on 15/6/3.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMTTextMarker.h"
#import "CMTImageMarker.h"

@protocol CMTLiveListCellDelegate<NSObject>

-(void)CMTGoLiveTagList : (CMTLiveTag*)LiveTag ;

@end
@protocol CMTCaseListCellDelegate <NSObject>
@optional
// 点击赞的操作
-(void)CMTSomePraise:(BOOL)ISCancelPraise index:(NSIndexPath*)indexpath;

-(void)CMTClickComments:(NSIndexPath*)indexPath;

-(void)CMTClickShare:(NSIndexPath *)indexPath;

-(void)CmtLiveMore:(NSIndexPath *)indexPath;
@end
@protocol CMTLivedetailsDelegate <NSObject>
-(void)CMTClickPic:(NSString*)picpath;


@end
@interface CMTCaseListCell: UITableViewCell
//标签数组 目前未用到；

@property(nonatomic,copy,readonly)NSMutableArray *tagArray;
@property(nonatomic,weak)UIViewController *lastController;
@property(nonatomic,strong)NSIndexPath *indexPath;
@property(nonatomic,weak)id<CMTCaseListCellDelegate>delegate;
@property(nonatomic, weak)id<CMTLiveListCellDelegate> liveDelegate;
@property(nonatomic, weak)id<CMTLivedetailsDelegate>livedetailsDelegate;
@property(nonatomic,strong)void(^updateheadView)();
//cell绘制区域上下左右的边距
@property(nonatomic,assign) UIEdgeInsets insets;
//是否需要展示评论和点赞
@property(nonatomic,assign)BOOL isShowinteractive;
//搜索关键字
@property(nonatomic,strong)NSString *searchkey;
//是否搜索
@property(nonatomic,assign)BOOL isSearch;
//是否拥有小组信息头
@property(nonatomic,assign) BOOL ishaveSectionHeadView;
//是否是直播详情
@property(nonatomic,assign)BOOL isLivedetails;
//刷新cell坐标和内容，普通的病例Cell
- (void)reloadCaseCell:(CMTPost*)post index:(NSIndexPath*)indexpath;
//刷新cell坐标和内容，直播的Cell
-(void)reloadLiveCell:(CMTLive *)live index:(NSIndexPath *)indexpath;
@property(nonatomic,assign)BOOL ISCanShowBigImage;


@end

