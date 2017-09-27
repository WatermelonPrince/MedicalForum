//
//  CMTGetDigitalSubject.m
//  
//
//  Created by guoyuanchao on 15/12/24.
//
//

#import "CMTGetDigitalSubject.h"
@implementation CMTClient(CMTGetDigitalSubject)
///获取数字报详情
- (RACSignal *)GetDigitalSubject:(NSDictionary *)parameters {
    
    return [self GET:@"app/user/epaper_subject.json" parameters:parameters resultClass:[CMTDigitalObject class] withStore:NO];
}
///获取html文本
- (RACSignal *)GetDigitalHtml:(NSString *)Url {
    
    return [self GET:Url parameters:@{} resultClass:[CMTDigitalObject class] withStore:NO];
}

@end

