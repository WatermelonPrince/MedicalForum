//
//  CMTDiseaseListCell.h
//  MedicalForum
//
//  Created by CMT on 15/6/9.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CMTDiseaseListCell : UITableViewCell
@property(nonatomic,assign) BOOL isShowFocusButton;
-(void)reloadCellData:(CMTDisease*)Disease index:(NSInteger)index;
@end
