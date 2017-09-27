//
//  CMTSystemNoticeCell.h
//  MedicalForum
//
//  Created by zhaohuan on 15/11/25.
//  Copyright © 2015年 CMT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMTCaseSystemNoticeModel.h"

@interface CMTSystemNoticeCell : UITableViewCell //组内系统通知

- (void)configureCellWithModel:(CMTCaseSystemNoticeModel *)model;

+(float)getTextheight:(NSString*)text fontsize:(float)size width:(float) width;//计算label高度


@end
