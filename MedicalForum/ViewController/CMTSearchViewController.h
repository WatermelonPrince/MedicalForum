//
//  CMTSearchViewController.h
//  MedicalForum
//
//  Created by Bo Shen on 14/12/16.
//  Copyright (c) 2014年 CMT. All rights reserved.
//


typedef NS_ENUM(NSInteger, NSTouchState)
{
    kTouchStatsBegin,
    kTouchStatsCanCel,
};

#import "CMTBaseViewController.h"
#import "CMTTextSearchFileld.h"

@interface CMTSearchViewController : CMTBaseViewController

/*纪录点击TextField状态*/
@property (assign)NSTouchState mCurrentStats;


@end
