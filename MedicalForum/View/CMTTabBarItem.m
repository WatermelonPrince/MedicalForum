//
//  CMTTabBarItem.m
//  MedicalForum
//
//  Created by fenglei on 15/5/8.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

// view
#import "CMTTabBarItem.h"               // header file
#import "CMTBadgePoint.h"               // 标记红点
#import "CMTBadge.h"

@interface CMTTabBarItem ()

// view
@property (nonatomic, strong) UIImageView *imageView;           // 图片视图
@property (nonatomic, strong) UILabel *titleLabel;              // 标题视图
@property (nonatomic, strong) CMTBadgePoint *badgePoint;        // 标记红点
@property(nonatomic,strong)CMTBadge *badgeNumber ;             //未读文章数

// data
@property (nonatomic, copy) UIImage *image;                     // 默认图片
@property (nonatomic, copy) UIImage *selectedImage;             // 选中图片
@property (nonatomic, copy) NSString *title;                    // 标题

@property (nonatomic, assign) BOOL initialization;              // 是否初始化frame

@end

@implementation CMTTabBarItem

#pragma mark Initializers

- (UIImageView *)imageView {
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc] init];
        _imageView.backgroundColor = COLOR(c_clear);
    }
    
    return _imageView;
}

- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = COLOR(c_clear);
        _titleLabel.textColor = self.index==2?COLOR(c_ffffff):COLOR(c_424242);
        _titleLabel.font = FONT(9.0);
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    return _titleLabel;
}

- (CMTBadgePoint *)badgePoint {
    if (_badgePoint == nil) {
        _badgePoint = [[CMTBadgePoint alloc] init];
    }
    
    return _badgePoint;
}
-(CMTBadge*)badgeNumber{
    if (_badgeNumber==nil) {
        _badgeNumber=[[CMTBadge alloc]init];
    }
    return _badgeNumber;
}
- (instancetype)initWithTitle:(NSString *)title image:(UIImage *)image selectedImage:(UIImage *)selectedImage index:(NSInteger)index{
    self.index=index;
    self=[self initWithTitle:title image:image selectedImage:selectedImage];
    if (self) {
        
    }
    return self;
}
- (instancetype)initWithTitle:(NSString *)title image:(UIImage *)image selectedImage:(UIImage *)selectedImage {
    self = [super init];
    if (self == nil) return nil;
    CMTLog(@"%s", __FUNCTION__);
    @weakify(self);
    [self.rac_willDeallocSignal subscribeCompleted:^{
        CMTLog(@"TabBarItem willDeallocSignal");
    }];
    
    self.title = title;
    self.image = image;
    self.selectedImage = selectedImage;
    
    self.backgroundColor = COLOR(c_clear);
    self.imageView.image = image;
    self.titleLabel.text = title;
    self.badgePoint.hidden = YES;
    self.badgeNumber.hidden=YES;
    
    [[RACObserve(self, badgeValue)
      deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSString *badgeValue) {
        @strongify(self);
        if (!self.isShowBagde) {
            self.badgeNumber.hidden=YES;
            if (badgeValue.integerValue > 0) {
                self.badgePoint.hidden = NO;
            }
            else {
                self.badgePoint.hidden = YES;
            }

        }else{
             self.badgePoint.hidden = YES;
            if (badgeValue.integerValue > 0) {
              self.badgeNumber.hidden=NO;
              self.badgeNumber.text=badgeValue;
            }else{
                self.badgeNumber.hidden=YES;

            }
         }
    }];
    
    // 初始化frame
    [[RACObserve(self, frame)
      deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        @strongify(self);
        if (self.frame.size.height > 0 && !self.initialization) {
        
            self.initialization = [self initializeWithSize:self.frame.size];
        }
    }];
    
    return self;
}

- (BOOL)initializeWithSize:(CGSize)size {
    CMTLog(@"%s", __FUNCTION__);
    
    CGFloat imageViewHeight = 27.0;
    CGFloat imageViewBottomGap = 1.5;
    CGFloat titleLabelHeight = 14.0;
    
    CGFloat imageViewTopGuide = (self.height - (imageViewHeight + imageViewBottomGap + titleLabelHeight))/2.0 + 1.0;
    
    [self.imageView builtinContainer:self WithLeft:0.0 Top:self.index==2?-20:imageViewTopGuide Width:self.index!=2?27.0:69 Height:self.index!=2?27.0:69];
    [self.titleLabel builtinContainer:self WithLeft:0.0 Top:self.index==2?imageViewTopGuide+27+imageViewBottomGap :self.imageView.bottom + imageViewBottomGap Width:self.width Height:titleLabelHeight];

    self.imageView.centerX = self.titleLabel.centerX;
    self.badgePoint.frame = CGRectMake(self.index==2?55:20,self.index==2?self.imageView.height-CMTTabBarHeight:self.imageView.top - 6.5, CMTBadgePointWidth, CMTBadgePointWidth);
    self.badgeNumber.frame=CGRectMake( self.imageView.width-kCMTBadgeWidth/2,  self.imageView.top - 6.5, kCMTBadgeWidth, kCMTBadgeWidth);
    [self.imageView addSubview:self.badgeNumber];
    [self.imageView addSubview:self.badgePoint];
    
    return YES;
}

#pragma mark LifeCycle

- (void)setSelected:(BOOL)selected {
    if (_selected == selected) {
        return;
    }
    
    _selected = selected;
    
    if (selected == YES) {
        self.imageView.image = self.selectedImage;
        self.titleLabel.textColor =self.index==2?[UIColor colorWithHexString:@"#fcffce"]:COLOR(c_32c7c2);
    }
    else {
        self.imageView.image = self.image;
        self.titleLabel.textColor =self.index==2?COLOR(c_ffffff):COLOR(c_424242);
;
    }
}

@end
