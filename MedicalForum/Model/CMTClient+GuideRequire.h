//
//  CMTClient+GuideRequire.h
//  MedicalForum
//
//  Created by CMT on 15/6/15.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTClient+GuideRequire.h"

@interface CMTClient(GuideRequire)
- (RACSignal *)SentGuideRequire:(NSDictionary *)parameters;
@end
