//
//  UIImageView+CMTExtension.h
//  MedicalForum
//
//  Created by fenglei on 15/1/7.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (CMTExtension)

// The URL string of the image that should displayed in the image view, default is nil.
@property (nonatomic, copy) NSString *imageURLString;

//- (void)setImageURL:(NSString *)URLString placeholderImage:(UIImage *)placeholderImage;

- (void)setImageURL:(NSString *)URLString placeholderImage:(UIImage *)placeholderImage contentSize:(CGSize)contentSize;
- (void)setQuadrateScaledImageURL:(NSString *)URLString placeholderImage:(UIImage *)placeholderImage width:(CGFloat)width;
- (void)setLimitedImageURL:(NSString *)URLString placeholderImage:(UIImage *)placeholderImage;
- (void)setLimitedImageURL:(NSString *)URLString placeholderImage:(UIImage *)placeholderImage contentSize:(CGSize)contentSize;

@end
