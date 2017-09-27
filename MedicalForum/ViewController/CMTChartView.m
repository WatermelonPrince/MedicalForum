//
//  CMTChartView.m
//  MedicalForum
//
//  Created by guoyuanchao on 16/6/6.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import "CMTChartView.h"
#import <QuartzCore/QuartzCore.h>
#import "ChartTableViewCell.h"
@implementation CMTChartView
-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        self.chartTableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.width, self.height-50)];
        self.chartTableView.backgroundColor=ColorWithHexStringIndex(c_ffffff);
        self.chartTableView.delegate=self;
        self.chartTableView.dataSource=self;
        self.chartTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
        self.chartTableView.allowsSelection=NO;
        self.chartTableView.placeholderView=[self tableViewPlaceholderView];
        [self.chartTableView setPlaceholderViewOffset:[NSValue valueWithCGSize:CGSizeMake(0,-self.chartTableView.height/2+50)]];
        [self addSubview:self.chartTableView];
    
    }
    return self;
}
- (UIView *)tableViewPlaceholderView {
    UIView *placeholderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self. self.chartTableView.width, 100.0)];
    placeholderView.backgroundColor = COLOR(c_clear);
    
    UILabel *placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, placeholderView.width, 100.0)];
    placeholderLabel.backgroundColor = COLOR(c_clear);
    placeholderLabel.textColor = COLOR(c_9e9e9e);
    placeholderLabel.font = FONT(15.0);
    placeholderLabel.textAlignment = NSTextAlignmentCenter;
    placeholderLabel.text =@"争做第一发言人，赶紧发出您的问题吧！";
    
    [placeholderView addSubview:placeholderLabel];
    
    
    return placeholderView;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataSourceArray.count;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ChartTableViewCell *cell=nil;
    cell=[tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell==nil) {
        cell=[[ChartTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    [cell reloadCell:[self.dataSourceArray objectAtIndex:indexPath.row]];
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}
@end
