//
//  CMTLevelViewController.m
//  MedicalForum
//
//  Created by zhaohuan on 16/4/1.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import "CMTLevelViewController.h"
#import "CMTUpgradeViewController.h"


@interface CMTLevelViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, weak)CMTUpgradeViewController *mUpgradeVC;
@property(nonatomic,strong)UITableView *tableView;


@end

@implementation CMTLevelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setContentState:CMTContentStateNormal];
    self.titleText = @"职称选择";
    self.tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, CMTNavigationBarBottomGuide, SCREEN_WIDTH, SCREEN_HEIGHT-CMTNavigationBarBottomGuide) style:UITableViewStylePlain];
     [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    self.tableView.rowHeight = 50;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate = self;
    self.tableView.dataSource=self;
    self.tableView.backgroundColor=[UIColor colorWithHexString:@"#f7f7f7"];
   [self.contentBaseView addSubview:self.tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.backgroundColor=[UIColor whiteColor];
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"主任医师";
            break;
        case 1:
            cell.textLabel.text = @"副主任医师";
            break;
        case 2:
            cell.textLabel.text = @"主治医师";
            break;
        case 3:
            cell.textLabel.text = @"住院医师";
            break;
        case 4:
            cell.textLabel.text = @"其他";
            break;
        
            
        default:
            break;
    }
    UIView *lineview = [[UIView alloc]initWithFrame:CGRectMake(0, 49, SCREEN_WIDTH-5, 1)];
    lineview.backgroundColor = [UIColor colorWithHexString:@"#f7f7f7"];
    [cell.contentView addSubview:lineview];

    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *transValue = cell.textLabel.text;
    @weakify(self);
    if (self.updateLeve!=nil) {
          @strongify(self);
        self.updateLeve(transValue);
    }
    for (int i = 0; i < self.navigationController.viewControllers.count;i++)
    {
        UIViewController *pVC =[self.navigationController.viewControllers objectAtIndex:i];
        if ([pVC isKindOfClass:[CMTUpgradeViewController class]])
        {
            self.mUpgradeVC = (CMTUpgradeViewController *)pVC;
            self.mUpgradeVC.mStrGrade = transValue;
            
            break;
        }
    }
     [self.navigationController popViewControllerAnimated:YES];
}



@end
