//
//  CMTClient+GuideunReadNotice.h
//  MedicalForum
//
//  Created by CMT on 15/6/15.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTClient+GuideunReadNotice.h"

@interface CMTClient(GuideunReadNotice)
- (RACSignal *)GetGuideunReadNotice:(NSDictionary *)parameters;
@end
