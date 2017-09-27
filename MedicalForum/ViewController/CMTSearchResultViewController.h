//
//  CMTSearchResultViewController.h
//  MedicalForum
//
//  Created by Bo Shen on 15/1/9.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTBaseViewController.h"

@interface CMTSearchResultViewController : CMTBaseViewController<UITextFieldDelegate>
/*记录搜索条件*/
@property (strong, nonatomic) NSDictionary *mDic;

//压栈请求，弹栈不请求
@property (assign) BOOL needRequest;

@end
