//
//  CMTSubscriptingAssignmentTrampoline.h
//  MedicalForum
//
//  Created by fenglei on 14/12/15.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import <Foundation/Foundation.h>

// escape exception due to unrecognized selector or other reason
#define CMTCALL(STATEMENT)\
@try {STATEMENT} @catch (NSException *exception) {CMTLogError(@"EXCEPTION: %@", exception);}

// escape exception due to unrecognized selector of a property
#define keypath_CMT(OBJ, PATH)\
(((void)(NO && ((void)OBJ.PATH, NO)), # PATH))

#define keypathString_CMT(OBJ, PATH)\
[NSString stringWithCString:keypath_CMT(OBJ, PATH) encoding:NSUTF8StringEncoding]

#define CMTSET_(TARGET, KEYPATH, NILVALUE)\
[[CMTSubscriptingAssignmentTrampoline alloc] initWithTarget:(TARGET) nilValue:(NILVALUE)][@keypath_CMT(TARGET, KEYPATH)]

#define CMTSET(TARGET, ...)\
(CMTSET_(TARGET, __VA_ARGS__, nil))

@interface CMTSubscriptingAssignmentTrampoline : NSObject

- (instancetype)initWithTarget:(id)target nilValue:(id)nilValue;
- (void)setObject:(id)value forKeyedSubscript:(NSString *)keyPath;

@end
