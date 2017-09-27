//
//  CMTBadgePoint.m
//  MedicalForum
//
//  Created by fenglei on 15/2/11.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTBadgePoint.h"

const CGFloat CMTBadgePointWidth = 8.0;

@interface CMTBadgePoint ()

@property (nonatomic, assign) BOOL initialization;

@end

@implementation CMTBadgePoint

#pragma mark Initializers

- (instancetype)init {
    self = [super init];
    if (self == nil) return nil;
    CMTLog(@"%s", __FUNCTION__);
    @weakify(self);
    [self.rac_willDeallocSignal subscribeCompleted:^{
        CMTLog(@"BadgePoint willDeallocSignal");
    }];
    
    self.backgroundColor = COLOR(c_f74c31);
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = CMTBadgePointWidth / 2.0;
    
    [[RACObserve(self, frame) deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        @strongify(self);
        if (!self.initialization) {
            self.initialization = [self initializeWithSize:self.frame.size];
        }
    }];
    
    return self;
}

- (BOOL)initializeWithSize:(CGSize)size {
    CMTLog(@"%s", __FUNCTION__);
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, CMTBadgePointWidth, CMTBadgePointWidth);
    
    return YES;
}

@end
