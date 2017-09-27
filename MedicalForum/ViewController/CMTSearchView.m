//
//  CMTSearchView.m
//  MedicalForum
//
//  Created by CMT on 15/6/5.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTSearchView.h"
#import "CMTTypeSearchViewController.h"
#import "CMTSearchViewController.h"
#import "CMTSearchMemberViewController.h"
#import "CMTGroupMembersViewController.h"

@implementation CMTSearchView
-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        self.layer.borderWidth=1;
        self.layer.cornerRadius=3;
        self.layer.borderColor=(__bridge CGColorRef)([UIColor colorWithHexString:@"#EEEEF4"]);
    }
    return self;
}
-(UIButton*)searchbutton{
    if (_searchbutton==nil) {
        _searchbutton=[UIButton buttonWithType:UIButtonTypeRoundedRect];
         _searchbutton.layer.cornerRadius=8;
       [_searchbutton addTarget:self action:@selector(search) forControlEvents:UIControlEventTouchUpInside];
    }
    return _searchbutton;
}
//绘制搜索按钮
-(void)drawSearchButton:(NSString*)titleString{
    self.searchbutton.frame=CGRectMake(0, 0, self.width, self.height);
    float lableWith=[CMTGetStringWith_Height CMTGetLableTitleWith:titleString fontSize:self.titlefontSize];
   
    UIImageView *searchImageView=[[UIImageView alloc]initWithFrame:CGRectMake((self.width-18-5-lableWith)/2, (self.height-18)/2, 18, 18)];
    searchImageView.image=[UIImage imageNamed:@"search_leftItem"];
    [self.searchbutton addSubview:searchImageView];
    self.titlelable=[[UILabel alloc]initWithFrame:CGRectMake(searchImageView.right+5,0, lableWith, self.height)];
    self.titlelable.font=[UIFont systemFontOfSize:self.titlefontSize];
    self.titlelable.textColor=COLOR(c_1515157F);
    self.titlelable.text=titleString;
    [self.searchbutton addSubview: self.titlelable];
    [self addSubview:self.searchbutton];
    
}
//搜索事件
-(void)search{
    switch (self.module.integerValue) {
        case 0:
           [MobClick event:@"B_Search_Home"];
            break;
        case 1:
           [MobClick event:@"B_Endocrine_Guideline"];
            break;
        case 2:
          [MobClick event:@"B_Search_Guideline"];
            break;
            
        default:
            break;
    }

    if ([self.module isEqualToString:@"1"]) {
        CMTSearchViewController *SearchView=[[CMTSearchViewController alloc]init];
        [self.lastController.navigationController pushViewController:SearchView animated:YES];
        return;
    }
    if ([self.module isEqualToString:@"3"]) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(pushToNextVC)]) {
            [self.delegate pushToNextVC];
        }
        return;
    }
    NSDictionary *pDic = @{@"keyword":@"",@"module":self.module};
    CMTLog(@"postType:%@,postTypeId=%@",@"",self.searchTypeID);
    CMTTypeSearchViewController *pTypeSearchVC = [[CMTTypeSearchViewController alloc]initWithNibName:nil bundle:nil];
    pTypeSearchVC.mDic = pDic;
    pTypeSearchVC.placeHold =[self getplaceHold];
    pTypeSearchVC.needRequest = NO;
    [self.lastController.navigationController pushViewController:pTypeSearchVC animated:YES];
}
-(NSString*)getplaceHold{
    NSString *st;
    switch (self.module.integerValue) {
        case 0:
            st=@"文章";
            break;
        case 1:
             st=@"病例";
            break;
        case 2:
             st=@"指南";
            break;
            
        default:
            break;
    }
    return  st;
}
@end
