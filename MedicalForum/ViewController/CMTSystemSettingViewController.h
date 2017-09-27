//
//  CMTSystemSettingViewController.h
//  MedicalForum
//
//  Created by Bo Shen on 14/12/23.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTBaseViewController.h"

@interface CMTSystemSettingViewController : CMTBaseViewController<UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) UITableView *mTableView;
@property (strong, nonatomic) UILabel *lbBufferSize;
@property (strong, nonatomic) UILabel *lbSoftVersion;
/*本地缓存文件名数组*/
@property (strong, nonatomic) NSMutableArray *mAllFiles;

@property (strong, nonatomic) UIAlertView *mAlertView;
///自制警告框
@property (strong, nonatomic) UIAlertView *mUpDateAlertView;
///路径
@property (strong, nonatomic) NSString *path;
///分割线
@property (strong, nonatomic) UIView *separatorLine;
///底线
@property (strong, nonatomic) UIView *bottomLine;


- (UITableView *)mTableView;
- (UILabel *)lbBufferSize;
- (UILabel *)lbSoftVersion;

/*获取软件版本号*/
- (void)softVersion;

/*获取软件已缓存数据大小*/
- (void)bufferSize:(NSString *)currentSize;

- (void)callBackSelectorWithDictionary:(NSDictionary *)appUpdateInfo;
//改变开关状态
-(void)changeSwitchState;

@end
