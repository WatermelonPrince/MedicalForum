//
//  CMTLearningRecordCell.m
//  MedicalForum
//
//  Created by guoyuanchao on 17/2/13.
//  Copyright © 2017年 CMT. All rights reserved.
//

#import "CMTLearningRecordCell.h"
@interface CMTLearningRecordCell()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property(nonatomic,strong)UIImageView *LearnRecordImageView;
@property(nonatomic,strong)UILabel *LearnRecordLable;
@property(nonatomic,strong)UIImageView *rightImageView;
@property(nonatomic,strong)UICollectionView *recordCollectionView;
@property(nonatomic,strong)NSArray *dataSourceArray;
@property(nonatomic,strong)UIView *line;
@end
@implementation CMTLearningRecordCell
#define Cell_HEIGHT 50

-(UIImageView *)LearnRecordImageView{
    if(_LearnRecordImageView==nil){
        _LearnRecordImageView=[[UIImageView alloc] initWithFrame:CGRectMake(10*RATIO, Cell_HEIGHT/2-(20/2), 20, 20)];
        _LearnRecordImageView.image=IMAGE(@"ic_mine_left_learnHis");
    }
    return _LearnRecordImageView;
}
-(UILabel*)LearnRecordLable{
    if(_LearnRecordLable==nil){
        _LearnRecordLable=[[UILabel alloc] initWithFrame:CGRectMake(10*RATIO+20+10*RATIO, Cell_HEIGHT/2-(20/2), 100, 20)];
        _LearnRecordLable.text=@"学习记录";
        _LearnRecordLable.font=FONT(16);
    }
    return _LearnRecordLable;
}
-(UIImageView*)rightImageView{
    if(_rightImageView==nil){
        _rightImageView=[[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-10*RATIO-9, Cell_HEIGHT/2-(13/2), 9, 13 )];
        _rightImageView.image=[UIImage imageNamed:@"acc"];
    }
    return _rightImageView;
}
-(UIControl*)cellView{
    if(_cellView==nil){
        _cellView=[[UIControl alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
        [_cellView addSubview:self.LearnRecordImageView];
        [_cellView addSubview:self.LearnRecordLable];
        [_cellView addSubview:self.rightImageView];

    }
    return _cellView;
}
-(UICollectionView*)recordCollectionView{
    if(_recordCollectionView==nil){
        float heigt=130/16*9+20/3+50/3;
        float textheigt=[CMTGetStringWith_Height getTextheight:@"中国" fontsize:11 width:130]*2;
        heigt=textheigt+heigt;
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        //设置单元格的尺寸
        flowLayout.scrollDirection=UICollectionViewScrollDirectionHorizontal;
        flowLayout.minimumLineSpacing=10*RATIO;
        _recordCollectionView=[[UICollectionView alloc]initWithFrame:CGRectMake(0, Cell_HEIGHT, SCREEN_WIDTH,heigt) collectionViewLayout:flowLayout] ;
        [_recordCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
        _recordCollectionView.delegate=self;
        _recordCollectionView.dataSource=self;
        _recordCollectionView.backgroundColor=COLOR(c_ffffff);
       }
          return _recordCollectionView;
    }
   
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

   
}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        [self.contentView addSubview:self.cellView];
        [self.contentView addSubview:self.recordCollectionView];
        self.line=[[UIView alloc]initWithFrame:CGRectMake(0, self.recordCollectionView.bottom, SCREEN_WIDTH, PIXEL)];
        self.line.backgroundColor= COLOR(c_eaeaea);
        [self.contentView addSubview:self.line];
    }
    return self;
        
}
-(void)reloadCell:(NSArray*)dataArray{
    self.dataSourceArray=dataArray;
    [self.recordCollectionView reloadData];
    if(dataArray.count==0){
        self.recordCollectionView.hidden=YES;
        self.line.top=self.cellView.bottom;
    }else{
        self.recordCollectionView.hidden=NO;
        self.line.top=self.recordCollectionView.bottom;
    }
    self.height=self.line.bottom;
}
#pragma mark -UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

//指定单元格的个数 ，这个是一个组里面有多少单元格，e.g : 一个单元格就是一张图片
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataSourceArray.count;
}

//构建单元格
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
      UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
        UIImageView *imagepic=[cell.contentView viewWithTag:1000];
     CMTLivesRecord *live=[self.dataSourceArray objectAtIndex:indexPath.row];
     if(imagepic==nil){
          imagepic=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0,130, 130/16*9)];
         [imagepic setImageURL:live.roomPic placeholderImage:IMAGE(@"Placeholderdefault") contentSize:CGSizeMake(130, 130/16*9)];
          imagepic.tag=1000;
         [cell.contentView addSubview:imagepic];
      }else{
          [imagepic setImageURL:live.roomPic placeholderImage:IMAGE(@"Placeholderdefault") contentSize:CGSizeMake(130, 130/16*9)];
      }
    
    UILabel *timelable=[cell.contentView viewWithTag:1001];
    NSString *str=@"";
    if(live.playstatus.integerValue==1){
        str=@"  已看完  ";
    }else{
        if(live.playDuration.floatValue/1000<(float)60){
             str=@"  观看不足一分钟  ";
        }else{
            NSDate *pastDate = [NSDate dateWithTimeIntervalSince1970:live.playDuration.floatValue/1000];
            str=[self getTimeByDate:pastDate byProgress:live.playDuration.floatValue/1000];
            str=[@"  已观看至" stringByAppendingFormat:@"%@%@",str,@"  "];

        }
    }
    if(timelable==nil){
        float with=[CMTGetStringWith_Height CMTGetLableTitleWith:str fontSize:11];
        timelable=[[UILabel alloc]initWithFrame:CGRectMake(0,imagepic.height-16,with, 16)];
        timelable.text=str;
        timelable.tag=1001;
        timelable.font=FONT(11);
        timelable.textColor=COLOR(c_ffffff);
        timelable.backgroundColor = [[UIColor colorWithHexString:@"#030303"] colorWithAlphaComponent:0.7];
        [imagepic addSubview:timelable];
    }else{
        float with=[CMTGetStringWith_Height CMTGetLableTitleWith:str fontSize:11];
        timelable.text=str;
        timelable.width=with;
    }
    UILabel *titlelbale=[cell.contentView viewWithTag:1002];
    if(titlelbale==nil){
        float textheigt=[CMTGetStringWith_Height getTextheight:@"中国" fontsize:11 width:130]*2;
        float textheigt1=[CMTGetStringWith_Height getTextheight:live.title fontsize:11 width:130];
        if(textheigt1<textheigt){
            textheigt=textheigt1;
        }
        titlelbale=[[UILabel alloc]initWithFrame:CGRectMake(0, imagepic.bottom+20/3,imagepic.width, textheigt)];
        titlelbale.text=live.title;
        titlelbale.tag=1002;
        titlelbale.numberOfLines=2;
        titlelbale.lineBreakMode = NSLineBreakByTruncatingTail;
        titlelbale.font=FONT(11);
        titlelbale.textColor=[UIColor colorWithHexString:@"#929292"];
        [cell.contentView addSubview:titlelbale];
    }else{
        float textheigt=[CMTGetStringWith_Height getTextheight:@"中国" fontsize:11 width:130]*2;
        float textheigt1=[CMTGetStringWith_Height getTextheight:live.title fontsize:11 width:130];
        if(textheigt1<textheigt){
            textheigt=textheigt1;
        }
        titlelbale.text=live.title;
        titlelbale.height=textheigt;
        
    }
    return cell;
}
//获取替换时间格式
- (NSString *)getTimeByDate:(NSDate *)date byProgress:(float)current {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSInteger hour=0;
    if (current / 3600 >= 1) {
        hour =(NSInteger)(current/3600);
        date=[NSDate dateWithTimeIntervalSince1970:current-hour*3600];
        [formatter setDateFormat:@"mm:ss"];
    } else {
        [formatter setDateFormat:@"mm:ss"];
    }
    if (hour>=1) {
        return [NSString stringWithFormat:@"%@%ld:%@",hour>9?@"":@"0",hour,[formatter stringFromDate:date]];
    }else{
        return [NSString stringWithFormat:@"%@:%@",@"00",[formatter stringFromDate:date]];
    }
    return [formatter stringFromDate:date];
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if(self.WatchVideo!=nil){
        self.WatchVideo(self.dataSourceArray[indexPath.row]);
    }
}
//通过协议方法设置单元格尺寸
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    float heigt=130/16*9+20/3+50/3;
    float textheigt=[CMTGetStringWith_Height getTextheight:@"中国" fontsize:11 width:130]*2;
    heigt=textheigt+heigt;
    return CGSizeMake(130, heigt);
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 10*RATIO,0, 10*RATIO);
}
@end
