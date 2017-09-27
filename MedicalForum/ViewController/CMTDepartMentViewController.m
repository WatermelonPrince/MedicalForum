//
//  CMTDepartMentViewController.m
//  MedicalForum
//
//  Created by Bo Shen on 14/12/26.
//  Copyright (c) 2014年 CMT. All rights reserved.
//


#import "CMTDepartMentViewController.h"
#import "CMTSubDepartmentViewController.h"

@interface CMTDepartMentViewController ()

@property (strong, nonatomic) CMTSubDepartmentViewController *mSubDepartVC;
@property (strong, nonatomic) NSString *mCachePathDeparts;

@end

@implementation CMTDepartMentViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.titleText = @"选择科室";
    [self.view addSubview:self.mDepartTableView];
    self.mDepartTableView.hidden = YES;
    [self initViewControllers];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self getDepartmentList:nil];
}

- (void)getDepartmentList:(id)sender
{
//    if ([[NSFileManager defaultManager]fileExistsAtPath:self.mCachePathDeparts])
//    {
//        self.mArrDepartments = [NSKeyedUnarchiver unarchiveObjectWithFile:self.mCachePathDeparts];
//        self.mDepartTableView.hidden = NO;
//    }
//    else
    {
        [self runAnimationInPosition:self.view.center];
        @weakify(self);
        [self.rac_deallocDisposable addDisposable:[[CMTCLIENT getDepart]subscribeNext:^(NSArray * array) {
            @strongify(self);
            DEALLOC_HANDLE_SUCCESS
            self.mArrDepartments = [array mutableCopy];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self stopAnimation];
                self.mDepartTableView.hidden = NO;
                self.mReloadBaseView.hidden = YES;
                [self.mDepartTableView reloadData];
            });
        } error:^(NSError *error) {
            CMTLog(@"errMes:%@",error.userInfo[CMTClientServerErrorUserInfoMessageKey]);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self stopAnimation];
                self.mDepartTableView.hidden = YES;
                self.mReloadBaseView.hidden = NO;
            });
        } completed:^{
            CMTLog(@"完成");
        }]];
    }
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.mReloadBaseView.hidden = YES;
    [self getDepartmentList:nil];
}

- (void)initViewControllers
{
    self.mSubDepartVC = [[CMTSubDepartmentViewController alloc]init];
}
- (NSString *)mCachePathDeparts
{
    NSString *path = [PATH_USERS stringByAppendingPathComponent:@"Departs"];
    return path;
}
- (NSMutableArray *)mArrDepartments
{
    if (!_mArrDepartments)
    {
        _mArrDepartments = [NSMutableArray array];
    }
    return _mArrDepartments;
}

- (UITableView *)mDepartTableView
{
    if (!_mDepartTableView)
    {
        _mDepartTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT-64) style:UITableViewStylePlain];
        _mDepartTableView.delegate = self;
        _mDepartTableView.dataSource = self;
        
    }
    return _mDepartTableView;
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
        CMTDepart *depart = [self.mArrDepartments objectAtIndex:indexPath.row];
        self.mSubDepartVC.mDepart = depart;
        @weakify(self);
        self.mSubDepartVC.updateDepart=^(CMTSubDepart* subdepart){
              @strongify(self);
         if(self.updateDepart!=nil){
            self.updateDepart(subdepart);
           }
        };
        [self.navigationController pushViewController:self.mSubDepartVC animated:YES];
    }
    @catch (NSException *exception) {
        CMTLog(@"touch  error  no depart");
    }
   
}

#pragma mark  UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.mArrDepartments.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifer = @"cell";
    UITableViewCell *pCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifer];
    
    if (!pCell)
    {
        pCell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifer];
    }
    pCell.selectionStyle = UITableViewCellSelectionStyleNone;
    @try {
        CMTDepart *depart = [self.mArrDepartments objectAtIndex:indexPath.row];
        pCell.textLabel.text = depart.department;
    }
    @catch (NSException *exception) {
        CMTLog(@"no departs");
    }
    pCell.accessoryType  = UITableViewCellAccessoryDisclosureIndicator;
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
