//
//  CMTSendCaseViewController.m
//  MedicalForum
//
//  Created by fenglei on 15/7/31.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

// controller
#import "CMTSendCaseViewController.h"                       // header file
#import "CMTCaseSendSubjectViewController.h"                // 设置病例学科
#import "CMTSetCaseTagViewController.h"                     // 设置病例标签
#import <AssetsLibrary/AssetsLibrary.h>
#import <ImageIO/ImageIO.h>
#import "WPMediaPicker.h"
#import "SDWebImageManager.h"
#import "CMTGroupMembersViewController.h"
#import "CMTSetRemindPeopleViewController.h"
#import "CmtVoteViewController.h"

// view
#import "CMTSendCaseHeaderView.h"                           // 发帖顶部视图
#import <QuartzCore/QuartzCore.h>

static NSString * const CMTSendCaseEditorCellIdentifier = @"CMTSendCaseEditorCell";

@interface CMTSendCaseViewController () <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, CMTSendSubjectDelegate, CMTSetCaseTagViewDelegate, CMTSendCaseHeaderViewDelegate>

// view
@property (nonatomic, strong) UIBarButtonItem *cancelItem;                          // 取消按钮
@property (nonatomic, strong) UIBarButtonItem *sendItem;                            // 发布按钮
@property (nonatomic, strong) UIBarButtonItem *unsendItem;                            // 发布按钮
@property (nonatomic, strong) UITableView *tableView;                               // 发帖编辑区
@property (nonatomic, strong) CMTSendCaseHeaderView *sendCaseHeaderView;            // 发帖顶部视图
 @property(nonatomic,strong)UIButton *sendButton;                                   //发帖按钮
@property(nonatomic,strong)UIButton *cancelButton;                                   //发帖按钮
@property(nonatomic,strong)NSArray *leftItems;

@property(nonatomic,strong)NSArray *rightItems;


// data
@property (nonatomic, assign) CMTSendCaseType sendCaseType;                         // 发帖类型
@property (nonatomic, strong) CMTAddPost *sendCaseData;                             // 发帖信息
@property (nonatomic, copy) NSString *groupSubjectId;                               // 小组学科ID(第一个可见学科)
@property(nonatomic,strong)CMTLive *mylive;                                        //我的直播
@property(nonatomic,assign)NSInteger contentmaxlength;
@property(nonatomic,strong)UIView *CmttoolBar;


@end

@implementation CMTSendCaseViewController

#pragma mark - Initializers
-(instancetype)initWithSenLivemassge:(CMTLive*)live {
    self = [super initWithNibName:nil bundle:nil];
    if (self == nil) return nil;
    CMTLog(@"%s", __FUNCTION__);
    self.mylive=live;
    self.sendCaseData = CMTAPPCONFIG.addLivemessageData;
    self.sendCaseData.liveBroadcastId=live.liveBroadcastId;
    self.contentmaxlength = 500;
    return self;
}
- (instancetype)initWithSendCaseType:(CMTSendCaseType)sendCaseType
                              postId:(NSString *)postId
                          postTypeId:(NSString *)postTypeId
                             groupId:(NSString *)groupId
                      groupSubjectId:(NSString *)groupSubjectId {
    self = [super initWithNibName:nil bundle:nil];
    if (self == nil) return nil;
    CMTLog(@"%s", __FUNCTION__);
    
    // 设置发帖类型
    self.sendCaseType = sendCaseType;
    
    // 设置发帖信息
    switch (sendCaseType) {
        case CMTSendCaseTypeAddPost: {
            self.sendCaseData = CMTAPPCONFIG.addPostData;
        }
            break;
        case CMTSendCaseTypeAddGroupPost: {
            self.sendCaseData = CMTAPPCONFIG.addGroupPostData;
        }
            break;
        case CMTSendCaseTypeAddPostDescribe: {
            self.sendCaseData = CMTAPPCONFIG.addPostAdditionalData;
            self.sendCaseData.contentType = @"0";
        }
            break;
        case CMTSendCaseTypeAddPostConclusion: {
            self.sendCaseData = CMTAPPCONFIG.addPostAdditionalData;
            self.sendCaseData.contentType = @"1";
        }
            break;
        default:
            break;
    }
     self.sendCaseData.postId = postId;
     self.sendCaseData.postTypeId = postTypeId;
    if (![self.sendCaseData.groupId isEqualToString:groupId]) {
        self.sendCaseData.userinfoArray=@[];
        self.sendCaseData.voteTilte=@"";
        self.sendCaseData.voteArray=@[];
     }
      self.sendCaseData.groupId = groupId;

    
     self.groupSubjectId = groupSubjectId;
    self.contentmaxlength = 2000;
    
    return self;
}
- (NSArray *)leftItems {
    if (_leftItems == nil) {
        UIBarButtonItem *leftFixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        leftFixedSpace.width =-20+(RATIO - 1.0)*(CGFloat)12.0;
        _leftItems = @[leftFixedSpace, self.cancelItem];
    }
    
    return _leftItems;
}
- (NSArray *)rightItems{
    if (_rightItems == nil) {
        UIBarButtonItem *leftFixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        leftFixedSpace.width =-10+(RATIO - 1.0)*(CGFloat)12.0;
        _rightItems = @[leftFixedSpace, self.sendItem];
    }
    
    return _rightItems;
}


- (UIButton *)cancelButton {
    if (_cancelButton == nil) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelButton.frame=CGRectMake(0, 0, 50, 30);
        _cancelButton.titleLabel.font = FONT(13);
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelButton setTitleColor:COLOR(C_919191) forState:UIControlStateNormal];
        [_cancelButton setTitleColor:COLOR(C_919191) forState:UIControlStateDisabled];
    }
    return _cancelButton;
}


- (UIBarButtonItem *)cancelItem {
    if (_cancelItem == nil) {
        _cancelItem = [[UIBarButtonItem alloc] initWithCustomView:self.cancelButton];
    }
    
    return _cancelItem;
}

-(UIButton*)sendButton{
    if (_sendButton == nil) {
        _sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _sendButton.frame=CGRectMake(0, 0, 50, 30);
        _sendButton.backgroundColor = COLOR(c_f5f5f5);
        _sendButton.enabled = NO;
        _sendButton.layer.borderColor=[UIColor colorWithHexString:@"d9d9d9"].CGColor;
        _sendButton.layer.cornerRadius=5;
        _sendButton.layer.borderWidth=1;
        _sendButton.titleLabel.font = FONT(13);
        _sendButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_sendButton setTitle:@"发布" forState:UIControlStateNormal];
        [_sendButton setTitleColor:[UIColor colorWithHexString:@"#d4d4d4"] forState:UIControlStateNormal];
        [_sendButton setTitleColor:COLOR(c_ababab) forState:UIControlStateDisabled];
    }
    return _sendButton;

}
- (UIBarButtonItem *)sendItem {
    if (_sendItem == nil) {
        _sendItem = [[UIBarButtonItem alloc] initWithCustomView:self.sendButton];
    }
    
    return _sendItem;
}
- (UILabel *)numberlable {
    if (_numberlable == nil) {
        _numberlable = [[UILabel alloc] init];
        _numberlable.backgroundColor =[UIColor clearColor];
        _numberlable.textColor = [UIColor colorWithHexString:@"#C4C4C4"];
        _numberlable.textAlignment=NSTextAlignmentRight;
        _numberlable.font = FONT(13);
    }
    
    return _numberlable;
}
- (UILabel *)numberlable2 {
    if (_numberlable2 == nil) {
        _numberlable2 = [[UILabel alloc] init];
        _numberlable2.backgroundColor =[UIColor clearColor];
        _numberlable2.textColor = [UIColor colorWithHexString:@"#C4C4C4"];
        _numberlable2.textAlignment=NSTextAlignmentRight;
        _numberlable2.font = FONT(13);
    }
    
    return _numberlable2;
}

- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] init];
        _tableView.contentInset = UIEdgeInsetsMake(CMTNavigationBarBottomGuide, 0.0, 75.0, 0.0);
        _tableView.backgroundColor = COLOR(c_ffffff);
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.allowsSelection=NO;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CMTSendCaseEditorCellIdentifier];
    }
    
    return _tableView;
}
-(UIView*)CmttoolBar{
    if (_CmttoolBar==nil) {
        _CmttoolBar=[[UIView alloc]initWithFrame:CGRectMake(0,SCREEN_HEIGHT-44, SCREEN_WIDTH,44)];
        _CmttoolBar.hidden=YES;
        _CmttoolBar.backgroundColor=ColorWithHexStringIndex(c_efeff4);
        UIButton *vote=[[UIButton alloc]initWithFrame:CGRectMake(20, 2, 40, 40)];
        if(self.sendCaseData.voteArray.count==0){
            [vote setImage:IMAGE(@"caseVote") forState:UIControlStateNormal];
        }else{
            [vote setImage:IMAGE(@"hasaseVote") forState:UIControlStateNormal];
        }

        vote.tag=1000;
        [vote addTarget:self action:@selector(setVoteAction) forControlEvents:UIControlEventTouchUpInside];
        [self.CmttoolBar addSubview:vote];
       
       
        UIButton *tagButton=[[UIButton alloc]initWithFrame:CGRectMake(vote.right+20, 2, 40, 40)];
        if (self.sendCaseData.diseaseTagArray.count==0) {
            [tagButton setImage:IMAGE(@"tag") forState:UIControlStateNormal];
            
        }else{
            [tagButton setImage:IMAGE(@"hastag") forState:UIControlStateNormal];
            
        }

           tagButton.tag=1002;
        [self.CmttoolBar addSubview:tagButton];
        [tagButton addTarget:self action:@selector(setTag) forControlEvents:UIControlEventTouchUpInside];
        
        
        UIButton *remind=[[UIButton alloc]initWithFrame:CGRectMake(tagButton.right+20, 2, 40, 40)];
        if (self.sendCaseData.userinfoArray.count==0) {
            [remind setImage:IMAGE(@"remindPepople") forState:UIControlStateNormal];
        }else{
            [remind setImage:IMAGE(@"hasRemindpeolpe") forState:UIControlStateNormal];
        }
        [self.CmttoolBar addSubview:remind];
        remind.tag=1001;
        [remind addTarget:self action:@selector(CMTremind) forControlEvents:UIControlEventTouchUpInside];
        
        self.numberlable2.frame=CGRectMake(tagButton.right+10, 6, SCREEN_WIDTH-tagButton.right-20, 30);
        [self.CmttoolBar addSubview:self.numberlable2];

    }
    return _CmttoolBar;
    
}
- (CMTSendCaseHeaderView *)sendCaseHeaderView {
    if (_sendCaseHeaderView == nil) {
        CMTSendCaseHeaderViewType sendCaseHeaderViewType = CMTSendCaseHeaderViewTypeAddPost;
        if (self.sendCaseType == CMTSendCaseTypeAddPostDescribe) {
            sendCaseHeaderViewType = CMTSendCaseHeaderViewTypeAddPostDescribe;
        }
        else if (self.sendCaseType == CMTSendCaseTypeAddPostConclusion) {
            sendCaseHeaderViewType = CMTSendCaseHeaderViewTypeAddPostConclusion;
        }
        if(self.mylive.liveBroadcastId==nil){
          _sendCaseHeaderView = [[CMTSendCaseHeaderView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.tableView.width, 0.0)
                                                            headerViewType:sendCaseHeaderViewType sendCaseType:self.sendCaseType viewController:self];
           _sendCaseHeaderView.delegate = self;
        }else{
            _sendCaseHeaderView = [[CMTSendCaseHeaderView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.tableView.width, 0.0)live:self.mylive viewController:self];
            _sendCaseHeaderView.delegate = self;
        }
    }
    
    return _sendCaseHeaderView;
}

#pragma mark - LifeCycle

- (void)loadView {
    [super loadView];
    
    // 发帖编辑区
    [self.tableView fillinContainer:self.contentBaseView
                            WithTop:0.0
                               Left:0.0
                             Bottom:0.0
                              Right:0.0
     ];
    
    self.tableView.contentSize = CGSizeMake(
                                            self.tableView.width,
                                            self.tableView.height - CMTNavigationBarBottomGuide + 0.5
                                                       );
    
    self.tableView.tableHeaderView = self.sendCaseHeaderView;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if(self.sendCaseType==CMTSendCaseTypeAddGroupPost){
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
    }

}
- (void)keyboardWillShow:(NSNotification *)notif {
    CGRect rect = [[notif.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat y = rect.origin.y;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.25];
    float height=self.sendCaseData.userinfoArray.count>0?44+25:44;
    height=self.sendCaseData.diseaseTagArray.count>0?height+25:height;
    if (self.sendCaseHeaderView.height+height>y-CMTNavigationBarBottomGuide) {
        self.CmttoolBar.frame=CGRectMake(0,y-44, SCREEN_WIDTH,44);
        self.CmttoolBar.hidden=NO;
        [self.contentBaseView addSubview:self.CmttoolBar];
    }
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)notif {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.25];
    self.CmttoolBar.frame=CGRectMake(0,SCREEN_HEIGHT-44, SCREEN_WIDTH,44);
    self.CmttoolBar.hidden=YES;
    [UIView commitAnimations];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if(self.sendCaseType==CMTSendCaseTypeAddGroupPost){
       [[NSNotificationCenter defaultCenter] removeObserver:self name:  UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    }

}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CMTLog(@"%s", __FUNCTION__);
    @weakify(self);
    [self.rac_willDeallocSignal subscribeCompleted:^{
        CMTLog(@"SendCase willDeallocSignal");
    }];
    
#pragma mark 导航栏按钮
    
    // 取消按钮
    self.navigationItem.leftBarButtonItems = self.leftItems;
    
    // 发布按钮
    self.navigationItem.rightBarButtonItems = self.rightItems;
    [[RACObserve(self,sendCaseData.pictureFilePaths)
      deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSArray *array) {
        @strongify(self);
        if (self.sendCaseType==CMTSendCaseTypeAddGroupPost ) {
            if (self.sendCaseHeaderView.contentTextView.text.length < ((self.mylive==nil&&(array.count==0&&self.sendCaseData.voteTilte.length==0) )? 1:1)) {
                self.sendButton.enabled =NO;
            }else{
                self.sendButton.enabled=YES;
            }

        }else{
            if (self.sendCaseHeaderView.contentTextView.text.length < ((self.mylive==nil&&array.count==0)? 1:1)) {
                self.sendButton.enabled =NO;
            }else{
                self.sendButton.enabled=YES;
            }

        }
    }];

    [[[self.sendCaseHeaderView.titleField rac_textSignal]
      deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSString *voteTilte) {
        @strongify(self);
        if (self.sendCaseType==CMTSendCaseTypeAddGroupPost ) {
            voteTilte = [voteTilte stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

            if (self.sendCaseHeaderView.contentTextView.text.length < 1) {
                self.sendButton.enabled =NO;
            }else{
                self.sendButton.enabled=YES;
            }
            
        }else{
            voteTilte = [voteTilte stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if (voteTilte.length < ((self.mylive==nil&&self.sendCaseData.pictureFilePaths.count==0)? 1:1)) {
                self.sendButton.enabled =NO;
            }else{
                self.sendButton.enabled=YES;
            }
            
        }
    }];

    // 发送按钮状态
    [[[self.sendCaseHeaderView.contentTextView rac_textSignal]
      deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSString *x) {
        @strongify(self);
        // 正文内容不足20个字符
        if (self.sendCaseType==CMTSendCaseTypeAddGroupPost) {
            x = [x stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if (x.length < ((self.mylive==nil&&(self.sendCaseData.pictureFilePaths.count==0&&self.sendCaseData.voteTilte.length==0))? 1:1)) {
                self.sendButton.enabled =NO;
            }else{
                self.sendButton.enabled=YES;
            }

        }else {
           x = [x stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
          if (x.length < ((self.mylive==nil&&(self.sendCaseData.pictureFilePaths.count==0))? 1:1)) {
                self.sendButton.enabled =NO;
            }else{
                self.sendButton.enabled=YES;
            }
        }

        
    }];
    
    [[RACObserve(self.sendButton, enabled)
      deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSNumber *enabled) {
        @strongify(self);
        if (enabled.boolValue == YES) {
            self.sendButton.backgroundColor = COLOR(c_32c7c2);
            self.sendButton.layer.borderColor = COLOR(c_32c7c2).CGColor;
            [self.sendButton setTitleColor:COLOR(c_ffffff) forState:UIControlStateNormal];
        }
        else {
            self.sendButton.backgroundColor = COLOR(c_f5f5f5);
            self.sendButton.layer.borderColor=[UIColor colorWithHexString:@"d9d9d9"].CGColor;
            [_sendButton setTitleColor:[UIColor colorWithHexString:@"#d4d4d4"]  forState:UIControlStateNormal];
        }
    }];
    #pragma mark 取消
    
    self.cancelButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self);
        
        NSString *text = self.sendCaseHeaderView.contentTextView.text;
        // 正文内容超出字数限制
        if (text.length > self.contentmaxlength) {
            self.sendCaseData.addPostContent = [text substringToIndex:self.contentmaxlength];
        }
        else {
            self.sendCaseData.addPostContent = text;
        }
        
        // 广场发帖
        if (self.sendCaseType == CMTSendCaseTypeAddPost) {
            [CMTAPPCONFIG saveAddPostData];
        }
        // 小组发帖
        else if (self.sendCaseType == CMTSendCaseTypeAddGroupPost) {
            [CMTAPPCONFIG saveAddGroupPostData];
        }
        // 帖子追加
        else if (self.sendCaseType == CMTSendCaseTypeAddPostDescribe ||
                 self.sendCaseType == CMTSendCaseTypeAddPostConclusion) {
            [CMTAPPCONFIG saveAddPostAdditionalData];
        }else if (self.mylive!=nil){
            [CMTAPPCONFIG saveaddLivemessageData];
        }
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
        return [RACSignal empty];
    }];
    
#pragma mark 发布
    
    self.sendButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self);
        CMTLog(@"sendCaseData: %@", self.sendCaseData);
        
        NSString *text = self.sendCaseHeaderView.contentTextView.text;
        // 正文内容超出字数限制
        if (text.length > self.contentmaxlength) {
            self.sendCaseData.addPostContent = [text substringToIndex:self.contentmaxlength];
        }
        else {
            self.sendCaseData.addPostContent = text;
        }
        NSString *str=[text stringByReplacingOccurrencesOfString:@" " withString:@""];
        str=[str stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        if (str.length==0&&self.sendCaseData.addPostContent.length!=0) {
            [self toastAnimation:@"正文内容不能只输入空格或者回车字符"];
            return [RACSignal empty];
        }
        if (!CMTAPPCONFIG.reachability.boolValue) {
            [self toastAnimation:@"你的网络不给力"];
        }else {
            // 广场发帖
            if (self.sendCaseType == CMTSendCaseTypeAddPost) {
                [CMTAPPCONFIG addPostWithCompleteBlock:self.updateCaseList];
            }
            // 小组发帖
            else if (self.sendCaseType == CMTSendCaseTypeAddGroupPost) {
                [CMTAPPCONFIG addGroupPostWithCompleteBlock:self.updateCaseList];
            }
            // 帖子追加
            else if (self.sendCaseType == CMTSendCaseTypeAddPostDescribe ||
                     self.sendCaseType == CMTSendCaseTypeAddPostConclusion) {
                [CMTAPPCONFIG addPostAdditionalWithCompleteBlock:self.updateCaseList];
            }else if(self.mylive!=nil){
                [CMTAPPCONFIG addLivemessageDataWithCompleteBlock:self.updateCaseList];

            }
            
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        
        return [RACSignal empty];
    }];

#pragma mark 标题内容
    
    [self.sendCaseHeaderView.titleTextSignal subscribeNext:^(NSString *text) {
        @strongify(self);
        self.sendCaseData.title = text;
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - SetCaseSubject

- (void)refreshSubjectName {
    
    [self.tableView reloadData];
}

#pragma mark - SetCaseDiseaseTag

- (void)setCaseTagData {
    UIButton *tagButton=[self.CmttoolBar viewWithTag:1002];
    if (self.sendCaseData.diseaseTagArray.count==0) {
        [tagButton setImage:IMAGE(@"tag") forState:UIControlStateNormal];
        
    }else{
        [tagButton setImage:IMAGE(@"hastag") forState:UIControlStateNormal];
        
    }

    
    [self.tableView reloadData];
}

#pragma mark - SendCaseHeaderView

- (void)presentMediaPicker:(UIViewController *)mediaPicker animated:(BOOL)animated {
    if ([mediaPicker isKindOfClass:[UIViewController class]]) {
        [self presentViewController:mediaPicker animated:animated completion:nil];
    }
}

static size_t getAssetBytesCallback(void *info, void *buffer, off_t position, size_t count) {
    ALAssetRepresentation *rep = (__bridge id)info;
    
    NSError *error = nil;
    size_t countRead = [rep getBytes:(uint8_t *)buffer fromOffset:position length:count error:&error];
    
    if (countRead == 0 && error) {
        // We have no way of passing this info back to the caller, so we log it, at least.
        CMTLogError(@"thumbnailForAsset:maxPixelSize: got an error reading an asset: %@", error);
    }
    
    return countRead;
}
static void releaseAssetCallback(void *info) {
    // The info here is an ALAssetRepresentation which we CFRetain in thumbnailForAsset:maxPixelSize:.
    // This release balances that retain.
    CFRelease(info);
}

//压缩图片
- (UIImage *)thumbnailForAsset:(ALAsset *)asset maxPixelSize:(NSUInteger)size
{
    NSParameterAssert(asset != nil);
    NSParameterAssert(size > 0);
    
    ALAssetRepresentation *rep = [asset defaultRepresentation];
    
    CGDataProviderDirectCallbacks callbacks = {
        .version = 0,
        .getBytePointer = NULL,
        .releaseBytePointer = NULL,
        .getBytesAtPosition = getAssetBytesCallback,
        .releaseInfo = releaseAssetCallback,
    };
    
    CGDataProviderRef provider = CGDataProviderCreateDirect((void *)CFBridgingRetain(rep), [rep size], &callbacks);
    
    CGImageSourceRef source = CGImageSourceCreateWithDataProvider(provider, NULL);
    
    CGImageRef imageRef = CGImageSourceCreateThumbnailAtIndex(source,
                                                              0,
                                                              (__bridge CFDictionaryRef)@{
                                                                                          (NSString *)kCGImageSourceCreateThumbnailFromImageAlways: @YES,
                                                                                          (NSString *)kCGImageSourceThumbnailMaxPixelSize : [NSNumber numberWithUnsignedInteger:size],
                                                                                          (NSString *)kCGImageSourceCreateThumbnailWithTransform :@YES,
                                                                                          });
    CFRelease(source);
    CFRelease(provider);
    
    if (!imageRef) {
        return nil;
    }
    
    UIImage *toReturn = [UIImage imageWithCGImage:imageRef];
    
    CFRelease(imageRef);
    
    return toReturn;
}

- (void)mediaPickerDidFinishPickingAssets:(NSArray *)assets {
    NSMutableArray *pictureFilePaths = [NSMutableArray array];
    for (ALAsset *asset in assets) {
        NSURL *assetRepresentationURL = asset.defaultRepresentation.url;
        CGSize dimensions = [asset defaultRepresentation].dimensions;
        CMTLog(@"dimensions:%@", NSStringFromCGSize(dimensions));
        CGFloat maxPixel = dimensions.width > dimensions.height ? dimensions.width : dimensions.height;
        [[SDWebImageManager sharedManager] saveImageToCache:[self thumbnailForAsset:asset maxPixelSize:maxPixel*0.5]
                                                     forURL:assetRepresentationURL];
        NSString *pictureFilePath = [[SDWebImageManager sharedManager].imageCache defaultCachePathForKey:
                                     [[SDWebImageManager sharedManager] cacheKeyForURL:assetRepresentationURL]];
        
        [pictureFilePaths addObject:[[CMTPicture alloc] initWithDictionary:@{
                                                                             @"pictureFilePath": pictureFilePath ?: @"",
                                                                             @"assetRepresentationURL": assetRepresentationURL.absoluteString ?: @"",
                                                                             } error:nil]];

    }
    
    self.sendCaseData.pictureFilePaths = [NSArray arrayWithArray:pictureFilePaths];
}

- (void)dismissMediaPickerAnimated:(BOOL)animated completion:(void (^)(void))completion; {
    [self dismissViewControllerAnimated:animated completion:completion];
}

- (void)refreshSendCaseHeaderView {
    self.tableView.tableHeaderView = self.sendCaseHeaderView;
}

#pragma mark - ScrollView

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

#pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.sendCaseType == CMTSendCaseTypeAddPost) {
        return 3;
    }
    else if (self.sendCaseType == CMTSendCaseTypeAddGroupPost) {
        return 3;
    }
    
    return 0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(self.sendCaseType==CMTSendCaseTypeAddGroupPost){
        return 0;
    }
        
    return 1;
}
-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view=[[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 1)];
    view.backgroundColor=COLOR(c_efeff4);
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row==0){
        if (self.sendCaseData.diseaseTagArray.count>0) {
            return 25;

        }else{
             return 0;
        }

    }else if(indexPath.row==1){
        if (self.sendCaseData.userinfoArray.count>0) {
            return 25;
            
        }else{
            return 0;
        }

    }
        
    return 44.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CMTSendCaseEditorCellIdentifier  forIndexPath:indexPath];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CMTSendCaseEditorCellIdentifier];
    }
    for (UIView *view in [cell.contentView subviews]) {
        [view removeFromSuperview];
    }
    if (indexPath.row==0||indexPath.row==1) {
        UIView *bottomLine = [cell viewWithTag:1000];
        if (bottomLine == nil) {
            bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0.0, cell.height - PIXEL, cell.width, PIXEL)];
            bottomLine.backgroundColor = COLOR(c_dddddd);
            [cell.contentView addSubview:bottomLine];
        }
        NSString *text = nil;
        if (indexPath.row==0) {
            NSString *diseaseTagNames = [[self.sendCaseData.diseaseTagArray componentsOfValueForKey:@"disease"] componentsJoinedByString:@","];
            text =self.sendCaseData.diseaseTagArray.count>0?[NSString stringWithFormat:@"标签: %@", diseaseTagNames ?: @""]:@"";
            bottomLine.hidden=self.sendCaseData.diseaseTagArray.count==0;

        }else{
            NSString *userNames=[[self.sendCaseData.userinfoArray componentsOfValueForKey:@"nickname"] componentsJoinedByString:@","];
            text =self.sendCaseData.userinfoArray.count>0?[NSString stringWithFormat:@"提醒谁看: %@",userNames?: @""]:@"";
               bottomLine.hidden=self.sendCaseData.userinfoArray.count==0;
        }
        UILabel *lable=[[UILabel alloc]initWithFrame:CGRectMake(10, 0, SCREEN_WIDTH-20, cell.height)];
        lable.textColor = COLOR(c_9e9e9e);
        lable.font = FONT(13);
        lable.text = text;
        [cell.contentView addSubview:lable];

    }else{
        
        cell.backgroundColor=ColorWithHexStringIndex(c_efeff4);
        //投票
        UIButton *vote=[[UIButton alloc]initWithFrame:CGRectMake(20, 2, 40, 40)];
        if(self.sendCaseData.voteArray.count==0){
            [vote setImage:IMAGE(@"caseVote") forState:UIControlStateNormal];
        }else{
             [vote setImage:IMAGE(@"hasaseVote") forState:UIControlStateNormal];
        }
        [vote addTarget:self action:@selector(setVoteAction) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:vote];
        
      
        //标签
        UIButton *tagButton=[[UIButton alloc]initWithFrame:CGRectMake(vote.right+20, 2, 40, 40)];
        if (self.sendCaseData.diseaseTagArray.count==0) {
            [tagButton setImage:IMAGE(@"tag") forState:UIControlStateNormal];
            
        }else{
            [tagButton setImage:IMAGE(@"hastag") forState:UIControlStateNormal];
            
        }
        [cell.contentView addSubview:tagButton];
        [tagButton addTarget:self action:@selector(setTag) forControlEvents:UIControlEventTouchUpInside];
        
        //提醒人
        UIButton *remind=[[UIButton alloc]initWithFrame:CGRectMake(tagButton.right+20, 2, 40, 40)];
        if (self.sendCaseData.userinfoArray.count==0) {
            [remind setImage:IMAGE(@"remindPepople") forState:UIControlStateNormal];
        }else{
            [remind setImage:IMAGE(@"hasRemindpeolpe") forState:UIControlStateNormal];
        }
        
        [cell.contentView addSubview:remind];
        [remind addTarget:self action:@selector(CMTremind) forControlEvents:UIControlEventTouchUpInside];
        
        self.numberlable.frame=CGRectMake(tagButton.right+10, 6, SCREEN_WIDTH-tagButton.right-20, 30);
        [cell.contentView addSubview:self.numberlable];
    }
    return cell;
}
/**
 *  设置还能输入多少字
 *
 *  @param text <#text description#>
 */
-(void)setNumberlableText:(NSString *)text{
    self.numberlable.text=text;
}
/**
 *  设置投票
 */
-(void)setVoteAction{
    CmtVoteViewController *vote=[[CmtVoteViewController alloc]init];
    @weakify(self);
    vote.updatedata=^(){
        @strongify(self);
    if(self.sendCaseData.voteArray.count==0){
        [((UIButton*)[self.CmttoolBar viewWithTag:1000]) setImage:IMAGE(@"caseVote") forState:UIControlStateNormal];
    }else{
        [((UIButton*)[self.CmttoolBar viewWithTag:1000]) setImage:IMAGE(@"hasaseVote") forState:UIControlStateNormal];
    }
    

        [self.tableView reloadData];
    };
    CMTNavigationController *nav=[[CMTNavigationController alloc]initWithRootViewController:vote];
    
    [self presentViewController:nav animated:YES completion:nil];
}
/**
 *  选择标签
 */
-(void)setTag{
    NSString *subjectId = nil;
    subjectId = self.groupSubjectId;
    
    CMTSetCaseTagViewController *setCaseTagViewController = [[CMTSetCaseTagViewController alloc] initWithSubject:subjectId
                                                                                                          module:self.sendCaseType];
    setCaseTagViewController.deleagte = self;
    CMTNavigationController *nav=[[CMTNavigationController alloc]initWithRootViewController:setCaseTagViewController];
    
    [self presentViewController:nav animated:YES completion:nil];
}
/**
 *  设置提醒用户
 */
-(void)CMTremind{
    CMTSetRemindPeopleViewController *groupMember=[[CMTSetRemindPeopleViewController alloc]initWithGroupID:self.sendCaseData.groupId];
    @weakify(self);
    groupMember.updatedata=^(){
        @strongify(self);
        UIButton *remind=[self.CmttoolBar viewWithTag:1001];
        if (self.sendCaseData.userinfoArray.count==0) {
            [remind setImage:IMAGE(@"remindPepople") forState:UIControlStateNormal];
        }else{
            [remind setImage:IMAGE(@"hasRemindpeolpe") forState:UIControlStateNormal];
        }

        [self.tableView reloadData];
    };
    CMTNavigationController *navcation=[[CMTNavigationController alloc]initWithRootViewController:groupMember];
    
    
    [self presentMediaPicker:navcation animated:YES];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        return;
    }
    
    UIViewController *viewController = nil;
    
    // 设置学科
    if (self.sendCaseType == CMTSendCaseTypeAddPost && indexPath.row == 1) {
        
        CMTCaseSendSubjectViewController *caseSendSubjectViewController = [[CMTCaseSendSubjectViewController alloc] initWithModule:self.sendCaseType];
        caseSendSubjectViewController.delegate = self;
        viewController = caseSendSubjectViewController;
    }
    // 设置标签
    else {
        NSString *subjectId = nil;
        if (self.sendCaseType == CMTSendCaseTypeAddPost) {
            subjectId = CMTAPPCONFIG.addPostSubject.subjectId;
        }
        else {
            subjectId = self.groupSubjectId;
        }
        
        CMTSetCaseTagViewController *setCaseTagViewController = [[CMTSetCaseTagViewController alloc] initWithSubject:subjectId
                                                                                                              module:self.sendCaseType];
        setCaseTagViewController.deleagte = self;
        viewController = setCaseTagViewController;
    }
    
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
