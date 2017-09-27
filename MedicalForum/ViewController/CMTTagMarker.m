//
//  CMTLableMangeView.m
//  MedicalForum
//
//  Created by CMT on 15/6/1.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTTagMarker.h"
#import "CMTTagButton.h"
#import "CMTAddTagButton.h"
#import "CMTSubjectListViewController.h"
static float const fontsize=14;//字体大小

@interface CMTTagMarker()
@property(nonatomic,strong)NSMutableArray *tagArray;//标记已经订阅的标签
@property(nonatomic,strong)NSMutableArray *layouttagArray;//用来标记一行的标签在数组中的坐标;
/**YES是直播列表的标签，NO普通标签*/
@property(nonatomic, assign)BOOL isLive;
/**标签高度*/
@property(nonatomic, assign) float tagheight;
/**左右标签间隔*/
@property(nonatomic, assign) float spacing;
/**上下标签间隔*/
@property(nonatomic, assign) float heightSpace;
/**在字体宽度基础上增加部分宽度。*/
@property(nonatomic, assign) float taglableWithadd;

@end
@implementation CMTTagMarker
-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        self.isShowBubble=YES;
        self.isLive = NO;
        self.tagheight = 40;
        self.spacing = 20;
        self.heightSpace = 20;
        self.taglableWithadd = 30;
    }
    return self;
}
//tag标签数组
-(NSMutableArray*)tagArray{
    if (_tagArray==nil) {
        _tagArray=[[NSMutableArray alloc]init];
    }
    return _tagArray;
}
-(NSMutableArray*)layouttagArray{
    if (_layouttagArray==nil) {
        _layouttagArray=[[NSMutableArray alloc]init];
    }
    return _layouttagArray;
}
//绘制tag 视图
-(void)DrawTagMakerMangeView:(NSMutableArray*)lableArray{
    [self.layouttagArray removeAllObjects];
    self.tagArray=lableArray;
    [self getLayoutArray];
    [self CMTDrawButton];
    
}
//获取换行分组
-(void)getLayoutArray{
    float with=0;
    NSString *indexStr=@"";
    for (int i=0;i<[self.tagArray count];i++) {
        CMTDisease *dis=[self.tagArray objectAtIndex:i];
        NSString *titleString=dis.disease;
        with+=[CMTGetStringWith_Height CMTGetLableTitleWith:titleString fontSize:fontsize]+self.spacing+self.taglableWithadd;
        if (with<=self.width) {
            indexStr=[indexStr stringByAppendingFormat:@"&&%d",i];
        }else{
            if (!isEmptyString(indexStr)) {
                [self.layouttagArray addObject:indexStr];
            }

            indexStr=[@"" stringByAppendingFormat:@"&&%d",i];
            with=[CMTGetStringWith_Height CMTGetLableTitleWith:titleString fontSize:fontsize]+self.spacing+self.taglableWithadd;
            
        }
        
        
    }
    if (!isEmptyString(indexStr)) {
         [self.layouttagArray addObject:indexStr];
    }
   

}
//绘制button
-(void)CMTDrawButton{
//    标签按钮的纵坐标
    float viewheight=self.heightSpace;
    for(int b=0;b<[self.layouttagArray count];b++){
        NSArray *array=[[self.layouttagArray objectAtIndex:b]componentsSeparatedByString:@"&&"];
        float Viewwith=10;//标签横坐标
        for(int number=1;number<[array count];number++){
            CMTDisease *diease=[self.tagArray objectAtIndex:[[array objectAtIndex:number]integerValue]];
            float tagWith=[CMTGetStringWith_Height CMTGetLableTitleWith:diease.disease fontSize:fontsize];
            CMTTagButton *tagbutton=[[CMTTagButton alloc]initWithFrame:CGRectMake(Viewwith,viewheight,tagWith+self.taglableWithadd,self.tagheight)];
            tagbutton.model=self.model;
            tagbutton.fontsize=fontsize;
            [self addSubview:tagbutton];
            [tagbutton addTarget:self action:@selector(TabuttonAction:) forControlEvents:UIControlEventTouchUpInside];
            [tagbutton setTagelayout:diease];
            Viewwith=Viewwith+self.spacing+tagWith+self.taglableWithadd;
        }
        viewheight=viewheight+self.tagheight+self.spacing;
    }
    if(NO == self.isLive){
     //普通标签添加订阅标签按钮
        CMTAddTagButton *tagbutton=[[CMTAddTagButton alloc]initWithFrame:CGRectMake(10,viewheight,150,self.tagheight)];
        [self addSubview:tagbutton];
        [tagbutton addTarget:self action:@selector(addAndFouceTag) forControlEvents:UIControlEventTouchUpInside];
        [tagbutton setTitle:@"+添加订阅标签" forState:UIControlStateNormal];
        [tagbutton setTitleColor:[UIColor colorWithHexString:@"#8D8D92"] forState:UIControlStateNormal];
        tagbutton.titleLabel.font=[UIFont boldSystemFontOfSize:fontsize];
        viewheight=viewheight+self.tagheight+self.spacing;
    }
    self.frame=CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, viewheight);
}

//设置是否是直播列表的标签
//@param YES是直播列表的标签，NO普通标签
-(void)setIsLive : (BOOL) isLive{
    _isLive = isLive;
    self.tagheight = 20;
    self.spacing = 5;
    self.heightSpace = 5;
    self.taglableWithadd = 10;

}

-(void)addAndFouceTag{
    if (self.delegate!=nil&&[self.delegate respondsToSelector:@selector(CmtAddTagAction)]) {
        [self.delegate CmtAddTagAction];
    }
}
-(void)TabuttonAction:(CMTTagButton*)action{
    
    if (self.delegate!=nil) {
        [self.delegate CMTGotoGuidePostListView:action.disease];
    }
}
@end
