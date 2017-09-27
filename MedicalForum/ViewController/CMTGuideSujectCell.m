//
//  CMTGuideSujectCell.m
//  MedicalForum
//
//  Created by CMT on 15/6/1.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTGuideSujectCell.h"
#import "CMTSubject.h"
@interface CMTGuideSujectCell()
@end
@implementation CMTGuideSujectCell
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor=COLOR(c_ffffff);
        [self.contentView addSubview:self.mLbSub];
        [self.contentView addSubview:self.mSubArticleNumber];
        [self.contentView addSubview:self.badgePoint];
        [self.contentView addSubview:self.nextImage];
        [self.contentView addSubview:self.splitline];
    }
    return self;
}
//学科名
-(UILabel*)mLbSub{
    if (_mLbSub==nil) {
        _mLbSub=[[UILabel alloc]initWithFrame:CGRectZero];
    }
    return _mLbSub;
}
- (CMTBadgePoint *)badgePoint {
    if (_badgePoint == nil) {
        _badgePoint = [[CMTBadgePoint alloc] init];
        _badgePoint.hidden = YES;
    }
    
    return _badgePoint;
}
//文章数量
-(UILabel*)mSubArticleNumber{
    if (_mSubArticleNumber==nil) {
        _mSubArticleNumber=[[UILabel alloc]initWithFrame:CGRectZero];
    }
    return _mSubArticleNumber;
}
//底部线
-(UIView*)splitline{
    if (_splitline==nil) {
        _splitline=[[UIView alloc]initWithFrame:CGRectZero];
        _splitline.backgroundColor=COLOR(c_f8f8f9);
    }
    return _splitline;
}
//下一级指示图片
-(UIImageView*)nextImage{
    if (_nextImage==nil) {
        _nextImage=[[UIImageView alloc]initWithImage:IMAGE(@"Guide_forward")];
    }
    return _nextImage;
}

#pragma 绘制列表cell
-(void)reloadSujectCell:(CMTSubject*)object{
//   CGFloat postTypeWidth=[CMTGetLableTitleWith CMTGetLableTitleWith:object.subject fontSize:14];
    self.mLbSub.frame=CGRectMake(10, 0, 80,50);
    [self.mLbSub setFont:FONT(16)];
    self.mLbSub.text=object.subject;
    self.badgePoint.frame=CGRectMake(100,15, 10, 10);
    self.nextImage.frame=CGRectMake(SCREEN_WIDTH-21-10, (50-21)/2, 21, 21);
    self.splitline.frame=CGRectMake(0,50, SCREEN_WIDTH, 1);
    self.frame=CGRectMake(self.frame.origin.x, self.frame.origin.y, SCREEN_WIDTH,51);
    
}
@end
