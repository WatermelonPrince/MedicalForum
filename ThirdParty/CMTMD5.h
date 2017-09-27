//
//  CMTMD5.h
//  MedicalForum
//
//  Created by guoyuanchao on 15/12/21.
//  Copyright © 2015年 CMT. All rights reserved.
//

#import "CMTObject.h"
#import <Foundation/Foundation.h>


@interface CMTMD5 : CMTObject
+(NSString *) md5: (NSString *) inPutText ;
@end
