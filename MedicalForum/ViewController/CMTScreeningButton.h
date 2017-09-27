//
//  CMTScreeningButton.h
//  MedicalForum
//
//  Created by guoyuanchao on 16/12/22.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CMTScreeningButton : UIControl
@property(nonatomic,strong)UIImageView *screeningImageView;
@property(nonatomic,strong)UILabel *screeninglable;
-(void)drawSelectedComponent;
-(void)drawUnSelectedComponent;
@end
