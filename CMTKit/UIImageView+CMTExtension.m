//
//  UIImageView+CMTExtension.m
//  MedicalForum
//
//  Created by fenglei on 15/1/7.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "UIImageView+CMTExtension.h"
#import "UIImageView+WebCache.h"
#import <objc/runtime.h>

@implementation UIImageView (CMTExtension)

static void *UIImageViewCMTImageURLStringKey = &UIImageViewCMTImageURLStringKey;

- (NSString *)imageURLString {
    return objc_getAssociatedObject(self, UIImageViewCMTImageURLStringKey);
}

- (void)setImageURLString:(NSString *)imageURLString {
    NSString *_imageURLString = objc_getAssociatedObject(self, UIImageViewCMTImageURLStringKey);
    @try {
        if ([_imageURLString isEqual:imageURLString]) return;
    }
    @catch (NSException *exception) {
        CMTLogError(@"UIImageView Compare Image URL String Exception: %@", exception);
    }
    
    objc_setAssociatedObject(self, UIImageViewCMTImageURLStringKey, imageURLString, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)setImageURL:(NSString *)URLString placeholderImage:(UIImage *)placeholderImage {
    @weakify(self);
    self.imageURLString = URLString;
    
    // URL为空
    if (BEMPTY(URLString)) {
        self.image = placeholderImage;
        return;
    }

    // 读取缓存图片
    RACSignal *loadImageSignal = [[[RACSignal return:URLString]
                                   deliverOn:[RACScheduler scheduler]] map:^id(NSString *URL) {
        return @{
                 CMTExtensionUIImageTupleImageURLKey: URL ?: @"",
                 CMTExtensionUIImageTupleImagePathKey: [UIImage imagePathWithURL:URL] ?: @"",
                 };
    }];
    
    // 设置缓存图片
    [[[[loadImageSignal filter:^BOOL(NSDictionary *tuple) {
        @strongify(self);
        return !BEMPTY(tuple[CMTExtensionUIImageTupleImagePathKey]) && [tuple[CMTExtensionUIImageTupleImageURLKey] isEqual:self.imageURLString];
    }] map:^id(NSDictionary *tuple) {
        return [[UIImage alloc] initWithContentsOfFile:tuple[CMTExtensionUIImageTupleImagePathKey]];
    }] deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(UIImage *image) {
        @strongify(self);
        if (image != nil) {
            self.image = image;
        }
        else {
            CMTLogError(@"UIImageView Load Image From Cache Error: Init With File Failure");
        }
    }];
    
    // 没有缓存图片
    [[[loadImageSignal filter:^BOOL(NSDictionary *tuple) {
        return BEMPTY(tuple[CMTExtensionUIImageTupleImagePathKey]);
    }] deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSDictionary *tuple) {
        @strongify(self);
        // 设置等待图片
        self.image = placeholderImage;
        // 请求图片
        [[[[[UIImage requestImageWithURL:tuple[CMTExtensionUIImageTupleImageURLKey]]
            filter:^BOOL(NSDictionary *imageTuple) {
                @strongify(self);
                return [imageTuple[CMTExtensionUIImageTupleImageURLKey] isEqual:self.imageURLString];
            }]
           map:^id(NSDictionary *imageTuple) {
               return [[UIImage alloc] initWithContentsOfFile:imageTuple[CMTExtensionUIImageTupleImagePathKey]];
           }]
          deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(UIImage *image) {
            @strongify(self);
            if (image != nil) {
                self.image = image;
            }
            else {
                CMTLogError(@"UIImageView Request Image Error: Init With File Failure");
            }
        } error:^(NSError *error) {
            CMTLogError(@"UIImageView Request Image Error: %@", error);
        }];
    }];
}

- (void)setImageURL:(NSString *)URLString placeholderImage:(UIImage *)placeholderImage contentSize:(CGSize)contentSize {
    // URL为空
    if (BEMPTY(URLString)) {
        self.image = placeholderImage;
        return;
    }
    
    NSURL *imageURL = nil;
    if (CGSizeEqualToSize(contentSize, CGSizeZero)) {
        imageURL = [NSURL URLWithString:URLString];
    }
    else {
        imageURL = [NSURL URLWithString:[UIImage scaledImageURLWithURL:URLString contentSize:contentSize]];
    }
    
    [self sd_setImageWithURL:imageURL
            placeholderImage:placeholderImage
                     options:SDWebImageHighPriority];
}

- (void)setQuadrateScaledImageURL:(NSString *)URLString placeholderImage:(UIImage *)placeholderImage width:(CGFloat)width {
    // URL为空
    if (BEMPTY(URLString)) {
        self.image = placeholderImage;
        return;
    }
    
    NSURL *imageURL = nil;
    if (width == 0) {
        imageURL = [NSURL URLWithString:URLString];
    }
    else {
        imageURL = [NSURL URLWithString:[UIImage quadrateScaledImageURLWithURL:URLString width:width]];
    }
    
    [self sd_setImageWithURL:imageURL
            placeholderImage:placeholderImage
                     options:SDWebImageHighPriority];
}

- (void)setLimitedImageURL:(NSString *)URLString placeholderImage:(UIImage *)placeholderImage {
    // URL为空
    if (BEMPTY(URLString)) {
        self.image = placeholderImage;
        return;
    }
    
    [self sd_setImageWithURL:[NSURL URLWithString:[UIImage lowQualityImageURLWithURL:URLString]]
            placeholderImage:placeholderImage
                     options:SDWebImageHighPriority];
}

- (void)setLimitedImageURL:(NSString *)URLString placeholderImage:(UIImage *)placeholderImage contentSize:(CGSize)contentSize {
    // URL为空
    if (BEMPTY(URLString)) {
        self.image = placeholderImage;
        return;
    }
    
    [self sd_setImageWithURL:[NSURL URLWithString:[UIImage lowQualityImageURLWithURL:URLString contentSize:contentSize]]
            placeholderImage:placeholderImage
                     options:SDWebImageHighPriority];
}



@end
