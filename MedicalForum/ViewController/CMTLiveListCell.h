//
//  CMTLiveListCell.h
//  MedicalForum
//
//  Created by guoyuanchao on 15/8/20.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CMTLiveListCell : UITableViewCell
@property(nonatomic,strong)NSIndexPath *index;
@property(nonatomic,readonly)UIImageView *livePic;
-(void)reloadCell:(CMTLive*)live index:(NSIndexPath*)index;
@end
