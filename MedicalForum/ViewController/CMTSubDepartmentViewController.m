//
//  CMTSubDepartmentViewController.m
//  MedicalForum
//
//  Created by Bo Shen on 14/12/26.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTSubDepartmentViewController.h"
#import "CMTUpgradeViewController.h"
#import "CMTSettingViewController.h"
@interface CMTSubDepartmentViewController ()

@property (strong, nonatomic) CMTUpgradeViewController *mUpgradeVC;

@end

@implementation CMTSubDepartmentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.titleText = @"选择科室";
    [self.view addSubview:self.mSubDepartTableView];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    for (UIViewController *vc in self.navigationController.viewControllers)
    {
        if ([vc isKindOfClass:[CMTUpgradeViewController class]])
        {
            self.mUpgradeVC = (CMTUpgradeViewController *)vc;
            break;
        }
    }
    
    self.mArrSubDepartments = [self.mDepart.subDeparts mutableCopy];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.mSubDepartTableView reloadData];
    });
}

- (NSMutableArray *)mArrSubDepartments
{
    if (!_mArrSubDepartments)
    {
        _mArrSubDepartments = [NSMutableArray array];
    }
    return _mArrSubDepartments;
}
- (UILabel *)mLbSubDepart
{
    if (!_mLbSubDepart)
    {
        _mLbSubDepart = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 30)];
        _mLbSubDepart.textColor = [UIColor colorWithRed:130.0/255 green:130.0/255 blue:130.0/255 alpha:1.0];
        _mLbSubDepart.textAlignment = NSTextAlignmentRight;
    }
    return _mLbSubDepart;
}

- (UITableView *)mSubDepartTableView
{
    if (!_mSubDepartTableView)
    {
        _mSubDepartTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT-64) style:UITableViewStylePlain];
        _mSubDepartTableView.delegate = self;
        _mSubDepartTableView.dataSource = self;
    }
    return _mSubDepartTableView;
}

#pragma mark  UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
     CMTLog(@"{%ld,%ld}",(long)indexPath.section,(long)indexPath.row);
    @try {
        /*获取当前点击Cell中的内容*/
        UITableViewCell *pCurrentCell = [tableView cellForRowAtIndexPath:indexPath];
        NSString *pSubDepart = pCurrentCell.textLabel.text;
        self.mLbSubDepart.text = pSubDepart;
        self.mUpgradeVC.mDepart = self.mDepart;
        CMTSubDepart *subDepart = [self.mArrSubDepartments objectAtIndex:indexPath.row];
        self.mUpgradeVC.mSubDepart = subDepart;
        self.mUpgradeVC.mLbDepartment = self.mLbSubDepart;
        self.mUpgradeVC.mStrDepartment = subDepart.subDepartment;
        /*获取到要替换内容的cell*/
        if(self.mUpgradeVC!=nil){
            NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
            UITableViewCell *pRefreshCell = [self.mUpgradeVC.mTableView cellForRowAtIndexPath:newIndexPath];
            pRefreshCell.accessoryView = self.mLbSubDepart;
            [self.navigationController popToViewController:self.mUpgradeVC animated:YES];
        }else{
            @weakify(self);
            if(self.updateDepart!=nil){
                @strongify(self);
                subDepart.departId=self.mDepart.departId;
                self.updateDepart(subDepart);
            }
            NSArray *array=self.navigationController.viewControllers;
            for (UIViewController *vc in array) {
                if([vc isKindOfClass:[CMTSettingViewController class]]){
                    [self.navigationController popToViewController:vc animated:YES];
                }
            }
        }
    }
    @catch (NSException *exception) {
        CMTLog(@"depart subdepart  error");
    }
    
}

#pragma mark  UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.mArrSubDepartments.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifer = @"cell";
    UITableViewCell *pCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifer];
    
    if (!pCell)
    {
        pCell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifer];
    }
    
    @try {
        CMTSubDepart *subDepart = [self.mArrSubDepartments objectAtIndex:indexPath.row];
        pCell.textLabel.text = subDepart.subDepartment;
    }
    @catch (NSException *exception) {
        CMTLog(@"no subDepart");
    }
    
   
    return pCell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 2;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
