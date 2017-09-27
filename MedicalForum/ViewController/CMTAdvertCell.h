//
//  CMTAdvertCell.h
//  MedicalForum
//
//  Created by zhaohuan on 2017/2/28.
//  Copyright © 2017年 CMT. All rights reserved.
//


//广告类型的cell
#import <UIKit/UIKit.h>

@protocol CMTAdvertCellDelegate <NSObject>


- (void)didSelectAdvert:(CMTAdvert *)advert;

@end


@interface CMTAdvertCell : UITableViewCell

@property (nonatomic, assign)id<CMTAdvertCellDelegate> delegate;
@property (nonatomic, strong)CMTAdvert *advert;
@property (nonatomic, strong)UIImageView *advertImageView;

- (void)reloadCellWithModel:(CMTAdvert *)model;

@end
