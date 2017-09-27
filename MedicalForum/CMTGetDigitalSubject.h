//
//  CMTGetDigitalSubject.h
//  
//
//  Created by guoyuanchao on 15/12/24.
//
//

#import "CMTClient.h"
@interface CMTClient(CMTGetDigitalSubject)
- (RACSignal *)GetDigitalSubject:(NSDictionary *)parameters;
///获取活动列表
- (RACSignal *)GetDigitalHtml:(NSString *)Url;
@end
