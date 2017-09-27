//
//  ModelImfo.h
//  IJKPlayerDemo
//
//  Created by gensee on 2017/3/23.
//  Copyright © 2017年 gensee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ModelInfo : NSObject

@property (nonatomic, strong) NSString *userName;

@property (nonatomic, strong) NSString *touserName;

@property (nonatomic, strong) NSString *userId;

@property (nonatomic, strong) NSString *amount;

@property (nonatomic, strong) NSString *total;

@property (nonatomic, strong) NSString *Id;

@property (nonatomic, strong) NSString *time;

@property (nonatomic, strong) NSString *touser;

- (id)initModelIndoWithDictionary:(NSDictionary *)dic;
+ (id)modelInfoWithDictionary:(NSDictionary *)dic;

@end
