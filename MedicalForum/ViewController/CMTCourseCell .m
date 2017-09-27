//
//  CMTSeriousVedioCell.m
//  MedicalForum
//
//  Created by zhaohuan on 16/7/25.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import "CMTCourseCell.h"
#import "CMTCourcePicView.h"
@interface CMTCourseCell ()

@property (nonatomic, assign)BOOL header;


@end

@implementation CMTCourseCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.header=NO;
    }
    return self;
}

-(void)reloadCellWithData:(NSMutableArray *)data
           withBoolHeader:(BOOL)header{
    self.header = header;
    [self reloadCellWithData:data];
    
}

-(void)reloadCellWithData:(NSMutableArray *)data{
    if(data.count!=2){
       for (UIView * view in  [self.contentView subviews]) {
           view.hidden=YES;
        }
    }
        for (int i = 0; i < data.count; i ++ ) {
           CMTLivesRecord *model = data[i];
            int a = i  < 2 ? i : i - 2;
            CMTCourcePicView *coure=[self.contentView viewWithTag:1000+i];
            if(coure==nil){
                CMTCourcePicView *coure= [[CMTCourcePicView alloc]initWithFrame:CGRectMake(10 * XXXRATIO + a * ((SCREEN_WIDTH - 2.75 * 10 *XXXRATIO)/2 + 0.75 *10 * XXXRATIO),self.header?10 *XXXRATIO:0, (SCREEN_WIDTH - 3 * 10 *XXXRATIO)/2, (SCREEN_WIDTH - 2.75 * 10 *XXXRATIO)/2*9/16*1.6)];
              coure.tag = 1000 + i;
              coure.searchKey=self.searchKey;
             [coure reloadData:model];
 
             [coure addTarget:self action:@selector(tapAction:) forControlEvents:UIControlEventTouchUpInside];
             [self.contentView addSubview:coure];
            }else{
                if(self.header){
                    coure.top=self.header?10 *XXXRATIO:0;
                }
                 coure.searchKey=self.searchKey;
                [coure reloadData:model];
                coure.hidden=NO;
            }
        }
    float viewheight=((UIView *)[self.contentView subviews].firstObject).height;
    if(data.count>1){
        viewheight=((UIView *)[self.contentView subviews].lastObject).height>viewheight?((UIView *)[self.contentView subviews].lastObject).height:viewheight;
    }
    self.frame = CGRectMake(0, 0, SCREEN_WIDTH, viewheight+((UIView *)[self.contentView subviews].firstObject).top);
}

- (void)tapAction:(CMTCourcePicView *)Cource{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelecteVideo:)]) {
        [self.delegate didSelecteVideo:Cource.LivesRecord];
    }
}


@end
