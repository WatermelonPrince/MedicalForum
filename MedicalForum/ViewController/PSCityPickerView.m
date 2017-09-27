//
//  PSCityPickerView.m
//  Diamond
//
//  Created by Pan on 15/8/12.
//  Copyright (c) 2015年 Pan. All rights reserved.
//

#import "PSCityPickerView.h"

#define PS_CITY_PICKER_COMPONENTS 3
#define PROVINCE_COMPONENT        0
#define CITY_COMPONENT            1
#define DISCTRCT_COMPONENT        2
#define FIRST_INDEX               0


#define COMPONENT_WIDTH 100 //每一列的宽度

@interface PSCityPickerView ()<UIPickerViewDelegate,UIPickerViewDataSource>


@property (nonatomic, copy, readwrite) CMTProvince *province;
@property (nonatomic, copy, readwrite) CMTCity *city;
@property (nonatomic, copy, readwrite) CMTArea *area;

@property (nonatomic, copy) NSDictionary *allCityInfo;
@property (nonatomic, copy) NSArray *provinceArr;/**< 省名称数组*/
@property (nonatomic, copy) NSArray *cityArr;/**< 市名称数组*/
@property (nonatomic, copy) NSArray *districtArr;/**< 区名称数组*/
@property (nonatomic, copy) NSDictionary *currentProvinceDic;
@property (nonatomic, copy) NSDictionary *currentCityDic;
@property (strong, nonatomic)NSMutableArray *dataAreasArr;//区域地点数据


@end

@implementation PSCityPickerView
- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.delegate = self;
        self.dataSource = self;
       
        
    }
    return self;
}


- (NSMutableArray *)dataAreasArr{
    if (!_dataAreasArr) {
        _dataAreasArr = [[NSKeyedUnarchiver unarchiveObjectWithFile:[PATH_ALLAREAS stringByAppendingPathComponent:@"areas_list"]]mutableCopy];
        self.province = [self.dataAreasArr firstObject];
        if (self.province.cities.count > 0) {
            self.city = [self.province.cities firstObject];
            if (self.city.areas.count > 0) {
                self.area = [self.city.areas firstObject];
            }
            
        }
        if ([self.cityPickerDelegate respondsToSelector:@selector(cityPickerView:finishPickProvince:city:district:)])
        {
            [self.cityPickerDelegate cityPickerView:self finishPickProvince:self.province city:self.city district:self.area];
        }
        [self reloadAllComponents];
        
    }
    return _dataAreasArr;
}
- (NSArray *)cityArr
{
    if (!_cityArr)
    {
        _cityArr = [NSArray array];
        _cityArr = [self.dataAreasArr.firstObject cities];
    }
    return _cityArr;
}

- (NSArray *)districtArr
{
    if (!_districtArr)
    {
        
        _districtArr = [NSArray array];
        _districtArr = [self.cityArr.firstObject areas];
    }
    return _districtArr;
}



#pragma mark - UIPickerViewDelegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView*)pickerView
{
    //包含3列
    return PS_CITY_PICKER_COMPONENTS;
}

//该方法返回值决定该控件指定列包含多少个列表项
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    switch (component)
    {
        case PROVINCE_COMPONENT: return [self.dataAreasArr count];
        case CITY_COMPONENT:     return [self.cityArr count];
        case DISCTRCT_COMPONENT: return [self.districtArr count];
    }
    return 0;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *titleLabel = (UILabel *)view;
    if (!titleLabel)
    {
        titleLabel = [self labelForPickerView];
    }
    titleLabel.text = [self titleForComponent:component row:row];
    return titleLabel;
}

//选择指定列、指定列表项时激发该方法
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (component == PROVINCE_COMPONENT)
    {
        
        
        CMTProvince *province = [self.dataAreasArr objectAtIndex:row];
        self.province = province;
        self.cityArr = province.cities;
    
        CMTCity *city = self.cityArr.firstObject;
        self.districtArr = city.areas;
        
        
        self.city = city;
        CMTArea *area = [self.districtArr firstObject];
        self.area = area;
        
        [pickerView selectRow:FIRST_INDEX inComponent:CITY_COMPONENT animated:YES];
        [pickerView selectRow:FIRST_INDEX inComponent:DISCTRCT_COMPONENT animated:YES];
        
        [pickerView reloadAllComponents];
    }
    else if (component == CITY_COMPONENT)
    {

        CMTCity *city = [self.cityArr objectAtIndex:row];
        self.districtArr = city.areas;
        self.city = city;
        CMTArea *area = [self.districtArr firstObject];
        self.area = area;
        [pickerView selectRow:FIRST_INDEX inComponent:DISCTRCT_COMPONENT animated:YES];
        [pickerView reloadComponent:DISCTRCT_COMPONENT];
    }
    else if (component == DISCTRCT_COMPONENT)
    {
        if (self.districtArr.count > 0) {
            CMTArea * area = [self.districtArr objectAtIndex:row];
            self.area = area;
        }
    }
    
    if (self.cityPickerDelegate)
    {
        [self.cityPickerDelegate cityPickerView:self finishPickProvince:self.province city:self.city district:self.area];
    }
}

//指定列的宽度
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    // 宽度
    return COMPONENT_WIDTH;
}


#pragma mark - Private
- (UILabel *)labelForPickerView
{
    UILabel *label = [[UILabel alloc] init];
    label.textColor = [UIColor colorWithRed:85/255 green:85/255 blue:85/255 alpha:1];
    label.textAlignment = NSTextAlignmentCenter;
    label.adjustsFontSizeToFitWidth = YES;
    return label;
}

- (NSString *)titleForComponent:(NSInteger)component row:(NSInteger)row;
{
    switch (component)
    {
        case PROVINCE_COMPONENT: return [[self.dataAreasArr objectAtIndex:row] province];
        case CITY_COMPONENT:     return [[self.cityArr objectAtIndex:row] city];
        case DISCTRCT_COMPONENT: return [[self.districtArr objectAtIndex:row] area];
    }
    return @"";
}







@end
