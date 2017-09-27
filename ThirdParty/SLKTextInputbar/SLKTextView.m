//
//   Copyright 2014 Slack Technologies, Inc.
//
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in writing, software
//   distributed under the License is distributed on an "AS IS" BASIS,
//   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//   See the License for the specific language governing permissions and
//   limitations under the License.
//

#import "SLKTextView.h"

NSString * const SLKTextViewContentSizeDidChangeNotification = @"SLKTextViewContentSizeDidChangeNotification";

@interface SLKTextView ()

@property (nonatomic) BOOL didFlashScrollIndicators;

@end

@implementation SLKTextView

#pragma mark - Initialization

- (instancetype)initWithFrame:(CGRect)frame textContainer:(NSTextContainer *)textContainer {
    if (self = [super initWithFrame:frame textContainer:textContainer]) {
        
        self.font = [UIFont systemFontOfSize:14.0];
        self.editable = YES;
        self.selectable = YES;
        self.scrollEnabled = YES;
        self.scrollsToTop = NO;
        self.directionalLockEnabled = YES;
        self.dataDetectorTypes = UIDataDetectorTypeNone;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(slk_didChangeText:) name:UITextViewTextDidChangeNotification object:nil];
        [self addObserver:self forKeyPath:NSStringFromSelector(@selector(contentSize)) options:NSKeyValueObservingOptionNew context:NULL];
    }
    
    return self;
}

#pragma mark - Getters

- (NSUInteger)numberOfLines {
    return fabs(self.contentSize.height/self.font.lineHeight);
}

#pragma mark - UIView Overrides

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(UIViewNoIntrinsicMetric, 34.0);
}

#pragma mark - UITextView Overrides

- (void)setText:(NSString *)text {
    [super setText:text];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:UITextViewTextDidChangeNotification object:self];
}

#pragma mark - Notification Events

- (void)slk_didChangeText:(NSNotification *)notification {
    if ([notification.object isEqual:self] == NO) {
        return;
    }
    
    if (self.numberOfLines == self.maxNumberOfLines+1) {
        if (_didFlashScrollIndicators == NO) {
            _didFlashScrollIndicators = YES;
            [super flashScrollIndicators];
        }
    }
    else if (_didFlashScrollIndicators) {
        _didFlashScrollIndicators = NO;
    }
}

#pragma mark - KVO Listener

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([object isEqual:self] && [keyPath isEqualToString:NSStringFromSelector(@selector(contentSize))]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SLKTextViewContentSizeDidChangeNotification object:self userInfo:nil];
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - Lifeterm

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeObserver:self forKeyPath:NSStringFromSelector(@selector(contentSize))];
}

@end
