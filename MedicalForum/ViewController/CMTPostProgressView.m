//
//  CMTPostProgressView.m
//  MedicalForum
//
//  Created by guoyuanchao on 15/8/3.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTPostProgressView.h"
@interface CMTPostProgressView()<UIAlertViewDelegate>
@property(nonatomic,strong)UIProgressView *progress;
@property(nonatomic,strong)UIView *startView;
@property(nonatomic,strong)UIView *endView;
@property(nonatomic,strong)UIImageView *postimage;
@property(nonatomic,weak) NSTimer *time;
@property(nonatomic,assign)float suspended;
//0 详情 1 病例首页 2 小组详情
@property(nonatomic,assign)CMTSendCaseType module;
@end
@implementation CMTPostProgressView
-(UIView*)startView{
    if (_startView==nil) {
        _startView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.width, self.height)];
        _startView.backgroundColor=COLOR(c_ffffff);
        _startView.layer.borderWidth=1;
         _startView.layer.borderColor=(__bridge CGColorRef)([UIColor colorWithHexString:@"#EEEEF4"]);
        self.postimage=[[UIImageView alloc]initWithFrame:CGRectMake(10, 5, 20, 20)];
        self.postimage.contentMode=UIViewContentModeScaleAspectFill;
        self.postimage.clipsToBounds=YES;
        if (self.module==CMTSendCaseTypeAddPost) {
            CMTLog(@"jfhehfuehfuefhueh%@",CMTAPPCONFIG.addPostData.pictureFilePaths);
            CMTPicture *picture =[CMTAPPCONFIG.addPostData.pictureFilePaths count]>0?[CMTAPPCONFIG.addPostData.pictureFilePaths objectAtIndex:0]:nil;
            UIImage *image=[UIImage imageWithContentsOfFile:picture.pictureFilePath ];
            self.postimage.image=[self changeimageSize:image];
        }else if((self.module==CMTSendCaseTypeAddPostDescribe)||(self.module==CMTSendCaseTypeAddPostConclusion)){
            CMTPicture *picture =[CMTAPPCONFIG.addPostAdditionalData.pictureFilePaths count]>0? [CMTAPPCONFIG.addPostAdditionalData.pictureFilePaths objectAtIndex:0]:nil;
            UIImage *image=[UIImage imageWithContentsOfFile:picture.pictureFilePath ];
            if(picture==nil){
                [self.postimage setImageURL:nil placeholderImage:[UIImage imageNamed:@"notiices_post_image"] contentSize:CGSizeMake(20, 20)];
            }else{
               self.postimage.image=[self changeimageSize:image];
            }

        }else if(self.module==CMTSendCaseTypeAddGroupPost){
            CMTPicture *picture =[CMTAPPCONFIG.addGroupPostData.pictureFilePaths count]>0? [CMTAPPCONFIG.addGroupPostData.pictureFilePaths objectAtIndex:0]:nil;
            UIImage *image=[UIImage imageWithContentsOfFile:picture.pictureFilePath ];
            if(picture==nil){
                  [self.postimage setImageURL:nil placeholderImage:[UIImage imageNamed:@"notiices_post_image"] contentSize:CGSizeMake(20, 20)];
            }else{
                self.postimage.image=[self changeimageSize:image];
            }


        }else if (self.module==CmtSendLiveTypeAddpost){
            CMTPicture *picture =[CMTAPPCONFIG.addLivemessageData.pictureFilePaths count]>0?[CMTAPPCONFIG.addLivemessageData.pictureFilePaths objectAtIndex:0]:nil;
            UIImage *image=[UIImage imageWithContentsOfFile:picture.pictureFilePath ];
            if(picture==nil){
                [self.postimage setImageURL:nil placeholderImage:[UIImage imageNamed:@"notiices_post_image"] contentSize:CGSizeMake(20, 20)];            }else{
                self.postimage.image=[self changeimageSize:image];
            }

        }

        self.progress=[[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleBar ];
         self.progress.frame=CGRectMake(self.postimage.right+10, 15, SCREEN_WIDTH-self.postimage.right-40, 20);
        self.progress.transform = CGAffineTransformMakeScale(1.0f,2.0f);
        self.progress.layer.borderColor=(__bridge CGColorRef)([UIColor colorWithHexString:@"F4F4F4"]);
        self.progress.layer.borderWidth=0.25;
        self.progress.trackTintColor=COLOR(c_ffffff);
        self.progress.progressTintColor=COLOR(c_25C25B);
        self.progress.progressViewStyle=UIProgressViewStyleDefault;
        [_startView addSubview:self.postimage];
        [_startView addSubview:self.progress];
       
    }
    return _startView;
}
-(UIView*)endView{
    if (_endView==nil) {
        _endView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.width, self.height)];
         _endView.backgroundColor=COLOR(c_ffffff);
        _endView.hidden=NO;
        _endView.layer.borderWidth=1;
        _endView.layer.borderColor=(__bridge CGColorRef)([UIColor colorWithHexString:@"#EEEEF4"]);
        self.postimage=[[UIImageView alloc]initWithFrame:CGRectMake(10, 5, 20, 20)];
         self.postimage.clipsToBounds=YES;
        self.postimage.contentMode=UIViewContentModeScaleAspectFill;
        if (self.module==CMTSendCaseTypeAddPost) {
            CMTPicture *picture = [CMTAPPCONFIG.addPostData.pictureFilePaths count]>0?[CMTAPPCONFIG.addPostData.pictureFilePaths objectAtIndex:0]:nil;
            UIImage *image=[UIImage imageWithContentsOfFile:picture.pictureFilePath ];
            if(picture==nil){
                [self.postimage setImageURL:nil placeholderImage:[UIImage imageNamed:@"notiices_post_image"] contentSize:CGSizeMake(20, 20)];            }else{
                    self.postimage.image=[self changeimageSize:image];
                }

        }else if((self.module==CMTSendCaseTypeAddPostDescribe)||(self.module==CMTSendCaseTypeAddPostConclusion)){
            CMTPicture *picture = [CMTAPPCONFIG.addPostAdditionalData.pictureFilePaths count]>0?[CMTAPPCONFIG.addPostAdditionalData.pictureFilePaths objectAtIndex:0]:nil;
            UIImage *image=[UIImage imageWithContentsOfFile:picture.pictureFilePath ];
            if(image==nil){
                [self.postimage setImageURL:nil placeholderImage:[UIImage imageNamed:@"notiices_post_image"] contentSize:CGSizeMake(20, 20)];            }else{
                    self.postimage.image=[self changeimageSize:image];
                }


        }else if(self.module==CMTSendCaseTypeAddGroupPost){
            CMTPicture *picture = [CMTAPPCONFIG.addGroupPostData.pictureFilePaths count]>0?[CMTAPPCONFIG.addGroupPostData.pictureFilePaths objectAtIndex:0]:nil;
            UIImage *image=[UIImage imageWithContentsOfFile:picture.pictureFilePath ];
            if(image==nil){
                [self.postimage setImageURL:nil placeholderImage:[UIImage imageNamed:@"notiices_post_image"] contentSize:CGSizeMake(20, 20)];            }else{
                    self.postimage.image=[self changeimageSize:image];
                }

        }else if (self.module==CmtSendLiveTypeAddpost){
            CMTPicture *picture =[CMTAPPCONFIG.addLivemessageData.pictureFilePaths count]>0? [CMTAPPCONFIG.addLivemessageData.pictureFilePaths objectAtIndex:0]:nil;
            UIImage *image=[UIImage imageWithContentsOfFile:picture.pictureFilePath ];
            if(image==nil){
                [self.postimage setImageURL:nil placeholderImage:[UIImage imageNamed:@"notiices_post_image"] contentSize:CGSizeMake(20, 20)];            }else{
                    self.postimage.image=[self changeimageSize:image];
                }

        }


       
        [_endView addSubview:self.postimage];
        UILabel *lable=[[UILabel alloc]initWithFrame:CGRectMake(self.postimage.right+20,0,self.width-self.postimage.right-20-88,30)];
        lable.text=@"发送失败";
        lable.font=FONT(15);
        [_endView addSubview:lable];
        
        UIButton *button=[[UIButton alloc]initWithFrame:CGRectMake(self.width-78, 5, 20, 20)];
        [button setBackgroundImage:IMAGE(@"resend") forState:UIControlStateNormal];
        [button addTarget:self action:@selector(reSend) forControlEvents:UIControlEventTouchUpInside];
        [self.endView addSubview:button];
        
        UIButton *button2=[[UIButton alloc]initWithFrame:CGRectMake(self.width-34, 5, 20, 20)];
        [button2 setBackgroundImage:IMAGE(@"deletePosting") forState:UIControlStateNormal];
        [button2 addTarget:self action:@selector(deleteAction) forControlEvents:UIControlEventTouchUpInside];
        [self.endView addSubview:button2];

        
    }
    return _endView;
}

-(instancetype)initWithFrame:(CGRect)frame module:(CMTSendCaseType)module{
    self=[super initWithFrame:frame];
    if (self) {
        self.module=module;
        self.layer.borderWidth=1;
        self.layer.cornerRadius=5;
        self.layer.borderColor=(__bridge CGColorRef)([UIColor colorWithHexString:@"#EEEEF4"]);
        [self addSubview:self.startView];
        [self addSubview:self.endView];
        
    }
    return self;
}
//开始发送
-(void)start{
    self.progress.progress=0;
    self.startView.hidden=NO;
    self.endView.hidden=YES;

    self.suspended=(float)([self getRandomNumber:40 to:90]*0.01);
    if(self.time==nil){
       self.time=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(setProgress) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.time forMode:NSRunLoopCommonModes];
    }else{
        [self.time setFireDate:[NSDate dateWithTimeIntervalSinceNow:5.0]];
    }
    
}
//重发
-(void)reSend{
    @weakify(self);
    if (self.module==CMTSendCaseTypeAddPost) {
        [CMTAPPCONFIG addPostWithCompleteBlock:^(CMTAddPost *newCase) {
            @strongify(self);
            CMTLog(@"newCase.postBrief: %@", newCase.postBrief);
            CMTLog(@"newCase.score: %@", newCase.score);
               dispatch_async(dispatch_get_main_queue(), ^{
                   if (self.delegate!=nil&&[self.delegate respondsToSelector:@selector(reloadCaselistData:)]) {
                [self.delegate reloadCaselistData:newCase];
             }
          });
        }];

    }else if((self.module==CMTSendCaseTypeAddPostDescribe)||(self.module==CMTSendCaseTypeAddPostConclusion)){
        [CMTAPPCONFIG addPostAdditionalWithCompleteBlock:^(CMTAddPost *newCase) {
            @strongify(self);
            CMTLog(@"newCase.content: %@", newCase.content);
            CMTLog(@"newCase.picList: %@", newCase.picList);
            CMTLog(@"newCase.score: %@", newCase.score);
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.delegate!=nil&&[self.delegate respondsToSelector:@selector(reloadCaselistData:)]) {
                    [self.delegate reloadCaselistData:newCase];
                }
            });
        }];
    }else if(self.module==CMTSendCaseTypeAddGroupPost){
        [CMTAPPCONFIG addGroupPostWithCompleteBlock:^(CMTAddPost *newCase) {
            @strongify(self);
            CMTLog(@"newCase.postBrief: %@", newCase.postBrief);
            CMTLog(@"newCase.score: %@", newCase.score);
            if (self.delegate!=nil&&[self.delegate respondsToSelector:@selector(reloadCaselistData:)]) {
                [self.delegate reloadCaselistData:newCase];
            }

        }];
    }else if(self.module==CmtSendLiveTypeAddpost){
        [CMTAPPCONFIG addLivemessageDataWithCompleteBlock:^(CMTAddPost *newCase){
            if (self.delegate!=nil&&[self.delegate respondsToSelector:@selector(reloadCaselistData:)]) {
                [self.delegate reloadCaselistData:newCase];
            }

        }];
    }
        
}
//发送失败
-(void)SendFailure{
    [self.time setFireDate:[NSDate distantFuture]];
    self.startView.hidden=YES;
    self.endView.hidden=NO;
}
//发送成功
-(void)SendSuccess{
    [self.progress setProgress:1.0 animated:YES];
    [[RACScheduler mainThreadScheduler] afterDelay:1 schedule:^{
         [self deletePostSend];
    }];
   
}
//删除动作
-(void)deleteAction{
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"确定删除吗？" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert show];
}
#pragma alert 代理
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        [self deletePostSend];
    }
}

//删除文章发送
-(void)deletePostSend{
    [self.time setFireDate:[NSDate distantFuture]];
    if (self.module==CMTSendCaseTypeAddPost) {
        [CMTAPPCONFIG clearAddPostData];
        
    }else if((self.module==CMTSendCaseTypeAddPostDescribe)||(self.module==CMTSendCaseTypeAddPostConclusion)){
        [CMTAPPCONFIG clearAddPostAdditionalData];
    }else if(self.module==CMTSendCaseTypeAddGroupPost){
        [CMTAPPCONFIG clearAddGroupPostData];
        
    }else if(self.module==CmtSendLiveTypeAddpost){
        [CMTAPPCONFIG clearaddLivemessageData];
    }


    [self removeFromSuperview];
    if (self.delegate!=nil&&[self.delegate respondsToSelector:@selector(DeletePosting)]) {
        [self.delegate DeletePosting];
    }
}
//设置进度
-(void)setProgress{
    if (self.progress.progress<=self.suspended) {
        [self.progress setProgress:self.progress.progress+0.05 animated:YES];
    }
    
}
//获取随机数
-(int)getRandomNumber:(int)from to:(int)to

{
    
    return (int)(from + (arc4random() % (to -from + 1)));
    
}
//修改图片大小并将图片裁剪成方形
-(UIImage*)changeimageSize:(UIImage*)image{
    CGRect rect1 = CGRectMake(0, 0, image.size.width>image.size.height?image.size.height:image.size.width, image.size.width>image.size.height?image.size.height:image.size.width);//创建矩形框
    //对图片进行截取
    UIImage * image2 = [UIImage imageWithCGImage:CGImageCreateWithImageInRect([image CGImage], rect1)];
    return image2;
}
@end
