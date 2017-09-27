//
//  CMTImageMarker.m
//  MedicalForum
//
//  Created by FengLei on 15/4/11.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

// view
#import "CMTImageMarker.h"          // header file

@interface CMTImageMarker ()

// view
@property (nonatomic, strong) UIImageView *imageView;                   // 图片

// data
@property (nonatomic, assign, readwrite) CGSize markerSize;             // 标注大小

@end

@implementation CMTImageMarker

#pragma mark Initializers

- (UIImageView *)imageView {
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc] init];
        _imageView.backgroundColor = COLOR(c_clear);
    }
    
    return _imageView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self == nil) return nil;
    
    self.backgroundColor = COLOR(c_clear);
    [self addSubview:self.imageView];
    
    return self;
}

#pragma mark LifeCycle

- (void)setMarkerType:(CMTImageMarkerType)markerType {
    if (_markerType == markerType) return;
    
    _markerType = markerType;
    
    switch (markerType) {
        case CMTImageMarkerTypePDF: {
            [self performLayoutWithImage:IMAGE(@"marker_PDF")];
        }
            break;
        case CMTImageMarkerTypePPT: {
            [self performLayoutWithImage:IMAGE(@"marker_PPT")];
        }
            break;
        case CMTImageMarkerTypeVideo: {
            [self performLayoutWithImage:IMAGE(@"marker_video")];
        }
            break;
        case CMTImageMarkerTypeAudio: {
            [self performLayoutWithImage:IMAGE(@"marker_audio")];
        }
            break;
        case CMTImageMarkerTypeAnswer:{
            [self performLayoutWithImage:IMAGE(@"marker_answer")];
            break;
        }
        case CMTImageMarkerTypeVote:{
            [self performLayoutWithImage:IMAGE(@"marker_vote")];
            break;
        }
        default:
            break;
    }
}

- (void)performLayoutWithImage:(UIImage *)image {
    
    self.frame = CGRectMake(0.0, 0.0, image.size.width, image.size.height);
    self.imageView.frame = self.bounds;
    self.imageView.image = image;
    self.markerSize = self.frame.size;
}

@end
