//
//  CMTDownloadManagerView.h
//  MedicalForum
//
//  Created by guoyuanchao on 2017/3/15.
//  Copyright © 2017年 CMT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CMTDownloadManagerView : UIView
@property(nonatomic,strong)NSString *downNumber;
@property(nonatomic,strong)UILabel*title;
@property(nonatomic,strong)UIButton *closebutton;
@property(nonatomic,strong)UIControl *contentCell;
@property(nonatomic,strong)UIImageView *downimage;
@property(nonatomic,strong)UILabel *namelable;
@property(nonatomic,strong)UILabel *sizelable;
@property(nonatomic,strong)UILabel *equipmentStorage;
@property(nonatomic,strong)CMTLivesRecord *mylive;
@property(nonatomic,assign)CMTBaseViewController *parent;
@property(nonatomic,copy)void(^updateDemanDownstate)(NSString*state);
-(void)reloadData:(CMTLivesRecord*)live;

@end
