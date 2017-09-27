//
//  CMTAddressesInfoViewController.m
//  MedicalForum
//
//  Created by zhaohuan on 2017/4/13.
//  Copyright © 2017年 CMT. All rights reserved.
//

#import "CMTAddressesInfoViewController.h"
#import "CMTNameEditViewController.h"
#import "CMTPersonalCell.h"
#import "PSCityPickerView.h"

@interface CMTAddressesInfoViewController ()<PSCityPickerViewDelegate, UITableViewDelegate, UITableViewDataSource,UIActionSheetDelegate>
@property (nonatomic, strong)UITableView *addressesTableView;//地址tableView;
@property (nonatomic, strong)UIBarButtonItem *mRightItem;//保存自定义item
@property (nonatomic, copy)NSString *receiveAdressString;//pickerView传过来的省市
@property (nonatomic, strong)CMTProvince *reciverprovince;//传过来的省份
@property (nonatomic, strong)CMTProvince *province;//确定选的省份

@property (nonatomic, strong)CMTCity *recivercity;//传过来的城市
@property (nonatomic, strong)CMTCity *city;//城市

@property (nonatomic, strong)CMTArea *receiverarea;//传过来的区域;
@property (nonatomic, strong)CMTArea *area;//区域;

@property (nonatomic, copy)NSString *adressString;//联系地址
@property (nonatomic, copy)NSString *detailAddress;//详细联系地址
@property (nonatomic, copy)NSString *receiver;//收货人姓名
@property (nonatomic, copy)NSString *emailAddress;//邮箱
@property (nonatomic, copy)NSString *phoneNumber;//电话
@property (nonatomic, strong)NSArray *rightItems;
@property (strong, nonatomic) PSCityPickerView *cityPicker;
@property (strong, nonatomic)UIView *pickerBGView;//picker的backGroudView;
@property (strong, nonatomic)UIView *pickerToolView;//picker控制视图
@property (strong, nonatomic)UIButton *cancleBtn;//取消button;
@property (strong, nonatomic)UIButton *finishPickerBtn;//完成选择按钮




@end

@implementation CMTAddressesInfoViewController

- (CMTProvince *)province{
    if (!_province) {
        _province = [[CMTProvince alloc]init];
    }
    return _province;
}
- (CMTCity *)city{
    if (!_city) {
        _city = [[CMTCity alloc]init];
    }
    return _city;
}
- (CMTArea *)area{
    if (!_area) {
        _area = [[CMTArea alloc]init];
    }
    return _area;
}

- (UIView *)pickerBGView{
    if (!_pickerBGView) {
        _pickerBGView = [[UIView alloc]init];
        _pickerBGView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT);
        [_pickerBGView addSubview:self.cityPicker];
        [_pickerBGView addSubview:self.pickerToolView];
    }
    return _pickerBGView;
}

- (UIView *)pickerToolView{
    if (!_pickerToolView) {
        _pickerToolView = [[UIView alloc]init];
        _pickerToolView.backgroundColor = COLOR(c_eeeeee);
        _pickerToolView.frame = CGRectMake(0, 40, SCREEN_WIDTH, 40);
        self.cancleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.cancleBtn.frame = CGRectMake(10, 0, 60, 40);
        [self.cancleBtn setTitle:@"取消" forState:UIControlStateNormal];
        [self.cancleBtn setTitleColor:[UIColor colorWithHexString:@"1b7adc"] forState:UIControlStateNormal];
        self.cancleBtn.titleLabel.font = FONT(15);
        [self.cancleBtn addTarget:self action:@selector(cancleChoiceAction:) forControlEvents:UIControlEventTouchUpInside];
        self.finishPickerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.finishPickerBtn.frame = CGRectMake(SCREEN_WIDTH - 70, 0, 60, 40);
        [self.finishPickerBtn setTitle:@"完成" forState:UIControlStateNormal];
        [self.finishPickerBtn setTitleColor:[UIColor colorWithHexString:@"1b7adc"] forState:UIControlStateNormal];
        self.finishPickerBtn.titleLabel.font = FONT(15);
        [self.finishPickerBtn addTarget:self action:@selector(finishPickerAction:) forControlEvents:UIControlEventTouchUpInside];
        [_pickerToolView addSubview:self.cancleBtn];
        [_pickerToolView addSubview:self.finishPickerBtn];
    }
        return _pickerToolView;
}




- (UIBarButtonItem *)mRightItem
{
    if (!_mRightItem)
    {
        NSString *pTitle = [self string:@"保存" WithColor:COLOR(c_32c7c2)];
        
        _mRightItem = [[UIBarButtonItem alloc]initWithTitle:pTitle style:UIBarButtonItemStyleDone target:self action:@selector(buttonSave:)];
    }
    return _mRightItem;
}
- (NSArray *)rightItems {
    if (_rightItems == nil) {
        UIBarButtonItem *FixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        FixedSpace.width = 10;
        _rightItems=[[NSArray alloc]initWithObjects:FixedSpace,self.mRightItem, nil];
    }
    
    return _rightItems;
}

- (UITableView *)addressesTableView
{
    if (!_addressesTableView)
    {
        _addressesTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT - 64) style:UITableViewStylePlain];
        _addressesTableView.delegate  = self;
        _addressesTableView.dataSource = self;
        _addressesTableView.bounces = NO;
        _addressesTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _addressesTableView.backgroundColor = COLOR(c_f7f7f7);
    }
    return _addressesTableView;
}
#pragma mark--保存收货信息到服务器

- (void)buttonSave:(UIBarButtonItem *)action{
    if (self.receiver.length == 0) {
        [self toastAnimation:@"收货人不能为空"];
        return;
    }
    if (self.emailAddress.length == 0) {
        [self toastAnimation:@"邮箱地址不能为空"];
        return;
    }
    if (self.phoneNumber.length == 0) {
        [self toastAnimation:@"联系电话不能为空"];
        return;
    }
    if (self.province.province == nil) {
        [self toastAnimation:@"收货省市不能为空"];
        return;
    }
    if (self.detailAddress.length == 0) {
        [self toastAnimation:@"联系地址不能为空"];
        return;
    }
    //如果保存相同数据，不在请求接口
    CMTReceiverAddress *address = CMTUSERINFO.addresses[0];
    if ([self.receiver isEqual: address.receiveUser] && [self.emailAddress isEqualToString:address.email]&&[self.phoneNumber isEqualToString:address.cellphone]&&[self.province.provinceid isEqualToString:address.provinceid] && [self.city.cityid isEqualToString:address.cityid] && [self.area.areaid isEqualToString:address.areaid] && [self.detailAddress isEqualToString:address.address]) {
        [self toastAnimation:@"收货信息无修改"];
        return;
        
    }
    NSDictionary *dic = @{
                          @"userId":CMTUSERINFO.userId?:@"0",
                          @"receiveUser":self.receiver?:@"",
                          @"email":self.emailAddress?:@"",
                          @"cellphone":self.phoneNumber?:@"",
                          @"provinceid":self.province.provinceid?:@"",
                          @"province":self.province.province?:@"",
                          @"cityid":self.city.cityid?:@"",
                          @"city":self.city.city?:@"",
                          @"areaid":self.area.areaid?:@"",
                          @"area":self.area.area?:@"",
                          @"address":self.detailAddress?:@"",

                          };
    
    [[[CMTCLIENT saveShippingaddress:dic]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(CMTReceiverAddress * x) {
        [self toastAnimation:@"保存成功"];
        if (x.addressId !=nil) {
            CMTReceiverAddress *address;
            CMTLog(@"CMTUSERINFO.addresses:%@",CMTUSERINFO.addresses);
            if (CMTUSERINFO.addresses.count > 0) {
                address = CMTUSERINFO.addresses[0];
            }else{
                address = [[CMTReceiverAddress alloc]init];

            }
            CMTLog(@"CMTUSERINFO.addresses:%@",CMTUSERINFO.addresses);

            address.addressId = x.addressId;
            address.receiveUser = self.receiver;
            address.email = self.emailAddress;
            address.cellphone = self.phoneNumber;
            address.provinceid = self.province.provinceid;
            address.province = self.province.province;
            address.cityid = self.city.cityid;
            address.city = self.city.city;
            address.areaid = self.area.areaid;
            address.area = self.area.area;
            address.address = self.detailAddress;
            CMTLog(@"CMTUSERINFO.addresses:%@",CMTUSERINFO.addresses);

            if (CMTUSERINFO.addresses.count == 0) {
                NSMutableArray *arr = [NSMutableArray array];
                [arr addObject:address];
                CMTUSERINFO.addresses = [arr copy];
            }
        }
        
    } error:^(NSError *error) {
        if (CMTAPPCONFIG.reachability.integerValue==0||([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus==AFNetworkReachabilityStatusNotReachable)||(error.code>=-1009&&error.code<=-1001)) {
            CMTLog(@"你的网络不给力");
        }else{
            CMTLog(@"%@",[error.userInfo objectForKey:@"errmsg"]);
            
        }
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (CMTUSERINFO.addresses.count > 0) {
        CMTReceiverAddress *receiverAddress = CMTUSERINFO.addresses[0];
        self.receiver = receiverAddress.receiveUser;
        self.emailAddress = receiverAddress.email;
        self.phoneNumber = receiverAddress.cellphone;
        self.province.province = receiverAddress.province;
        self.province.provinceid = receiverAddress.provinceid;
        self.city.city = receiverAddress.city;
        self.city.cityid = receiverAddress.cityid;
        self.area.area = receiverAddress.area;
        self.area.areaid = receiverAddress.areaid;
        self.adressString = [NSString stringWithFormat:@"%@%@%@",receiverAddress.province,receiverAddress.city,receiverAddress.area];
        self.detailAddress = receiverAddress.address;
        [self.addressesTableView reloadData];
    }
    CMTLog(@"CMTUSERINFO.addresses:%@",CMTUSERINFO.addresses);

    self.receiveAdressString = @"北京北京市东城区";
    self.titleText = @"我的账号";
    self.contentBaseView.backgroundColor = COLOR(c_f7f7f7);
    [self.contentBaseView addSubview:self.addressesTableView];
    [self.contentBaseView addSubview:self.pickerBGView];
    self.navigationItem.leftBarButtonItems = self.customleftItems;
    self.navigationItem.rightBarButtonItems = self.rightItems;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CMTPersonalCell *cell = [tableView dequeueReusableCellWithIdentifier:@"personalCell"];
    if (cell == nil) {
        cell = [[CMTPersonalCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"personalCell"];
    }
    switch (indexPath.row) {
        case 0:
        {
            [cell reloadWithLeftString:@"收货人" rightString:self.receiver WithImage:nil];
        }
            break;
        case 1:
        {
            [cell reloadWithLeftString:@"E-mail" rightString:self.emailAddress WithImage:nil];
        }
            break;
        case 2:
        {
            NSString *tel = [self.phoneNumber stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
            [cell reloadWithLeftString:@"联系电话" rightString:tel WithImage:nil];
        }
            break;
        case 3:
        {
            [cell reloadWithLeftString:@"收货省市" rightString:self.adressString WithImage:nil];
        }
            break;
        case 4:
        {
            [cell reloadWithLeftString:@"联系地址" rightString:self.detailAddress WithImage:nil];
        }
            break;
            
        default:
            break;
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row !=3) {
        [self hidePickerView];
    }
    switch (indexPath.row) {
        case 0:
        {
            CMTNameEditViewController *editVC = [[CMTNameEditViewController alloc]init];
            editVC.inputClass = @"收货人";
            editVC.row = 9999999;
            [editVC setUpdatRealname:^(NSString *str) {
                self.receiver = str;
                [self.addressesTableView reloadData];
            }];
            [self.navigationController pushViewController:editVC animated:YES];
        }
            break;
        case 1:
        {
            CMTNameEditViewController *editVC = [[CMTNameEditViewController alloc]init];
            editVC.inputClass = @"E-mail";
            editVC.row = 9999999;
            [editVC setUpdatRealname:^(NSString *str) {
                self.emailAddress = str;
                [self.addressesTableView reloadData];
            }];
            [self.navigationController pushViewController:editVC animated:YES];
        }
            break;
        case 2:
        {
            CMTNameEditViewController *editVC = [[CMTNameEditViewController alloc]init];
            editVC.inputClass = @"联系电话";
            editVC.row = 9999999;
            [editVC setUpdatRealname:^(NSString *str) {
                self.phoneNumber = str;
                [self.addressesTableView reloadData];

            }];
            [self.navigationController pushViewController:editVC animated:YES];

        }
            break;
        case 3:
        {

            [self showPickerView];
        }
            break;
        case 4:
        {
            CMTNameEditViewController *editVC = [[CMTNameEditViewController alloc]init];
            editVC.inputClass = @"联系地址";
            editVC.row = 9999999;
            [editVC setUpdatRealname:^(NSString *str) {
                self.detailAddress = str;
                [self.addressesTableView reloadData];
            }];
            [self.navigationController pushViewController:editVC animated:YES];
        }
            break;
            
            
        default:
            break;
    }
    
}

#pragma mark--CityPickerView的方法

- (void)cityPickerView:(PSCityPickerView *)picker finishPickProvince:(CMTProvince *)province city:(CMTCity *)city district:(CMTArea *)district{
    NSString *provinceString = province.province;
    NSString *cityString = city.city;
    NSString *areaString = district.area;
    
    if (province.province==nil) {
        provinceString = @"";
    }
    if (city.city==nil) {
        cityString = @"";
    }
    if (district.area==nil) {
        areaString = @"";
    }
    self.reciverprovince = province;
    self.recivercity = city;
    self.receiverarea = district;
    self.receiveAdressString = [NSString stringWithFormat:@"%@%@%@",provinceString,cityString,areaString];
    CMTLog(@"收货省市:%@",self.adressString);
    [self.addressesTableView reloadData];
}

- (PSCityPickerView *)cityPicker
{
    if (!_cityPicker)
    {
        _cityPicker = [[PSCityPickerView alloc] init];
        _cityPicker.cityPickerDelegate = self;
        _cityPicker.userInteractionEnabled = YES;
        _cityPicker.centerX = SCREEN_WIDTH/2;
        _cityPicker.width = SCREEN_WIDTH;
//        _cityPicker.height = 180;
        _cityPicker.left = 0;
        _cityPicker.top = 40;
        _cityPicker.backgroundColor = COLOR(c_ffffff);
        
        //[_cityPicker addSubview:button];
        
    }
    return _cityPicker;
}

- (void)cancleChoiceAction:(UIButton*)action{
    [self hidePickerView];
    
}

- (void)finishPickerAction:(UIButton*)action{
    self.adressString = self.receiveAdressString;
    self.province = self.reciverprovince;
    self.city = self.recivercity;
    self.area = self.receiverarea;
    [self.addressesTableView reloadData];
    [self hidePickerView];
}

-(void)showPickerView
{
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^(void){
        [self.pickerBGView setFrame:CGRectMake(0, SCREEN_HEIGHT-self.cityPicker.height - 40, SCREEN_WIDTH, self.cityPicker.height + 40)];
    } completion:^(BOOL isFinished){
        
    }];
}
-(void)hidePickerView
{
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^(void){
        self.pickerBGView.backgroundColor = [UIColor clearColor];
        [self.pickerBGView setFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT)];
    } completion:^(BOOL isFinished){
//        self.userInteractionEnabled = NO;
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.height;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
