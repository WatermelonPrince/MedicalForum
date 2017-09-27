//
//  CMTVideoCollectionViewCell.m
//  MedicalForum
//
//  Created by zhaohuan on 2017/2/13.
//  Copyright © 2017年 CMT. All rights reserved.
//

#import "CMTVideoCollectionViewCell.h"

@implementation CMTVideoCollectionViewCell
- (UIView *)tapSlectedView{
    if (_tapSlectedView==nil) {
        _tapSlectedView = [[UIView alloc]init];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(ChangeimageViewStatus:)];
        [_tapSlectedView addGestureRecognizer:tapGesture];
    }
    return _tapSlectedView;
}

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (UILabel *)mLbTitle
{
    if (!_mLbTitle)
    {
        _mLbTitle = [[UILabel alloc]initWithFrame:CGRectMake(15.0*RATIO, 10, SCREEN_WIDTH - 30*RATIO - self.mImageView.width, 42.0)];
        _mLbTitle.numberOfLines = 2;
        _mLbTitle.textColor = COLOR(c_151515);
        _mLbTitle.backgroundColor = COLOR(c_clear);
        _mLbTitle.textColor = COLOR(c_151515);
        _mLbTitle.font = FONT(17.0);
    }
    return _mLbTitle;
}
- (UILabel *)mLbAuthor
{
    if (!_mLbAuthor)
    {
        _mLbAuthor = [[UILabel alloc]initWithFrame:CGRectMake(self.mImageView.left - 64 - 10, 61, 64, 13)];
        _mLbAuthor.font = FONT(11.0);
        _mLbDate.textAlignment = NSTextAlignmentRight;
        _mLbAuthor.textColor = COLOR(c_9e9e9e);
    }
    return _mLbAuthor;
}

- (UILabel *)mLbDate
{
    if (!_mLbDate)
    {
        _mLbDate = [[UILabel alloc]init];
        _mLbDate.font = FONT(11.0);
        _mLbDate.textAlignment = NSTextAlignmentRight;
        _mLbDate.textColor = COLOR(c_9e9e9e);
    }
    return _mLbDate;
}

- (UIImageView *)mImageView
{
    if (!_mImageView)
    {
        _mImageView = [[UIImageView alloc]initWithImage:nil];
        //[_mImageView setFrame:CGRectMake(232.0*RATIO + 73.0*(RATIO - 1), 13.5, 73.0, 60.5)];
        [_mImageView setFrame:CGRectMake(203*RATIO + 60 * 16/9*(RATIO - 1), 13.5, 60 * 16/9, 60)];
        _mImageView.clipsToBounds = YES;
        _mImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _mImageView;
}
- (UIView *)bottomLine {
    if (_bottomLine == nil) {
        _bottomLine = [[UIView alloc] init];
        _bottomLine.backgroundColor = COLOR(c_eaeaea);
    }
    
    return _bottomLine;
}
- (UIImageView *)imageViewStatus{
    if (!_imageViewStatus) {
        _imageViewStatus = [[UIImageView alloc]initWithFrame:CGRectMake(-30, 0, 20, 20)];
    }
    return _imageViewStatus;
}
-(void)ChangeimageViewStatus:(UITapGestureRecognizer *)tap{
    if(self.updateSelectState!=nil){
        self.updateSelectState(self.liveRecord);
    }
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        [self.contentView addSubview:self.mLbAuthor];
        [self.contentView addSubview:self.mLbDate];
        [self.contentView addSubview:self.mImageView];
        [self.contentView addSubview:self.mLbTitle];
        [self.contentView addSubview:self.bottomLine];
        [self.contentView addSubview:self.imageViewStatus];
        [self.contentView addSubview:self.tapSlectedView];
        [self.bottomLine builtinContainer:self WithLeft:0 Top:87-PIXEL Width:SCREEN_WIDTH Height:PIXEL];
        
    }
    return self;
}
//刷新cell
- (void)reloadCellWithdate:(NSString *)type
                     model:(CMTLivesRecord *)record{
     self.liveRecord=record;
    if ([type isEqualToString:@"1"]) {
        NSString *str=@"";
        if(record.playstatus.integerValue==1){
            str=@"已看完";
        }else{
            if(record.playDuration.floatValue/1000<(float)60){
                str=@"观看不足一分钟";
            }else{
                NSDate *pastDate = [NSDate dateWithTimeIntervalSince1970:record.playDuration.floatValue/1000];
                str=[str getTimeByDate:pastDate byProgress:record.playDuration.floatValue/1000];
                str=[@"已观看至" stringByAppendingFormat:@"%@",str];
                
            }
        }

        float width = ceilf([CMTGetStringWith_Height CMTGetLableTitleWith:str fontSize:11]);
        self.mLbDate.frame = CGRectMake(self.mLbTitle.left, self.mLbAuthor.top, width, self.mLbAuthor.height);
        self.mLbDate.text =str ;
        self.mLbAuthor.text = record.collegeInfo.collegeName;
        self.mLbAuthor.hidden = NO;

    }else{
        float width = ceilf([CMTGetStringWith_Height CMTGetLableTitleWith:type.integerValue==2?[CMTDownLoad AccessFileSize:record.fileSize]:record.createdTime fontSize:11]);
        self.mLbDate.frame = CGRectMake(self.mLbTitle.left, self.mLbAuthor.top, width, self.mLbAuthor.height);
        self.mLbDate.text =type.integerValue==2?[CMTDownLoad AccessFileSize:record.fileSize]:record.createdTime;
        self.mLbAuthor.hidden = YES;

    }
    self.mLbTitle.text = record.title;
    [ self.mImageView setImageURL:record.roomPic placeholderImage:IMAGE(@"Placeholderdefault") contentSize:self.mImageView.size];
    self.imageViewStatus.image=record.isSelected ? [UIImage imageNamed:@"ic_checkbox_pressed"] : [UIImage imageNamed:@"ic_checkbox_normal"];
     self.imageViewStatus.centerY =self.mImageView.centerY;
    self.frame=CGRectMake(self.left, self.top, SCREEN_WIDTH, self.bottomLine.bottom);
    self.contentView.frame=CGRectMake(0, 0, self.width, self.height);
    self.tapSlectedView.frame=self.contentView.frame;
}

@end
