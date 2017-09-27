//
//  CMTReplyInputView.m
//  MedicalForum
//
//  Created by fenglei on 15/9/18.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

// view
#import "CMTReplyInputView.h"           // header file
#import "UITextView+Placeholder.h"      // textView空数据提示
#import <AssetsLibrary/AssetsLibrary.h>
#import "SDWebImageManager.h"
#import "CMTSetRemindPeopleViewController.h"
#import "CMTNavigationController.h"
#import "CMTImageCompression.h"
#import <AssetsLibrary/AssetsLibrary.h>
@interface CMTReplyInputView () <UITextViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

// view
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UITextView *contentTextView;
@property (nonatomic,strong)  UILabel *numberlable;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *sendButton;
@property (nonatomic, strong) UIImageView *backgroundView;
@property (nonatomic, strong) UIViewController *rootViewController;
@property (nonatomic, weak) UIWindow *previousWindow;
@property (nonatomic, strong) UIWindow *inputViewWindow;
@property(nonatomic,strong)UIButton *picbutton;
@property(nonatomic,strong)UILabel *remindlable;
@property(nonatomic,strong)UIView *actionView;
@property(nonatomic,strong)ALAssetsLibrary *assetsLibrary;
@property (nonatomic, strong) UIImageView *arrowImage;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) UIView *hiddenView;//遮挡textView的下边缘


// data
@property (nonatomic, assign) CMTReplyInputViewModel inputViewModel;                    // 输入框类型
@property (nonatomic, assign) NSInteger contentMaxLength;                               // 最大字数限制
@property (nonatomic, copy) NSDate *lastCommentSendTime;                                // 上次评论发送时间
@property (nonatomic, strong, readwrite) RACSignal *commentCancelButtonSignal;          // 点击取消按钮
@property (nonatomic, strong, readwrite) RACSignal *commentSendButtonSignal;            // 点击发送评论按钮
@property (nonatomic, strong, readwrite) RACSignal *commentTextSignal;                  // 评论内容

@end

@implementation CMTReplyInputView

#pragma mark - Initialization

- (UIView *)hiddenView{
    if (_hiddenView == nil) {
        _hiddenView = [[UIView alloc]init];
        _hiddenView.backgroundColor = COLOR(c_ffffff);
    }
    return _hiddenView;
}

- (UIView *)contentView {
    if (_contentView == nil) {
        _contentView = [UIView new];
        _contentView.backgroundColor = COLOR(c_f5f5f5);
        _contentView.layer.cornerRadius = ceilf(4.65*RATIO);
        _contentView.layer.masksToBounds = YES;
        _contentView.layer.borderWidth = PIXEL;
        _contentView.layer.borderColor = COLOR(c_C4C4C4).CGColor;
        [_contentView addSubview:self.contentTextView];
        [_contentView addSubview:self.numberlable];
        [_contentView addSubview:self.cancelButton];
        [_contentView addSubview:self.sendButton];
        [_contentView addSubview:self.hiddenView];
    }
    return _contentView;
}

- (UITextView *)contentTextView {
    if (_contentTextView == nil) {
        _contentTextView = [UITextView new];
        _contentTextView.backgroundColor = COLOR(c_ffffff);
        _contentTextView.textColor = COLOR(c_151515);
        _contentTextView.showsHorizontalScrollIndicator = NO;
        _contentTextView.showsVerticalScrollIndicator = NO;
        _contentTextView.textContainerInset = UIEdgeInsetsMake(8, 10, 8, 10);
        _contentTextView.font = FONT(15.0);
        _contentTextView.layoutManager.allowsNonContiguousLayout = NO;
        _contentTextView.delegate = self;
    }
    return _contentTextView;
}

- (UILabel *)numberlable {
    if (_numberlable == nil) {
        _numberlable = [[UILabel alloc]init];
        _numberlable.layer.cornerRadius = 7.5;
        _numberlable.layer.masksToBounds = YES;
        _numberlable.backgroundColor = [UIColor colorWithHexString:@"#C2C2C2"];
        //_numberlable.backgroundColor = COLOR(c_f5f5f5);
        _numberlable.textColor = [UIColor whiteColor];
        _numberlable.textAlignment = NSTextAlignmentCenter;
        _numberlable.adjustsFontSizeToFitWidth = YES;
        _numberlable.font = [UIFont systemFontOfSize:10];
    }
    return _numberlable;
}
-(ALAssetsLibrary*)assetsLibrary{
    if (_assetsLibrary==nil) {
        _assetsLibrary=[[ALAssetsLibrary alloc]init];
    }
    return _assetsLibrary;
}
- (UIButton *)cancelButton {
    if (_cancelButton == nil) {
        _cancelButton = [UIButton new];
        _cancelButton.backgroundColor = COLOR(c_f5f5f5);
        _cancelButton.enabled = NO;
        _cancelButton.titleLabel.font = FONT(ceilf(13*RATIO));
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelButton setTitleColor:COLOR(c_ababab) forState:UIControlStateNormal];
        [_cancelButton setTitleColor:COLOR(c_ababab) forState:UIControlStateDisabled];
    }
    return _cancelButton;
}

- (UIButton *)sendButton {
    if (_sendButton == nil) {
        _sendButton = [UIButton new];
        _sendButton.backgroundColor = COLOR(c_f5f5f5);
        _sendButton.enabled = NO;
        _sendButton.titleLabel.font = FONT(ceilf(13*RATIO));
        _sendButton.titleLabel.textAlignment = NSTextAlignmentRight;
        [_sendButton setTitle:@"发送" forState:UIControlStateNormal];
        [_sendButton setTitleColor:COLOR(c_ffffff) forState:UIControlStateNormal];
        [_sendButton setTitleColor:COLOR(c_ababab) forState:UIControlStateDisabled];
    }
    return _sendButton;
}
- (UIImageView *)backgroundView {
    if (_backgroundView == nil) {
        _backgroundView = [UIImageView new];
        _backgroundView.userInteractionEnabled = YES;
        _backgroundView.backgroundColor = COLOR(c_1515157F);
        _backgroundView.backgroundColor = [UIColor blackColor];
        _backgroundView.alpha = 0.0;
    }
    return _backgroundView;
}
- (UITapGestureRecognizer *)tapGesture{
    if (_tapGesture == nil) {
        _tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(RemindPeople)];
        _tapGesture.numberOfTapsRequired = 1;
    }
    return _tapGesture;
}
-(UILabel*)remindlable{
    if (_remindlable==nil) {
        _remindlable=[[UILabel alloc]init];
        _remindlable.userInteractionEnabled = YES;
        _remindlable.textColor = COLOR(c_9e9e9e);
        _remindlable.font=FONT(13);
        [_remindlable addGestureRecognizer:self.tapGesture];
    }
    return _remindlable;
}
-(UIButton*)picbutton{
    if (_picbutton==nil) {
        _picbutton=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 38, 38)];
        _picbutton.imageView.contentMode=UIViewContentModeScaleAspectFill;
        [_picbutton setImage:IMAGE(@"pinglun") forState:UIControlStateNormal];
        [_picbutton addTarget:self action:@selector(OpenPhotoalbum) forControlEvents:UIControlEventTouchUpInside];
        UIButton *deleteButton=[[UIButton alloc]initWithFrame:CGRectMake(_picbutton.width-20,-10,30, 30)];
        [deleteButton setImage:IMAGE(@"deletePinglunPic") forState:UIControlStateNormal];
        deleteButton.hidden=YES;
        deleteButton.tag=100;
        [deleteButton addTarget:self action:@selector(deleteimage:) forControlEvents:UIControlEventTouchUpInside];
        [_picbutton addSubview:deleteButton];
    }
    return _picbutton;
}
- (UIImageView *)arrowImage{
    if (_arrowImage == nil) {
        _arrowImage = [[UIImageView alloc]init];
        _arrowImage.image = IMAGE(@"acc1");

        _arrowImage.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(RemindPeople)];
        tapGesture.numberOfTapsRequired = 1;
        [_arrowImage addGestureRecognizer:tapGesture];
    }
    return _arrowImage;
}
-(UIView*)actionView{
    if (_actionView==nil) {
        _actionView=[[UIView alloc]init];
        _actionView.backgroundColor=COLOR(c_ffffff);
        self.picbutton.frame=CGRectMake(10,5, 38, 38);
        
        self.remindlable.frame=CGRectMake(10,  self.picbutton.bottom,self.view.bounds.size.width -20-40-15-6, 32);
        self.arrowImage.frame = CGRectMake(self.remindlable.right, self.picbutton.bottom+5, 21, 21);

        [_actionView addSubview:self.picbutton];
        [_actionView addSubview:self.remindlable];
        [_actionView addSubview:self.arrowImage];

    }
    return _actionView;
}
/**
 *  删除图片
 */
-(void)deleteimage:(UIButton*)btn{
     UIButton *subbutton=(UIButton*)[btn superview];
     [subbutton setImage:IMAGE(@"pinglun") forState:UIControlStateNormal];
     self.picFilepath=@"";
     btn.hidden=YES;
    
}
- (instancetype)initWithInputViewModel:(CMTReplyInputViewModel)inputViewModel
                      contentMaxLength:(NSInteger)contentMaxLength {
    self = [super init];
    if (self == nil) return nil;
    CMTLog(@"%s", __FUNCTION__);
    @weakify(self);
    [self.rac_willDeallocSignal subscribeCompleted:^{
        CMTLog(@"ReplyInputView willDeallocSignal");
    }];
    
    // data
    self.inputViewModel = inputViewModel;
    self.contentMaxLength = contentMaxLength;

    // view
    [self.view addSubview:self.backgroundView];
    [self.view addSubview:self.contentView];
    if (inputViewModel==CMTReplyInputViewModelGroupPostDetail) {
        [self.contentView addSubview:self.actionView];
        self.hiddenView.hidden = YES;
    }
    
    // 评论数
    [[RACObserve(self, badgeNumber)
      deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSString * badgeNumber) {
        @strongify(self);
        if ([badgeNumber integerValue] > 0) {
            self.contentTextView.placeholder = @"我想说...";
        }
        else {
            self.contentTextView.placeholder = @"争做第一发言人";
        }
        self.remindString=@"";
        self.remindArray=nil;
        self.picFilepath=@"";
        self.remindlable.text=@"提醒谁看：";
        [self.picbutton setImage:IMAGE(@"pinglun") forState:UIControlStateNormal];
        [self.picbutton viewWithTag:100].hidden=YES;

    }];
    
    // 被回复的昵称提示
    [[[RACObserve(self, beRepliedNickName) distinctUntilChanged]
      deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSString *beRepliedNickName) {
        @strongify(self);
        self.remindString=@"";
        self.remindArray=nil;
        self.picFilepath=@"";
        if (beRepliedNickName == nil) {
            //self.hiddenView.hidden = YES;
            self.contentTextView.placeholder = [self.badgeNumber integerValue] == 0 ? @"争做第一发言人" : @"我想说...";
            if (self.actionView.hidden) {
                self.contentTextView.frame = CGRectMake(self.contentTextView.left, self.contentTextView.top, self.contentTextView.width,self.contentTextView.height-75);
                self.actionView.hidden=NO;
                self.contentTextView.layer.borderWidth =0;
                 self.contentTextView.layer.borderColor = COLOR(c_clear).CGColor;
            }

        }
        else {
            if (!self.actionView.hidden){
                self.hiddenView.hidden = YES;
                self.contentTextView.placeholder = [NSString stringWithFormat:@"回复%@:", beRepliedNickName];
                self.contentTextView.frame = CGRectMake(self.contentTextView.left, self.contentTextView.top, self.contentTextView.width,self.contentTextView.height+75);
                self.actionView.hidden=YES;
                self.contentTextView.layer.borderWidth =PIXEL;
                self.contentTextView.layer.borderColor = COLOR(c_ababab).CGColor;

            }

        }
    }];
    
    // 评论内容
    self.commentTextSignal = [self.contentTextView rac_textSignal];
    
    // 字数限制
    
   

    // 点击取消按钮
    self.commentCancelButtonSignal = [self.cancelButton rac_signalForControlEvents:UIControlEventTouchUpInside];
    [[self.cancelButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        //[self loadView];
        self.cancelButton.enabled = NO;
        self.hiddenView.hidden = NO;
        [self hideInputView];
    }];
    
    // 发送按钮状态
    [[[self.contentTextView rac_textSignal]
      deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        @strongify(self);
         self.numberlable.text = [NSString stringWithFormat:@"%ld/%ld",self.contentTextView.text.length ,(long)self.contentMaxLength];
        self.hiddenView.hidden = NO;
        self.sendButton.enabled = (self.contentTextView.text.length > 0);
    }];
    
    [[RACObserve(self.sendButton, enabled)
      deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSNumber *enabled) {
        @strongify(self);
        if (enabled.boolValue == YES) {
//            self.sendButton.backgroundColor = COLOR(c_32c7c2);
//            self.sendButton.layer.borderColor = COLOR(c_32c7c2).CGColor;
            [self.sendButton setTitleColor:COLOR(c_32c7c2) forState:UIControlStateNormal];
        }
        else {
//            self.sendButton.backgroundColor = COLOR(c_f5f5f5);
//            self.sendButton.layer.borderColor = COLOR(c_ababab).CGColor;
            [_sendButton setTitleColor:COLOR(c_ffffff) forState:UIControlStateNormal];
        }
    }];
    
    // 点击发送评论按钮
    self.commentSendButtonSignal = [self.sendButton rac_signalForControlEvents:UIControlEventTouchUpInside];
    [[self.sendButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        self.sendButton.enabled = NO;
        // 刷新发送评论时间
        self.lastCommentSendTime = [NSDate date];
        self.numberlable.text = [NSString stringWithFormat:@"0/%ld",(long)self.contentMaxLength];
    }];
    
    return self;
}

#pragma mark - LifeCycle

- (void)loadView {
    [super loadView];
    BOOL isGroup=self.inputViewModel==CMTReplyInputViewModelGroupPostDetail;
    float actionViewHeight=isGroup?75:0;
    self.view.backgroundColor = [UIColor clearColor];
    
    self.backgroundView.frame = self.view.bounds;
    
    CGFloat ratio = RATIO;
    CGFloat margen = 10.0;
    CGFloat leftGap = ceilf(9.3*ratio);
    CGFloat bottomGap = ceilf(5.6*ratio);
    CGFloat keyboardMaxHeight = ceilf(252.0*( (ratio > 1.2) ? (ratio/1.2) : ( (ratio > 1.1) ? (ratio/1.14) : ratio ) ));
    CGFloat contentViewTop = ceilf(30.0*ratio);
    CGFloat contentViewWidht = self.view.bounds.size.width - margen*2.0;
    CGFloat contentViewHeight = self.view.bounds.size.height - contentViewTop - keyboardMaxHeight - margen;
    CGFloat numberlableHeight = ceilf(15*ratio);
    CGFloat buttonWidth = ceilf(46.5*ratio);
    CGFloat buttonHeight = ceilf(23.25*ratio);
    
    
    self.contentView.frame = CGRectMake(margen, contentViewTop - self.view.bounds.size.height, contentViewWidht, contentViewHeight);
    //self.contentView.backgroundColor = [UIColor redColor];
    self.contentTextView.frame = CGRectMake(leftGap, ceilf(14.0*ratio), contentViewWidht - leftGap*2.0, contentViewHeight - ceilf(14.0*ratio) - (bottomGap + buttonHeight + numberlableHeight)-actionViewHeight);
    if (self.inputViewModel!= CMTReplyInputViewModelGroupPostDetail) {
        self.contentTextView.frame = CGRectMake(leftGap, ceilf(14.0*ratio), contentViewWidht - leftGap*2.0, contentViewHeight - ceilf(14.0*ratio) - (bottomGap + buttonHeight + numberlableHeight)-actionViewHeight-75);
    }
    //self.contentTextView.backgroundColor = [UIColor blueColor];
    self.hiddenView.frame = CGRectMake(leftGap, self.contentTextView.bottom - 1, self.contentTextView.width, 76);
    self.actionView.frame=CGRectMake(leftGap, self.contentTextView.bottom, self.contentTextView.width, actionViewHeight);
    
    self.numberlable.frame = CGRectMake(contentViewWidht - 72, contentViewHeight - (bottomGap + buttonHeight) - numberlableHeight + 3, self.contentTextView.right - (contentViewWidht - 72), numberlableHeight - 3);
    
    self.cancelButton.frame = CGRectMake(leftGap, contentViewHeight - bottomGap - buttonHeight, buttonWidth, buttonHeight);
    self.sendButton.frame = CGRectMake(contentViewWidht - leftGap - buttonWidth, contentViewHeight - bottomGap - buttonHeight, buttonWidth, buttonHeight);
}
//更改评论界面
-(void)loadViewGroupimageView:(CMTReplyInputViewModel)InputViewModel{
        [self.contentView addSubview:self.actionView];
        self.hiddenView.hidden = YES;
    self.inputViewModel=InputViewModel;
    BOOL isGroup=YES;
    float actionViewHeight=isGroup?75:0;
    self.view.backgroundColor = [UIColor clearColor];
    
    self.backgroundView.frame = self.view.bounds;
    
    CGFloat ratio = RATIO;
    CGFloat margen = 10.0;
    CGFloat leftGap = ceilf(9.3*ratio);
    CGFloat bottomGap = ceilf(5.6*ratio);
    CGFloat keyboardMaxHeight = ceilf(252.0*( (ratio > 1.2) ? (ratio/1.2) : ( (ratio > 1.1) ? (ratio/1.14) : ratio ) ));
    CGFloat contentViewTop = ceilf(30.0*ratio);
    CGFloat contentViewWidht = self.view.bounds.size.width - margen*2.0;
    CGFloat contentViewHeight = self.view.bounds.size.height - contentViewTop - keyboardMaxHeight - margen;
    CGFloat numberlableHeight = ceilf(15*ratio);
    CGFloat buttonWidth = ceilf(46.5*ratio);
    CGFloat buttonHeight = ceilf(23.25*ratio);
    
    
    self.contentView.frame = CGRectMake(margen, contentViewTop - self.view.bounds.size.height, contentViewWidht, contentViewHeight);
    //self.contentView.backgroundColor = [UIColor redColor];
    self.contentTextView.frame = CGRectMake(leftGap, ceilf(14.0*ratio), contentViewWidht - leftGap*2.0, contentViewHeight - ceilf(14.0*ratio) - (bottomGap + buttonHeight + numberlableHeight)-actionViewHeight);
    if (self.inputViewModel!= CMTReplyInputViewModelGroupPostDetail) {
        self.contentTextView.frame = CGRectMake(leftGap, ceilf(14.0*ratio), contentViewWidht - leftGap*2.0, contentViewHeight - ceilf(14.0*ratio) - (bottomGap + buttonHeight + numberlableHeight)-actionViewHeight-75);
    }
    //self.contentTextView.backgroundColor = [UIColor blueColor];
    self.hiddenView.frame = CGRectMake(leftGap, self.contentTextView.bottom - 1, self.contentTextView.width, 76);
    self.actionView.frame=CGRectMake(leftGap, self.contentTextView.bottom, self.contentTextView.width, actionViewHeight);
    
    self.numberlable.frame = CGRectMake(contentViewWidht - 72, contentViewHeight - (bottomGap + buttonHeight) - numberlableHeight + 3, self.contentTextView.right - (contentViewWidht - 72), numberlableHeight - 3);
    
    self.cancelButton.frame = CGRectMake(leftGap, contentViewHeight - bottomGap - buttonHeight, buttonWidth, buttonHeight);
    self.sendButton.frame = CGRectMake(contentViewWidht - leftGap - buttonWidth, contentViewHeight - bottomGap - buttonHeight, buttonWidth, buttonHeight);
}

#pragma mark - Show & Hide

- (void)showInputView {
    
    if (self.inputViewModel == CMTReplyInputViewModelPostDetail||self.inputViewModel == CMTReplyInputViewModelGroupPostDetail) {
        if (self.lastCommentSendTime != nil && -[self.lastCommentSendTime timeIntervalSinceNow] < 15) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"频繁评论" message:@"请15秒之后进行评论" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alertView show];
            return;
        }
    }
    self.previousWindow = [[UIApplication sharedApplication] keyWindow];
    UIWindow *inputViewWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    inputViewWindow.windowLevel =self.inputViewModel == CMTReplyInputViewModelGroupPostDetail?UIWindowLevelNormal:UIWindowLevelAlert;
    inputViewWindow.backgroundColor = [UIColor clearColor];
    inputViewWindow.rootViewController = self;
    self.inputViewWindow = inputViewWindow;
    [self.inputViewWindow makeKeyAndVisible];
    [self slideInFromTop];
    [self.contentTextView becomeFirstResponder];
    self.cancelButton.enabled = YES;
}

- (void)hideInputView {
    [self slideOutToTop];
    [self.contentTextView resignFirstResponder];
}

#pragma mark - Animations

- (void)slideInFromTop {
    [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:1.0 initialSpringVelocity:0.5 options:0 animations:^{
        CGRect frame = self.contentView.frame;
        frame.origin.y += self.view.bounds.size.height;
        self.contentView.frame = frame;
        self.backgroundView.alpha = 0.5;
    } completion:nil];
}

- (void)slideOutToTop {
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = self.contentView.frame;
        frame.origin.y -= self.view.bounds.size.height;
        self.contentView.frame = frame;
        self.backgroundView.alpha = 0.0;
    } completion:^(BOOL completed) {
        [self.previousWindow makeKeyAndVisible];
        self.previousWindow = nil;
        self.inputViewWindow = nil;
    }];
}

#pragma mark - TextView

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
//    NSString *string = [textView.text stringByAppendingString:text];
//    if (string.length > self.contentMaxLength) {
//        string = [string substringToIndex:self.contentMaxLength];
//        textView.text = string;
//        self.sendButton.enabled = YES;
//        self.numberlable.text = [NSString stringWithFormat:@"%ld/%ld",string.length,(long)self.contentMaxLength];
//        return NO;
//    }
//    self.numberlable.text = [NSString stringWithFormat:@"%ld/%ld", string.length,self.contentMaxLength];
//    return YES;
    if (range.location >= 500) {
        textView.text = [textView.text substringToIndex:500];
        self.numberlable.text = [NSString stringWithFormat:@"%ld/%ld",textView.text.length,self.contentMaxLength];
        return NO;
        
    }else{
        self.numberlable.text = [NSString stringWithFormat:@"%ld/%ld",textView.text.length,self.contentMaxLength];
        return YES;
    }
}
/**
 *  打开相册
 */
-(void)OpenPhotoalbum{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    picker.allowsEditing = NO;
    [self presentViewController:picker animated:YES completion:nil];
}
-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"kfjefjeifjeifjeifj%@",info);
    @weakify(self);
    [self.assetsLibrary assetForURL:info[UIImagePickerControllerReferenceURL] resultBlock:^(ALAsset *asset){
        @strongify(self);
        [[SDWebImageManager sharedManager] saveImageToCache:[self reduceImage:asset]forURL:info[UIImagePickerControllerReferenceURL] ];
        self.picFilepath=[[SDWebImageManager sharedManager].imageCache defaultCachePathForKey:[[SDWebImageManager sharedManager] cacheKeyForURL:info[UIImagePickerControllerReferenceURL]]];

       
    } failureBlock:^(NSError *error) {
        
    }];
    [self.picbutton setImage:info[UIImagePickerControllerOriginalImage] forState:UIControlStateNormal];
    [self.picbutton viewWithTag:100].hidden=NO;
    
    // 隐藏当前模态窗口
    [self dismissViewControllerAnimated:YES completion:nil];
    
    
}
//压缩图片
-(UIImage *)reduceImage:(ALAsset *)image
{
    CGSize dimensions = [image defaultRepresentation].dimensions;
    CMTLog(@"dimensions:%@", NSStringFromCGSize(dimensions));
    CGFloat maxPixel = dimensions.width > dimensions.height ? dimensions.width : dimensions.height;

    return [CMTImageCompression thumbnailForAsset:image maxPixelSize:maxPixel*0.5] ;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker

{
    NSLog(@"您取消了选择图片");
    [picker dismissViewControllerAnimated:YES completion:nil];
}
/**
 *  提醒人员
 */
-(void)RemindPeople{
  CMTSetRemindPeopleViewController *groupMember=[[CMTSetRemindPeopleViewController alloc]initWithGroupID:self.groupID remindArray:self.remindArray model:@"0"];
     @weakify(self);
    NSString *str=@"提醒谁:";
    groupMember.updateRemind=^(NSArray *array){
         @strongify(self);
        self.remindlable.text=array.count>0?[str stringByAppendingString:[[array componentsOfValueForKey:@"nickname"]componentsJoinedByString:@","]]:@"提醒谁看";
        self.remindArray=array;
        self.remindString=array.count>0?[@""stringByAppendingString:[[array componentsOfValueForKey:@"userId"]componentsJoinedByString:@","]]:@"";
    };
    
  CMTNavigationController *navcation=[[CMTNavigationController alloc]initWithRootViewController:groupMember];
    [self presentViewController:navcation animated:YES completion:nil];
}

@end
