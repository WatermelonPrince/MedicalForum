//
//  CMTRecordListViewCell.m
//  MedicalForum
//
//  Created by zhaohuan on 16/7/29.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import "CMTSeriousListViewCell.h"

@interface CMTSeriousListViewCell ()
@property (nonatomic, strong)UIImageView *listimageView;
@property (nonatomic, strong)UIView *view;
@property (nonatomic, strong)UILabel *dateTimeLabel;
@property (nonatomic, strong)UILabel *totalHeatLabel;
@property (nonatomic, strong)UIView *heatImageViewbgView;
@end

@implementation CMTSeriousListViewCell

- (UIImageView *)listimageView{
    if (!_listimageView) {
        _listimageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH *9/16)];
        _listimageView.contentMode=UIViewContentModeScaleAspectFill;
        _listimageView.clipsToBounds=YES;
    }
    return _listimageView;
}

- (UILabel *)dateTimeLabel{
    if (!_dateTimeLabel) {
        _dateTimeLabel = [[UILabel alloc]init];
        _dateTimeLabel.textAlignment = NSTextAlignmentRight;
        _dateTimeLabel.backgroundColor =  [[UIColor colorWithHexString:@"#030303"] colorWithAlphaComponent:0.5];
        _dateTimeLabel.font = FONT(14);
        _dateTimeLabel.textColor = [UIColor whiteColor];
        _dateTimeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _dateTimeLabel;
}

- (UILabel *)totalHeatLabel{
    if (!_totalHeatLabel) {
        _totalHeatLabel = [[UILabel alloc]init];
        _totalHeatLabel = [[UILabel alloc]init];
        _totalHeatLabel.textAlignment = NSTextAlignmentRight;
        _totalHeatLabel.backgroundColor =  [[UIColor colorWithHexString:@"#030303"] colorWithAlphaComponent:0.3];
        _totalHeatLabel.font = FONT(14);
        _totalHeatLabel.textColor = [UIColor whiteColor];
        _totalHeatLabel.textAlignment = NSTextAlignmentLeft;

    }
    return _totalHeatLabel;
}

- (UILabel *)label{
    if (!_label) {
        _label = [[UILabel alloc]initWithFrame:CGRectMake(0, self.listimageView.bottom - 40 * XXXRATIO, SCREEN_WIDTH, 40 * XXXRATIO)];
        _label.font = FONT(17 * XXXRATIO);
        _label.textColor = [UIColor whiteColor];
    }
    return _label;
}

- (UIView *)heatImageViewbgView{
    if (_heatImageViewbgView==nil) {
        _heatImageViewbgView = [[UIView alloc]init];
        _heatImageViewbgView.backgroundColor = [[UIColor colorWithHexString:@"#030303"] colorWithAlphaComponent:0.3];
        ;
    }
    return _heatImageViewbgView;
}


- (UIView *)view{
    if (!_view) {
        _view = [[UIView alloc]initWithFrame:CGRectMake(0, self.listimageView.bottom - 40 * XXXRATIO, SCREEN_WIDTH, 40 * XXXRATIO)];
        _view.backgroundColor = [UIColor blackColor];
        _view.alpha = 0.5;
    }
    return _view;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor=COLOR(c_ffffff);
        [self.contentView addSubview:self.listimageView];
        [self.listimageView addSubview:self.dateTimeLabel];
        [self.listimageView addSubview:self.totalHeatLabel];
        [self.listimageView addSubview:self.heatImageViewbgView];
//        [self.listimageView addSubview:self.view];
        
    }
    return  self;
}


- (void)reloadCellWithModel:(CMTSeriesDetails*)model{
    [self.listimageView setImageURL:model.picUrl placeholderImage:IMAGE(@"Placeholderdefault") contentSize:self.listimageView.size];
    float width = ceilf([CMTGetStringWith_Height CMTGetLableTitleWith:model.dateTime fontSize:ceil(14)]);
    self.dateTimeLabel.frame = CGRectMake(0, self.listimageView.height - 40 * XXXRATIO, width + 20 *XXXRATIO, 40 * XXXRATIO);
    float width1 = ceilf([CMTGetStringWith_Height CMTGetLableTitleWith:model.totalHeat fontSize:ceil(14)]);
    self.totalHeatLabel.frame = CGRectMake(self.listimageView.width - width1 - 10 * XXXRATIO, self.listimageView.height - 40 * XXXRATIO, width1 + 10 * XXXRATIO, 40 * XXXRATIO);
    self.heatImageViewbgView.frame = CGRectMake(self.totalHeatLabel.left - 40 * XXXRATIO, self.totalHeatLabel.top, 40 * XXXRATIO, 40 * XXXRATIO);
    UIImageView *heatImageVIew = [[UIImageView alloc]init];
    heatImageVIew.frame = CGRectMake(0, 0, 18 * XXXRATIO, 18 * XXXRATIO);
    heatImageVIew.center = CGPointMake(self.heatImageViewbgView.width/2, self.heatImageViewbgView.height/2);
    heatImageVIew.image =  IMAGE(@"college_vedioIcon");
    [self.heatImageViewbgView addSubview:heatImageVIew];
    
    self.dateTimeLabel.text = model.dateTime;
    self.totalHeatLabel.text = model.totalHeat;
    NSString *str = [NSString stringWithFormat:@"  %@",model.seriesName];
    self.frame=CGRectMake(0, 0, SCREEN_WIDTH, self.listimageView.top+self.listimageView.height + 7 * XXXRATIO);
}



@end
