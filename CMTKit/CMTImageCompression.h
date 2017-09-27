//
//  CMTImageScale.h
//  MedicalForum
//
//  Created by guoyuanchao on 15/12/8.
//  Copyright © 2015年 CMT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <ImageIO/ImageIO.h>
@interface CMTImageCompression : NSObject
//放大缩小图片
+(UIImage *)thumbnailForAsset:(ALAsset *)asset maxPixelSize:(NSUInteger)size;
//放大 然后缩小图片
+ (void) shakeToShow:(UIView*)aView;
//放大缩小按钮背景图
+(void)shakeToShowButton:(UIButton *)button;
+(void)deleteFile:(NSString*)filename;
@end
