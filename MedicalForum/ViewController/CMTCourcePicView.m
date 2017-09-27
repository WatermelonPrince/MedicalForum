//
//  CMTCourcePicView.m
//  MedicalForum
//
//  Created by guoyuanchao on 16/12/19.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import "CMTCourcePicView.h"

@implementation CMTCourcePicView
-(UIImageView*)VideoimageView{
    if(_VideoimageView==nil){
        _VideoimageView=[[UIImageView alloc]init];
        _VideoimageView.contentMode = UIViewContentModeScaleAspectFill;
        _VideoimageView.clipsToBounds = YES;
    }
    return _VideoimageView;
}
-(UIImageView*)VideoSymbol{
    if (_VideoSymbol==nil) {
        _VideoSymbol=[[UIImageView alloc]init];
        _VideoSymbolView.contentMode=UIViewContentModeScaleAspectFill;
        _VideoSymbolView.clipsToBounds=YES;
    }
    return _VideoSymbol;
}
-(UIView*)VideoSymbolView{
    if(_VideoSymbolView==nil){
        _VideoSymbolView=[[UIView alloc]init];
        _VideoSymbolView.backgroundColor=[[UIColor colorWithHexString:@"#030303"] colorWithAlphaComponent:0.5];
    }
    return _VideoSymbolView;
}
-(UILabel *)usersLable{
    if(_usersLable==nil){
        _usersLable=[[UILabel alloc]init];
        _usersLable.textAlignment = NSTextAlignmentLeft;
        _usersLable.backgroundColor =  [[UIColor colorWithHexString:@"#030303"] colorWithAlphaComponent:0.5];
    }
    return _usersLable;
}
-(UILabel *)VideoSymbolName{
    if(_VideoSymbolName==nil){
        _VideoSymbolName=[[UILabel alloc]init];
        _VideoSymbolName.textAlignment = NSTextAlignmentLeft;
        _VideoSymbolName.font=FONT(14);
        _VideoSymbolName.textColor = [UIColor whiteColor];
    }
    return _VideoSymbolName;
}

-(UILabel*)titlelable{
    if (_titlelable==nil) {
        _titlelable=[[UILabel alloc]init];
    }
    return _titlelable;
}


- (UIView *)heatImageViewbgView{
    if (_heatImageViewbgView==nil) {
        _heatImageViewbgView = [[UIView alloc]init];
        _heatImageViewbgView.backgroundColor = [[UIColor colorWithHexString:@"#030303"] colorWithAlphaComponent:0.5];
;
    }
    return _heatImageViewbgView;
}
-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if(self){
        float height=24;
        self.VideoimageView.frame=CGRectMake(0, 0, frame.size.width, frame.size.height*10/16);
        
        self.titlelable.numberOfLines = 2;
        [self addSubview:self.VideoimageView];
        [self addSubview:self.titlelable];
        
        float width = ceilf([CMTGetStringWith_Height CMTGetLableTitleWith:@"100000+" fontSize:ceil(14)]);
       
         float SymbolNamewith=[CMTGetStringWith_Height CMTGetLableTitleWith:@"系列" fontSize:14];
        self.VideoSymbolView.frame=CGRectMake(0 , self.VideoimageView.height -height,5+SymbolNamewith+12+5+5, height);
       
        self.VideoSymbol.frame =CGRectMake((self.VideoSymbolView.width-12-SymbolNamewith-5)/2,  (self.VideoSymbolView.height-12)/2, 12, 12);
        self.VideoSymbolName.frame=CGRectMake(self.VideoSymbol.right+5, 0, SymbolNamewith,self.VideoSymbolView.height);
         self.VideoSymbolName.text=@"系列";
        
        self.usersLable.frame = CGRectMake(self.VideoimageView.width - width-5, self.VideoimageView.height - height, width+5, height);
    
        self.heatImageViewbgView.frame = CGRectMake(self.usersLable.left-22, self.usersLable.top,22, height);
        UIImageView *heatImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0,0 , 12, 12)];
        heatImageView.center = CGPointMake(self.heatImageViewbgView.width/2, self.heatImageViewbgView.height/2);
        heatImageView.image =  IMAGE(@"college_vedioIcon");

        self.usersLable.font = FONT(14);
        self.usersLable.textColor = [UIColor whiteColor];
        self.titlelable.textColor = COLOR(c_151515);
        self.titlelable.font = FONT(16);
        [self.VideoimageView addSubview:self.usersLable];
        [self.VideoimageView addSubview:self.heatImageViewbgView];
        [self.heatImageViewbgView addSubview:heatImageView];
        [self.VideoimageView addSubview:self.VideoSymbolView];
        [self.VideoSymbolView addSubview:self.VideoSymbol];
        [self.VideoSymbolView addSubview:self.VideoSymbolName];
    }
    return self;
}

-(void)reloadData:(CMTLivesRecord*)model{
    self.LivesRecord=model;
    //动态标题高度
    float height = ([CMTGetStringWith_Height getTextheight:model.title fontsize:16 width:ceil(self.VideoimageView.width)]);
    float height1 = ([CMTGetStringWith_Height getTextheight:@"哈" fontsize:16 width:ceil(self.VideoimageView.width)]);
    if (height > height1 * 2) {
        self.titlelable.frame = CGRectMake(0, self.VideoimageView.height+35/3, ceil(self.VideoimageView.width), height1 * 2);
    }else{
         self.titlelable.frame = CGRectMake(0,self.VideoimageView.height +35/3, ceil(self.VideoimageView.width), height);
    }
    
    [ self.VideoimageView setImageURL:model.roomPic placeholderImage:IMAGE(@"Placeholderdefault") contentSize:self.VideoimageView.size];
    //动态热度长度

    float width = ceilf([CMTGetStringWith_Height CMTGetLableTitleWith:model.users fontSize:14]);
        self.usersLable.frame = CGRectMake(self.VideoimageView.width - width -5, self.VideoimageView.height -24, width+5,self.usersLable.height);
    self.heatImageViewbgView.frame = CGRectMake(self.usersLable.left -self.heatImageViewbgView.width, self.usersLable.top, self.heatImageViewbgView.width, self.heatImageViewbgView.height);
    self.usersLable.text = model.users;
    if(self.searchKey.length>0){
        NSRange range = [model.title rangeOfString:self.searchKey];
        NSMutableAttributedString *pStr = [[NSMutableAttributedString alloc]initWithString:model.title];
        [pStr addAttribute:NSForegroundColorAttributeName value:COLOR(c_32c7c2) range:range];
        self.titlelable.attributedText= pStr;

    }else{
        self.titlelable.text = model.title;
    }
    [self.VideoSymbol setImageURL:model.themeInfo.picUrl placeholderImage:IMAGE(@"videoSymbolImage") contentSize:CGSizeMake(self.VideoSymbol.width, self.VideoSymbol.height)];
       if ([model.themeInfo.themeUuid isEqualToString:@""]) {
         self.VideoSymbolView.hidden = YES;
           
    }else{
        self.VideoSymbolView.hidden = NO;
    }
   float SymbolNamewith=[CMTGetStringWith_Height CMTGetLableTitleWith:@"系列" fontSize:14];
    float SymbolNamewith2=[CMTGetStringWith_Height CMTGetLableTitleWith:(model.themeInfo.markName!=nil?model.themeInfo.markName:@"系列") fontSize:14];
    self.VideoSymbolName.text=model.themeInfo.markName!=nil?model.themeInfo.markName:@"系列";
    if(SymbolNamewith2-SymbolNamewith!=(float)0){
        self.VideoSymbolView.width=self.VideoSymbolView.width+SymbolNamewith2-SymbolNamewith;
        self.VideoSymbolName.width=SymbolNamewith2;
    }
    self.height=self.titlelable.bottom+35/3*2.5;
    
}
@end
