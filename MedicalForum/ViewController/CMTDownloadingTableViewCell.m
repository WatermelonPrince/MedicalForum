//
//  CMTDownloadingTableViewCell.m
//  MedicalForum
//
//  Created by guoyuanchao on 2017/3/20.
//  Copyright © 2017年 CMT. All rights reserved.
//

#import "CMTDownloadingTableViewCell.h"

@implementation CMTDownloadingTableViewCell

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
        _mLbTitle = [[UILabel alloc]initWithFrame:CGRectMake(15.0, 10, SCREEN_WIDTH -45 - self.mImageView.width, 42.0)];
        _mLbTitle.numberOfLines = 2;
        _mLbTitle.textColor = COLOR(c_151515);
        _mLbTitle.backgroundColor = COLOR(c_clear);
        _mLbTitle.textColor = COLOR(c_151515);
        _mLbTitle.font = FONT(17.0);
    }
    return _mLbTitle;
}
- (UILabel *)mlbdataSize
{
    if (!_mlbdataSize)
    {
        _mlbdataSize = [[UILabel alloc]initWithFrame:CGRectMake(self.mImageView.left - 64 - 10, 61, 64, 13)];
        _mlbdataSize.font = FONT(11.0);
        _mLbloadState.textAlignment = NSTextAlignmentRight;
        _mlbdataSize.textColor = COLOR(c_9e9e9e);
    }
    return _mlbdataSize;
}

- (UILabel *)mLbloadState
{
    if (!_mLbloadState)
    {
        _mLbloadState = [[UILabel alloc]init];
        _mLbloadState.font = FONT(11.0);
        _mLbloadState.textAlignment = NSTextAlignmentRight;
        _mLbloadState.textColor = COLOR(c_9e9e9e);
    }
    return _mLbloadState;
}

- (UIImageView *)mImageView
{
    if (!_mImageView)
    {
        _mImageView = [[UIImageView alloc]initWithImage:nil];
        [_mImageView setFrame:CGRectMake(SCREEN_WIDTH-60 * 16/9-15, 13.5, 60 * 16/9, 60)];
        _mImageView.clipsToBounds = YES;
        _mImageView.contentMode = UIViewContentModeScaleAspectFill;
        _playStateimage=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
        UIView *view=[[UIView alloc]initWithFrame:CGRectMake(0, 0, _mImageView.width,  _mImageView.height)];
        view.backgroundColor=[[UIColor colorWithHexString:@"#151515"] colorWithAlphaComponent:0.5];
        [_mImageView addSubview:view];
        [_playStateimage setImage:IMAGE(@"startDownState") forState:UIControlStateNormal];
        [_playStateimage setImage:IMAGE(@"pauseDownstate") forState:UIControlStateSelected];
        _playStateimage.center=CGPointMake(_mImageView.width/2, _mImageView.height/2);
        [view addSubview:_playStateimage];
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
-(UIProgressView*)ProgressView{
    if(_ProgressView==nil){
        _ProgressView=[[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleDefault];
        _ProgressView.progressTintColor=[UIColor colorWithHexString:@"#00ae87"];
        _ProgressView.trackTintColor=[UIColor colorWithHexString:@"#cbcacb"];
        _ProgressView.frame=CGRectMake(self.mLbTitle.left, self.mlbdataSize.bottom+5, self.mLbTitle.width, 30);
    }
    return _ProgressView;
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
        [self.contentView addSubview:self.mLbTitle];
        [self.contentView addSubview:self.mlbdataSize];
        [self.contentView addSubview:self.mLbloadState];
        [self.contentView addSubview:self.mImageView];
        [self.contentView addSubview:self.bottomLine];
        [self.contentView addSubview:self.imageViewStatus];
        [self.contentView addSubview:self.tapSlectedView];
        [self.contentView addSubview:self.ProgressView];
        [self.bottomLine builtinContainer:self WithLeft:0 Top:self.ProgressView.bottom+5 Width:SCREEN_WIDTH Height:PIXEL];
        
    }
    return self;
}
//刷新cell
- (void)reloadCell:(CMTLivesRecord *)record{
        self.liveRecord=record;
        float width = ceilf([CMTGetStringWith_Height CMTGetLableTitleWith:[self downloadState] fontSize:11]);
        self.mLbloadState.frame = CGRectMake(self.mLbTitle.left, self.mlbdataSize.top, width, self.mlbdataSize.height);
        self.mLbloadState.text =[self downloadState] ;
    float dataSizewith=[CMTGetStringWith_Height CMTGetLableTitleWith:[CMTDownLoad AccessFileSize:record.fileSize ] fontSize:11];
        self.mlbdataSize.width=dataSizewith;
        self.mlbdataSize.right=self.mLbTitle.right;
    self.mlbdataSize.text =[CMTDownLoad AccessFileSize:record.fileSize];
        self.mLbTitle.text = record.title;
       [ self.mImageView setImageURL:record.roomPic placeholderImage:IMAGE(@"Placeholderdefault") contentSize:self.mImageView.size];
     if(record.Downstate==1||record.Downstate==3){
         self.playStateimage.selected=YES;
     }else{
         self.playStateimage.selected=NO;
     }
      self.imageViewStatus.image=record.isSelected ? [UIImage imageNamed:@"ic_checkbox_pressed"] : [UIImage imageNamed:@"ic_checkbox_normal"];
      self.imageViewStatus.centerY =self.mImageView.centerY;
      self.frame=CGRectMake(self.left, self.top, SCREEN_WIDTH, self.bottomLine.bottom);
      self.contentView.frame=CGRectMake(0, 0, self.width, self.height);
      self.tapSlectedView.frame=self.contentView.frame;
     [self.ProgressView setProgress:record.downloadProgress];
    
}
-(NSString*)downloadState{
    NSString *str=@"等待下载中";
    if(self.liveRecord.Downstate==1){
        str=@"正在下载";
    }else if(self.liveRecord.Downstate==2){
        str=@"已暂停";
    }else if(self.liveRecord.Downstate==3){
        str=@"正在连接";
    }else if(self.liveRecord.Downstate==4){
        str=@"下载失败";
    }else if(self.liveRecord.Downstate==5){
        str=@"已取消下载";
    }else if(self.liveRecord.Downstate==6){
        str=@"当前非wifi网络";
    }else if(self.liveRecord.Downstate==7){
        str=@"已经下载";
    }


    return str;
}
@end
