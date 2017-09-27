//
//  NSString+CMTExtension_DigitString.m
//  MedicalForum
//
//  Created by fenglei on 15/6/10.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "NSString+CMTExtension_DigitString.h"

@implementation NSString (CMTExtension_DigitString)

#pragma mark Digit

- (BOOL)isComposeDigit:(NSString *)digitString {
    if (BEMPTY(self)) {
        return NO;
    }
    if (![digitString isKindOfClass:[NSString class]]) {
        CMTLogError(@"The Argument is not kind of NSString class");
        return NO;
    }
    
    if ((self.integerValue & digitString.integerValue) == digitString.integerValue) {
        
        return YES;
    }
    else {
        
        return NO;
    }
}

#pragma mark PostAttr

- (BOOL)isPostAttrPDF {
    return [self isComposeDigit:@"1"];
}

- (BOOL)isPostAttrAnswer {
    return [self isComposeDigit:@"2"];
}

- (BOOL)isPostAttrVote {
    return [self isComposeDigit:@"4"];
}
//有视频或者音频
- (BOOL)isPostAttrVideo{
    return ([self isComposeDigit:@"64"]||[self isComposeDigit:@"128"]);
}
//只有视频
- (BOOL)isPostAttrOnlyVideo{
    return [self isComposeDigit:@"64"];
}
////只有音频
- (BOOL)isPostAttrAudio{
    return [self isComposeDigit:@"128"];
}


#pragma mark PostModule

- (BOOL)isPostModuleHome {
    return [self isEqualToString:@"0"];
}

- (BOOL)isPostModuleCase {
    return [self isEqualToString:@"1"];
}

- (BOOL)isPostModuleGuide {
    return [self isEqualToString:@"2"];
}

- (NSString *)moduleString {
    if (self.isPostModuleHome) {
        return @"文章";
    }
    else if (self.isPostModuleCase) {
        return @"病例";
    }
    else if (self.isPostModuleGuide) {
        return @"指南";
    }
    else {
        return @"文章";
    }
}

#pragma mark BoolValue

- (BOOL)isTrue {
    return self.boolValue == YES;
}

- (BOOL)isFalse {
    return self.boolValue == NO;
}

@end
