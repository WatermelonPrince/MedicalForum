//
//  CMTCollectViewCell.h
//  MedicalForum
//
//  Created by Bo Shen on 15/2/3.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CMTCollectViewCellDelegate <NSObject>

- (void)tapSelectedAction:(CMTStore *)model
              NsIndexPath:(NSIndexPath *)indexPath;

@end

@interface CMTCollectViewCell : UITableViewCell

@property (strong, nonatomic) UILabel *mLbTitle;
@property (strong, nonatomic) UILabel *mLbAuthor;
@property (strong, nonatomic) UIImageView *mImageView;
@property (strong, nonatomic) UILabel *mLbDate;
@property (strong, nonatomic) UIImageView *imageViewStatus;
@property (strong, nonatomic) UIView *tapSlectedView;
@property (strong, nonatomic) CMTStore *model;
@property (strong, nonatomic) NSIndexPath *indexPath;

///分割线
@property (strong, nonatomic) UIView *separatorLine;
///底线
@property (strong, nonatomic) UIView *bottomLine;

@property (nonatomic, weak) id <CMTCollectViewCellDelegate> delegate;


- (void)reloadCellWithModel:(CMTStore *)model
                NsIndexPath:(NSIndexPath *)indexPath;

@end
