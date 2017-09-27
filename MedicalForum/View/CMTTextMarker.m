//
//  CMTTextMarker.m
//  MedicalForum
//
//  Created by FengLei on 15/4/11.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

// view
#import "CMTTextMarker.h"           // header file

/// 文字标注 颜色风格
typedef NS_OPTIONS(NSUInteger, CMTTextMarkerColorStyle) {
    CMTTextMarkerColorStyleNone = 0,        // 未指定
    CMTTextMarkerColorStyleRed,             // 红色
    CMTTextMarkerColorStyleWhite,             //白色
};

/// 文字标注 形状风格
typedef NS_OPTIONS(NSUInteger, CMTTextMarkerShapeStyle) {
    CMTTextMarkerShapeStyleNone = 0,        // 未指定
    CMTTextMarkerShapeStyleRoundRect,       // 圆角矩形
};

@interface CMTTextMarker ()

// view
@property (nonatomic, strong) UILabel *contentLabel;                    // 内容

// data
@property (nonatomic, assign) CMTTextMarkerShapeStyle shapeStyle;       // 形状风格
@property (nonatomic, assign) CMTTextMarkerColorStyle colorStyle;       // 颜色风格
@property (nonatomic, assign, readwrite) CGSize markerSize;             // 标注大小

@end

@implementation CMTTextMarker

#pragma mark Initializers

- (UILabel *)contentLabel {
    if (_contentLabel == nil) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.backgroundColor = COLOR(c_clear);
    }
    
    return _contentLabel;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self == nil) return nil;
    
    self.backgroundColor = COLOR(c_clear);
    [self addSubview:self.contentLabel];
    
    return self;
}

#pragma mark LifeCycle

- (void)setShapeStyle:(CMTTextMarkerShapeStyle)shapeStyle {
    if (_shapeStyle == shapeStyle) return;
    
    _shapeStyle = shapeStyle;
    
    switch (shapeStyle) {
            // 圆角矩形
        case CMTTextMarkerShapeStyleRoundRect: {
            self.layer.borderWidth = PIXEL;
            self.layer.masksToBounds = YES;
            self.layer.cornerRadius = 5.0/3.0;
        }
            break;
            
        default:
            break;
    }
}

- (void)setColorStyle:(CMTTextMarkerColorStyle)colorStyle {
    if (_colorStyle == colorStyle) return;
    
    _colorStyle = colorStyle;
    
    switch (colorStyle) {
            // 红色
        case CMTTextMarkerColorStyleRed: {
            // border色
            self.layer.borderColor = COLOR(c_e51c23).CGColor;
            // contentLabel字色
            self.contentLabel.textColor = COLOR(c_e51c23);
            self.contentLabel.highlightedTextColor = COLOR(c_e51c23);
        }
             break;
        case CMTTextMarkerColorStyleWhite:{
            self.layer.borderColor = [UIColor colorWithHexString:@"30c2a9"].CGColor;
            // contentLabel字色
            self.contentLabel.textColor = COLOR(c_ffffff);
            self.contentLabel.highlightedTextColor = COLOR(c_ffffff);
        }
            break;
            
        default:
            break;
    }
}

- (void)setMarkerType:(CMTTextMarkerType)markerType {
    if (_markerType == markerType) return;
    
    _markerType = markerType;
    
    switch (markerType) {
        case CMTTextMarkerTypeTheme: {
            self.shapeStyle = CMTTextMarkerShapeStyleRoundRect;
            self.colorStyle = CMTTextMarkerColorStyleRed;
            self.contentLabel.text = @"专题";
            self.frame = CGRectMake(0.0, 0.0, 30.0, 13.5);
            self.markerSize = self.frame.size;
        }
            break;
        case CMTTextMarkerTypeTop: {
            self.shapeStyle = CMTTextMarkerShapeStyleRoundRect;
            self.colorStyle = CMTTextMarkerColorStyleWhite;
            self.contentLabel.text = @"置顶";
            self.frame = CGRectMake(0.0, 0.0, 30.0, 13.5);
            self.markerSize = self.frame.size;
        }
            break;

            
        default:
            break;
    }
    
    [self performLayout];
}

- (void)performLayout {
    
    self.contentLabel.frame = CGRectMake(0.0, 0.0, self.width, self.height);
    self.contentLabel.font = FONT(11.0);
    self.contentLabel.textAlignment = NSTextAlignmentCenter;
}

@end
