//
//  CMTUserInfo.m
//  MedicalForum
//
//  Created by guanyx on 14/12/11.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTUserInfo.h"

@implementation CMTUserInfo

// `+<key>JSONTransformer` method
+ (NSValueTransformer *)followsJSONTransformer {
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[CMTFollow class]];
}
+ (NSValueTransformer *)addressesJSONTransformer {
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[CMTReceiverAddress class]];
}
+ (NSValueTransformer *)departJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[CMTSubDepart class]];
}
+ (NSValueTransformer *)epaperSubjectResultJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[CMTUserInfo class]];
}
- (void)setFollows:(NSArray *)follows {
    if (_follows == follows) return;
    
    // 升序排列
    NSArray *sortedArray = nil;
    @try {
        sortedArray = [follows sortedArrayUsingComparator:^NSComparisonResult(CMTFollow *follow1, CMTFollow *follow2) {
            return [follow1.subjectId compare:follow2.subjectId options:NSCaseInsensitiveSearch];
        }];
    }
    @catch (NSException *exception) {
        sortedArray = nil;
        CMTLogError(@"USERINFO -Follows Sort Array Exception: %@", exception);
    }
    sortedArray = sortedArray ?: follows;
    
    _follows =  [sortedArray copy];
}

/**
 * 当前用户是不是作者
 * @return
 */
-(BOOL) isAuthor{
    if(nil != self.roleId){
        if([self.roleId isEqualToString:@"2"]
           || [self.roleId isEqualToString:@"3"]
            || [self.roleId isEqualToString:@"4"]){
            return YES;
        }
    }
    return NO;
}

@end
