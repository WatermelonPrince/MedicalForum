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

#import "SLKTextInputbar.h"
#import "SLKTextView.h"

typedef NS_ENUM(NSUInteger, SLKKeyboardStatus) {
    SLKKeyboardStatusDidHide,
    SLKKeyboardStatusWillShow,
    SLKKeyboardStatusDidShow,
    SLKKeyboardStatusWillHide
};

@interface SLKTextInputbar ()

// viewController auto-layout
@property (nonatomic, strong) NSLayoutConstraint *textInputbarHC;
@property (nonatomic, strong) NSLayoutConstraint *keyboardHC;

// view
@property (nonatomic, weak) UIView *lastSuperView;
@property (nonatomic, strong) UIView *editorContentView;
@property (nonatomic, strong) UILabel *editorTitle;
@property (nonatomic, strong) UIButton *editortLeftButton;
@property (nonatomic, strong) UIButton *editortRightButton;
@property (nonatomic, strong) SLKTextView *textView;

// view auto-layout
@property (nonatomic, strong) NSLayoutConstraint *editorContentViewHC;
@property (nonatomic) SLKKeyboardStatus keyboardStatus;

/** The custom input accessory view, used as empty achor view to detect the keyboard frame. */
@property (nonatomic, strong) UIView *inputAccessoryView;

/** The inner padding to use when laying out content in the view. Default is {5, 8, 5, 8}. */
@property (nonatomic, assign) UIEdgeInsets contentInset;

/** The accessory view's maximum height. Default is 38 pts. */
@property (nonatomic, assign) CGFloat editorContentViewHeight;

/** The minimum height based on the intrinsic content size's. */
@property (nonatomic, readonly) CGFloat minimumInputbarHeight;

/** The most appropriate height calculated based on the amount of lines of text and other factors. */
@property (nonatomic, readonly) CGFloat appropriateHeight;

@end

@implementation SLKTextInputbar

#pragma mark - Initialization

- (id)init {
    if (self = [super init]) {
        
        self.editorContentViewHeight = 38.0;
        self.contentInset = UIEdgeInsetsMake(5.0, 8.0, 5.0, 8.0);
        
        [self addSubview:self.editorContentView];
        [self addSubview:self.textView];
        
        [self slk_setupViewConstraints];
        [self slk_updateConstraintConstants];
        [self slk_registerNotifications];
    }
    
    return self;
}

#pragma mark - Getters

- (SLKTextView *)textView {
    if (_textView == nil) {
        _textView = [[SLKTextView alloc] init];
        _textView.translatesAutoresizingMaskIntoConstraints = NO;
        _textView.layoutManager.allowsNonContiguousLayout = NO;
        _textView.font = [UIFont systemFontOfSize:15.0];
        _textView.maxNumberOfLines = 6;
        
        _textView.autocapitalizationType = UITextAutocapitalizationTypeSentences;
        _textView.keyboardType = UIKeyboardTypeDefault;
        _textView.returnKeyType = UIReturnKeyDefault;
        _textView.enablesReturnKeyAutomatically = YES;
        _textView.scrollIndicatorInsets = UIEdgeInsetsMake(0.0, -1.0, 0.0, 1.0);
        _textView.textContainerInset = UIEdgeInsetsMake(8.0, 4.0, 8.0, 0.0);
        _textView.layer.cornerRadius = 5.0;
        _textView.layer.borderWidth = 0.5;
        _textView.layer.borderColor =  [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:205.0/255.0 alpha:1.0].CGColor;
    }
    
    return _textView;
}

- (UIView *)inputAccessoryView {
    if (_inputAccessoryView == nil) {
        _inputAccessoryView = [[UIView alloc] initWithFrame:self.bounds];
        _inputAccessoryView.backgroundColor = [UIColor clearColor];
        _inputAccessoryView.userInteractionEnabled = NO;
    }
    
    return _inputAccessoryView;
}

- (UIView *)editorContentView {
    if (_editorContentView == nil) {
        _editorContentView = [UIView new];
        _editorContentView.translatesAutoresizingMaskIntoConstraints = NO;
        _editorContentView.backgroundColor = self.backgroundColor;
        _editorContentView.clipsToBounds = YES;
        
        _editorTitle = [UILabel new];
        _editorTitle.translatesAutoresizingMaskIntoConstraints = NO;
        _editorTitle.text = @"编辑";
        _editorTitle.textAlignment = NSTextAlignmentCenter;
        _editorTitle.backgroundColor = [UIColor clearColor];
        _editorTitle.font = [UIFont boldSystemFontOfSize:15.0];
        _editorTitle.numberOfLines = 1;
        [_editorContentView addSubview:self.editorTitle];
        
        _editortLeftButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _editortLeftButton.translatesAutoresizingMaskIntoConstraints = NO;
        _editortLeftButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _editortLeftButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
        [_editortLeftButton setTitle:@"取消" forState:UIControlStateNormal];
        [_editortLeftButton addTarget:self action:@selector(didCancelTextEditing:) forControlEvents:UIControlEventTouchUpInside];
        [_editorContentView addSubview:self.editortLeftButton];
        
        _editortRightButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _editortRightButton.translatesAutoresizingMaskIntoConstraints = NO;
        _editortRightButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        _editortRightButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
        [_editortRightButton setTitle:@"发送" forState:UIControlStateNormal];
        [_editortRightButton addTarget:self action:@selector(didCommitTextEditing:) forControlEvents:UIControlEventTouchUpInside];
        [_editorContentView addSubview:self.editortRightButton];
        
        
        
        NSDictionary *views = @{
                                @"label": self.editorTitle,
                                @"editortLeftButton": self.editortLeftButton,
                                @"editortRightButton": self.editortRightButton,
                                };
        
        NSDictionary *metrics = @{
                                  @"left" : @(self.contentInset.left),
                                  @"right" : @(self.contentInset.right),
                                  };
        
        [_editorContentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(left)-[editortLeftButton(40)]-(left)-[label]-(right)-[editortRightButton(40)]-(right)-|" options:0 metrics:metrics views:views]];
        [_editorContentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[editortLeftButton]|" options:0 metrics:metrics views:views]];
        [_editorContentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[editortRightButton]|" options:0 metrics:metrics views:views]];
        [_editorContentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[label]|" options:0 metrics:metrics views:views]];
    }
    
    return _editorContentView;
}

#pragma mark - UIView Overrides

- (void)layoutIfNeeded {
    if (self.constraints.count == 0) {
        return;
    }
    
    [self slk_updateConstraintConstants];
    [super layoutIfNeeded];
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(UIViewNoIntrinsicMetric, 44.0);
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

#pragma mark - View Auto-Layout

- (void)slk_setupViewConstraints {
    
    NSDictionary *views = @{@"textView": self.textView,
                            @"contentView": self.editorContentView,
                            };
    
    NSDictionary *metrics = @{@"top" : @(self.contentInset.top),
                              @"bottom" : @(self.contentInset.bottom),
                              @"left" : @(self.contentInset.left),
                              @"right" : @(self.contentInset.right),
                              @"minTextViewHeight" : @(self.textView.intrinsicContentSize.height),
                              };
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(left)-[textView]-(right)-|" options:0 metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[contentView(0)]-(<=top)-[textView(minTextViewHeight@250)]-(bottom)-|" options:0 metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[contentView]|" options:0 metrics:metrics views:views]];
    
    self.editorContentViewHC = [self slk_constraintForView:self attribute:NSLayoutAttributeHeight firstItem:self.editorContentView secondItem:nil];
}

- (void)slk_updateConstraintConstants {
    self.editorContentViewHC.constant = self.editorContentViewHeight;
}

- (NSLayoutConstraint *)slk_constraintForView:(UIView *)view attribute:(NSLayoutAttribute)attribute firstItem:(id)first secondItem:(id)second
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"firstAttribute = %d AND firstItem = %@ AND secondItem = %@", attribute, first, second];
    return [[view.constraints filteredArrayUsingPredicate:predicate] firstObject];
}

#pragma mark - ViewController Auto-Layout

- (CGFloat)minimumInputbarHeight {
    return self.intrinsicContentSize.height;
}

- (CGFloat)appropriateHeight {
    CGFloat height = 0.0;
    CGFloat minimumHeight = [self minimumInputbarHeight];
    
    if (self.textView.numberOfLines == 1) {
        height = minimumHeight;
    }
    else if (self.textView.numberOfLines < self.textView.maxNumberOfLines) {
        height = [self slk_inputBarHeightForLines:self.textView.numberOfLines];
    }
    else {
        height = [self slk_inputBarHeightForLines:self.textView.maxNumberOfLines];
    }
    
    if (height < minimumHeight) {
        height = minimumHeight;
    }
    
    height += self.editorContentViewHeight;
    
    return roundf(height);
}

- (CGFloat)slk_inputBarHeightForLines:(NSUInteger)numberOfLines {
    CGFloat height = self.textView.intrinsicContentSize.height - self.textView.font.lineHeight;
    height += roundf(self.textView.font.lineHeight * numberOfLines);
    height += self.contentInset.top + self.contentInset.bottom;
    
    return height;
}

#pragma mark - LifeCycle

- (void)didMoveToSuperview {
    if (self.lastSuperView == self.superview || [self.lastSuperView isEqual:self.superview]) {
        return;
    }
    else {
        self.lastSuperView = self.superview;
    }
    
    // layout subviews
    UIView *topMarginView = [[UIView alloc] initWithFrame:CGRectZero];
    topMarginView.translatesAutoresizingMaskIntoConstraints = NO;
    topMarginView.backgroundColor = [UIColor clearColor];
    topMarginView.userInteractionEnabled = NO;
    [self.superview addSubview:topMarginView];
    
    NSDictionary *views = @{
                            @"topMarginView": topMarginView,
                            @"textInputbar": self,
                            };
    
    [self.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[topMarginView(0@750)]-0@999-[textInputbar(>=0)]-0-|" options:0 metrics:nil views:views]];
    [self.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[topMarginView]|" options:0 metrics:nil views:views]];
    [self.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[textInputbar]|" options:0 metrics:nil views:views]];
    
    self.textInputbarHC = [self slk_constraintForView:self.superview attribute:NSLayoutAttributeHeight firstItem:self secondItem:nil];
    self.keyboardHC = [self slk_constraintForView:self.superview attribute:NSLayoutAttributeBottom firstItem:self.superview secondItem:self];
    
    self.textInputbarHC.constant = self.minimumInputbarHeight + self.editorContentViewHeight;
}

- (void)setEditorTitleText:(NSString *)editorTitleText {
    if ([_editorTitleText isEqualToString:editorTitleText]) {
        return;
    }
    
    _editorTitleText = [editorTitleText copy];
    
    self.editorTitle.text = _editorTitleText ?: @"";
}

- (void)didCommitTextEditing:(id)sender {
    [self dismissKeyboard];
}

- (void)didCancelTextEditing:(id)sender {
    [self dismissKeyboard];
}

- (void)presentKeyboard {
    if ([self.textView isFirstResponder] == YES) {
        return;
    }
    
    [self.textView becomeFirstResponder];
}

- (void)dismissKeyboard {
    if ([self.textView isFirstResponder] == NO) {
        if (self.keyboardHC.constant > 0) {
            [self.superview.window endEditing:NO];
        }
        return;
    }
    
    [self.textView resignFirstResponder];
}

#pragma mark - KeyboardStatus

- (BOOL)slk_updateKeyboardStatus:(SLKKeyboardStatus)status {
    if (_keyboardStatus == status) {
        return NO;
    }
    if ([self slk_isIllogicalKeyboardStatus:status]) {
        return NO;
    }
    
    _keyboardStatus = status;
    
    return YES;
}

- (BOOL)slk_isIllogicalKeyboardStatus:(SLKKeyboardStatus)status {
    if ((self.keyboardStatus == 0 && status == 1) ||
        (self.keyboardStatus == 1 && status == 2) ||
        (self.keyboardStatus == 2 && status == 3) ||
        (self.keyboardStatus == 3 && status == 0)) {
        return NO;
    }
    return YES;
}

- (void)slk_dismissTextInputbarIfNeeded {
    if (self.keyboardHC.constant == 0) {
        return;
    }
    
    self.keyboardHC.constant = 0.0;
    
    [self slk_updateKeyboardStatus:SLKKeyboardStatusDidHide];
    [self.superview layoutIfNeeded];
}

- (SLKKeyboardStatus)slk_keyboardStatusForNotification:(NSNotification *)notification {
    NSString *name = notification.name;
    if ([name isEqualToString:UIKeyboardWillShowNotification]) {
        return SLKKeyboardStatusWillShow;
    }
    if ([name isEqualToString:UIKeyboardDidShowNotification]) {
        return SLKKeyboardStatusDidShow;
    }
    if ([name isEqualToString:UIKeyboardWillHideNotification]) {
        return SLKKeyboardStatusWillHide;
    }
    if ([name isEqualToString:UIKeyboardDidHideNotification]) {
        return SLKKeyboardStatusDidHide;
    }
    return -1;
}

#pragma mark - KeyboardHeight

- (CGFloat)slk_appropriateKeyboardHeightFromNotification:(NSNotification *)notification {
    CGRect rect = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    return [self slk_appropriateKeyboardHeightFromRect:rect];
}

- (CGFloat)slk_appropriateKeyboardHeightFromRect:(CGRect)rect {
    CGRect keyboardRect = [self.superview convertRect:rect fromView:nil];
    CGFloat viewHeight = CGRectGetHeight(self.superview.bounds);
    CGFloat keyboardMinY = CGRectGetMinY(keyboardRect);
    CGFloat inputAccessoryViewHeight = CGRectGetHeight(self.inputAccessoryView.bounds);
    return MAX(0.0, viewHeight - (keyboardMinY + inputAccessoryViewHeight));
}

#pragma mark - KeyboardNotification

- (void)slk_willShowOrHideKeyboard:(NSNotification *)notification {
    if (self.superview.window == nil) {
        return;
    }
    if ([self.textView isFirstResponder] == NO) {
        return [self slk_dismissTextInputbarIfNeeded];
    }
    
    // update Status
    self.keyboardHC.constant = [self slk_appropriateKeyboardHeightFromNotification:notification];
    SLKKeyboardStatus status = [self slk_keyboardStatusForNotification:notification];
    [self slk_updateKeyboardStatus:status];
    
    // keyboard animation
    NSInteger curve = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    NSTimeInterval duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:duration
                          delay:0.0
                        options:(curve<<16)|UIViewAnimationOptionLayoutSubviews|UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [self.superview layoutIfNeeded];
                         if (status == SLKKeyboardStatusWillShow || status == SLKKeyboardStatusDidShow) {
                             self.hidden = NO;
                         }
                         else {
                             self.hidden = YES;
                         }
                     }
                     completion:nil];
}

- (void)slk_didShowOrHideKeyboard:(NSNotification *)notification {
    if (self.superview.window == nil) {
        return;
    }
    
    SLKKeyboardStatus status = [self slk_keyboardStatusForNotification:notification];
    if (self.keyboardStatus == status) {
        return;
    }
    
    [self slk_updateKeyboardStatus:status];
}

#pragma mark - TextView

- (void)textDidUpdate:(BOOL)animated {
    CGFloat inputbarHeight = self.appropriateHeight;
    
    if (inputbarHeight != self.textInputbarHC.constant) {
        self.textInputbarHC.constant = inputbarHeight;
        
        if (animated) {
            
            UIViewAnimationOptions options = UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionLayoutSubviews|UIViewAnimationOptionBeginFromCurrentState;
            
            if ([self.textView isFirstResponder]) {
                [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:0.7 initialSpringVelocity:0.7 options:options
                                 animations:^{
                                     [self layoutIfNeeded];
                                     [UIView performWithoutAnimation:^{
                                         [self.textView scrollRangeToVisible:self.textView.selectedRange];
                                     }];
                                 }
                                 completion:nil];
            }
            else {
                [UIView animateWithDuration:0.2 delay:0.0 options:options
                                 animations:^{
                                     [self layoutIfNeeded];
                                     [UIView performWithoutAnimation:^{
                                         [self.textView scrollRangeToVisible:self.textView.selectedRange];
                                     }];
                                 }
                                 completion:nil];
            }
        }
        else {
            [self.superview layoutIfNeeded];
        }
    }
}

#pragma mark - TextViewNotification

- (void)slk_didChangeTextViewText:(NSNotification *)notification {
    if ([notification.object isEqual:self.textView] == NO) {
        return;
    }
    
    [self textDidUpdate:self.isViewVisible];
}

- (void)slk_didChangeTextViewContentSize:(NSNotification *)notification {
    if ([notification.object isEqual:self.textView] == NO) {
        return;
    }
    
    [self textDidUpdate:self.isViewVisible];
}

#pragma mark - NSNotificationCenter register/unregister

- (void)slk_registerNotifications {
    
    [self slk_unregisterNotifications];
    
    // Keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(slk_willShowOrHideKeyboard:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(slk_willShowOrHideKeyboard:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(slk_didShowOrHideKeyboard:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(slk_didShowOrHideKeyboard:) name:UIKeyboardDidHideNotification object:nil];
    
    // TextView notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(slk_didChangeTextViewText:) name:UITextViewTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(slk_didChangeTextViewContentSize:) name:SLKTextViewContentSizeDidChangeNotification object:nil];
}

- (void)slk_unregisterNotifications {
    
    // Keyboard notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    
    // TextView notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SLKTextViewContentSizeDidChangeNotification object:nil];
}

- (void)dealloc {
    [self slk_unregisterNotifications];
}

@end
