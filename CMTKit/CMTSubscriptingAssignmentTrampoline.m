//
//  CMTSubscriptingAssignmentTrampoline.m
//  MedicalForum
//
//  Created by fenglei on 14/12/15.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTSubscriptingAssignmentTrampoline.h"
#import <objc/runtime.h>

@interface CMTSubscriptingAssignmentTrampoline ()

// The object to bind to.
@property (nonatomic, strong, readonly) id target;

// A value to use when `nil` is sent on the bound signal.
@property (nonatomic, strong, readonly) id nilValue;

@end


@implementation CMTSubscriptingAssignmentTrampoline

- (instancetype)initWithTarget:(id)target nilValue:(id)nilValue {
    // This is often a programmer error, but this prevents crashes if the target
    // object has unexpectedly deallocated.
    if (target == nil) return nil;
    
    self = [super init];
    if (self == nil) return nil;
    
    _target = target;
    _nilValue = nilValue;
    
    return self;
}

- (void)setObject:(id)value forKeyedSubscript:(NSString *)keyPath {
    // Mark this as being autoreleased, because validateValue may return
    // a new object to be stored in this variable (and we don't want ARC to
    // double-free or leak the old or new values).
    __autoreleasing id validatedValue = value;
    NSError *error = nil;
    
    @try {
        if (![_target validateValue:&validatedValue forKey:keyPath error:&error]) {
            CMTLogError(@"CMTSET InValidateValue Error: %@", error);
            return;
        }
        
        objc_property_t property = class_getProperty([_target class], [keyPath UTF8String]);
        if (property == NULL) {
            CMTLogError(@"CMTSET NoneProperty Error for Class: %@ Property: %@ Instance: %@", [_target class], keyPath, _target);
            return;
        }
        
        [_target setValue:value forKey:keyPath];
    } @catch (NSException *ex) {
        CMTLogError(@"*** Caught exception setting key \"%@\" : %@", keyPath, ex);
        // Fail fast in Debug builds.
#if DEBUG
        @throw ex;
#endif
    }
}

@end
