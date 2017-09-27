//
//  UIImage+CMTExtension.m
//  MedicalForum
//
//  Created by Bo Shen on 15/1/5.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "UIImage+CMTExtension.h"
#import <Accelerate/Accelerate.h>

@implementation UIImage (CMTExtension)

#pragma mark - For Image Effects

+ (instancetype)circleImageWithName:(NSData *)data borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor
{
    
    // 1.加载原图
    UIImage *oldImage = [UIImage imageWithData:data];
    
    // 2.开启上下文
    CGFloat imageW = oldImage.size.width + 2 * borderWidth;
    CGFloat imageH = oldImage.size.height + 2 * borderWidth;
    CGSize imageSize = CGSizeMake(imageW, imageH);
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0.0);
    
    // 3.取得当前的上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // 4.画边框(大圆)
    [borderColor set];
    CGFloat bigRadius = imageW * 0.35; // 大圆半径
    
    CGFloat centerX = bigRadius; // 圆心
    CGFloat centerY = bigRadius;
    CGContextAddArc(ctx, centerX, centerY, bigRadius, 0, M_PI * 2, 0);
    CGContextFillPath(ctx); // 画圆
    
    // 5.小圆
    CGFloat smallRadius = bigRadius - borderWidth;
    CGContextAddArc(ctx, centerX, centerY, smallRadius, 0, M_PI * 2, 0);
    // 裁剪(后面画的东西才会受裁剪的影响)
    CGContextClip(ctx);
    
    // 6.画图
    //[oldImage drawInRect:CGRectMake(borderWidth, borderWidth, oldImage.size.width, oldImage.size.height)];
    [oldImage drawInRect:CGRectMake(borderWidth, borderWidth, oldImage.size.width, oldImage.size.height)];
    
    // 7.取图
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 8.结束上下文
    UIGraphicsEndImageContext();
    
    return newImage;
}

/**
 *@param inset 创建出的位图大小，也是返回图像的大小
 */
+(instancetype) circleImage:(UIImage*) image withParam:(CGFloat) inset {
    
    UIGraphicsBeginImageContext(image.size);
    
    CGContextRef context =UIGraphicsGetCurrentContext();
    
    //圆的边框宽度为2，颜色为红色
    
    CGContextSetLineWidth(context,2);
    
    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
    
    CGRect rect = CGRectMake(inset, inset, image.size.width - inset *2.0f, image.size.height - inset *2.0f);
    
    CGContextAddEllipseInRect(context, rect);
    
    CGContextClip(context);
    
    //在圆区域内画出image原图
    
    [image drawInRect:rect];
    
    CGContextAddEllipseInRect(context, rect);
    
    CGContextStrokePath(context);
    
    //生成新的image
    
    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newimg;
    
}

/// blur effect image
- (UIImage *)applyLightEffect {
    UIColor *tintColor = [UIColor colorWithWhite:1.0 alpha:0.3];
    return [self applyBlurWithRadius:30 tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil];
}

- (UIImage *)applyExtraLightEffect {
    UIColor *tintColor = [UIColor colorWithWhite:0.97 alpha:0.82];
    return [self applyBlurWithRadius:20 tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil];
}

- (UIImage *)applyDarkEffect {
    UIColor *tintColor = [UIColor colorWithWhite:0.11 alpha:0.73];
    return [self applyBlurWithRadius:20 tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil];
}

- (UIImage *)applyTintEffectWithColor:(UIColor *)tintColor {
    const CGFloat EffectColorAlpha = 0.6;
    UIColor *effectColor = tintColor;
    NSUInteger componentCount = CGColorGetNumberOfComponents(tintColor.CGColor);
    if (componentCount == 2) {
        CGFloat b;
        if ([tintColor getWhite:&b alpha:NULL]) {
            effectColor = [UIColor colorWithWhite:b alpha:EffectColorAlpha];
        }
    }
    else {
        CGFloat r, g, b;
        if ([tintColor getRed:&r green:&g blue:&b alpha:NULL]) {
            effectColor = [UIColor colorWithRed:r green:g blue:b alpha:EffectColorAlpha];
        }
    }
    return [self applyBlurWithRadius:10 tintColor:effectColor saturationDeltaFactor:-1.0 maskImage:nil];
}

/// blur image
- (UIImage *)applyBlurWithRadius:(CGFloat)blurRadius
                       tintColor:(UIColor *)tintColor
           saturationDeltaFactor:(CGFloat)saturationDeltaFactor
                       maskImage:(UIImage *)maskImage {
    
    // Check pre-conditions.
    if (self.size.width < 1 || self.size.height < 1) {
        CMTLogError(@"*** error: invalid size: (%.2f x %.2f). Both dimensions must be >= 1: %@", self.size.width, self.size.height, self);
        return nil;
    }
    if (!self.CGImage) {
        CMTLogError(@"*** error: image must be backed by a CGImage: %@", self);
        return nil;
    }
    if (maskImage && !maskImage.CGImage) {
        CMTLogError(@"*** error: maskImage must be backed by a CGImage: %@", maskImage);
        return nil;
    }
    
    CGRect imageRect = { CGPointZero, self.size };
    UIImage *effectImage = self;
    
    BOOL hasBlur = blurRadius > __FLT_EPSILON__;
    BOOL hasSaturationChange = fabs(saturationDeltaFactor - 1.) > __FLT_EPSILON__;
    if (hasBlur || hasSaturationChange) {
        UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
        CGContextRef effectInContext = UIGraphicsGetCurrentContext();
        CGContextScaleCTM(effectInContext, 1.0, -1.0);
        CGContextTranslateCTM(effectInContext, 0, -self.size.height);
        CGContextDrawImage(effectInContext, imageRect, self.CGImage);
        
        vImage_Buffer effectInBuffer;
        effectInBuffer.data     = CGBitmapContextGetData(effectInContext);
        effectInBuffer.width    = CGBitmapContextGetWidth(effectInContext);
        effectInBuffer.height   = CGBitmapContextGetHeight(effectInContext);
        effectInBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectInContext);
        
        UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
        CGContextRef effectOutContext = UIGraphicsGetCurrentContext();
        vImage_Buffer effectOutBuffer;
        effectOutBuffer.data     = CGBitmapContextGetData(effectOutContext);
        effectOutBuffer.width    = CGBitmapContextGetWidth(effectOutContext);
        effectOutBuffer.height   = CGBitmapContextGetHeight(effectOutContext);
        effectOutBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectOutContext);
        
        if (hasBlur) {
            // A description of how to compute the box kernel width from the Gaussian
            // radius (aka standard deviation) appears in the SVG spec:
            // http://www.w3.org/TR/SVG/filters.html#feGaussianBlurElement
            //
            // For larger values of 's' (s >= 2.0), an approximation can be used: Three
            // successive box-blurs build a piece-wise quadratic convolution kernel, which
            // approximates the Gaussian kernel to within roughly 3%.
            //
            // let d = floor(s * 3*sqrt(2*pi)/4 + 0.5)
            //
            // ... if d is odd, use three box-blurs of size 'd', centered on the output pixel.
            //
            CGFloat inputRadius = blurRadius * [[UIScreen mainScreen] scale];
            uint32_t radius = floor(inputRadius * 3. * sqrt(2 * M_PI) / 4 + 0.5);
            if (radius % 2 != 1) {
                radius += 1; // force radius to be odd so that the three box-blur methodology works.
            }
            vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, (uint32_t)radius, (uint32_t)radius, 0, kvImageEdgeExtend);
            vImageBoxConvolve_ARGB8888(&effectOutBuffer, &effectInBuffer, NULL, 0, 0, (uint32_t)radius, (uint32_t)radius, 0, kvImageEdgeExtend);
            vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, (uint32_t)radius, (uint32_t)radius, 0, kvImageEdgeExtend);
            
        }
        BOOL effectImageBuffersAreSwapped = NO;
        if (hasSaturationChange) {
            CGFloat s = saturationDeltaFactor;
            CGFloat floatingPointSaturationMatrix[] = {
                0.0722 + 0.9278 * s,  0.0722 - 0.0722 * s,  0.0722 - 0.0722 * s,  0,
                0.7152 - 0.7152 * s,  0.7152 + 0.2848 * s,  0.7152 - 0.7152 * s,  0,
                0.2126 - 0.2126 * s,  0.2126 - 0.2126 * s,  0.2126 + 0.7873 * s,  0,
                0,                    0,                    0,  1,
            };
            const int32_t divisor = 256;
            NSUInteger matrixSize = sizeof(floatingPointSaturationMatrix)/sizeof(floatingPointSaturationMatrix[0]);
            int16_t saturationMatrix[matrixSize];
            for (NSUInteger i = 0; i < matrixSize; ++i) {
                saturationMatrix[i] = (int16_t)roundf(floatingPointSaturationMatrix[i] * divisor);
            }
            if (hasBlur) {
                vImageMatrixMultiply_ARGB8888(&effectOutBuffer, &effectInBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
                effectImageBuffersAreSwapped = YES;
            }
            else {
                vImageMatrixMultiply_ARGB8888(&effectInBuffer, &effectOutBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
            }
        }
        if (!effectImageBuffersAreSwapped)
            effectImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        if (effectImageBuffersAreSwapped)
            effectImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    // Set up output context.
    UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
    CGContextRef outputContext = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(outputContext, 1.0, -1.0);
    CGContextTranslateCTM(outputContext, 0, -self.size.height);
    
    // Draw base image.
    CGContextDrawImage(outputContext, imageRect, self.CGImage);
    
    // Draw effect image.
    if (hasBlur) {
        CGContextSaveGState(outputContext);
        if (maskImage) {
            CGContextClipToMask(outputContext, imageRect, maskImage.CGImage);
        }
        CGContextDrawImage(outputContext, imageRect, effectImage.CGImage);
        CGContextRestoreGState(outputContext);
    }
    
    // Add in color tint.
    if (tintColor) {
        CGContextSaveGState(outputContext);
        CGContextSetFillColorWithColor(outputContext, tintColor.CGColor);
        CGContextFillRect(outputContext, imageRect);
        CGContextRestoreGState(outputContext);
    }
    
    // Output image is ready.
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return outputImage;
}

#pragma mark - For Image Request

+ (NSString *)generateImagePathWithURL:(NSString *)URLString {
    if (BEMPTY(URLString)) {
        return nil;
    }
    
    NSString *imagePath = nil;
    @try {
        NSString *imageName = [URLString stringByReplacingOccurrencesOfString:@"/" withString:@""];
        imagePath = [PATH_CACHE_IMAGES stringByAppendingPathComponent:imageName];
        if (BEMPTY(imagePath)) {
            imagePath = nil;
        }
    }
    @catch (NSException *exception) {
        imagePath = nil;
        CMTLogError(@"UIImage Generate imagePath With URL: %@ Exception: %@", URLString, exception);
    }
    
    return imagePath;
}

+ (NSString *)imagePathWithURL:(NSString *)URLString {
    NSString *imagePath = [self generateImagePathWithURL:URLString];
    if (imagePath == nil) {
        return nil;
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath]) {
        imagePath = nil;
    }
    
    return imagePath;
}

+ (instancetype)loadImageWithURL:(NSString *)URLString {
    return [[UIImage alloc] initWithContentsOfFile:[UIImage imagePathWithURL:URLString]];
}

NSString * const CMTExtensionUIImageTupleImageURLKey = @"CMTExtensionUIImageTupleImageURLKey";
NSString * const CMTExtensionUIImageTupleImagePathKey = @"CMTExtensionUIImageTupleImagePathKey";
NSString * const CMTImageRequestRefererKey = @"Referer";
NSString * const CMTImageRequestReferer = @"http://app.medtrib.cn/";

+ (NSOperationQueue *)sharedImageRequestOperationQueue {
    static NSOperationQueue *sharedImageRequestOperationQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedImageRequestOperationQueue = [[NSOperationQueue alloc] init];
        sharedImageRequestOperationQueue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount;
    });
    
    return sharedImageRequestOperationQueue;
}

+ (RACSignal *)requestImageWithURL:(NSString *)URLString {
    // 目前的问题 flattenMap只flatten sendNext 所以 sendCompleted sendError 会被忽略 无法得到错误信息
    // 所以目前错误信息以CMTLogError形式log
    return [[[RACSignal return:URLString] deliverOn:[RACScheduler scheduler]] flattenMap:^RACStream *(NSString *URL) {
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            if (!BEMPTY(URL)) {
                __block NSString *imagePathString = [UIImage generateImagePathWithURL:URL];
                if (!BEMPTY(imagePathString)) {
                    
                    // cache image exists
                    if ([[NSFileManager defaultManager] fileExistsAtPath:imagePathString]) {
                        NSDictionary *imageTuple = nil;
                        @try {
                            imageTuple = @{
                                           CMTExtensionUIImageTupleImageURLKey: URL ?: @"",
                                           CMTExtensionUIImageTupleImagePathKey: imagePathString ?: @"",
                                           };
                        }
                        @catch (NSException *exception) {
                            imageTuple = nil;
                            CMTLogError(@"UIImage +Request Create ImageTuple From Cache Exception: %@", exception);
                        }
                        if (imageTuple != nil) {
                            [subscriber sendNext:imageTuple];
                            [subscriber sendCompleted];
                            return nil;
                        }
                    }
                    
                    // cache image not exists or
                    // create imageTuple failed,
                    // request image
                    NSMutableURLRequest *imageRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL]];
                    if (![imageRequest valueForHTTPHeaderField:CMTImageRequestRefererKey]) {
                        [imageRequest setValue:CMTImageRequestReferer forHTTPHeaderField:CMTImageRequestRefererKey];
                    }
                    AFHTTPSessionManager *operation = [AFHTTPSessionManager manager];
                    operation.requestSerializer = [AFHTTPRequestSerializer serializer];
                    if (![imageRequest valueForHTTPHeaderField:CMTImageRequestRefererKey]) {
                        [imageRequest setValue:CMTImageRequestReferer forHTTPHeaderField:CMTImageRequestRefererKey];
                        //系统参数
                        [operation.requestSerializer setValue:CMTImageRequestReferer forHTTPHeaderField:CMTImageRequestRefererKey];
                    }
                    NSURLSessionDataTask *task=[operation dataTaskWithRequest:imageRequest uploadProgress:nil downloadProgress:nil
                                                            completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                                                                
                                                                if (error==nil) {
                                                                    
                                                                    UIImage *image = [UIImage imageWithData:responseObject];
                                                                    if (image != nil) {
                                                                        
                                                                        NSString *pStr = [URL substringFromIndex:URL.length-3];
                                                                        // save cache
                                                                        if ([pStr isEqualToString:@"png"])
                                                                        {
                                                                            if (![UIImagePNGRepresentation(image) writeToFile:imagePathString atomically:YES]) {
                                                                                CMTLogError(@"UIImage +Request Write Image:%@\nto File Error at Path: %@", image, imagePathString);
                                                                                imagePathString = @"";
                                                                            }
                                                                        }
                                                                        else
                                                                        {
                                                                            if (![UIImageJPEGRepresentation(image, 1.0) writeToFile:imagePathString atomically:YES]) {
                                                                                CMTLogError(@"UIImage +Request Write Image:%@\nto File Error at Path: %@", image, imagePathString);
                                                                                imagePathString = @"";
                                                                            }
                                                                        }
                                                                        
                                                                        // create imageTuple
                                                                        NSDictionary *imageTuple = nil;
                                                                        @try {
                                                                            imageTuple = @{
                                                                                           CMTExtensionUIImageTupleImageURLKey: URL ?: @"",
                                                                                           CMTExtensionUIImageTupleImagePathKey: imagePathString ?: @"",
                                                                                           };
                                                                        }
                                                                        @catch (NSException *exception) {
                                                                            imageTuple = nil;
                                                                            CMTLogError(@"UIImage +Request Create ImageTuple From Request Exception: %@", exception);
                                                                        }
                                                                        if (imageTuple != nil) {
                                                                            [subscriber sendNext:imageTuple];
                                                                            [subscriber sendCompleted];
                                                                        } else {
                                                                            // create imageTuple failed
                                                                            [subscriber sendError:[NSError errorWithDomain:@"UIImage +Request" code:3 userInfo:@{@"error": @"create imageTuple from Request failed"}]];
                                                                            CMTLogError(@"UIImage +Request Create ImageTuple From Request Failed");
                                                                        }
                                                                        
                                                                    } else {
                                                                        // create image with request data failed
                                                                        [subscriber sendError:[NSError errorWithDomain:@"UIImage +Request" code:2 userInfo:@{@"error": @"Create image with request data failed"}]];
                                                                        CMTLogError(@"UIImage +Request Create Image With Request Data Failed");
                                                                    }
                                                                    
                                                                    
                                                                }else{
                                                                    [subscriber sendError:error];
                                                                    CMTLogError(@"UIImage +Request RequestOperation Error: %@", error);
                                                                    
                                                                    
                                                                }
                                                            }];
                    
                    
                    //                    operation.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                    //                    [[UIImage sharedImageRequestOperationQueue] addOperation:];
                    
                    return [RACDisposable disposableWithBlock:^{
                        [task cancel];
                    }];
                    
                } else {
                    // empty imagePathString
                    [subscriber sendError:[NSError errorWithDomain:@"UIImage +Request" code:1 userInfo:@{@"error": @"Empty imagePathString"}]];
                    CMTLogError(@"UIImage +Request Empty ImagePathString");
                }
                
            } else {
                // empty imageURLString
                [subscriber sendError:[NSError errorWithDomain:@"UIImage +Request" code:0 userInfo:@{@"error": @"Empty imageURLString"}]];
                CMTLogError(@"UIImage +Request Empty ImageURLString");
            }
            
            return nil;
        }];
    }];
}

// 可变质量imageURL
// withScale 按尺寸压缩 默认按照屏幕宽压缩 contentSize不为CGSizeZero则按照contentSize.width压缩
// withQuadrateScale 正方形压缩 须withScale为YES且contentSize不为CGSizeZero
// withCompact 按质量压缩 在withLimited为NO时生效 wifi环境90Q质量 否则 40Q质量
// withLimited 按质量压缩 40Q质量
+ (NSString *)imageURLWithURL:(NSString *)URLString
                    withScale:(BOOL)withScale
            withQuadrateScale:(BOOL)withQuadrateScale
                  withCompact:(BOOL)withCompact
                  withLimited:(BOOL)withLimited
               andContentSize:(CGSize)contentSize {
    
    if (BEMPTY(URLString)) {
        return nil;
    }
    
    // gif
    if ([URLString hasSuffix:@"gif"] || [URLString hasSuffix:@"GIF"]) {
        return URLString;
    }
    
    NSString *imageURLString = nil;
    
    // scale
    if (withScale == YES) {
        // scale by SCREEN
        if (CGSizeEqualToSize(contentSize, CGSizeZero)) {
            CGFloat SCALE = SCREEN_SCALE;
            if (SCALE > 2.0) {
                SCALE = 2.0;
            }
            NSInteger screenWidthPixel = SCREEN_WIDTH * SCALE;
            imageURLString = [NSString stringWithFormat:@"%@@%ldw_", URLString, (long)screenWidthPixel];
        }
        // scale by contentSize
        else {
            NSInteger imageWidthPixel = contentSize.width * SCREEN_SCALE;
            // quadrateScaled
            if (withQuadrateScale == YES) {
                imageURLString = [NSString stringWithFormat:@"%@@%ldw_%ldh_1e_1c", URLString, (long)imageWidthPixel, (long)imageWidthPixel];
            }
            else {
                imageURLString = [NSString stringWithFormat:@"%@@%ldw", URLString, (long)imageWidthPixel];
            }
        }
    }
    else {
        imageURLString = [NSString stringWithFormat:@"%@@", URLString];
    }
    
    // quality
    if ([imageURLString hasSuffix:@"_"] || [imageURLString hasSuffix:@"@"]) {
        
        if (withLimited == YES || (withCompact == YES && !NET_WIFI)) {
            imageURLString = [imageURLString stringByAppendingString:@"40Q"];
        }
        else {
            imageURLString = [imageURLString stringByAppendingString:@"90Q"];
        }
    }
    
    // Suffix
    return [imageURLString stringByAppendingString:[URLString imageSuffix]];
}

+ (NSString *)scaledImageURLWithURL:(NSString *)URLString contentSize:(CGSize)contentSize {
    return [self imageURLWithURL:URLString withScale:YES withQuadrateScale:NO withCompact:NO withLimited:NO andContentSize:contentSize];
}

+ (NSString *)quadrateScaledImageURLWithURL:(NSString *)URLString width:(CGFloat)width {
    return [self imageURLWithURL:URLString withScale:YES withQuadrateScale:YES withCompact:NO withLimited:NO andContentSize:CGSizeMake(width, width)];
}

+ (NSString *)fullQualityImageURLWithURL:(NSString *)URLString {
    return [self imageURLWithURL:URLString withScale:NO withQuadrateScale:NO withCompact:NO withLimited:NO andContentSize:CGSizeZero];
}

+ (NSString *)lowQualityImageURLWithURL:(NSString *)URLString {
    return [self imageURLWithURL:URLString withScale:NO withQuadrateScale:NO withCompact:NO withLimited:YES andContentSize:CGSizeZero];
}

+ (NSString *)lowQualityImageURLWithURL:(NSString *)URLString contentSize:(CGSize)contentSize{
    return [self imageURLWithURL:URLString withScale:YES withQuadrateScale:NO withCompact:NO withLimited:YES andContentSize:contentSize];
}


+ (NSString *)compactImageURLWithURL:(NSString *)URLString {
    return [self imageURLWithURL:URLString withScale:NO withQuadrateScale:NO withCompact:YES withLimited:NO andContentSize:CGSizeZero];
}

+ (NSString *)compactImagePathWithURL:(NSString *)URLString {
    NSString *imagePath = [self imagePathWithURL:URLString];
    if (imagePath != nil) {
        return imagePath;
    }
    
    return [self imagePathWithURL:[self compactImageURLWithURL:URLString]];
}

+ (instancetype)loadCompactImageWithURL:(NSString *)URLString {
    return [[UIImage alloc] initWithContentsOfFile:[UIImage compactImagePathWithURL:URLString]];
}

+ (RACSignal *)requestCompactImageWithURL:(NSString *)URLString {
    return [self requestImageWithURL:[self compactImageURLWithURL:URLString]];
}

@end
