//
//  CMTSwizzle.m
//  MedicalForum
//
//  Created by fenglei on 15/6/11.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "CMTSwizzle.h"
#import <objc/runtime.h>

void CMTSwizzleMethod(Class class, SEL originalName, SEL replacedName) {
    Method originalMethod = class_getInstanceMethod(class, originalName);
    Method replacedMethod = class_getInstanceMethod(class, replacedName);
    
    if (class_addMethod(class, originalName, method_getImplementation(replacedMethod), method_getTypeEncoding(replacedMethod))) {
        
        class_replaceMethod(class, replacedName, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    }
    else {
        
        method_exchangeImplementations(originalMethod, replacedMethod);
    }
}
