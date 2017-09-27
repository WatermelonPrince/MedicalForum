//
//  CMTReplyListWrapCell.m
//  MedicalForum
//
//  Created by fenglei on 15/1/17.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTReplyListWrapCell.h"
#import "CMTReplyListCell.h"

NSString * const CMTPostDetailCommentListReplyWrapCellIdentifier = @"CMTPostDetailCommentListReplyWrapCell";

static const CGFloat kCMTReplyListWrapCellMargen = 10;
const CGFloat kCMTReplyListWrapCellVerticalGap = 10.0;

@interface CMTReplyListWrapCell ()<CMTReplyListCellPraiseDelegate>

@property (nonatomic, copy, readwrite) CMTReply *reply;
@property (nonatomic, copy, readwrite) CMTComment *comment;
@property (nonatomic, copy, readwrite) NSIndexPath *indexPath;
@property (nonatomic, assign, readwrite) BOOL last;

@property (nonatomic, strong) UIButton *ground;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *bottomLine;

@property (nonatomic, assign) CGFloat tableViewWidth;
@property (nonatomic, assign) CGFloat tableViewHeight;

@end

@implementation CMTReplyListWrapCell

#pragma mark Initializers

- (UIButton *)ground {
    if (_ground == nil) {
        _ground = [UIButton buttonWithType:UIButtonTypeCustom];
        _ground.backgroundColor = COLOR(c_clear);
    }
    
    return _ground;
}

- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] init];
        _tableView.backgroundColor = COLOR(c_e7e7e7);
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.scrollEnabled = NO;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [_tableView registerClass:[CMTReplyListCell class] forCellReuseIdentifier:CMTPostDetailCommentListReplyWrapCellIdentifier];
    }
    
    return _tableView;
}

- (UIView *)bottomLine {
    if (_bottomLine == nil) {
        _bottomLine = [[UIView alloc] init];
        _bottomLine.backgroundColor = COLOR(c_dcdcdc);
    }
    
    return _bottomLine;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self == nil) return nil;
    
    UIView *background = [[UIView alloc] init];
    background.backgroundColor = COLOR(c_ffffff);
    self.backgroundView = background;
    
    [self.contentView addSubview:self.ground];
    [self.contentView addSubview:self.tableView];
    [self.contentView addSubview:self.bottomLine];
    self.bottomLine.hidden = YES;
    
    return self;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected

#pragma mark LifeCycle
 animated:animated];

    // Configure the view for the selected state
}

+ (CGFloat)cellHeightFromReply:(CMTReply *)reply comment:(CMTComment *)comment cellWidth:(CGFloat)cellWidth last:(BOOL)last {
    CGFloat tableViewLeftGuide = kCMTReplyListWrapCellMargen*RATIO;
    CGFloat tableViewRightGuide = cellWidth - kCMTReplyListWrapCellMargen*RATIO;
    CGFloat tableViewWidth = tableViewRightGuide - tableViewLeftGuide-47;
    
    // tableView
    CGFloat tableViewHeight = [CMTReplyListCell cellHeightFromReply:reply comment:comment cellWidth:tableViewWidth];
    
    // bottomLine
    tableViewHeight += last ? kCMTReplyListWrapCellVerticalGap : 0.0;
    
    return tableViewHeight;
    
}

- (void)reloadReply:(CMTReply *)reply comment:(CMTComment *)comment cellWidth:(CGFloat)cellWidth indexPath:(NSIndexPath *)indexPath last:(BOOL)last {
    self.reply = reply;
    self.comment = comment;
    self.indexPath = indexPath;
    self.last = last;
    
    // layout
    CGFloat cellHeight = [CMTReplyListWrapCell cellHeightFromReply:reply comment:comment cellWidth:cellWidth last:last];
    [self layoutWithCellWidth:cellWidth cellHeight:cellHeight last:last];
    
    // tableView
    [self.tableView reloadData];
}

- (BOOL)layoutWithCellWidth:(CGFloat)cellWidth cellHeight:(CGFloat)cellHeight last:(BOOL)last {
    CGFloat tableViewLeftGuide = kCMTReplyListWrapCellMargen;
    CGFloat tableViewRightGuide = cellWidth - kCMTReplyListWrapCellMargen;
    CGFloat tableViewWidth = tableViewRightGuide - tableViewLeftGuide-45;
    CGFloat tableViewHeight = cellHeight - (last ? kCMTReplyListWrapCellVerticalGap : 0.0);
    
    // ground
    self.ground.frame = CGRectMake(0, 0, cellWidth, cellHeight);
    
    // tableView
    self.tableView.frame = CGRectMake(tableViewLeftGuide+45, 0.0, tableViewWidth, tableViewHeight);
    self.tableViewWidth = tableViewWidth;
    self.tableViewHeight = tableViewHeight;
    
    // bottomLine
    self.bottomLine.frame = CGRectMake(0.0, cellHeight - PIXEL, cellWidth, PIXEL);
    self.bottomLine.hidden = !last;
    
    return YES;
}

#pragma mark TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.tableViewHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CMTReplyListCell *cell = [tableView dequeueReusableCellWithIdentifier:CMTPostDetailCommentListReplyWrapCellIdentifier forIndexPath:indexPath];
    cell.delegate=self;
    
    [cell reloadReply:self.reply comment:self.comment cellWidth:self.tableViewWidth cellHeight:self.tableViewHeight last:self.last];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([self.delegate respondsToSelector:@selector(replyListWrapCell:didSelectRowAtIndexPath:)]) {
        [self.delegate replyListWrapCell:self didSelectRowAtIndexPath:self.indexPath];
    }
}
-(void)ReplyListCellPraise:(CMTReply*)reply{
    if (self.delegate!=nil&&[self.delegate respondsToSelector:@selector(replyListPraise:index:)]) {
        [self.delegate replyListPraise:reply index:self.indexPath];
    }
}
@end
