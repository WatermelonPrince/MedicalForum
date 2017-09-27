//
//  CMTSeresLabelsView.m
//  MedicalForum
//
//  Created by guoyuanchao on 16/7/25.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import "CMTSeresLabelsView.h"
#import "CMTGetStringWith_Height.h"
static float fontsize=14.0;
@interface CMTSeresLabelsView()
@property(nonatomic,strong)NSMutableArray *layouttagArray;//用来标记一行的标签在数组中的坐标;
/**标签高度*/
@property(nonatomic, assign) float tagheight;
/**左右标签间隔*/
@property(nonatomic, assign) float spacing;
/**上下标签间隔*/
@property(nonatomic, assign) float heightSpace;
/**在字体宽度基础上增加部分宽度。*/
@property(nonatomic, assign) float taglableWithadd;
@end
@implementation CMTSeresLabelsView
//创建标签
-(void)CreatSeresLable{
    self.tagheight = 30;
    self.spacing = 10*XXXRATIO;
    self.heightSpace = 10;
    self.taglableWithadd =10*XXXRATIO;
    [self setBackgroundColor:ColorWithHexStringIndex(c_ffffff)];
    self.layouttagArray=[NSMutableArray new];
    for(UIView *view in [self subviews]){
        [view removeFromSuperview];
    }
    [self getLayoutArray];
    [self CMTDrawButton];

}
//获取换行分组
-(void)getLayoutArray{
    float with=0;
    NSString *indexStr=@"";
    for (int i=0;i<[self.navigationArray count];i++) {
        CMTSeriesNavigation *Navigation=[self.navigationArray objectAtIndex:i];
        NSString *titleString=Navigation.navigationName;
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
            CMTSeriesNavigation *navigation=[self.navigationArray objectAtIndex:[[array objectAtIndex:number]integerValue]];
            float tagWith=[CMTGetStringWith_Height CMTGetLableTitleWith:navigation.navigationName fontSize:fontsize];
            UIButton *tagbutton=[[UIButton alloc]initWithFrame:CGRectMake(Viewwith,viewheight,tagWith+self.taglableWithadd,self.tagheight)];
            tagbutton.titleLabel.font=[UIFont systemFontOfSize:fontsize];
            [tagbutton setTitle:navigation.navigationName forState:UIControlStateNormal];
            [tagbutton setTitleColor:[UIColor colorWithHexString:@"#17bea1"] forState:UIControlStateNormal];
            [tagbutton setBackgroundColor:[UIColor colorWithHexString:@"#e8fff8"]];
            tagbutton.layer.borderWidth=1;
            tagbutton.layer.cornerRadius=5;
            tagbutton.tag=[[array objectAtIndex:number]integerValue];
            tagbutton.layer.borderColor=[UIColor colorWithHexString:@"#00bb9c"].CGColor;
            [self addSubview:tagbutton];
            [tagbutton addTarget:self action:@selector(TabuttonAction:) forControlEvents:UIControlEventTouchUpInside];
            Viewwith=Viewwith+self.spacing+tagWith+self.taglableWithadd;
        }
        viewheight=viewheight+self.tagheight+self.heightSpace;
    }
        self.frame=CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, viewheight);
}
-(void)TabuttonAction:(UIButton*)action{
    if(self.SeresLabelAction!=nil){
        self.SeresLabelAction(action.tag);
    }
  }


@end
