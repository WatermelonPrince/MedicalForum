//
//  CMTDigitalNewspaperViewController.m
//  MedicalForum
//
//  Created by guoyuanchao on 15/12/22.
//  Copyright © 2015年 CMT. All rights reserved.
//

#import "CMTDigitalNewspaperViewController.h"
#import "CMTDigitalWebViewController.h"
#import "CMTReadCodeBlindViewController.h"
@interface CMTDigitalNewspaperViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
@property(nonatomic,strong)UICollectionView *SubjectCollectionView;
@property(nonatomic,strong)NSMutableArray*dataArray;
@property (nonatomic, strong) UIImageView *titleView;                           // 标题
@end

@implementation CMTDigitalNewspaperViewController
- (UIImageView *)titleView {
    if (_titleView  == nil) {
        _titleView = [[UIImageView alloc] initWithImage:IMAGE(@"digitalNews")];
        _titleView.hidden = YES;
    }
    
    return _titleView;
}

-(NSMutableArray*)dataArray{
    if (_dataArray==nil) {
        _dataArray=[[NSMutableArray alloc]init];
    }
    return _dataArray;
}
-(UICollectionView*)SubjectCollectionView{
    if (_SubjectCollectionView==nil) {
        UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
        flowLayout.sectionInset = UIEdgeInsetsMake(20 * SCREEN_WIDTH / 414, 20 * SCREEN_WIDTH / 414, 20 *SCREEN_WIDTH / 414, 20 * SCREEN_WIDTH / 414);
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        
        _SubjectCollectionView=[[UICollectionView alloc]initWithFrame:CGRectMake(0, CMTNavigationBarBottomGuide, SCREEN_WIDTH, SCREEN_HEIGHT - CMTNavigationBarBottomGuide) collectionViewLayout:flowLayout];
        _SubjectCollectionView.backgroundColor=COLOR(c_ffffff);
        _SubjectCollectionView.dataSource=self;
        _SubjectCollectionView.delegate=self;
        [_SubjectCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"CollectionView"];
    }
    return _SubjectCollectionView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setContentState:CMTContentStateLoading];
    self.navigationItem.titleView = self.titleView;
    self.titleText = @"中国医学论坛报";
    [self.contentBaseView addSubview:self.SubjectCollectionView];
    //加载数据
    [self loaddata];
    
}
/**
 *加载数据
 */
-(void)loaddata{
    @weakify(self);
    NSDictionary *param=@{@"onlyDecryptKey":@"0",
                          @"userId":CMTUSERINFO.userId?:@"0",
                          };
    [[[CMTCLIENT GetDigitalSubject:param]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(CMTDigitalObject *Digital) {
        @strongify(self);
        if (Digital.subjectList.count>0) {
            self.dataArray=[Digital.subjectList mutableCopy];
            CMTAPPCONFIG.epaperStoreUrl = Digital.epaperStoreUrl;
            CMTUSERINFO.decryptKey=Digital.decryptKey;
            CMTUSERINFO.canRead=Digital.canRead;
            [self.SubjectCollectionView reloadData];
            [self setContentState:CMTContentStateNormal];
        }else{
            [self toastAnimation:@"暂无学科"];
        }
        
    } error:^(NSError *error) {
          @strongify(self);
        NSString *errorCode = error.userInfo[CMTClientServerErrorCodeKey];
        if ([errorCode integerValue] > 100) {
            CMTLog(@"errMes:%@",error.userInfo[CMTClientServerErrorUserInfoMessageKey]);
            
            [self toastAnimation:error.userInfo[CMTClientServerErrorUserInfoMessageKey]];
            
        } else {
            [self toastAnimation:@"你的网络不给力"];
            CMTLogError(@"Request verification code System Error: %@", error);
        }
        [self setContentState:CMTContentStateReload];

    } completed:^{
        CMTLog(@"加载完成");
    }];
}
-(void)animationFlash{
    [super animationFlash];
    [self loaddata];
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataArray.count;
}
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(530/3 * SCREEN_WIDTH/414, 600/3 * SCREEN_WIDTH/414 );
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 40/3 * SCREEN_WIDTH / 414;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 60/3 * SCREEN_WIDTH / 414;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * CellIdentifier = @"CollectionView";
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    CMTSubject *subject=[self.dataArray objectAtIndex:indexPath.row];
    NSLog(@"fuudfhefhuh%@%@",subject.subjectId,subject.subject);
    UIImageView *imageView=nil;
    if ([cell.contentView viewWithTag:1000]==nil) {
        NSString *imageString=[@"subjectImage-" stringByAppendingFormat:@"%@",subject.subjectId];
        imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 530/3 * SCREEN_WIDTH / 414, 600/3 * SCREEN_WIDTH / 414)];
        [imageView setImageURL:subject.headPic
              placeholderImage:IMAGE(imageString) contentSize:CGSizeMake(imageView.frame.size.width, imageView.frame.size.height)];
        UILabel *issueLabel = [[UILabel alloc]initWithFrame:CGRectMake(imageView.left, imageView.bottom - 25, imageView.width, 25)];
        issueLabel.backgroundColor = [UIColor clearColor];
        issueLabel.textAlignment = NSTextAlignmentCenter;
        if (subject.issueNo.integerValue == 0) {
            issueLabel.hidden = YES;
        }else{
            issueLabel.text = [NSString stringWithFormat:@"%@",subject.issueNo];

        }
        issueLabel.font = FONT(12);
        issueLabel.textColor = [UIColor whiteColor];
        [imageView addSubview:issueLabel];
        imageView.tag=1000;
        [cell.contentView addSubview:imageView];
        cell.clipsToBounds=YES;
        cell.contentMode=UIViewContentModeScaleAspectFill;
    }else{
        NSString *imageString=[@"subjectImage-" stringByAppendingFormat:@"%@",subject.subjectId];
        [imageView setImageURL:subject.headPic
              placeholderImage:IMAGE(imageString) contentSize:CGSizeMake(imageView.frame.size.width, imageView.frame.size.height)];

    }
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
        CMTSubject *sub=[self.dataArray objectAtIndex:indexPath.row];
          //添加点击事件
        [self addStatistical:sub];
        CMTDigitalWebViewController *web=[[CMTDigitalWebViewController alloc]initWithURl:sub.url model:@"0"];
        [self.navigationController pushViewController:web animated:YES];

}
//添加点击监听
-(void)addStatistical:(CMTSubject*)sub{
    
    if ([sub.subjectId isEqualToString:@"1"])
    {
        //肿瘤
        [MobClick event:@"B_Tumour_Paper"];
    }
    else if ([sub.subjectId isEqualToString:@"2"])
    {
        //综合
        [MobClick event:@"B_Zonghe_Paper"];
    }
    else if ([sub.subjectId isEqualToString:@"3"])
    {
        //循环
        [MobClick event:@"B_Xunhuan_Paper"];
    }
    else if ([sub.subjectId isEqualToString:@"4"])
    {
        //消化
        [MobClick event:@"B_Digestion_Paper"];
    }
    else if ([sub.subjectId isEqualToString:@"5"])
    {
        //全科
        [MobClick event:@"B_General_Paper"];
    }
    else if ([sub.subjectId isEqualToString:@"6"])
    {
        //JAMA
        [MobClick event:@"B_JAMA_Paper"];
    }
   
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   
}


@end
