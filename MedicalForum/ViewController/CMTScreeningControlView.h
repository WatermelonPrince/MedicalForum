//
//  CMTScreeningControlView.h
//  MedicalForum
//
//  Created by guoyuanchao on 16/12/26.
//  Copyright © 2016年 CMT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CMTScreeningControlView : UIScrollView
@property(nonatomic,strong)void(^updateScreening)(NSString*assortmentId,NSString *classType);
@property(nonatomic,strong)void(^updateClassScreening)(NSString*calss);

-(void)DrawTagMakerMangeView:(NSMutableArray*)assortmenArray  assortmentId:(NSString*)assortmentId classType:(NSString*)classType;
@end
