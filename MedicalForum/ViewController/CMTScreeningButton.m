//
//  CMTScreeningButton.m
//  MedicalForum
//
//  Created by guoyuanchao on 16/12/22.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import "CMTScreeningButton.h"

@implementation CMTScreeningButton
-(UILabel*)screeninglable{
    if(_screeninglable==nil){
        _screeninglable=[[UILabel alloc]init];
        _screeninglable.font=FONT(14);
    }
    return _screeninglable;
}
-(UIImageView*)screeningImageView{
    if(_screeningImageView==nil){
        _screeningImageView=[[UIImageView alloc]init];
        _screeningImageView.image=IMAGE(@"screeningunseclectImage");
    }
    return _screeningImageView;
}
-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if(self){
        [self addSubview:self.screeningImageView];
        [self addSubview:self.screeninglable];
        [self drawComponent];
        self.layer.cornerRadius=5;
    }
    return self;
        
}
-(void)drawComponent{
    self.screeningImageView.frame=CGRectMake(10, 10, 10,self.height-20);
    float with=[CMTGetStringWith_Height CMTGetLableTitleWith:@"筛选" fontSize:14];
    self.screeninglable.frame=CGRectMake(self.screeningImageView.right+5,0, with,self.height);
    self.screeninglable.text=@"筛选";
    self.backgroundColor=[UIColor colorWithHexString:@"#e9ebee"];
    self.screeninglable.textColor=[UIColor colorWithHexString:@"#545659"];
}
-(void)drawSelectedComponent{
    self.screeningImageView.image=IMAGE(@"screeningImage");
    self.backgroundColor=[UIColor clearColor];
    self.layer.borderWidth=1;
    self.layer.borderColor=[UIColor colorWithHexString:@"#3cc6c1"].CGColor;
    self.screeninglable.textColor=[UIColor colorWithHexString:@"#3cc6c1"];
}
-(void)drawUnSelectedComponent{
    self.backgroundColor=[UIColor colorWithHexString:@"#e9ebee"];
    self.screeninglable.textColor=[UIColor colorWithHexString:@"#545659"];
    self.layer.borderWidth=0;
    self.screeningImageView.image=IMAGE(@"screeningunseclectImage");
}
@end
