//
//  CMTSendCaseHeaderView.m
//  MedicalForum
//
//  Created by fenglei on 15/8/6.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

// view
#import "CMTSendCaseHeaderView.h"                   // header file
#import "UITextView+Placeholder.h"                  // textView空数据提示
#import <AssetsLibrary/AssetsLibrary.h>
#import "WPMediaPicker.h"                           // 图片选择器
#import "SDWebImageManager.h"
#import "CMTWithoutPermissionViewController.h"

@interface CMTSendCaseHeaderView () <UITextViewDelegate, WPMediaPickerViewControllerDelegate>

// output
@property (nonatomic, strong, readwrite) RACSignal *titleTextSignal;                // 标题内容
@property (nonatomic, strong, readwrite) RACSignal *contentTextSignal;              // 正文内容

// view
@property (nonatomic, strong) UIView *titleBackgroundView;                          // 标题背景

@property (nonatomic, strong) UIView *contentBackgroundView;                        // 正文背景
@property (nonatomic, strong, readwrite) UITextView *contentTextView;               // 正文输入区
@property (nonatomic,strong)  UIView *numberlableView;
@property (nonatomic,strong)  UILabel *numberlable;
@property (nonatomic, strong) UIView *pictureBackgroundView;                        // 图片背景
@property (nonatomic, strong) UIButton *addPictureButton;                           // 添加图片按钮
@property (nonatomic, strong) UILabel *addPicturePlaceholder;                       // 添加图片提示
@property(nonatomic,strong)UIControl *Textcontorl;

// data
@property (nonatomic, assign) CMTSendCaseHeaderViewType headerViewType;             // 发帖顶部视图类型
@property (nonatomic, strong) NSArray *pictureAssets;                                 // 图片信息
@property(nonatomic,assign)CMTSendCaseType sendCasePostType;
@property(nonatomic,strong)ALAssetsLibrary *assetsLibrary;
@property(nonatomic,assign)NSInteger contentmaxlength;


@end

@implementation CMTSendCaseHeaderView

#pragma mark Initializers

- (UIView *)titleBackgroundView {
    if (_titleBackgroundView == nil) {
        _titleBackgroundView = [[UIView alloc] init];
        _titleBackgroundView.backgroundColor = COLOR(c_ffffff);
    }
    
    return _titleBackgroundView;
}
-(ALAssetsLibrary*)assetsLibrary{
    if (_assetsLibrary==nil) {
        _assetsLibrary=[[ALAssetsLibrary alloc]init];
    }
    return _assetsLibrary;
}
- (UITextField *)titleField {
    if (_titleField == nil) {
        _titleField = [[UITextField alloc] init];
        _titleField.backgroundColor = COLOR(c_clear);
        _titleField.textColor = COLOR(c_151515);
        _titleField.font = FONT(15.0);
    }
    
    return _titleField;
}
- (UILabel *)numberlable {
    if (_numberlable == nil) {
        _numberlable = [[UILabel alloc] init];
        _numberlable.backgroundColor = COLOR(c_clear);
        _numberlable.textColor = [UIColor colorWithHexString:@"#C4C4C4"];
        _numberlable.textAlignment=NSTextAlignmentRight;
        _numberlable.font = FONT(13);
    }
    
    return _numberlable;
}
-(UIView*)numberlableView{
    if (_numberlableView == nil) {
        _numberlableView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
        _numberlableView.backgroundColor = COLOR(c_ffffff);
        self.numberlable.frame=CGRectMake(0, 0, SCREEN_WIDTH-10, 30);
        [self.numberlableView addSubview:self.numberlable];
    }
    return _numberlableView;

}


- (UIView *)contentBackgroundView {
    if (_contentBackgroundView == nil) {
        _contentBackgroundView = [[UIView alloc] init];
        _contentBackgroundView.backgroundColor = COLOR(c_ffffff);
    }
    
    return _contentBackgroundView;
}

- (UITextView *)contentTextView {
    if (_contentTextView == nil) {
        _contentTextView = [[UITextView alloc] init];
        _contentTextView.backgroundColor = COLOR(c_clear);
        _contentTextView.textColor = COLOR(c_151515);
        _contentTextView.showsHorizontalScrollIndicator = NO;
        _contentTextView.showsVerticalScrollIndicator = NO;
        _contentTextView.font = FONT(15.0);
        _contentTextView.layoutManager.allowsNonContiguousLayout = NO;
        _contentTextView.delegate = self;
    }
    
    return _contentTextView;
}

- (UIView *)pictureBackgroundView {
    if (_pictureBackgroundView == nil) {
        _pictureBackgroundView = [[UIView alloc] init];
        _pictureBackgroundView.backgroundColor = COLOR(c_ffffff);
    }
    
    return _pictureBackgroundView;
}

- (UIButton *)addPictureButton {
    if (_addPictureButton == nil) {
        _addPictureButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _addPictureButton.backgroundColor = COLOR(c_clear);
        [_addPictureButton setImage:IMAGE(@"case_addPicture") forState:UIControlStateNormal];
        [_addPictureButton setImage:IMAGE(@"case_addPicture") forState:UIControlStateHighlighted];
    }
    
    return _addPictureButton;
}

- (UILabel *)addPicturePlaceholder {
    if (_addPicturePlaceholder == nil) {
        _addPicturePlaceholder = [[UILabel alloc] init];
        _addPicturePlaceholder.backgroundColor = COLOR(c_clear);
        _addPicturePlaceholder.textColor = COLOR(c_9e9e9e);
        _addPicturePlaceholder.font = FONT(15.0);
        _addPicturePlaceholder.text = @"添加图片";
    }
    
    return _addPicturePlaceholder;
}
-(UIControl*)Textcontorl{
    if(_Textcontorl==nil){
        _Textcontorl=[[UIControl alloc]init];
        [_Textcontorl addTarget:self action:@selector(setLivetag) forControlEvents:UIControlEventTouchUpInside];
    }
    return _Textcontorl;
}

- (void)loadSubView {
    
    UIView *subViewGuide = nil;
    
    // 标题
    if (self.headerViewType == CMTSendCaseHeaderViewTypeAddPost||self.mylive.hasTags.boolValue) {
        // 标题背景
        [self.titleBackgroundView builtinContainer:self
                                          WithLeft:0.0
                                               Top:0.0
                                             Width:self.width
                                            Height:54.0
         ];
        // 标题输入框
        [self.titleField fillinContainer:self.titleBackgroundView
                                 WithTop:0.0
                                    Left:15.0
                                  Bottom:0.0
                                   Right:0.0
         ];
        if (self.mylive.hasTags.boolValue) {
            self.Textcontorl.frame=self.titleField.frame;
            [self addSubview:self.Textcontorl];

        }
        // 标题分隔线
        UIView *titleBottomLine = [[UIView alloc] init];
        titleBottomLine.backgroundColor = COLOR(c_dddddd);
        
        [titleBottomLine builtinContainer:self.titleBackgroundView
                                 WithLeft:0.0
                                      Top:self.titleBackgroundView.height - PIXEL
                                    Width:self.titleBackgroundView.width
                                   Height:PIXEL
         ];
        
        subViewGuide = self.titleBackgroundView;
    }
    
    // 正文
    CGFloat contentBackgroundViewTop = subViewGuide.bottom;
    CGFloat contentBackgroundViewHeight = 180.0;
    if (self.headerViewType == CMTSendCaseHeaderViewTypeAddPostDescribe ||
        self.headerViewType == CMTSendCaseHeaderViewTypeAddPostConclusion) {
        contentBackgroundViewHeight = 223.0;
    }
    // 正文背景
    [self.contentBackgroundView builtinContainer:self
                                        WithLeft:0.0
                                             Top:contentBackgroundViewTop
                                           Width:self.width
                                          Height:contentBackgroundViewHeight
     ];
    // 正文输入区
    [self.contentTextView fillinContainer:self.contentBackgroundView
                                  WithTop:0.0
                                     Left:10.0
                                   Bottom:0.0
                                    Right:0.0
     ];
    if (self.sendCasePostType==CMTSendCaseTypeAddGroupPost) {
        [self.numberlableView builtinContainer:self
                                      WithLeft:0.0
                                           Top:self.contentBackgroundView.bottom
                                         Width:self.width
                                        Height:0];
    }else{
        [self.numberlableView builtinContainer:self
                                      WithLeft:0.0
                                           Top:self.contentBackgroundView.bottom
                                         Width:self.width
                                        Height:30];
    }
   
    // 正文分隔线
    UIView *contentBottomLine = [[UIView alloc] init];
    contentBottomLine.backgroundColor = COLOR(c_dddddd);
    
    [contentBottomLine builtinContainer:self.numberlableView
                               WithLeft:0.0
                                    Top:self.numberlableView.height - PIXEL
                                  Width:self.numberlableView.width
                                 Height:self.sendCasePostType==CMTSendCaseTypeAddGroupPost?0:PIXEL
     ];
    
    // 图片背景
    CGFloat buttonMargin = 9.0*RATIO;
    CGFloat buttonWidth = (self.width - (buttonMargin * 5.0)) / 4.0;
    [self.pictureBackgroundView builtinContainer:self
                                        WithLeft:0.0
                                             Top:self.sendCasePostType==CMTSendCaseTypeAddGroupPost?self.numberlableView.bottom:self.numberlableView.bottom+5                                        Width:self.width
                                          Height:(buttonMargin + buttonWidth) + buttonMargin
     ];
    // 添加图片按钮
    [self.addPictureButton builtinContainer:self.pictureBackgroundView WithLeft:buttonMargin Top:buttonMargin Width:buttonWidth Height:buttonWidth];
    // 添加图片提示
    [self.addPicturePlaceholder builtinContainer:self.pictureBackgroundView
                                        WithLeft:self.addPictureButton.right + buttonMargin
                                             Top:0.0
                                           Width:70.0*RATIO
                                          Height:self.pictureBackgroundView.height];
    
    // 刷新高度
    self.height = self.pictureBackgroundView.bottom;
}
#pragma 设置分会场
-(void)setLivetag{
    CMTSetLiveTagViewController *livetag=[[CMTSetLiveTagViewController alloc]initWithLiveID:self.mylive.liveBroadcastId];
    @weakify(self);
    livetag.updatetitle=^(CMTLiveTag *livetag){
        @strongify(self);
        if (livetag!=nil) {
            self.titleField.text=livetag.name;
        }else{
            self.titleField.text=@"";
        }
        
    };
    [self.myController.navigationController pushViewController:livetag animated:YES];
    
}
- (instancetype)initWithFrame:(CGRect)frame headerViewType:(CMTSendCaseHeaderViewType)headerViewType sendCaseType:(CMTSendCaseType)sendCaseType viewController:(UIViewController*)controller{
    self = [super initWithFrame:(CGRect){CGPointZero, {frame.size.width, 0.0}}];
    if (self == nil) return nil;
    CMTLog(@"%s", __FUNCTION__);
    @weakify(self);
    [self.rac_willDeallocSignal subscribeCompleted:^{
        CMTLog(@"SendCaseHeaderView willDeallocSignal");
    }];
    self.myController=controller;
    self.contentmaxlength=2000;
    self.sendCasePostType=sendCaseType;
    self.backgroundColor = COLOR(c_clear);
    
    // 发帖顶部视图类型
    self.headerViewType = headerViewType;
    // 加载子视图
    [self loadSubView];
    
    // 标题提示
    self.titleField.placeholder = @"标题（可选填）";
    if (!isEmptyString([self gettitleFieldText])) {
        self.titleField.text=[self gettitleFieldText];
    }
    // 正文提示
    switch (headerViewType) {
        case CMTSendCaseHeaderViewTypeAddPost: {
            self.contentTextView.placeholder = @"填写详细描述";
        }
            break;
        case CMTSendCaseHeaderViewTypeAddPostDescribe: {
            self.contentTextView.placeholder = @"添加描述，请输入内容...";
        }
            break;
        case CMTSendCaseHeaderViewTypeAddPostConclusion: {
            self.contentTextView.placeholder = @"添加结论，请输入内容...";
        }
            break;
        default:
            break;
    }
    if (!isEmptyString([self getDesectionFieldText])) {
        self.contentTextView.text=[self getDesectionFieldText];
        
    }
    if (self.sendCasePostType==CMTSendCaseTypeAddGroupPost) {
         ((CMTSendCaseViewController*)self.myController).numberlable.text=[@"" stringByAppendingFormat:@"%ld/%ld", (long)self.contentTextView.text.length,(long)self.contentmaxlength];
        
        ((CMTSendCaseViewController*)self.myController).numberlable2.text=[@"" stringByAppendingFormat:@"%ld/%ld", (long)self.contentTextView.text.length,(long)self.contentmaxlength];
    }else{
         self.numberlable.text=[@"" stringByAppendingFormat:@"还可输入%ld个字", (long)(self.contentmaxlength-self.contentTextView.text.length)];
    }
    
    
    self.pictureAssets=[self getssets];
    if ([self.pictureAssets count]!=0) {
        [self getAllimagessets];
    }else{
        self.pictureAssets=@[];
    }
    
    // 标题内容
    self.titleTextSignal = [self.titleField rac_textSignal];
    // 正文内容
    self.contentTextSignal = [self.contentTextView rac_textSignal];
    
    // 添加图片按钮
    [[self.addPictureButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        [self addPicture];
    }];
       return self;
}

//发布帖子
- (instancetype)initWithFrame:(CGRect)frame  live:(CMTLive*)live viewController:(UIViewController*)controller {
    self = [super initWithFrame:(CGRect){CGPointZero, {frame.size.width, 0.0}}];
    if (self == nil) return nil;
    CMTLog(@"%s", __FUNCTION__);
    @weakify(self);
    [self.rac_willDeallocSignal subscribeCompleted:^{
        CMTLog(@"SendCaseHeaderView willDeallocSignal");
    }];
    self.contentmaxlength=500;
    self.mylive=live;
    self.myController=controller;
    
    self.backgroundColor = COLOR(c_clear);

    // 加载子视图
    [self loadSubView];
    
    // 标题提示
    self.titleField.placeholder = @"选择分会场";
    if (!isEmptyString([self gettitleFieldText])) {
        self.titleField.text=[self gettitleFieldText];
    }
    // 正文提示
        self.contentTextView.placeholder = @"填写详细描述";
        if (!isEmptyString([self getDesectionFieldText])) {
        self.contentTextView.text=[self getDesectionFieldText];
       
    }
    self.numberlable.text=[@"" stringByAppendingFormat:@"还可输入%ld个字", (long)(self.contentmaxlength-self.contentTextView.text.length)];
   

    self.pictureAssets=[self getssets];
    if ([self.pictureAssets count]!=0) {
        [self getAllimagessets];
    }else{
        self.pictureAssets=@[];
    }
    
    // 标题内容
    self.titleTextSignal = [self.titleField rac_textSignal];
    // 正文内容
    self.contentTextSignal = [self.contentTextView rac_textSignal];
    
    // 添加图片按钮
    [[self.addPictureButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        [self addPicture];
    }];
    
    return self;
}
//获取标题
-(NSString*)gettitleFieldText{
    NSString *string=@"";
    if (self.sendCasePostType==CMTSendCaseTypeAddPost) {
        string=CMTAPPCONFIG.addPostData.title?:@"";
    }else if((self.sendCasePostType==CMTSendCaseTypeAddPostConclusion)||(self.sendCasePostType==CMTSendCaseTypeAddPostDescribe)){
        string=CMTAPPCONFIG.addPostAdditionalData.title?:@"";
    }else if(self.sendCasePostType==CMTSendCaseTypeAddGroupPost){
        string=CMTAPPCONFIG.addGroupPostData.title?:@"";
    }else if (self.mylive.hasTags.boolValue){
        string=CMTAPPCONFIG.addLivemessageData.livetag.name?:@"";

    }
    return string;
}
//获取描述
-(NSString*)getDesectionFieldText{
    NSString *string=@"";
    if (self.sendCasePostType==CMTSendCaseTypeAddPost) {
        string=CMTAPPCONFIG.addPostData.addPostContent?:@"";
    }else if((self.sendCasePostType==CMTSendCaseTypeAddPostConclusion)||(self.sendCasePostType==CMTSendCaseTypeAddPostDescribe)){
        string=CMTAPPCONFIG.addPostAdditionalData.addPostContent?:@"";
    }else if(self.sendCasePostType==CMTSendCaseTypeAddGroupPost){
        string=CMTAPPCONFIG.addGroupPostData.addPostContent?:@"";
    }else if (self.mylive.liveBroadcastId!=nil){
        string=CMTAPPCONFIG.addLivemessageData.addPostContent?:@"";
        
    }
    return string;
}
//获取相册路径
-(NSArray*)getssets{
    NSArray *string=@[];
    if (self.sendCasePostType==CMTSendCaseTypeAddPost) {
        string=CMTAPPCONFIG.addPostData.pictureFilePaths?:@[];
    }else if((self.sendCasePostType==CMTSendCaseTypeAddPostConclusion)||(self.sendCasePostType==CMTSendCaseTypeAddPostDescribe)){
        string=CMTAPPCONFIG.addPostAdditionalData.pictureFilePaths?:@[];
    }else if(self.sendCasePostType==CMTSendCaseTypeAddGroupPost){
        string=CMTAPPCONFIG.addGroupPostData.pictureFilePaths?:@[];
    }else if (self.mylive.liveBroadcastId!=nil){
        string=CMTAPPCONFIG.addLivemessageData.pictureFilePaths?:@[];
        
    }

    return  [string componentsOfValueForKey:@"assetRepresentationURL"];
}
//获取相册
-(void)getAllimagessets{
    NSMutableArray *imageArray;
    imageArray=[[NSMutableArray alloc] init];
    for (NSString *str in self.pictureAssets) {
        NSURL *url=[[NSURL alloc]initWithString:str];
        [self.assetsLibrary assetForURL:url resultBlock:^(ALAsset *asset) {
            if([self.pictureAssets containsObject:asset.defaultRepresentation.url.absoluteString]){
                [imageArray addObject:asset];
                if(self.pictureAssets.count==[imageArray count])
                    [self performSelectorOnMainThread:@selector(refreshPictureWithAssets:) withObject:imageArray waitUntilDone:YES];
            }

        } failureBlock:^(NSError *error) {
            
        }];
    }
    
   
}
//获取学科
-(NSString*)getSubText{
    NSString *string=@"";
    if (self.sendCasePostType==CMTSendCaseTypeAddPost) {
        string=CMTAPPCONFIG.addPostSubject.subject?:@"";
    }
    return string;
}
- (void)addPicture {
    ALAuthorizationStatus authStatus =[ALAssetsLibrary authorizationStatus];
    if(authStatus == ALAuthorizationStatusRestricted || authStatus == ALAuthorizationStatusDenied){
        
        NSLog(@"相机权限受限");
        CMTWithoutPermissionViewController *per= [[CMTWithoutPermissionViewController alloc]initWithType:@"1"];
        UINavigationController *nav=[[UINavigationController alloc]initWithRootViewController:per];
        [self.myController presentViewController:nav animated:YES completion:nil];
        return;
    }

    NSMutableArray *mutable=[[NSMutableArray alloc]initWithArray:self.pictureAssets];
    for(id asseturl in self.pictureAssets){
        if ([asseturl isKindOfClass:[NSString class]]) {
            [mutable removeObject:asseturl];
        }
    }
    self.pictureAssets=[mutable copy];
    // 弹出图片选择器
    WPMediaPickerViewController *mediaPicker = [[WPMediaPickerViewController alloc] init];
    mediaPicker.filter = WPMediaTypeImage;
    mediaPicker.allowCaptureOfMedia = NO;
    mediaPicker.delegate = self;
    mediaPicker.selectarray=(self.pictureAssets==nil?@[]:self.pictureAssets);
    if ([self.delegate respondsToSelector:@selector(presentMediaPicker:animated:)]) {
        [self.delegate presentMediaPicker:mediaPicker animated:YES];
    }
}

- (void)exchangePicture {
           [self addPicture];
}

- (void)refreshPictureWithAssets:(NSArray *)assets {
    self.pictureAssets=[assets copy];
    
    CGFloat buttonMargin = 9.0*RATIO;
    CGFloat buttonWidth = (self.width - (buttonMargin * 5.0)) / 4.0;
    NSInteger pictureCount = [assets count]<9?[assets count]+1:[assets count];
    NSInteger numberOfRow = (pictureCount - 1) / 4 + 1;
    // 刷新图片背景高度
    self.pictureBackgroundView.height = (buttonMargin + buttonWidth) * numberOfRow + buttonMargin;
    // 刷新高度
    self.height = self.pictureBackgroundView.bottom;
    
    // 清除旧子视图
    for (UIView *subView in self.pictureBackgroundView.subviews) {
        [subView removeFromSuperview];
    }
    if (pictureCount == 0) {
        // 添加图片按钮
        [self.addPictureButton builtinContainer:self.pictureBackgroundView WithLeft:buttonMargin Top:buttonMargin Width:buttonWidth Height:buttonWidth];
        // 添加图片提示
        [self.addPicturePlaceholder builtinContainer:self.pictureBackgroundView
                                            WithLeft:self.addPictureButton.right + buttonMargin
                                                 Top:0.0
                                               Width:70.0*RATIO
                                              Height:self.pictureBackgroundView.height];
    }
   
    // 添加新图片
    BOOL ispicFull=[assets count]<9;
    for (NSInteger index = 0;index<=(ispicFull?[assets count]:[assets count]-1);index++) {
        ALAsset *asset=nil;
        UIImage *image =nil;
        if (ispicFull) {
            if (index!=[assets count]) {
                asset=[assets objectAtIndex:index];
                image=[[SDWebImageManager sharedManager].imageCache imageFromDiskCacheForKey:
                       [[SDWebImageManager sharedManager] cacheKeyForURL:asset.defaultRepresentation.url]];

            }else{
                image=IMAGE(@"case_addPicture");
            }
        }else{
            asset=[assets objectAtIndex:index];
            image=[[SDWebImageManager sharedManager].imageCache imageFromDiskCacheForKey:
                   [[SDWebImageManager sharedManager] cacheKeyForURL:asset.defaultRepresentation.url]];
        }
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag=index+1;
        button.backgroundColor = [UIColor clearColor];
        [button setImage:image forState:UIControlStateNormal];
        button.imageView.contentMode=UIViewContentModeScaleAspectFill;
        button.clipsToBounds=YES;

        [button addTarget:self action:@selector(exchangePicture) forControlEvents:UIControlEventTouchUpInside];
        
        NSInteger row = index / 4;
        NSInteger line = index % 4;
        CGFloat buttonTop = buttonMargin + (buttonMargin + buttonWidth) * row;
        CGFloat buttonLeft = buttonMargin + (buttonMargin + buttonWidth) * line;
        [button builtinContainer:self.pictureBackgroundView WithLeft:buttonLeft Top:buttonTop Width:buttonWidth Height:buttonWidth];
        UIButton *deleteButton=[[UIButton alloc]initWithFrame:CGRectMake(button.width-20,0,20, 20)];
        [deleteButton setImage:IMAGE(@"deletCaseimage") forState:UIControlStateNormal];
        deleteButton.tag=index+1;
        [deleteButton addTarget:self action:@selector(deleteimage:) forControlEvents:UIControlEventTouchUpInside];
        if (ispicFull&&index==[assets count]) {
            deleteButton.hidden=YES;
        }
        [button addSubview:deleteButton];
        
    }
    self.frame=CGRectMake(self.left, self.top, self.width,self.pictureBackgroundView.bottom);

    
    if ([self.delegate respondsToSelector:@selector(refreshSendCaseHeaderView)]) {
        [self.delegate refreshSendCaseHeaderView];
    }
}
//删除图片
-(void)deleteimage:(UIButton*)btn{
    CGFloat buttonMargin = 9.0*RATIO;
    CGFloat buttonWidth = (self.width - (buttonMargin * 5.0)) / 4.0;
    NSMutableArray *array=[[NSMutableArray alloc]initWithArray:self.pictureAssets];
    [array removeObjectAtIndex:btn.tag-1];
    self.pictureAssets=[array copy];
    NSMutableArray *arraypic=[NSMutableArray array];
   
    if (self.sendCasePostType==CMTSendCaseTypeAddPost) {
        [arraypic addObjectsFromArray:CMTAPPCONFIG.addPostData.pictureFilePaths];
        [arraypic removeObjectAtIndex:btn.tag-1];
        CMTAPPCONFIG.addPostData.pictureFilePaths=[arraypic copy];
    }else if((self.sendCasePostType==CMTSendCaseTypeAddPostConclusion)||(self.sendCasePostType==CMTSendCaseTypeAddPostDescribe)){
        [arraypic addObjectsFromArray:CMTAPPCONFIG.addPostAdditionalData.pictureFilePaths];
        [arraypic removeObjectAtIndex:btn.tag-1];
         CMTAPPCONFIG.addPostAdditionalData.pictureFilePaths=[arraypic copy];
    }else if(self.sendCasePostType==CMTSendCaseTypeAddGroupPost){
        [arraypic addObjectsFromArray:CMTAPPCONFIG.addGroupPostData.pictureFilePaths];
        [arraypic removeObjectAtIndex:btn.tag-1];
        CMTAPPCONFIG.addGroupPostData.pictureFilePaths=[arraypic copy];
    }else if (self.mylive.liveBroadcastId!=nil){
        [arraypic addObjectsFromArray:CMTAPPCONFIG.addLivemessageData.pictureFilePaths];
        [arraypic removeObjectAtIndex:btn.tag-1];
         CMTAPPCONFIG.addLivemessageData.pictureFilePaths=[arraypic copy];
        
    }
    @weakify(self);
    [UIView animateWithDuration:1 animations:^{
        @strongify(self);
        for (NSInteger index=0;index<[self.pictureBackgroundView subviews].count;index++) {
            if (index==btn.tag-1&&self.pictureAssets.count!=8 ) {
                UIButton *button=[self.pictureBackgroundView subviews][index];
                [button removeFromSuperview];

            }else if(self.pictureAssets.count==8){
                if (index!=self.pictureAssets.count) {
                    UIButton *button=[self.pictureBackgroundView subviews][index];
                    UIImage *image=[[SDWebImageManager sharedManager].imageCache imageFromDiskCacheForKey:
                                     [[SDWebImageManager sharedManager] cacheKeyForURL:((ALAsset*)self.pictureAssets[index]).defaultRepresentation.url]];
                    [button setImage:image forState:UIControlStateNormal];
                }
              
              
            }
        }

        for (NSInteger index=0;index<[self.pictureBackgroundView subviews].count;index++) {
            UIButton *button=[self.pictureBackgroundView subviews][index];
            button.tag=index+1;
            NSInteger row = index / 4;
            NSInteger line = index % 4;
            CGFloat buttonTop = buttonMargin + (buttonMargin + buttonWidth) * row;
            CGFloat buttonLeft = buttonMargin + (buttonMargin + buttonWidth) * line;
            button.frame=CGRectMake(buttonLeft, buttonTop, buttonWidth, buttonWidth);
            for (UIView *subview in [button subviews]) {
                if ([subview isKindOfClass:[UIButton class]]) {
                    subview.tag=index+1;
                }
                if (index==8) {
                    subview.hidden=YES;
                    [button setImage:IMAGE(@"case_addPicture") forState:UIControlStateNormal];
                }
            }

        }
    } completion:^(BOOL finished) {
         @strongify(self);
        NSInteger pictureCount = [self.pictureAssets count]<9?[self.pictureAssets count]+1:[self.pictureAssets count];
        NSInteger numberOfRow = (pictureCount - 1) / 4 + 1;
        // 刷新图片背景高度
        self.pictureBackgroundView.height = (buttonMargin + buttonWidth) * numberOfRow + buttonMargin;
        // 刷新高度
        self.height = self.pictureBackgroundView.bottom;
        
        self.frame=CGRectMake(self.left, self.top, self.width,self.pictureBackgroundView.bottom);
        
        
        if ([self.delegate respondsToSelector:@selector(refreshSendCaseHeaderView)]) {
            [self.delegate refreshSendCaseHeaderView];
        }

        
    }];
   
    
}

#pragma mark - MediaPicker

- (void)mediaPickerControllerDidCancel:(WPMediaPickerViewController *)picker {
    if ([self.delegate respondsToSelector:@selector(dismissMediaPickerAnimated:completion:)]) {
        [self.delegate dismissMediaPickerAnimated:YES completion:nil];
    }
}

- (void)mediaPickerController:(WPMediaPickerViewController *)picker didFinishPickingAssets:(NSArray *)assets {
    if ([self.delegate respondsToSelector:@selector(mediaPickerDidFinishPickingAssets:)]) {
        [self.delegate mediaPickerDidFinishPickingAssets:assets];
    }
    
    if ([self.delegate respondsToSelector:@selector(dismissMediaPickerAnimated:completion:)]) {
        [self.delegate dismissMediaPickerAnimated:YES completion:nil];
    }
    
    [self refreshPictureWithAssets:assets];
}

#pragma mark TextView

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSString *str=[self.contentTextView.text stringByAppendingString:text];
    if (str.length>self.contentmaxlength) {

        str=[str substringToIndex:self.contentmaxlength];
         textView.text=str;
        if (self.sendCasePostType==CMTSendCaseTypeAddGroupPost) {
            ((CMTSendCaseViewController*)self.myController).numberlable.text=[@"" stringByAppendingFormat:@"%ld/%ld", (long)str.length,(long)self.contentmaxlength];
            
             ((CMTSendCaseViewController*)self.myController).numberlable2.text=[@"" stringByAppendingFormat:@"%ld/%ld", (long)str.length,(long)self.contentmaxlength];
        }else{
           self.numberlable.text=[@"" stringByAppendingFormat:@"还可输入%ld个字", (long)(self.contentmaxlength-str.length)];
        }
        
        return NO;
    }else if (self.sendCasePostType==CMTSendCaseTypeAddGroupPost) {
       ((CMTSendCaseViewController*)self.myController).numberlable.text=[@"" stringByAppendingFormat:@"%ld/%ld", (long)str.length,(long)self.contentmaxlength];
        
         ((CMTSendCaseViewController*)self.myController).numberlable2.text=[@"" stringByAppendingFormat:@"%ld/%ld", (long)str.length,(long)self.contentmaxlength];
        return YES;

    }else{
        self.numberlable.text=[@"" stringByAppendingFormat:@"还可输入%ld个字", (long)(self.contentmaxlength-str.length)];
        return YES;

    }

    return NO;
    
    }
- (void)textViewDidChange:(UITextView *)textView{
    if (textView.text.length>self.contentmaxlength) {
        textView.text=[textView.text substringToIndex:self.contentmaxlength];
        
    }
    if (self.sendCasePostType==CMTSendCaseTypeAddGroupPost) {
        ((CMTSendCaseViewController*)self.myController).numberlable.text=[@"" stringByAppendingFormat:@"%ld/%ld", (long)textView.text.length,(long)self.contentmaxlength];
         ((CMTSendCaseViewController*)self.myController).numberlable2.text=[@"" stringByAppendingFormat:@"%ld/%ld", (long)textView.text.length,(long)self.contentmaxlength];
        
    }else{
        self.numberlable.text=[@"" stringByAppendingFormat:@"还可输入%ld个字", (long)(self.contentmaxlength-textView.text.length)];
    }

}


@end
