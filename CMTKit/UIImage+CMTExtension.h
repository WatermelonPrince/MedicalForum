//
//  UIImage+CMTExtension.h
//  MedicalForum
//
//  Created by Bo Shen on 15/1/5.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (CMTExtension)

/* For Image Effects */

+ (instancetype)circleImageWithName:(NSData *)data borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor;

+ (instancetype)circleImage:(UIImage*) image withParam:(CGFloat) inset;

/// blur effect image
- (UIImage *)applyLightEffect;
- (UIImage *)applyExtraLightEffect;
- (UIImage *)applyDarkEffect;
- (UIImage *)applyTintEffectWithColor:(UIColor *)tintColor;

/// blur image
- (UIImage *)applyBlurWithRadius:(CGFloat)blurRadius
                       tintColor:(UIColor *)tintColor
           saturationDeltaFactor:(CGFloat)saturationDeltaFactor
                       maskImage:(UIImage *)maskImage;

/* For Image Request */

/// return the imagePath string related to the URL,
+ (NSString *)generateImagePathWithURL:(NSString *)URLString;

/// return the imagePath at the ImageCachedDirectory related to the URL,
/// if image not exists or failed return nil
+ (NSString *)imagePathWithURL:(NSString *)URLString;

/// return the image related to the URL from CacheImages if that image exists, otherwise return nil.
+ (instancetype)loadImageWithURL:(NSString *)URLString;

FOUNDATION_EXPORT NSString * const CMTExtensionUIImageTupleImageURLKey;
FOUNDATION_EXPORT NSString * const CMTExtensionUIImageTupleImagePathKey;
FOUNDATION_EXPORT NSString * const CMTImageRequestRefererKey;
FOUNDATION_EXPORT NSString * const CMTImageRequestReferer;

/// Create a signal that send 'next' a RACTuple of UIImage, imageURLString, imagePathString,
/// if that image exists at CacheImages, it will send 'next' and 'complete' immediately,
/// otherwise a request will be made related to the URL,
/// when request success, send 'next' and 'complete' and cache that image,
/// if request failed, send 'error'.
+ (RACSignal *)requestImageWithURL:(NSString *)URLString;

/// return the scaled ImageURL related to the URL and contentSize
+ (NSString *)scaledImageURLWithURL:(NSString *)URLString contentSize:(CGSize)contentSize;

/// return the quadrateScaled ImageURL related to the URL and width
+ (NSString *)quadrateScaledImageURLWithURL:(NSString *)URLString width:(CGFloat)width;

/// return the full quality ImageURL related to the URL
+ (NSString *)fullQualityImageURLWithURL:(NSString *)URLString;

/// return the low quality ImageURL related to the URL
+ (NSString *)lowQualityImageURLWithURL:(NSString *)URLString;
/// return the low quality ImageURL related to the URL
+ (NSString *)lowQualityImageURLWithURL:(NSString *)URLString contentSize:(CGSize)contentSize;

/// return the compact ImageURL related to the URL
+ (NSString *)compactImageURLWithURL:(NSString *)URLString;

/// return the imagePath at the ImageCachedDirectory of the 'originality' or 'compact' image related to the URL,
/// if none of that images exist or failed return nil
+ (NSString *)compactImagePathWithURL:(NSString *)URLString;

/// return the compact image related to the URL from CacheImages if that compact image exists, otherwise return nil.
+ (instancetype)loadCompactImageWithURL:(NSString *)URLSting;

/// Compact the UIImage in the signal returned of +requestImageWithURL.
+ (RACSignal *)requestCompactImageWithURL:(NSString *)URLString;

@end