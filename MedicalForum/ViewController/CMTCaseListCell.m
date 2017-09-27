//
//  CMTCaseLIstCell.m
//  MedicalForum
//
//  Created by CMT on 15/6/3.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTCaseListCell.h"
#import "CMTTextMarker.h"
#import "CMTImageMarker.h"
#import "CMTOtherPostListViewController.h"
#import "CMTParticiViewController.h"
#import "CMTTagMarker.h"
#import "CMTLiveTagFilterViewController.h"
#import "CMTClient+get_live_message_praiser_list.h"
#import "MWPhotoBrowser.h" //图片浏览器
#import <QuartzCore/QuartzCore.h>

static float const fontsize=14;//字体大小

static float const leftsapce=10;//用于缩进热度，作者头像 和title 文本框
@interface CMTCaseListCell()<CMTTagMarkerDelegte,MWPhotoBrowserDelegate>
//病例描述或问题
@property (nonatomic, strong) UILabel *caseTitleLabel;
//热点标识
@property (nonatomic, strong) UIImageView *heatIcon;
//热点数值
@property (nonatomic, strong) UILabel *heatLabel;
//作者名称
@property (nonatomic, strong) UILabel *authorLabel;
//作者头像
@property(nonatomic,strong)   UIImageView *authorImageView;
//文章类型
@property (nonatomic, strong) UILabel *postTypeLabel;
//专题标识
@property (nonatomic, strong) CMTTextMarker *textMarker;
//病例中是否有图片
@property (nonatomic, strong) CMTImageMarker *imageMarker;
//病例是否有答题
@property (nonatomic, strong) CMTImageMarker *answerImageMarker;
//病例中是否有投票
@property (nonatomic, strong) CMTImageMarker *videoImageMarker;
//cell 上分割线
@property (nonatomic, strong) UIView *topLine;
//cell 下分割线
@property (nonatomic, strong) UIView *bottomLine;
//左侧分割线
@property(nonatomic,strong)UIView *leftLIne;
//右侧分割线
@property(nonatomic,strong)UIView *rightline;
//作者区域
@property(nonatomic,strong)UIView *card_head;
//卡片底部区域(热度、作者、描述、底部背景)
@property(nonatomic,strong)UIView *card_foot;
@property(nonatomic,strong)CardCellModel *cardCellModel;
//小组信息
@property(nonatomic,strong)UIView *teamView;
//参与人员视图
@property(nonatomic,strong)UIControl *partPeopleView;
//评论和点赞
@property(nonatomic,strong)UIView *CommentsAndGreatView;
//病例图片
@property(nonatomic,strong)UIView *casepic;
@property(nonatomic,strong)UIView *spliteline;

/**直播列表Cell显示上面标题，下面来自，最右面是时间*/
@property(nonatomic, strong)UIView *persInfor;
/**专题作者*/
@property(nonatomic, strong)UILabel *specialAuthor;
/**专题发布时间*/
@property(nonatomic, strong)UILabel *specialDate;
/**专题来自*/
@property(nonatomic, strong)UILabel *specialComeFrom;
/**直播标签*/
@property(nonatomic, strong)UIControl *liveTagView;
/**直播标签换行排列View*/
@property(nonatomic, strong)UILabel *TagMarkerView;
/**专题标签左边ICON*/
@property(nonatomic, strong) UIImageView *liveTagLeftImageView;
/**isLive 0不是直播，1直播*/
@property(nonatomic, assign)int isLive;
@property(nonatomic,assign)NSInteger number;//展示的点赞成员数目
/**置顶icon*/
@property(nonatomic, strong)UIImageView *liveTopImageView;
@property(nonatomic,strong)NSString *picFilepath;
//图片放大数组
@property(nonatomic,strong)NSArray *imageArray;


@end

@implementation CMTCaseListCell
- (UILabel *)caseTitleLabel {
    if (_caseTitleLabel == nil) {
        _caseTitleLabel = [[UILabel alloc] init];
        _caseTitleLabel.backgroundColor = COLOR(c_ffffff);
        _caseTitleLabel.textColor = COLOR(c_151515);
        _caseTitleLabel.font = FONT(17.0);
        _caseTitleLabel.numberOfLines = 2;
    }
    
    return _caseTitleLabel;
}
-(CMTTextMarker *)textMarker {
    if (_textMarker == nil) {
        _textMarker = [[CMTTextMarker alloc] init];
        _textMarker.backgroundColor = COLOR(c_clear);
        _textMarker.hidden=YES;
       _textMarker.markerType = CMTTextMarkerTypeTheme;
    }
    
    return _textMarker;
}


- (UIImageView *)heatIcon {
    if (_heatIcon == nil) {
        _heatIcon = [[UIImageView alloc] init];
        _heatIcon.backgroundColor = COLOR(c_clear);
        _heatIcon.image = IMAGE(@"hot_icon");
    }
    
    return _heatIcon;
}

- (UILabel *)heatLabel {
    if (_heatLabel == nil) {
        _heatLabel = [[UILabel alloc] init];
        _heatLabel.backgroundColor = COLOR(c_clear);
        _heatLabel.textColor = COLOR(c_9e9e9e);
        _heatLabel.font = FONT(13.0);
    }
    
    return _heatLabel;
}

- (UILabel *)authorLabel {
    if (_authorLabel == nil) {
        _authorLabel = [[UILabel alloc] init];
        _authorLabel.backgroundColor = COLOR(c_clear);
        _authorLabel.textColor = COLOR(c_9e9e9e);
        _authorLabel.font = FONT(16);
        _authorLabel.userInteractionEnabled=YES;
        UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(SearchAuthortPost)];
        [_authorLabel addGestureRecognizer:tap];

    }
    
    return _authorLabel;
}

- (UILabel *)postTypeLabel {
    if (_postTypeLabel == nil) {
        _postTypeLabel = [[UILabel alloc] init];
        _postTypeLabel.backgroundColor = COLOR(c_clear);
        _postTypeLabel.textColor = COLOR(c_9e9e9e);
        _postTypeLabel.font = FONT(12.0);
    }
    
    return _postTypeLabel;
}

- (CMTImageMarker *)imageMarker {
    if (_imageMarker == nil) {
        _imageMarker = [[CMTImageMarker alloc] init];
        _imageMarker.backgroundColor = COLOR(c_clear);
    }
    
    return _imageMarker;
}
- (CMTImageMarker *)AnswerImageView {
    if (self.answerImageMarker == nil) {
        self.answerImageMarker = [[CMTImageMarker alloc] init];
        self.answerImageMarker.backgroundColor = COLOR(c_clear);
    }
    
    return self.answerImageMarker;
}
- (CMTImageMarker *)videoImageMarker {
    if (_videoImageMarker == nil) {
        _videoImageMarker = [[CMTImageMarker alloc] init];
        _videoImageMarker.backgroundColor = COLOR(c_clear);
        _videoImageMarker.markerType=CMTImageMarkerTypeVideo;
    }
    
    return _videoImageMarker;
}

- (UIView *)spliteline {
    if (_spliteline == nil) {
        _spliteline = [[UIView alloc] init];
        _spliteline.backgroundColor = [UIColor colorWithHexString:@"#F4F4F4"];
    
        
    }
    
    return _spliteline;
}

- (UIView *)topLine {
    if (_topLine == nil) {
        _topLine = [[UIView alloc] init];
        _topLine.backgroundColor = COLOR(c_EBEBEE);
    }
    
    return _topLine;
}

- (UIView *)bottomLine {
    if (_bottomLine == nil) {
        _bottomLine = [[UIView alloc] init];
        _bottomLine.backgroundColor = COLOR(c_EBEBEE);
        
    }
    
    return _bottomLine;
}
-(UIImageView*)authorImageView{
    if (_authorImageView==nil) {
        _authorImageView=[[UIImageView alloc]init];
        _authorImageView.userInteractionEnabled=YES;
        _authorImageView.image=IMAGE(@"ic_default_head");
        _authorImageView.layer.masksToBounds = YES;
        [_authorImageView setContentMode:UIViewContentModeScaleAspectFill];
        [_authorImageView setClipsToBounds:YES];
        UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(SearchAuthortPost)];
        [_authorImageView addGestureRecognizer:tap];

    }
    return _authorImageView;
}
-(UIView*)leftLIne{
    if (_leftLIne==nil) {
        _leftLIne=[[UIView alloc]init];
        _leftLIne.backgroundColor=COLOR(c_EBEBEE);
    }
    return _leftLIne;
}
-(UIView*)rightline{
    if (_rightline==nil) {
        _rightline=[[UIView alloc]init];
        _rightline.backgroundColor=COLOR(c_EBEBEE);
    }
    return _rightline;
}
-(UIView*)card_head{
    if (_card_head==nil) {
        _card_head=[[UIView alloc]init];
        _card_head.backgroundColor=COLOR(c_ffffff);
    }
    return _card_head;
}
-(UIView*)card_foot{
    if (_card_foot==nil) {
        _card_foot=[[UIView alloc]init];
        _card_foot.backgroundColor=COLOR(c_ffffff);

    }
    return _card_foot;
}
-(CardCellModel*)cardCellModel{
    if (_cardCellModel==nil) {
        _cardCellModel=[[CardCellModel alloc]init];
    }
    return _cardCellModel;
}
-(UIControl *)partPeopleView{
    if(_partPeopleView==nil){
        _partPeopleView=[[UIControl alloc]init];
        _partPeopleView.backgroundColor=COLOR(c_ffffff);
    }
    return _partPeopleView;
}
-(UIView*)CommentsAndGreatView{
    if (_CommentsAndGreatView==nil) {
        _CommentsAndGreatView=[[UIView alloc]init];
        _CommentsAndGreatView.backgroundColor=COLOR(c_ffffff);
    }
    return _CommentsAndGreatView;
}
-(UIView*)teamView{
    if (_teamView==nil) {
        _teamView=[[UIView alloc]init];
        _teamView.backgroundColor=COLOR(c_ffffff);
    }
    return _teamView;
}
-(UIView*)casepic{
    if (_casepic==nil) {
        _casepic=[[UIView alloc]init];
        _casepic.backgroundColor=COLOR(c_ffffff);
    }
    return _casepic;
}

-(UIView *)persInfor{
    if(nil == _persInfor){
        _persInfor = [[UIView alloc] init];
        _persInfor.backgroundColor = COLOR(c_ffffff);
    }
    return  _persInfor;
}

-(UILabel *) specialAuthor{
    if(nil == _specialAuthor){
        _specialAuthor = [[UILabel alloc]init];
        _specialAuthor.font = FONT(16);
        _specialAuthor.textColor =  [UIColor colorWithHexString:@"#ef813e"];
    }
    return  _specialAuthor;
}

-(UILabel *) specialDate{
    if(nil == _specialDate){
        _specialDate = [[UILabel alloc]init];
        _specialDate.backgroundColor = COLOR(c_clear);
        _specialDate.textAlignment = NSTextAlignmentRight;
        _specialDate.textColor = COLOR(c_9e9e9e);
        _specialDate.font = FONT(11.0);
    }
    return _specialDate;
}

-(UILabel *) specialComeFrom{
    if(nil == _specialComeFrom){
        _specialComeFrom = [[UILabel alloc]init];
        _specialComeFrom.backgroundColor = COLOR(c_clear);
        _specialComeFrom.textColor = COLOR(c_9e9e9e);
        _specialComeFrom.font = FONT(11.0);
    }
    return _specialComeFrom;
}

-(UIControl *) liveTagView{
    if(nil == _liveTagView){
        _liveTagView = [[UIControl alloc] init];
        _liveTagView.backgroundColor = COLOR(c_ffffff);
        _liveTagView.layer.cornerRadius=5;
        [_liveTagView addTarget:self action:@selector(ClickTag) forControlEvents:UIControlEventTouchUpInside];
    }
    return _liveTagView;
}

//关注的标签管理视图
-(UILabel *)TagMarkerView{
    if (_TagMarkerView==nil) {
        _TagMarkerView=[[UILabel alloc]init];
        [_TagMarkerView setBackgroundColor:[UIColor colorWithHexString:@"#A8BFDC"]];
        _TagMarkerView.lineBreakMode=NSLineBreakByCharWrapping;
//        _TagMarkerView.textAlignment=NSTextAlignmentLeft;
        _TagMarkerView.font=[UIFont systemFontOfSize:fontsize];
        _TagMarkerView.textColor = [UIColor whiteColor ];
        _TagMarkerView.tag=1000;
        _TagMarkerView.numberOfLines=0;
        _TagMarkerView.layer.cornerRadius=5;
        _TagMarkerView.layer.masksToBounds=YES;
    }
    return _TagMarkerView;
}

-(UIImageView *)liveTagLeftImageView{
    if(nil == _liveTagLeftImageView){
        _liveTagLeftImageView = [[UIImageView alloc] init];
        _liveTagLeftImageView.backgroundColor = COLOR(c_ffffff);
        _liveTagLeftImageView.image = [UIImage imageNamed:@"ic_left_live_tag"];
    }
    return _liveTagLeftImageView;
}

-(UIImageView *)liveTopImageView{
    if(nil == _liveTopImageView){
        _liveTopImageView = [[UIImageView alloc]init];
        _liveTopImageView.image = IMAGE(@"ic_live_Top");
    }
    return _liveTopImageView;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self){
        self.ISCanShowBigImage=YES;
        self.isShowinteractive=YES;
        self.isSearch=NO;
        self.insets=UIEdgeInsetsMake(5,10,5,10);
        self.backgroundColor=COLOR(c_efeff4);
        [self.contentView addSubview:self.card_head];
        [self.contentView addSubview:self.card_foot];
        [self.contentView addSubview:self.teamView];
        [self.contentView addSubview:self.caseTitleLabel];
        [self.contentView addSubview:self.textMarker];
        [self.contentView addSubview:self.heatIcon];
        [self.contentView addSubview:self.heatLabel];
        [self.contentView addSubview:self.authorLabel];
        [self.contentView addSubview:self.postTypeLabel];
        [self.contentView addSubview:self.imageMarker];
        [self.contentView addSubview:self.AnswerImageView];
        [self.contentView addSubview:self.authorImageView];
        [self.contentView addSubview:self.casepic];
        [self.contentView addSubview:self.spliteline];
        [self.contentView addSubview:self.CommentsAndGreatView];
        [self.contentView addSubview:self.partPeopleView];
        [self.contentView addSubview:self.topLine];
        [self.contentView addSubview:self.bottomLine];
        [self.contentView addSubview:self.rightline];
        [self.contentView addSubview:self.leftLIne];
        [self.contentView addSubview:self.persInfor];
        //专题名字添加到专题的View上
        [self.persInfor addSubview:self.specialAuthor];
        [self.persInfor addSubview:self.specialDate];
        [self.persInfor addSubview:self.specialComeFrom];
        //专题标签
        [self.contentView addSubview:self.liveTagView];
        //专题标签左侧icon
        [self.liveTagView addSubview:self.liveTagLeftImageView];
        //置顶icon
        [self.contentView addSubview:self.liveTopImageView];
       
    }
    return self;
}



//刷新cell坐标和内容，普通的病例Cell
- (void)reloadCaseCell:(CMTPost*)post index:(NSIndexPath*)indexpath {
    if (self.ishaveSectionHeadView&&indexpath.row==0) {
         self.insets=UIEdgeInsetsMake(0,10,5,10);
    }else{
        self.insets=UIEdgeInsetsMake(5,10,5,10);

    }
    self.cardCellModel.cellId = post.postId;
    self.cardCellModel.themeStatus = post.themeStatus;
    self.cardCellModel.participators = post.participators;
    self.cardCellModel.imageList = post.imageList;
    self.cardCellModel.author = post.author;
    self.cardCellModel.authorId = post.authorId;
    self.cardCellModel.authorPic = post.authorPic;
    self.cardCellModel.groupId = post.groupId;
    self.cardCellModel.groupName = post.groupName;
    self.cardCellModel.picture = post.picture;
    self.cardCellModel.commentCount = post.commentCount;
    self.cardCellModel.isPraise = post.isPraise;
    self.cardCellModel.praiseCount = post.praiseCount;
    self.cardCellModel.postType = post.postType;
    self.cardCellModel.postAttr = post.postAttr;
    self.cardCellModel.heat = post.heat;
    self.cardCellModel.title = post.title;
    self.cardCellModel.topFlag = post.topFlag;
    
    [self reloadCardCell:self.cardCellModel index:indexpath isLive:0];
}

-(void)reloadLiveCell:(CMTLive *)live index:(NSIndexPath *)indexpath{
    if (indexpath.row==0) {
        self.insets=UIEdgeInsetsMake(0,0,5,0);

    }else{
        self.insets=UIEdgeInsetsMake(5,0,5,0);

    }
    
    self.cardCellModel.cellId = live.liveBroadcastId;
    self.cardCellModel.themeStatus = @"";
    self.cardCellModel.participators = live.praiseUserList;
    self.cardCellModel.imageList = live.pictureList;
    self.cardCellModel.author = live.createUserName;
    self.cardCellModel.authorId = live.createUserId;
    self.cardCellModel.authorPic = live.createUserPic;
    self.cardCellModel.groupId = @"";
    self.cardCellModel.groupName = @"";
    self.cardCellModel.picture = @"";
    self.cardCellModel.commentCount = live.commentCount;
    self.cardCellModel.isPraise = live.isPraise;
    self.cardCellModel.praiseCount = live.praiseCount;
    self.cardCellModel.postType = @"";
    self.cardCellModel.postAttr = @"";
    self.cardCellModel.heat = @"";
    self.cardCellModel.title = live.content;
    self.cardCellModel.createTime = live.createTime;
    self.cardCellModel.createUserDesc = live.createUserDesc;
    self.cardCellModel.hasTags = live.hasTags;
    self.cardCellModel.liveBroadcastTag = live.liveBroadcastTag;
    self.cardCellModel.topFlag = live.topFlag;
    self.cardCellModel.isOfficial = live.isOfficial;
    self.cardCellModel.liveBroadcastMessageId=live.liveBroadcastMessageId;
    
    [self reloadCardCell:self.cardCellModel index:indexpath isLive:1 ];
}

//刷新cell坐标和内容
//@param isLive 0不是直播，1直播
- (void)reloadCardCell:(CardCellModel *)cellModel index:(NSIndexPath*)indexpath isLive : (int) isLive{
    
    self.isLive = isLive;
    
    if (0 == isLive && indexpath.section==1&&indexpath.row==0) {
        self.insets=UIEdgeInsetsMake(5,10,5,10);
    }
    if (self.isLivedetails) {
        self.insets=UIEdgeInsetsMake(0,0,0,0);

    }
    self.indexPath=indexpath;
    self.cardCellModel=cellModel;
    self.imageMarker.hidden = YES;
    self.answerImageMarker.hidden = YES;
    self.videoImageMarker.hidden = YES;
     //上边线
    self.topLine.frame=CGRectMake(self.insets.left, self.insets.top-1,SCREEN_WIDTH-self.insets.left*2+2, 1);
    if (cellModel.groupId.integerValue==0) {
      self.teamView.frame=CGRectMake(self.insets.left, self.topLine.bottom,SCREEN_WIDTH-self.insets.left*2+2, 0);
        for (UIView *view in [self.teamView subviews]) {
            view.hidden=YES;
            
        }

    }else{
       self.teamView.frame=CGRectMake(self.insets.left, self.topLine.bottom,SCREEN_WIDTH-self.insets.left*2+2, 40);
      [self DrawTeamView];
    }
    //作者头像和名称
    self.authorImageView.frame=CGRectMake(self.insets.left+10,self.teamView.bottom+10, 40, 40);
     _authorImageView.layer.cornerRadius = _authorImageView.frame.size.height/2;
    _authorImageView.clipsToBounds=YES;
    [self.authorImageView setQuadrateScaledImageURL:cellModel.authorPic placeholderImage:IMAGE(@"ic_default_head") width:40.0];
    self.authorLabel.text=!isEmptyObject(cellModel.author)?cellModel.author:@"";
    self.authorLabel.frame=CGRectMake(self.authorImageView.right+10, self.authorImageView.top,SCREEN_WIDTH-self.authorImageView.right-self.insets.right-10, self.authorImageView.height);
    
    //直播列表Cell显示上面标题，下面来自，最右面是时间
    NSString *specialComeFromString = self.cardCellModel.createUserDesc;
    self.persInfor.frame = CGRectMake(self.authorImageView.right, self.authorImageView.top,SCREEN_WIDTH-self.authorImageView.right-self.insets.right-10, self.authorImageView.height);
    int persInforHeight =self.persInfor.height/2;
    int specialDateHeight = self.persInfor.height/2;
    int specialDateY = specialDateHeight;
    if([self isBlankString:specialComeFromString]){
        persInforHeight = self.persInfor.height;
        specialDateHeight = self.persInfor.height;
        specialDateY = 0;
    }
    //专题发布时间
    self.specialDate.frame = CGRectMake(self.persInfor.width-90, specialDateY, 90, specialDateHeight);
    if([@"1" isEqualToString:self.cardCellModel.topFlag]&&!self.isLivedetails){
        self.specialDate.text = [NSDate dateFormatPattern:@"yyyy-MM-dd" TimeStamp:self.cardCellModel.createTime];
    }else{
        self.specialDate.text = PASSED_DATE(self.cardCellModel.createTime);
    }
    //专题作者名字
    self.specialAuthor.frame = CGRectMake(10,  0, self.persInfor.width-self.specialDate.width-10,  [cellModel.isOfficial isEqualToString:@"1"]?persInforHeight:self.persInfor.height);
    self.specialAuthor.text=!isEmptyObject(cellModel.author)?cellModel.author:@"";
    if(nil != cellModel.isOfficial && [cellModel.isOfficial isEqualToString:@"1"]){
        self.specialAuthor.textColor =  [UIColor colorWithHexString:@"#ef813e"];
    }else{
        self.specialAuthor.textColor =  [UIColor colorWithHexString:@"#424242"];
    }
    //专题来自XXX
    self.specialComeFrom.frame = CGRectMake(10,  self.specialAuthor.height, self.persInfor.width-self.specialDate.width-10,  [cellModel.isOfficial isEqualToString:@"1"]?self.persInfor.height/2:0);
    self.specialComeFrom.text = [cellModel.isOfficial isEqualToString:@"1"]?specialComeFromString:@" ";
    
    //直播标签
        self.liveTagLeftImageView.frame = CGRectMake(self.authorImageView.left, 5, 20, 20);
    
        self.TagMarkerView.frame = CGRectMake(self.liveTagLeftImageView.right+8, 0, SCREEN_WIDTH-2*(self.insets.left+1)-self.liveTagLeftImageView.right-8-self.authorImageView.left, 0);
    if (self.isLive==1) {
        if (cellModel.liveBroadcastTag.liveBroadcastTagId.integerValue>0) {
            
             float tagHeight=[CMTGetStringWith_Height getTextheight:self.cardCellModel.liveBroadcastTag.name fontsize:fontsize width:self.TagMarkerView.width]+10;
            [self drawLiveTagView];
            self.liveTagView.frame = CGRectMake(0, self.authorImageView.bottom+5, SCREEN_WIDTH-2*self.insets.left, tagHeight);
        } else {
            self.liveTagLeftImageView.frame = CGRectMake(self.authorImageView.left, 5, 20,0);
            for (UIView *view in [self.TagMarkerView subviews]) {
                [view removeFromSuperview];
            }
            self.liveTagView.frame = CGRectMake(0, self.authorImageView.bottom, SCREEN_WIDTH-2*self.insets.left, 0);
            
            
        }

        
    }
    
    
    if(1 == isLive){
        //是直播
        self.authorLabel.hidden = YES;
        self.persInfor.hidden = NO;
        self.liveTagView.hidden = NO;
        if((nil == ((CMTLive *)self.cardCellModel.liveBroadcastTag).liveBroadcastTagId)
           || ([@"0" isEqualToString:((CMTLive *)self.cardCellModel.liveBroadcastTag).liveBroadcastTagId])){
            self.liveTagView.hidden = YES;
            self.liveTagView.frame = CGRectMake(self.insets.left+1, self.authorImageView.bottom, SCREEN_WIDTH-2*self.insets.left, 0);
        }
    }else{
        self.authorLabel.hidden = NO;
        self.persInfor.hidden = YES;
        self.liveTagView.hidden = YES;
        self.liveTagView.frame = CGRectMake(self.insets.left+1, self.authorImageView.bottom, SCREEN_WIDTH-2*self.insets.left, 0);
    }

    
    //病例说明
     float height=[CMTGetStringWith_Height getTextheight:!isEmptyObject(cellModel.title)?cellModel.title:@"" fontsize:17 width:SCREEN_WIDTH-self.insets.left*2-2-leftsapce]+30;
    self.caseTitleLabel.frame= CGRectMake(self.insets.left+leftsapce+1, self.liveTagView.bottom, SCREEN_WIDTH-self.insets.left*2-2-leftsapce, self.isLivedetails?height:47);
    if(self.isLivedetails){
        self.caseTitleLabel.numberOfLines=0;
        self.caseTitleLabel.lineBreakMode=NSLineBreakByWordWrapping;
    }
    
    //修改标题颜色
    if (isLive == 0) {
        if (cellModel.topFlag.integerValue == 1&&!self.isSearch) {
            self.caseTitleLabel.text = !isEmptyObject(cellModel.title)?[NSString stringWithFormat:@"【置顶】%@",cellModel.title]:@"";
            NSRange range = [self.caseTitleLabel.text rangeOfString:@"【置顶】"];
            NSMutableAttributedString *pStr = [[NSMutableAttributedString alloc]initWithString:self.caseTitleLabel.text];
            [pStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"#3bc6c1"] range:range];
            self.caseTitleLabel.attributedText = pStr;
        }else{
            self.caseTitleLabel.text=!isEmptyObject(cellModel.title)?cellModel.title:@"";
            if(self.isSearch){
                NSRange range2 = [ self.caseTitleLabel.text rangeOfString:self.searchkey];
                NSMutableAttributedString *pStr = [[NSMutableAttributedString alloc]initWithString:self.caseTitleLabel.text];
                [pStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"#3bc6c1"] range:range2];
                self.caseTitleLabel.attributedText = pStr;

            }
        }
    }else{
        self.caseTitleLabel.text=!isEmptyObject(cellModel.title)?cellModel.title:@"";
    };
    
    //cell头
    self.card_head.frame=CGRectMake(self.insets.left+1, self.teamView.top, SCREEN_WIDTH-self.insets.left*2, self.caseTitleLabel.bottom);
    //绘制病例图片
    if([cellModel.imageList count]>0){
       self.casepic.frame=CGRectMake(self.insets.left+1, self.caseTitleLabel.bottom, SCREEN_WIDTH-self.insets.left*2, 20);
       [self DrawCasepicView];
    }else{
        self.casepic.frame=CGRectMake(self.insets.left+1, self.caseTitleLabel.bottom, SCREEN_WIDTH-self.insets.left*2, 0);
        for (NSInteger i=0; i<[self.casepic subviews].count; i++) {
            ((UIImageView*)[[self.casepic subviews]objectAtIndex:i]).hidden=YES;
        }
        
    }
    
    if (cellModel.themeStatus.integerValue==2) {
        self.textMarker.frame = CGRectMake(self.insets.left+leftsapce,self.casepic.bottom+5, self.textMarker.markerSize.width, self.textMarker.markerSize.height);
        self.textMarker.hidden=NO;
        //热度
        self.heatIcon.frame = CGRectMake(self.textMarker.right+leftsapce,self.casepic.bottom+5, 20, 10);
        //self.heatIcon.centerY = self.textMarker.centerY;
    }else{
        self.textMarker.hidden=YES;
        //热度
        self.heatIcon.frame = CGRectMake(self.insets.left+leftsapce,self.casepic.bottom+5+(13.5/2-5), 20, 10);
    }
    // heatLabel
    self.heatLabel.frame = CGRectMake(self.heatIcon.right + 2.0,self.casepic.bottom+4, 100*RATIO, 12.0);
    self.heatLabel.centerY = self.heatIcon.centerY;
    self.heatLabel.text=!isEmptyObject(cellModel.heat)?cellModel.heat:@"";
    
        self.postTypeLabel.frame = CGRectMake(SCREEN_WIDTH - 0-self.insets.right-5,self.casepic.bottom+5, 0, 13.0);
    if ([cellModel.postAttr isPostAttrPDF]) {
        self.imageMarker.markerType = CMTImageMarkerTypePDF;
        self.imageMarker.frame=CGRectMake(self.postTypeLabel.left-(5+self.imageMarker.markerSize.width),self.casepic.bottom+3,self.imageMarker.markerSize.height,self.imageMarker.markerSize.height);
        self.imageMarker.hidden=NO;
    }
    //投票或者答题或者视频
    if (((([cellModel.postAttr isPostAttrVote]||[cellModel.postAttr isPostAttrAnswer])&&![cellModel.postAttr isPostAttrVideo])||(!([cellModel.postAttr isPostAttrVote]||[cellModel.postAttr isPostAttrAnswer])&&[cellModel.postAttr isPostAttrVideo]))&&![cellModel.postAttr isPostAttrPDF]) {
        if ([cellModel.postAttr isPostAttrAnswer]) {
            self.imageMarker.markerType = CMTImageMarkerTypeAnswer;
            
        }else if([cellModel.postAttr isPostAttrVote]){
             self.imageMarker.markerType = CMTImageMarkerTypeVote;
        }else{
            if((![cellModel.postAttr isPostAttrOnlyVideo]&&[cellModel.postAttr isPostAttrAudio])){
                self.imageMarker.markerType=CMTImageMarkerTypeAudio;
            }else{
                self.imageMarker.markerType=CMTImageMarkerTypeVideo;
            }
        }
        self.imageMarker.frame=CGRectMake(self.postTypeLabel.left-(5+self.imageMarker.markerSize.width),self.casepic.bottom+3,self.imageMarker.markerSize.height,self.imageMarker.markerSize.height);
        self.imageMarker.hidden=NO;
    }
    //投票或者答题
    if ([cellModel.postAttr isPostAttrPDF]) {
        if ((([cellModel.postAttr isPostAttrVote]||[cellModel.postAttr isPostAttrAnswer])&&![cellModel.postAttr isPostAttrVideo])||(!([cellModel.postAttr isPostAttrVote]||[cellModel.postAttr isPostAttrAnswer])&&[cellModel.postAttr isPostAttrVideo])){
            if ([cellModel.postAttr isPostAttrAnswer]) {
                self.AnswerImageView.markerType = CMTImageMarkerTypeAnswer;
                
            }else if([cellModel.postAttr isPostAttrVote]){
                self.AnswerImageView.markerType =CMTImageMarkerTypeVote;
            }else{
                if((![cellModel.postAttr isPostAttrOnlyVideo]&&[cellModel.postAttr isPostAttrAudio])){
                    self.answerImageMarker.markerType=CMTImageMarkerTypeAudio;
                }else{
                    self.answerImageMarker.markerType=CMTImageMarkerTypeVideo;
                }

            }
            self.AnswerImageView.frame=CGRectMake(self.imageMarker.left-(5+self.AnswerImageView.markerSize.width),self.casepic.bottom+3,self.AnswerImageView.markerSize.height,self.AnswerImageView.markerSize.height);
            self.AnswerImageView.hidden=NO;

            
        } else if((([cellModel.postAttr isPostAttrVote]||[cellModel.postAttr isPostAttrAnswer])&&[cellModel.postAttr isPostAttrVideo])&&[cellModel.postAttr isPostAttrPDF]){
                if ([cellModel.postAttr isPostAttrAnswer]) {
                    self.AnswerImageView.markerType = CMTImageMarkerTypeAnswer;
                    
                }else if([cellModel.postAttr isPostAttrVote]){
                    self.AnswerImageView.markerType =CMTImageMarkerTypeVote;
                }
       
        self.AnswerImageView.frame=CGRectMake(self.imageMarker.left-(5+self.AnswerImageView.markerSize.width),self.casepic.bottom+3,self.AnswerImageView.markerSize.height,self.AnswerImageView.markerSize.height);
        self.AnswerImageView.hidden=NO;
        self.videoImageMarker.frame=CGRectMake(self.answerImageMarker.left-(5+self.videoImageMarker.markerSize.width),self.casepic.bottom+3,self.videoImageMarker.markerSize.height,self.videoImageMarker.markerSize.height);
        self.videoImageMarker.hidden=NO;
        if((![cellModel.postAttr isPostAttrOnlyVideo]&&[cellModel.postAttr isPostAttrAudio])){
                self.videoImageMarker.markerType=CMTImageMarkerTypeAudio;
            }else{
                self.videoImageMarker.markerType=CMTImageMarkerTypeVideo;
            }
      }
    }else if((([cellModel.postAttr isPostAttrVote]||[cellModel.postAttr isPostAttrAnswer])&&[cellModel.postAttr isPostAttrVideo])){
        if ([cellModel.postAttr isPostAttrAnswer]) {
            self.imageMarker.markerType = CMTImageMarkerTypeAnswer;
            
        }else if([cellModel.postAttr isPostAttrVote]){
            self.imageMarker.markerType =CMTImageMarkerTypeVote;
        }
        self.imageMarker.frame=CGRectMake(self.postTypeLabel.left-(5+self.imageMarker.markerSize.width),self.casepic.bottom+3,self.imageMarker.markerSize.height,self.imageMarker.markerSize.height);
        self.imageMarker.hidden=NO;
        if((![cellModel.postAttr isPostAttrOnlyVideo]&&[cellModel.postAttr isPostAttrAudio])){
            self.answerImageMarker.markerType=CMTImageMarkerTypeAudio;
        }else{
            self.answerImageMarker.markerType=CMTImageMarkerTypeVideo;
        }
        self.AnswerImageView.frame=CGRectMake(self.imageMarker.left-(5+self.AnswerImageView.markerSize.width),self.casepic.bottom+3,self.AnswerImageView.markerSize.height,self.AnswerImageView.markerSize.height);
        self.AnswerImageView.hidden=NO;
        
    }
    if(1 == isLive){
        //是直播隐藏投票答题热度等标签
        self.textMarker.frame = CGRectMake(self.insets.left+leftsapce,self.casepic.bottom+5, self.textMarker.markerSize.width, 0);
        //热度
        self.heatIcon.frame = CGRectMake(self.textMarker.right+leftsapce,self.casepic.bottom+5, 13.0, 0);
        self.heatLabel.frame = CGRectMake(self.heatIcon.right + 2.0,self.casepic.bottom+5, 38.0*RATIO, 0);
        self.postTypeLabel.frame = CGRectMake(0,0, 0, 0);
        self.imageMarker.frame=CGRectMake(self.postTypeLabel.left-(5+self.imageMarker.markerSize.width),self.casepic.bottom+3,self.imageMarker.markerSize.height,0);
        self.AnswerImageView.frame=CGRectMake(self.imageMarker.left-(5+self.AnswerImageView.markerSize.width),self.casepic.bottom+3,self.AnswerImageView.markerSize.height,0);
          self.videoImageMarker.frame=CGRectMake(self.answerImageMarker.left-(5+self.videoImageMarker.markerSize.width),self.casepic.bottom+3,self.videoImageMarker.markerSize.height,0);
        self.card_foot.frame=CGRectMake(self.insets.left+1, self.casepic.bottom, SCREEN_WIDTH-self.insets.left*2,0);
    }else {
        //设置卡片底部
        self.card_foot.frame=CGRectMake(self.insets.left+1, self.casepic.bottom, SCREEN_WIDTH-self.insets.left*2,15+leftsapce+1);
    }
  
    //绘制参与的小组成员图片
    float partPeopleViewheight=((SCREEN_WIDTH-self.insets.left*2-2)-120)/11;
     if(SCREEN_WIDTH>414){
        partPeopleViewheight=40;
     }

    if ([cellModel.participators count]==0||(!self.isShowinteractive&&!self.isLivedetails)) {
        self.spliteline.frame=CGRectMake(self.insets.left+20,  self.card_foot.bottom, SCREEN_WIDTH-self.insets.left*2-19,0);
         self.partPeopleView.frame=CGRectMake(self.insets.left+1, self.spliteline.bottom-1,SCREEN_WIDTH-self.insets.left*2,0);
        for (UIView *view in [self.partPeopleView subviews]) {
            view.hidden=YES;
        }

    }else{
          self.spliteline.frame=CGRectMake(self.insets.left+20,  self.card_foot.bottom-1, self.card_foot.width-19,0.8);
       self.partPeopleView.frame=CGRectMake(self.insets.left+1, self.spliteline.bottom,SCREEN_WIDTH-self.insets.left*2,partPeopleViewheight+leftsapce*2);
        [self drawpartPeopleView];
    }
    //设置评论和点赞按钮、分享按钮
    if (self.isShowinteractive) {
        self.CommentsAndGreatView.frame=CGRectMake(self.insets.left+1,self.partPeopleView.bottom, SCREEN_WIDTH-self.insets.left*2,35);
        [self drawCommentsAndGreatView : self.isLive];
    }else{
        self.CommentsAndGreatView.frame=CGRectMake(self.insets.left+1,self.partPeopleView.bottom, SCREEN_WIDTH-self.insets.left*2,0);
        for (UIView *view in [self.CommentsAndGreatView subviews]) {
            [view removeFromSuperview];
            
        }
    }
    
    //设置左右下边线
    self.leftLIne.frame=CGRectMake(self.topLine.left,self.topLine.bottom, 1,self.CommentsAndGreatView.bottom-self.insets.bottom);
    self.rightline.frame=CGRectMake(self.topLine.right-1,self.topLine.bottom, 1,self.CommentsAndGreatView.bottom-self.insets.bottom);
    if(1 == self.isLive){
        self.bottomLine.frame=CGRectMake(self.topLine.left, self.CommentsAndGreatView.bottom,self.topLine.width, 0);
    }else{
        self.bottomLine.frame=CGRectMake(self.topLine.left, self.CommentsAndGreatView.bottom,self.topLine.width, 1);
    }

    //置顶标志
    if (isLive == 1) {
        if([@"1" isEqualToString:self.cardCellModel.topFlag]&&!self.isLivedetails){
            self.liveTopImageView.frame = CGRectMake(SCREEN_WIDTH-self.liveTopImageView.image.size.width, self.insets.top+1, self.liveTopImageView.image.size.width, self.liveTopImageView.image.size.height );
        }else{
            self.liveTopImageView.frame = CGRectMake(SCREEN_WIDTH-self.liveTopImageView.image.size.width, self.insets.top+1, self.liveTopImageView.image.size.width, 0 );
        }
    }
    
    
  //设置cell 大小
    self.frame=CGRectMake(0, 0, SCREEN_WIDTH,self.CommentsAndGreatView.bottom+self.insets.bottom);
}

//更改底部位置坐标 用于直播详情
-(void)drawFootCart{
    if (self.isShowinteractive) {
        self.CommentsAndGreatView.frame=CGRectMake(self.insets.left+1,self.partPeopleView.bottom, SCREEN_WIDTH-self.insets.left*2,35);
    }else{
        self.CommentsAndGreatView.frame=CGRectMake(self.insets.left+1,self.partPeopleView.bottom, SCREEN_WIDTH-self.insets.left*2,0);
        for (UIView *view in [self.CommentsAndGreatView subviews]) {
            [view removeFromSuperview];
            
        }
    }

    //设置左右下边线
    self.leftLIne.frame=CGRectMake(self.topLine.left,self.topLine.bottom, 1,self.CommentsAndGreatView.bottom-self.insets.bottom);
    self.rightline.frame=CGRectMake(self.topLine.right-1,self.topLine.bottom, 1,self.CommentsAndGreatView.bottom-self.insets.bottom);
    self.bottomLine.frame=CGRectMake(self.topLine.left, self.CommentsAndGreatView.bottom,self.topLine.width, 0);
    //设置cell 大小
    self.frame=CGRectMake(0, 0, SCREEN_WIDTH,self.CommentsAndGreatView.bottom+self.insets.bottom);

    
  }
- (BOOL) isBlankString:(NSString *)string {
    if (string == nil || string == NULL) {
               return YES;
    }
    if ([string isKindOfClass:[NSNull class]]) {
               return YES;
    }
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
        return YES;
    }
    return NO;
    
}

-(void)drawLiveTagView{
    if (self.cardCellModel.liveBroadcastTag.liveBroadcastTagId!=nil) {
        self.TagMarkerView.text =self.cardCellModel.liveBroadcastTag.name;
        float width=[CMTGetStringWith_Height CMTGetLableTitleWith:self.cardCellModel.liveBroadcastTag.name fontSize:fontsize]+10;
        if(width>self.TagMarkerView.width){
            self.TagMarkerView.textAlignment=NSTextAlignmentLeft;
        }else{
             self.TagMarkerView.textAlignment=NSTextAlignmentCenter;
        }
        width=width>self.TagMarkerView.width?self.TagMarkerView.width:width;
        float tagHeight=[CMTGetStringWith_Height getTextheight:self.cardCellModel.liveBroadcastTag.name fontsize:fontsize width:width]+10;
        self.TagMarkerView.frame=CGRectMake(self.liveTagLeftImageView.right+8, 0, width, tagHeight);
        if ([self.liveTagView viewWithTag:1000]==nil) {
          [self.liveTagView addSubview:self.TagMarkerView];
        }

    }
    
}

//绘制病例图片
-(void)DrawCasepicView{
    for (NSInteger i=[self.cardCellModel.imageList count]; i<[self.casepic subviews].count; i++) {
        ((UIImageView*)[[self.casepic subviews]objectAtIndex:i]).hidden=YES;
    }

    float casepicheight=(self.casepic.width-50)/4;
    if([self.cardCellModel.imageList count]==1){
        casepicheight=(casepicheight*3+20+10)/2;

    }else if([self.cardCellModel.imageList count]==2||[self.cardCellModel.imageList count]==4){
        casepicheight=(casepicheight*3+10)/2;
    }
    NSInteger number=[self.cardCellModel.imageList count]>9?9:[self.cardCellModel.imageList count];
    for (int i=0; i<number; i++) {
        CMTPicture *caseimage=[self.cardCellModel.imageList objectAtIndex:i];
        int xsplacenumber=number==4?(i%2)+1:(i%3)+1;
        int yspacenumber=number==4?(i/2)+1:((int)(i/3))+1;
        UIImageView *imageview=(UIImageView*)[self.casepic viewWithTag:i+1];
        if (imageview==nil) {
           imageview=[[UIImageView alloc]initWithFrame:CGRectMake(10*xsplacenumber+casepicheight*(xsplacenumber-1),yspacenumber*10+casepicheight*(yspacenumber-1), casepicheight, casepicheight)];
            imageview.contentMode=UIViewContentModeScaleAspectFill;
            imageview.clipsToBounds=YES;
            imageview.tag=i+1;

        }else{
            imageview.frame=CGRectMake(10*xsplacenumber+casepicheight*(xsplacenumber-1),yspacenumber*10+casepicheight*(yspacenumber-1), casepicheight, casepicheight);
            imageview.tag=i+1;
        }
        imageview.hidden=NO;
        [imageview setLimitedImageURL:caseimage.picFilepath placeholderImage:IMAGE(@"placeholder_list_loading") contentSize:CGSizeMake(casepicheight, casepicheight)];
        [self.casepic addSubview:imageview];
        if(self.ISCanShowBigImage){
         UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(Showpic:)];
         [imageview addGestureRecognizer:tap];
           imageview.userInteractionEnabled=YES;
        }
        self.casepic.frame=CGRectMake(self.casepic.left, self.casepic.top, self.casepic.width,imageview.bottom+10);
       
    }
   }
//查询作者文章
-(void)SearchAuthortPost{
    if(0 ==self.isLive){
        CMTOtherPostListViewController *otherPostListViewController = [[CMTOtherPostListViewController alloc]
                                                                   initWithAuthor:self.cardCellModel.author authorId:self.cardCellModel.authorId];
        [self.lastController.navigationController pushViewController:otherPostListViewController animated:YES];
    }
}
//绘制小组信息
-(void)DrawTeamView{
    UIView *view=[self.teamView viewWithTag:101];
    if (view==nil) {
       view=[[UIView alloc]initWithFrame:CGRectMake(20, self.teamView.height-1, self.teamView.width-20,1)];
        view.backgroundColor = [UIColor colorWithHexString:@"#F8F8F8"];
        view.tag=100+1;
        [self.teamView addSubview:view];
    }

   
    UILabel *teamTitlable=(UILabel*)[self.teamView viewWithTag:102];
    if (teamTitlable==nil) {
        teamTitlable=[[UILabel alloc]initWithFrame:CGRectMake(10, 0, self.teamView.width-40, self.teamView.height)];
      
        teamTitlable.font=[UIFont systemFontOfSize:15];
        teamTitlable.textColor=[UIColor colorWithHexString:@"#ACACAC"];
        teamTitlable.textAlignment=NSTextAlignmentRight;
        teamTitlable.tag=100+2;
        [self.teamView addSubview:teamTitlable];
    }
    teamTitlable.text=!isEmptyObject(self.cardCellModel.groupName)?self.cardCellModel.groupName:@"";
    
     UIImageView *image=(UIImageView*)[self.teamView viewWithTag:103];
     if (image==nil) {
       image=[[UIImageView alloc]initWithFrame:CGRectMake(self.teamView.width-25,10, 20, 20)];
        image.contentMode=UIViewContentModeScaleAspectFill;
        image.clipsToBounds=YES;
        image.tag=100+3;
        [self.teamView addSubview:image];
     }
     [image setImageURL:self.cardCellModel.picture placeholderImage:IMAGE(@"ic_default_head")contentSize:CGSizeMake(20, 20)];
     view.hidden=NO;
     teamTitlable.hidden=NO;
     image.hidden=NO;
 }
    //绘制partPeopleView
-(void)drawpartPeopleView{
    if (self.isLive==0) {
        [_partPeopleView addTarget:self action:@selector(showPartitics) forControlEvents:UIControlEventTouchUpInside];
    }else{
              _partPeopleView.userInteractionEnabled=self.isLivedetails;
    }
    
    if(self.isLivedetails){
        [self drawlivePraiseMember:self.cardCellModel.participators.count>=32?self.cardCellModel.participators.count+1:self.cardCellModel.participators.count];
        return;
    }else{
        NSInteger number=[self.cardCellModel.participators count]>=11?11:[self.cardCellModel.participators count];
        NSInteger imagenumber=(number<=10?10:11);
        float partPeopleViewheight=((SCREEN_WIDTH-self.insets.left*2-2)-10*(imagenumber+1))/imagenumber;
        float space=10;
        if(SCREEN_WIDTH>414){
            partPeopleViewheight=40;
            space=((SCREEN_WIDTH-self.insets.left*2-2)-partPeopleViewheight*imagenumber)/(imagenumber+1);
        }
        for (NSInteger i=[self.cardCellModel.participators count]; i<[self.partPeopleView subviews].count; i++) {
            ((UIImageView*)[[self.partPeopleView subviews]objectAtIndex:i]).hidden=YES;
        }
        for (int i=0; i<=number-1;i++) {
            UIImageView *imageview=(UIImageView*)[self.partPeopleView viewWithTag:i+1];
            if (imageview==nil) {
              imageview=[[UIImageView alloc]initWithFrame:CGRectMake(space*(i+1)+partPeopleViewheight*i,leftsapce-2, partPeopleViewheight, partPeopleViewheight)];
                imageview.layer.cornerRadius =partPeopleViewheight/2;
                imageview.contentMode=UIViewContentModeScaleAspectFill;
                imageview.layer.masksToBounds=YES;
                imageview.tag=i+1;

            }else{
                imageview.frame=CGRectMake(space*(i+1)+partPeopleViewheight*i,leftsapce-2, partPeopleViewheight, partPeopleViewheight);
            }
            if(imageview.hidden){
               imageview.hidden=NO;
            }
          if (i==10) {
                [imageview setImageURL:nil placeholderImage:IMAGE(@"caseMore") contentSize:CGSizeMake(partPeopleViewheight, partPeopleViewheight)];
            }else{
                CMTParticiPators *Part=((CMTParticiPators*)[self.cardCellModel.participators objectAtIndex:i]);
                if (Part.userType.integerValue==1) {
                    [imageview setImageURL:Part.picture placeholderImage:IMAGE(@"ic_default_head") contentSize:CGSizeZero];

                }else{

                      [imageview setLimitedImageURL:Part.picture placeholderImage:IMAGE(@"ic_default_head") contentSize:CGSizeMake(partPeopleViewheight, partPeopleViewheight)];
                }
              }
            [self.partPeopleView addSubview:imageview];
        }
    }
    
}
#pragma 绘制点赞成员列表
-(void)drawlivePraiseMember:(NSInteger)imagenumber{
    float partPeopleViewheight=((SCREEN_WIDTH-self.insets.left*2-2)-10*(12))/11;
    float space=10;
    if(SCREEN_WIDTH>414){
        partPeopleViewheight=40;
        space=((SCREEN_WIDTH-self.insets.left*2-2)-partPeopleViewheight*11)/12;
    }

    for (int i=0; i<=imagenumber-1;i++) {
        
        int xsplacenumber=(i%11)+1;
        int yspacenumber=((int)(i/11))+1;
        UIImageView *imageview=nil;
        if ([self.partPeopleView viewWithTag:10+i]!=nil) {
            imageview=(UIImageView*)[self.partPeopleView viewWithTag:10+i];
        }else{
        imageview =[[UIImageView alloc]initWithFrame:CGRectMake(space*xsplacenumber+partPeopleViewheight*(xsplacenumber-1),(leftsapce-2)*yspacenumber+partPeopleViewheight*(yspacenumber-1), partPeopleViewheight, partPeopleViewheight)];
         [self.partPeopleView addSubview:imageview];
        }
        imageview.layer.cornerRadius =partPeopleViewheight/2;
        imageview.layer.masksToBounds=YES;
        imageview.contentMode=UIViewContentModeScaleAspectFill;
        imageview.tag=10+i;
        if (i==imagenumber-1&&imagenumber>30) {
            [imageview setImageURL:nil placeholderImage:IMAGE(@"caseMore") contentSize:CGSizeMake(partPeopleViewheight, partPeopleViewheight)];
            UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showMoreLivePrasiemembers:)];
            [imageview removeGestureRecognizer:tap];
            [imageview addGestureRecognizer:tap];
            imageview.userInteractionEnabled=YES;
            
        }else{
           imageview.userInteractionEnabled=YES;
            CMTParticiPators *Part=((CMTParticiPators*)[self.cardCellModel.participators objectAtIndex:i]);
            if (Part.userType.integerValue==1) {
                [imageview setImageURL:Part.picture placeholderImage:IMAGE(@"ic_default_head") contentSize:CGSizeZero];
                
            }else{
                 [imageview setLimitedImageURL:Part.picture placeholderImage:IMAGE(@"ic_default_head") contentSize:CGSizeMake(partPeopleViewheight, partPeopleViewheight)];
            }
        }
       
    }
    self.partPeopleView.frame=CGRectMake(self.partPeopleView.left, self.partPeopleView.top, self.partPeopleView.width,((UIView*)[self.partPeopleView subviews].lastObject).bottom+10);
    [self drawFootCart];
    self.updateheadView();

}
#pragma 展示更多点赞成员
-(void)showMoreLivePrasiemembers:(UITapGestureRecognizer*)tap{
    if([self.cardCellModel.participators count]>0){
        CMTParticiPators *parts=self.cardCellModel.participators.lastObject;
        NSDictionary *params=@{
                               @"liveBroadcastMessageId":self.cardCellModel.liveBroadcastMessageId ?: @"",
                               @"incrId":parts.incrId?:@"0",
                               @"incrIdFlag":@"1",
                               @"pageSize":@"33",
                               };
        @weakify(self);
        [[[CMTCLIENT get_live_message_praiser_list:params]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(NSArray *partsArray) {
            @strongify(self);
            if ([partsArray count]>0) {
                NSMutableArray *array=[[NSMutableArray alloc]initWithArray:self.cardCellModel.participators];
                [array addObjectsFromArray:partsArray];
                self.cardCellModel.participators=[array copy];
                [self drawlivePraiseMember:self.cardCellModel.participators.count+1];
            }else{
                [tap.view removeFromSuperview];
                self.partPeopleView.frame=CGRectMake(self.partPeopleView.left, self.partPeopleView.top, self.partPeopleView.width,((UIView*)[self.partPeopleView subviews].lastObject).bottom+10);
                [self drawFootCart];
                self.updateheadView();

            }
           
            
        }error:^(NSError *error) {
            
            CMTLog(@"刷新失败");
        }];

    }
}
//展示参与者
-(void)showmembers{
    CMTParticiViewController *part=[[CMTParticiViewController alloc]init];
    [self.lastController.navigationController pushViewController:part animated:YES];
}
//绘制点赞评论分享视图
//@param isLive 0不是直播，1直播
-(void)drawCommentsAndGreatView : (int) isLive{
    for (UIView *view in [self.CommentsAndGreatView subviews]) {
        [view removeFromSuperview];
        
    }
    
    int per = 2;
    if(1 == isLive){
        per = 3;
    }
    int left = 0;
    if(3 == per){
        left = self.CommentsAndGreatView.width/per;
    }
    
    UIView *bottomline=[[UIView alloc]initWithFrame:CGRectMake(0,0, self.partPeopleView.width,1)];
    bottomline.backgroundColor = [UIColor colorWithHexString:@"#F8F8F8"];
    [self.CommentsAndGreatView addSubview:bottomline];
    
    if(3 == per){
        if( [CMTUSER.userInfo.userId isEqualToString:self.cardCellModel.authorId] ){
            UIControl *more=[[UIControl alloc]initWithFrame:CGRectMake(0, 0, self.CommentsAndGreatView.width/per-1, self.CommentsAndGreatView.height)];
            [more addTarget:self action:@selector(CmtLiveMore) forControlEvents:UIControlEventTouchUpInside];
            
            UIImageView *moreimage=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.CommentsAndGreatView.width/per-1, self.CommentsAndGreatView.height)];
            moreimage.contentMode = UIViewContentModeCenter;
            moreimage.image=[UIImage imageNamed:@"live_item_more"];
            [more addSubview:moreimage];
            [self.CommentsAndGreatView addSubview:more];
        }else{
            float lable3with=[CMTGetStringWith_Height CMTGetLableTitleWith:@"分享" fontSize:14];
            UIControl *share=[[UIControl alloc]initWithFrame:CGRectMake(0, 0, self.CommentsAndGreatView.width/per-1, self.CommentsAndGreatView.height)];
            [share addTarget:self action:@selector(CmtShare) forControlEvents:UIControlEventTouchUpInside];
        
            UIImageView *shareimage=[[UIImageView alloc]initWithFrame:CGRectMake( (self.CommentsAndGreatView.width/per-18-lable3with-5)/2 ,(self.CommentsAndGreatView.height-18)/2+1,18, 18)];
            shareimage.image=[UIImage imageNamed:@"ic_live_share"];
            [share addSubview:shareimage];
        
            UILabel *lable3=[[UILabel alloc]initWithFrame:CGRectMake(shareimage.right+5, 0,lable3with, share.height)];
            lable3.textColor=[UIColor colorWithHexString:@"#A2A2A2"];
            lable3.text=@"分享";
            lable3.font=[UIFont systemFontOfSize:14];
            [share addSubview:lable3];
            [self.CommentsAndGreatView addSubview:share];
        }

    }

    float lable1with=[CMTGetStringWith_Height CMTGetLableTitleWith:[self.cardCellModel.commentCount integerValue]==0?@"评论":self.cardCellModel.commentCount fontSize:14];
    UIControl *comment=[[UIControl alloc]initWithFrame:CGRectMake(left, 0, self.CommentsAndGreatView.width/per-1, self.CommentsAndGreatView.height)];
    [comment addTarget:self action:@selector(CmtComment:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *commentimage=[[UIImageView alloc]initWithFrame:CGRectMake( (self.CommentsAndGreatView.width/per-18-lable1with-5)/2 ,(self.CommentsAndGreatView.height-18)/2+1,18, 18)];
    commentimage.tag=1001;
    commentimage.image=[UIImage imageNamed:@"comments"];
    [comment addSubview:commentimage];

    UILabel *lable=[[UILabel alloc]initWithFrame:CGRectMake(commentimage.right+5, 0,lable1with, comment.height)];
    lable.text=[self.cardCellModel.commentCount integerValue]==0?@"评论":self.cardCellModel.commentCount;
    lable.textColor=[UIColor colorWithHexString:@"#A2A2A2"];
    lable.font=[UIFont systemFontOfSize:14];
    [comment addSubview:lable];
    [self.CommentsAndGreatView addSubview:comment];
    UIView  *line=[[UIView alloc]initWithFrame:CGRectMake(comment.width,0, 1, comment.height)];
    line.backgroundColor = [UIColor colorWithHexString:@"#F4F4F4"];
    [self.CommentsAndGreatView addSubview:line];
    
    
    float lable2with=[CMTGetStringWith_Height CMTGetLableTitleWith:[self.cardCellModel.praiseCount integerValue]==0?@"赞":self.cardCellModel.praiseCount fontSize:14];
    UIControl *great=[[UIControl alloc]initWithFrame:CGRectMake(comment.right, 1, self.CommentsAndGreatView.width/2, self.CommentsAndGreatView.height)];
    [great addTarget:self action:@selector(CmtPraise:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *greatimage=[[UIImageView alloc]initWithFrame:CGRectMake( (self.CommentsAndGreatView.width/per-18-lable2with)/2 ,(self.CommentsAndGreatView.height-18)/2,18, 18)];
    greatimage.tag=1000;
    [great addSubview:greatimage];

    UILabel *lable2=[[UILabel alloc]initWithFrame:CGRectMake(greatimage.right+5, 0,lable2with, great.height)];
    if(self.cardCellModel.isPraise.boolValue){
        lable2.textColor=[UIColor colorWithHexString:@"#38c9c3"];
    }else{
        lable2.textColor=[UIColor colorWithHexString:@"#A2A2A2"];
    }

    lable2.text=self.cardCellModel.praiseCount.integerValue==0?@"赞":self.cardCellModel.praiseCount;
    lable2.font=[UIFont systemFontOfSize:14];
    [great addSubview:lable2];
    [self.CommentsAndGreatView addSubview:great];
    if (self.cardCellModel.isPraise.boolValue) {
        greatimage.image=[UIImage imageNamed:@"praise"];
         lable2.textColor=[UIColor colorWithHexString:@"#3CC7C1"];
    }else{
        greatimage.image=[UIImage imageNamed:@"unpraise"];
         lable2.textColor=[UIColor colorWithHexString:@"#A2A2A2"];
        
    }

    if(3 == per){
        UIView  *line2=[[UIView alloc]initWithFrame:CGRectMake(comment.right,0, 1, comment.height)];
        line2.backgroundColor = [UIColor colorWithHexString:@"#F4F4F4"];
        [self.CommentsAndGreatView addSubview:line2];
    }
}

//更多
-(void)CmtLiveMore{
    if(nil != self.delegate&&[self.delegate respondsToSelector:@selector(CmtLiveMore:)]){
        [self.delegate CmtLiveMore:self.indexPath];
    }
}

//点赞事件
-(void)CmtPraise:(UIControl*)control{
    [CMTImageCompression shakeToShow:[control viewWithTag:1000]];
    if (self.delegate!=nil &&[self.delegate respondsToSelector:@selector(CMTSomePraise:index:)]) {
        [self.delegate CMTSomePraise:!self.cardCellModel.isPraise.boolValue index:self.indexPath];
    }
}

//点击分享
-(void)CmtShare{
    if (self.delegate!=nil &&[self.delegate respondsToSelector:@selector(CMTClickShare:)]) {
        [self.delegate CMTClickShare:self.indexPath];
    }
}

//点击评论
-(void)CmtComment:(UIControl*)contronl{
    [CMTImageCompression shakeToShow:[contronl viewWithTag:1001]];
    if (self.delegate!=nil&&[self.delegate respondsToSelector:@selector(CMTClickComments:)]) {
        [self.delegate CMTClickComments:self.indexPath];
    }
}
//点击tag
-(void)ClickTag{
    if (self.liveDelegate!=nil&&[self.liveDelegate respondsToSelector:@selector(CMTGoLiveTagList:)]) {
        [self.liveDelegate CMTGoLiveTagList:self.cardCellModel.liveBroadcastTag];
    }
}
//展示参与者
-(void)showPartitics{
    CMTParticiViewController *part=[[CMTParticiViewController alloc]initWithId:self.cardCellModel.cellId];
    [self.lastController.navigationController pushViewController:part animated:YES];
}
#pragma mark - 图片浏览
-(void)Showpic:(UITapGestureRecognizer*)tap{
    self.imageArray=@[];
    CMTPicture *caseimage=[self.cardCellModel.imageList objectAtIndex:tap.view.tag-1];
    NSMutableArray *array=[[NSMutableArray alloc]init];
    for (CMTPicture *pic in self.cardCellModel.imageList) {
        [array addObject:pic.picFilepath];
    }
    [self openPhotoBrowserWithCurrentImageURL:caseimage.picFilepath totalImageURLs:array];
    
}
- (void)openPhotoBrowserWithCurrentImageURL:(NSString *)imageURL
                             totalImageURLs:(NSArray *)totalImageURLs {
    // Photos
    if ( self.imageArray.count == 0) {
        NSMutableArray *photos = [NSMutableArray array];
        for (NSInteger index = 0; index < totalImageURLs.count; index++) {
            // 原始图片URL
            NSString *imageURLString = [UIImage fullQualityImageURLWithURL:totalImageURLs[index]];
            MWPhoto *photo = [MWPhoto photoWithURL:[NSURL URLWithString:imageURLString]];
            photo.caption = [NSString stringWithFormat:@"%ld/%ld", (long)(index + 1), (long)totalImageURLs.count];
            [photos addObject:photo];
        }
        self.imageArray = photos;
    }
    
    // PhotoBrowser
    MWPhotoBrowser *photoBrowser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    photoBrowser.zoomPhotosToFill = YES;
    photoBrowser.enableSwipeToDismiss = NO;
    [photoBrowser setCurrentPhotoIndex:[totalImageURLs indexOfObject:imageURL]];
    
    // Show
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:photoBrowser];
    navigationController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self.lastController presentViewController:navigationController animated:YES completion:nil];
}

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return  [self.imageArray count];
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index <  self.imageArray.count) {
        return  self.imageArray[index];
    }
    return nil;
}

@end
