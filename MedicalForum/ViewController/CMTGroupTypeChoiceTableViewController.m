//
//  CMTGroupTypeChoiceTableViewController.m
//  MedicalForum
//
//  Created by zhaohuan on 16/3/15.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import "CMTGroupTypeChoiceTableViewController.h"
#import "CMTGroupSettingViewController.h"
#import "CMTGroupCreatedMakeSureViewController.h"
#import "CMTGroupDisclaimerViewController.h"

@interface CMTGroupTypeChoiceTableViewController ()
@property (nonatomic, strong)NSMutableArray *arrData;//数据源


@end

@implementation CMTGroupTypeChoiceTableViewController


- (void)viewDidLoad {
    self.title = @"选择小组类型";
    [self.rac_willDeallocSignal subscribeCompleted:^{
        CMTLog(@"___CMTGroupTypeChoiceTableViewController");
    }];
    
    [super viewDidLoad];
    self.arrData = [NSKeyedUnarchiver unarchiveObjectWithFile:PATH_CACHE_GROUPTYPECHOICE];
    if (self.arrData.count == 0) {
        CMTGroup *openGroup = [[CMTGroup alloc]init];
        CMTGroup *limitGrop = [[CMTGroup alloc]init];
        openGroup.isSelected = @"0";
        openGroup.groupType = @"0";
        limitGrop.isSelected = @"0";
        limitGrop.groupType = @"1";
        NSMutableArray *arr = [NSMutableArray array];
        [arr addObject:openGroup];
        [arr addObject:limitGrop];
        self.arrData = [NSMutableArray arrayWithArray:arr];
        [NSKeyedArchiver archiveRootObject:self.arrData toFile:PATH_CACHE_GROUPTYPECHOICE];
    }
    @weakify(self);
    [[RACObserve(self, arrData) deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(NSArray *arrData) {
        @strongify(self);
        [self.tableView reloadData];
    }];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = ColorWithHexStringIndex(c_efeff4);
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton.frame = CGRectMake(SCREEN_WIDTH/2 - 30, 260, 60, 40);
    [cancelButton setTitleColor:[UIColor colorWithHexString:@"23bea5"] forState:UIControlStateNormal];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(poptoLastVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelButton];
}



- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationItem.hidesBackButton = YES;
    self.arrData = [NSKeyedUnarchiver unarchiveObjectWithFile:PATH_CACHE_GROUPTYPECHOICE];
    [self.tableView reloadData];
}
//返回上级控制器
- (void)poptoLastVC{
    [NSKeyedArchiver archiveRootObject:self.arrData toFile:PATH_CACHE_GROUPTYPECHOICE];
    [self.navigationController popViewControllerAnimated:YES];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrData.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CMTGroup *group = self.arrData[indexPath.row];
    static NSString *str = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:str];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str];
    }
    cell.contentView.backgroundColor = ColorWithHexStringIndex(c_efeff4);
    //小组类别 lable--classLabel
    UILabel * classLabel = [[UILabel alloc]init];
    classLabel.frame = CGRectMake(20, 10, 70, 30);
    //小组类别描述 label--desLabel
    UILabel * desLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 40, SCREEN_WIDTH - 40, 50)];
    //desLabel.backgroundColor = [UIColor yellowColor];
    desLabel.textColor = ColorWithHexStringIndex(c_A3A3A3);
    desLabel.numberOfLines = 0;
    UILabel *lineLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 119, SCREEN_WIDTH, 1)];
    lineLabel.backgroundColor = ColorWithHexStringIndex(c_f5f5f5);
    classLabel.font = [UIFont boldSystemFontOfSize:17];
    desLabel.font = [UIFont systemFontOfSize:15];
    
    //小组背景imageView
    UIView *cellBackGroudView = [[UIView alloc]initWithFrame:CGRectMake(10, 10, SCREEN_WIDTH- 20, 110)];
    cellBackGroudView.backgroundColor = ColorWithHexStringIndex(c_ffffff);
    UIImageView *tagImageView = [[UIImageView alloc]initWithFrame:CGRectMake(cellBackGroudView.right - 64, 0, 54, 54)];
    [cell.contentView addSubview:cellBackGroudView];
    [cellBackGroudView addSubview:desLabel];
    [cellBackGroudView addSubview:classLabel];
    [cellBackGroudView addSubview:tagImageView];
    if (indexPath.row == 0 ) {
      classLabel.text = @"公开";
        desLabel.text = @"任何用户都能看到小组，组内成员及其发布的内容。";
        group.groupType = @"0";
    }else{
        classLabel.text = @"封闭";
        desLabel.text = @"任何用户都能找到小组并查看小组成员，但只有组内成员能看到发布的内容。";
        group.groupType = @"1";
    }
    if ([group.isSelected isEqualToString:@"1"]) {
        tagImageView.image = [UIImage imageNamed:@"tagTypeImage"];
    }
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 120;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //将所有数据置为未选中状态
    for (CMTGroup *group in self.arrData) {
        group.isSelected = @"0";
    }
    CMTGroup *group = self.arrData[indexPath.row];
    group.isSelected = @"1";
    [NSKeyedArchiver archiveRootObject:self.arrData toFile:PATH_CACHE_GROUPTYPECHOICE];
    [tableView reloadData];
    if ([self.lastVC isKindOfClass:[CMTGroupCreatedMakeSureViewController class]] ||[self.lastVC isKindOfClass:[CMTGroupSettingViewController class]]) {
        if (self.RetureGroupType!=nil) {
            self.RetureGroupType(group.groupType);
        }
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }else{
        [MobClick event:@"B_lunBa_Continue1"];
    }
    CMTGroupSettingViewController *groupSetVC  = [[CMTGroupSettingViewController alloc]initWithGroup:group choiceTypeVC:self];
    [self.navigationController pushViewController:groupSetVC animated:YES];
}
@end
