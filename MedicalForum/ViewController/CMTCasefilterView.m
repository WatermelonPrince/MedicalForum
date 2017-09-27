//
//  CMTCasefilterView.m
//  MedicalForum
//
//  Created by guoyuanchao on 15/7/16.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTCasefilterView.h"
@interface CMTCasefilterView()<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong)UITableView *filterTableView;
@property(nonatomic,strong)NSArray *dataSource;
@property(nonatomic,strong)UIImageView *imageView;
@property(nonatomic,strong)UIView *filterBlankBackgroundView;
@property(nonatomic,assign)CMTCasefilterViewType casefilterViewType;
@end
@implementation CMTCasefilterView
-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        self.dataSource=[[NSArray alloc]initWithObjects:@"最新讨论",@"推荐",@"有结论的讨论", nil];
        [self addSubview:self.imageView];
        [self addSubview:self.filterTableView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
                       titles:(NSArray *)titles
           casefilterViewType:(CMTCasefilterViewType)casefilterViewType {
    self.casefilterViewType = casefilterViewType;
    self = [self initWithFrame:frame];
    if (self == nil) return nil;
    if ([titles isKindOfClass:[NSArray class]]) {
        self.dataSource = [titles copy];
    }
    else {
        self.dataSource = nil;
    }
    return self;
}

-(UITableView*)filterTableView{
    if (_filterTableView==nil) {
        _filterTableView=[[UITableView alloc]initWithFrame:CGRectMake(0, self.imageView.bottom, self.width, self.height-self.imageView.height)style:UITableViewStylePlain];
        _filterTableView.delegate=self;
        _filterTableView.dataSource=self;
        _filterTableView.alpha=0.95;
        _filterTableView.scrollEnabled=NO;
        _filterTableView.layer.cornerRadius=5;
        _filterTableView.separatorInset=UIEdgeInsetsMake(0, 10, 0, 20);
        if (self.casefilterViewType == CMTCasefilterViewTypeAppendDetailFilter) {
            _filterTableView.separatorInset=UIEdgeInsetsMake(0, 10, 0, 10);
        }
        _filterTableView.separatorColor=[UIColor colorWithHexString:@"#6e6e71"];
        [self addSubview:_filterTableView];
    }
    return _filterTableView;
}
-(UIImageView*)imageView{
    if (_imageView==nil) {
        CGFloat imageViewX = self.width - 40.0;
        if (self.casefilterViewType == CMTCasefilterViewTypeAppendDetailFilter) {
            imageViewX = self.width - 26.0;
        }
        _imageView=[[UIImageView alloc]initWithFrame:CGRectMake(imageViewX, 0, 15, 10)];
        _imageView.image=IMAGE(@"triangular");
    }
    return _imageView;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString * const CMTCellListCellIdentifier = @"CMTCellListCell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:CMTCellListCellIdentifier];
    if(cell==nil){
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CMTCellListCellIdentifier];
         cell.backgroundColor=[UIColor colorWithHexString:@"#515154"];
    }
    cell.textLabel.text=[self.dataSource objectAtIndex:indexPath.row];
    cell.textLabel.font=[UIFont systemFontOfSize:16];
    cell.textLabel.textColor=[UIColor whiteColor];
    
    if (self.casefilterViewType == CMTCasefilterViewTypeAppendDetailFilter) {
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    }

    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self hideFilter];
    
    if (self.delegate!=nil&&[self.delegate respondsToSelector:@selector(filterData:)]) {
        [self.delegate filterData:indexPath.row];
    }
}

- (void)showInView:(UIView *)view {
    
    self.filterBlankBackgroundView = [[UIView alloc] initWithFrame:view.bounds];
    self.filterBlankBackgroundView.backgroundColor = COLOR(c_clear);
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideFilter)];
    [self.filterBlankBackgroundView addGestureRecognizer:tapGesture];
    [view addSubview:self.filterBlankBackgroundView];
    [view addSubview:self];
}

- (void)showInView:(UIView *)view withOrigin:(CGPoint)origin {
    
    self.left = origin.x;
    self.top = origin.y;
    [self showInView:view];
}

- (void)hideFilter {
    // 病例详情页面 点击空白 同时取消键盘
    if ([self.delegate isKindOfClass:[UIViewController class]]) {
        UIView *view = [(UIViewController *)self.delegate view];
        [view endEditing:YES];
    }
    [self.filterBlankBackgroundView removeFromSuperview];
    self.filterBlankBackgroundView = nil;
    [self removeFromSuperview];
}

@end
