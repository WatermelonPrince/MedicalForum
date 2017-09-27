//
//  CMTBadge.m
//  MedicalForum
//
//  Created by fenglei on 14/12/24.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTBadge.h"

const CGFloat kCMTBadgeWidth =20;

@interface CMTBadge ()

@property (nonatomic, assign) CGPoint badgeCenter;
@property (nonatomic, assign) BOOL initialization;

@end

@implementation CMTBadge

#pragma mark Initializers

- (instancetype)init {
    self = [super init];
    if (self == nil) return nil;
    CMTLog(@"%s", __FUNCTION__);
    @weakify(self);
    [self.rac_willDeallocSignal subscribeCompleted:^{
        CMTLog(@"Badge willDeallocSignal");
    }];
    
    self.backgroundColor = COLOR(c_f74c31);
    self.textColor = COLOR(c_ffffff);
    self.font = FONT(8);
    self.textAlignment = NSTextAlignmentCenter;
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = kCMTBadgeWidth / 2.0;
    
    [[[RACObserve(self, frame) distinctUntilChanged]
      deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        @strongify(self);
        if (self.frame.size.height > 0 && !self.initialization) {
            self.initialization = [self initializeWithSize:self.frame.size];
        }
    }];

    [[[RACObserve(self, text) distinctUntilChanged]
      deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSString * text) {
        @strongify(self);
        NSInteger badgeNumber = [text integerValue];
        CGSize size = self.frame.size;
        BOOL hidden = NO;
        if ([text isEqualToString:@"999+"]) {
            size.width =25;
            size.height = self.layer.masksToBounds?24:self.height;

        }else if (badgeNumber <= 0) {
            hidden = YES;
            
        } else if (badgeNumber <= 99) {
            size.width = kCMTBadgeWidth;
            size.height = self.layer.masksToBounds?kCMTBadgeWidth:self.height;
            
        } else if (badgeNumber <= 999) {
            size.width = kCMTBadgeWidth;
            size.height = self.layer.masksToBounds?kCMTBadgeWidth:self.height;
        } else {
            self.text=@"999+";
            size.width = kCMTBadgeWidth;
            size.height = kCMTBadgeWidth;
            
        }
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, size.width, size.height);
        self.center = self.badgeCenter;
        self.hidden = hidden;
    }];
    
    return self;
}

- (BOOL)initializeWithSize:(CGSize)size {
    CMTLog(@"%s", __FUNCTION__);
    
    self.badgeCenter = self.center;
    
    return YES;
}

@end
