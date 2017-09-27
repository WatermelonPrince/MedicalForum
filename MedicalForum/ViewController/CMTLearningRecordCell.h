//
//  CMTLearningRecordCell.h
//  MedicalForum
//
//  Created by guoyuanchao on 17/2/13.
//  Copyright © 2017年 CMT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CMTLearningRecordCell : UITableViewCell
@property(nonatomic,strong)UIControl *cellView;
@property(nonatomic,copy)void(^WatchVideo)(CMTLivesRecord *live);
-(void)reloadCell:(NSArray*)dataArray;

@end
