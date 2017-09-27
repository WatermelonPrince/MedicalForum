//
//  CMTSeriousVedioCell.h
//  MedicalForum
//
//  Created by zhaohuan on 16/7/25.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CMTVedioCellDelegate <NSObject>

- (void)didSelecteVideo:(CMTLivesRecord*)Record;

@end

@interface CMTCourseCell : UITableViewCell

@property (nonatomic, assign)id<CMTVedioCellDelegate> delegate;
@property(nonatomic,strong)NSString *searchKey;
-(void)reloadCellWithData:(NSMutableArray *)data;

-(void)reloadCellWithData:(NSMutableArray *)data
           withBoolHeader:(BOOL)header;

@end
