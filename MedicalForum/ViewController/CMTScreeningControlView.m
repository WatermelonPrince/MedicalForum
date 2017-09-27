//
//  CMTScreeningControlView.m
//  MedicalForum
//
//  Created by guoyuanchao on 16/12/26.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import "CMTScreeningControlView.h"
static float const Assortfontsize=16;//字体大小
@interface CMTScreeningControlView()
@property(nonatomic,strong)NSMutableArray *AssortmentArray;//分类标签
@property(nonatomic,strong)NSMutableArray *layoutAssortmentArray;//用来标记一行的标签在数组中的坐标;
/**标签高度*/
@property(nonatomic, assign) float tagheight;
/**左右标签间隔*/
@property(nonatomic, assign) float spacing;
/**上下标签间隔*/
@property(nonatomic, assign) float heightSpace;
/**在字体宽度基础上增加部分宽度。*/
@property(nonatomic,strong)UILabel *titile;
@property(nonatomic,strong)UIView *assertsView;
@property(nonatomic,strong)UIView *actionView;
@property(nonatomic,strong)NSString *assortmentId;
@property(nonatomic,assign)float bigheight;
@property(nonatomic,strong)UIView *ClassTypesView;
@property(nonatomic,strong)NSString *classType;
@end
@implementation CMTScreeningControlView
-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if(self){
        self.bigheight=frame.size.height;
        self.backgroundColor=COLOR(c_f5f5f5);
        self.tagheight =90/3;
        self.spacing = 10*XXXRATIO;
        self.heightSpace =10;
        float height=[CMTGetStringWith_Height getTextheight:@"中国" fontsize:14 width:SCREEN_WIDTH];
        self.titile=[[UILabel alloc]initWithFrame:CGRectMake(10*XXXRATIO, 10,SCREEN_WIDTH,height)];
        self.titile.text=@"请选择分科";
        self.titile.textColor=[UIColor colorWithHexString:@"#151515"];
        self.titile.font=FONT(14);
        [self addSubview:self.titile];
        //绘制分类视图
        self.assertsView=[[UIView alloc]initWithFrame:CGRectMake(0, self.titile.bottom+15*XXXRATIO,self.width,0)];
        self.assertsView.tag=1001;
        [self addSubview:self.assertsView];
        
        self.ClassTypesView=[[UIView alloc]initWithFrame:CGRectMake(0,self.assertsView.bottom, self.width,0)];
        self.ClassTypesView.tag=1002;
        [self addSubview:self.ClassTypesView];
        
        
        self.actionView=[[UIView alloc]initWithFrame:CGRectMake(0, self.ClassTypesView.bottom,self.width, 45*XXXRATIO)];
        UIButton *button1=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.actionView.width/2, self.actionView.height)];
        button1.backgroundColor=COLOR(c_ffffff);
        [button1 setTitle:@"重置" forState:UIControlStateNormal];
        button1.titleLabel.font=FONT(16);
        [button1 setTitleColor:[UIColor colorWithHexString:@"#151515" ] forState:UIControlStateNormal];
        [button1 setTitleColor:[UIColor colorWithHexString:@"#151515" ] forState:UIControlStateHighlighted];
        @weakify(self);
        button1.rac_command=[[RACCommand alloc]initWithSignalBlock:^RACSignal *(id input) {
            @strongify(self);
            if(self.assortmentId.integerValue!=0||self.classType.integerValue!=0){
               self.assortmentId=@"0";
               self.classType=@"0";
               [self DrawTagMakerMangeView];
            }
            return [RACSignal empty];
        }];

        
        [self.actionView addSubview:button1];
        UIButton *button2=[[UIButton alloc]initWithFrame:CGRectMake(self.actionView.width/2, 0, self.actionView.width/2, self.actionView.height)];
        button2.backgroundColor=[UIColor colorWithHexString:@"#44c5c0"];
        [button2 setTitle:@"确定" forState:UIControlStateNormal];
        [button2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button2.titleLabel.font=FONT(16);
        [self.actionView addSubview:button2];
        button2.rac_command=[[RACCommand alloc]initWithSignalBlock:^RACSignal *(id input) {
            @strongify(self);
            if(self.updateScreening!=nil){
                self.updateScreening(self.assortmentId,self.classType);
            }
            return [RACSignal empty];
        }];
        
        [self addSubview:self.actionView];
        
    }
    return self;
}
//tag标签数组
-(NSMutableArray*)AssortmentArray{
    if (_AssortmentArray==nil) {
        _AssortmentArray=[[NSMutableArray alloc]init];
    }
    return _AssortmentArray;
}
-(NSMutableArray*)layoutAssortmentArray{
    if (_layoutAssortmentArray==nil) {
        _layoutAssortmentArray=[[NSMutableArray alloc]init];
    }
    return _layoutAssortmentArray;
}
//绘制tag 视图
-(void)DrawTagMakerMangeView:(NSMutableArray*)assortmenArray  assortmentId:(NSString*)assortmentId classType:(NSString*)classType{
    [self.layoutAssortmentArray removeAllObjects];
    self.assortmentId=assortmentId;
    self.classType=classType;
    self.AssortmentArray=assortmenArray;
    [self getLayoutArray];
    [self CMTDrawButton];
}
-(void)DrawTagMakerMangeView{
    [self.layoutAssortmentArray removeAllObjects];
    [self getLayoutArray];
    [self CMTDrawButton];
  
}
-(void)drawClassTypesView{
    for (UIView *view in [self.ClassTypesView subviews]) {
        [view removeFromSuperview];
    }
    NSArray *array=@[@"精品课程",@"系列课程"];
    float height=[CMTGetStringWith_Height getTextheight:@"中国" fontsize:14 width:SCREEN_WIDTH];
    self.titile=[[UILabel alloc]initWithFrame:CGRectMake(10*XXXRATIO, 10*XXXRATIO,SCREEN_WIDTH,height)];
    self.titile.text=@"请选择课程类型";
    self.titile.textColor=[UIColor colorWithHexString:@"#151515"];
    self.titile.font=FONT(14);
    [self.ClassTypesView addSubview:self.titile];
    float Viewwith=10*XXXRATIO;
    float viewheight=self.titile.bottom+self.spacing;
    for (int i=0; i<array.count;i++) {
        float tagWith=(SCREEN_WIDTH-10*XXXRATIO*5)/4;
        UIButton *Assortbutton=[UIButton buttonWithType:UIButtonTypeCustom];
        Assortbutton.frame=CGRectMake(Viewwith,viewheight,tagWith,self.tagheight);
        Assortbutton.titleLabel.font=FONT(14);
        if(self.classType.integerValue==i){
            Assortbutton.backgroundColor=[UIColor clearColor];
            Assortbutton.layer.borderWidth=1;
            Assortbutton.layer.borderColor=[UIColor colorWithHexString:@"#3cc6c1"].CGColor;
            [Assortbutton setTitleColor:[UIColor colorWithHexString:@"#3cc6c1"] forState:UIControlStateNormal];
            [Assortbutton setTitle:[@"√" stringByAppendingString:array[i]] forState:UIControlStateNormal];
        }else{
            Assortbutton.layer.borderWidth=0;
            [Assortbutton setTitle:array[i] forState:UIControlStateNormal];
            [Assortbutton setTitleColor:[UIColor colorWithHexString:@"#545659"] forState:UIControlStateNormal];
            Assortbutton.backgroundColor=[UIColor colorWithHexString:@"#e9ebee"];
            
        }
        Assortbutton.layer.cornerRadius=5;
        Assortbutton.tag=1000+i;
        [self.ClassTypesView addSubview:Assortbutton];
        [Assortbutton addTarget:self action:@selector(TabuttonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        
        Viewwith=Viewwith+self.spacing+tagWith;

    }
    viewheight=viewheight+self.tagheight+self.spacing*2;
    
    self.ClassTypesView.height=viewheight;
    self.actionView.top=self.ClassTypesView.bottom;
    if(self.bigheight<=self.actionView.bottom){
        self.height=self.bigheight;
        [self setContentSize:CGSizeMake(self.width, self.actionView.bottom)];
    }else{
        self.height=self.actionView.bottom;
    }

}
//获取换行分组
-(void)getLayoutArray{
    float with=10*XXXRATIO;
    NSString *indexStr=@"";
    for (int i=0;i<[self.AssortmentArray count];i++) {
        CMTAssortments *assort=[self.AssortmentArray objectAtIndex:i];
          NSString *titleString=assort.assortmentName;
        if([self.assortmentId isEqualToString:assort.assortmentId]){
            titleString=[@"√"stringByAppendingString:titleString];
        }
      
        with+=(SCREEN_WIDTH-10*XXXRATIO*5)/4;
        if (with<=self.width) {
            indexStr=[indexStr stringByAppendingFormat:@"&&%d",i];
        }else{
            if (!isEmptyString(indexStr)) {
                [self.layoutAssortmentArray addObject:indexStr];
            }
            
            indexStr=[@"" stringByAppendingFormat:@"&&%d",i];
            with=[CMTGetStringWith_Height CMTGetLableTitleWith:titleString fontSize:Assortfontsize*XXXRATIO]+self.spacing;
            
        }
        
        
    }
    if (!isEmptyString(indexStr)) {
        [self.layoutAssortmentArray addObject:indexStr];
    }
    
    
}
//绘制button
-(void)CMTDrawButton{
    for (UIView * view in [self.assertsView subviews]) {
        [view removeFromSuperview];
    }
    //    标签按钮的纵坐标
    float viewheight=0;
    for(int b=0;b<[self.layoutAssortmentArray count];b++){
        NSArray *array=[[self.layoutAssortmentArray objectAtIndex:b]componentsSeparatedByString:@"&&"];
        float Viewwith=10*XXXRATIO;//标签横坐标
        for(int number=1;number<[array count];number++){
            CMTAssortments *assort=[self.AssortmentArray objectAtIndex:[[array objectAtIndex:number]integerValue]];
            float tagWith=(SCREEN_WIDTH-10*XXXRATIO*5)/4;
            UIButton *Assortbutton=[UIButton buttonWithType:UIButtonTypeCustom];
            Assortbutton.frame=CGRectMake(Viewwith,viewheight,tagWith,self.tagheight);
            Assortbutton.titleLabel.font=FONT(14);
            if([self.assortmentId isEqualToString:assort.assortmentId]){
                 Assortbutton.backgroundColor=[UIColor clearColor];
                Assortbutton.layer.borderWidth=1;
                Assortbutton.layer.borderColor=[UIColor colorWithHexString:@"#3cc6c1"].CGColor;
                [Assortbutton setTitleColor:[UIColor colorWithHexString:@"#3cc6c1"] forState:UIControlStateNormal];
                 [Assortbutton setTitle:[@"√" stringByAppendingString:assort.assortmentName] forState:UIControlStateNormal];
            }else{
                 Assortbutton.layer.borderWidth=0;
                [Assortbutton setTitle:assort.assortmentName forState:UIControlStateNormal];
                  [Assortbutton setTitleColor:[UIColor colorWithHexString:@"#545659"] forState:UIControlStateNormal];
                Assortbutton.backgroundColor=[UIColor colorWithHexString:@"#e9ebee"];

            }
            Assortbutton.layer.cornerRadius=5;
            Assortbutton.tag=assort.assortmentId.integerValue+1000;
            [self.assertsView addSubview:Assortbutton];
            [Assortbutton addTarget:self action:@selector(TabuttonAction:) forControlEvents:UIControlEventTouchUpInside];
           
           
            Viewwith=Viewwith+self.spacing+tagWith;
        }
        viewheight=viewheight+self.tagheight+self.spacing;
    }
    self.assertsView.frame=CGRectMake(self.assertsView.frame.origin.x, self.assertsView.frame.origin.y, self.assertsView.frame.size.width, viewheight);
    self.ClassTypesView.top=self.assertsView.bottom;
      [self drawClassTypesView];
    
}
-(void)TabuttonAction:(UIButton*)button{
    if([button superview].tag==1001){
     NSString *assortId=[NSString stringWithFormat:@"%ld",button.tag-1000];
       if(![assortId isEqualToString:self.assortmentId]){
        self.assortmentId=assortId;
        [self DrawTagMakerMangeView];
       }
    }else{
        if(self.classType.integerValue!=button.tag-1000){
           self.classType=[NSString stringWithFormat:@"%ld",button.tag-1000];
           [self DrawTagMakerMangeView];
        }
    }
}
@end
