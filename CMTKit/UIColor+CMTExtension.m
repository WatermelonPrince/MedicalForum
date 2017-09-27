//
//  UIColor+CMTExtension.m
//  MedicalForum
//
//  Created by fenglei on 14/12/16.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "UIColor+CMTExtension.h"

@implementation UIColor (CMTExtension)

UIColor* ColorWithHexStringIndex(ColorHexStringIndex index) {
    NSString *HexString = nil;
    switch (index) {
        case c_clear:       HexString = @"#00000000";   break;
        case c_ffffff:      HexString = @"#ffffff";     break;
        case c_000000:      HexString = @"#000000";     break;
        case c_32c7c2:      HexString = @"#32c7c2";     break;
        case c_4766a8:      HexString = @"#4766a8";     break;
        case c_151515:      HexString = @"#151515";     break;
        case c_1515157F:    HexString = @"#1515157F";   break;
        case c_424242:      HexString = @"#424242";     break;
        case c_9e9e9e:      HexString = @"#9e9e9e";     break;
        case c_ababab:      HexString = @"#ababab";     break;
        case c_fafafa:      HexString = @"#fafafa";     break;
        case c_f5f5f5:      HexString = @"#f5f5f5";     break;
        case c_f5f5f5f5:    HexString = @"#f5f5f5f5";   break;
        case c_f6f6f6:      HexString = @"#f6f6f6";     break;
        case c_dddedf:      HexString = @"#dddedf";     break;
        case c_fdfdfd:      HexString = @"#fdfdfd";     break;
        case c_5e6971:      HexString = @"#5e6971";     break;
        case c_e7e7e7:      HexString = @"#e7e7e7";     break;
        case c_eaeaea:      HexString = @"#eaeaea";     break;
        case c_727272:      HexString = @"#727272";     break;
        case c_3b3b3b:      HexString = @"#3b3b3b";     break;
        case c_282929:      HexString = @"#282929";     break;
        case c_f74c31:      HexString = @"#f74c31";     break;
        case c_dadada:      HexString = @"#dadada";     break;
        case c_d2d2d2:      HexString = @"#d2d2d2";     break;
        case c_eeeeee:      HexString = @"#eeeeee";     break;
        case c_dcdcdc:      HexString = @"#dcdcdc";     break;
        case c_c3c3c3:      HexString = @"#c3c3c3";     break;
        case c_f7f7f7:      HexString = @"#f7f7f7";     break;
        case c_f07e7e:      HexString = @"#f07e7e";     break;
        case c_fbc36b:      HexString = @"#fbc36b";     break;
        case c_cfcfcf:      HexString = @"#cfcfcf";     break;
        case c_dfdfdf:      HexString = @"#dfdfdf";     break;
        case c_53ae93:      HexString = @"#53ae93";     break;
        case c_191919:      HexString = @"#191919";     break;
        case c_d84315:      HexString = @"#d84315";     break;
        case c_ffca28:      HexString = @"#ffca28";     break;
        case c_cddc39:      HexString = @"#cddc39";     break;
        case c_e51c23:      HexString = @"#e51c23";     break;
        case c_efeff4:      HexString = @"#EFEFF4";     break;
        case c_f8f8f9:      HexString = @"#F8F8F9";     break;
        case c_3CC6C1:      HexString = @"#3CC6C1";     break;
        case c_6ABAB8:      HexString = @"#6ABAB8";     break;
        case c_dddddd:      HexString = @"#dddddd";     break;
        case c_f14545:      HexString = @"#f14545";     break;
        case c_4eb357:      HexString = @"#4eb357";     break;
        case c_46CDC8:      HexString = @"#46CDC8";     break;
        case c_25C25B:      HexString = @"#25C25B";     break;
        case c_5B5B5B:      HexString = @"#5B5B5B";     break;
        case c_838389:      HexString = @"#838389";     break;
        case c_EBEBEE:      HexString = @"#EBEBEE";     break;
        case c_F7F7F7:      HexString = @"#F7F7F7";     break;
        case c_F5F5F8:      HexString = @"#F5F5F8";     break;
        case c_dedede:      HexString = @"#dedede";     break;
        case c_c30013:      HexString = @"#c30013";     break;
        case c_C4C4C4:      HexString = @"#C4C4C4";     break;
        case C_919191:      HexString = @"#919191";     break;
        case c_00b899:      HexString = @"#00b899";     break;
            
        case c_f5f6f6:      HexString = @"#f5f6f6";     break;
        case c_4acbb5:      HexString = @"#4acbb5";     break;
        case c_A3A3A3:      HexString = @"#A3A3A3";     break;
        case c_bfbfbf:      HexString = @"#bfbfbf";     break;
        case c_b9b9b9:      HexString = @"#b9b9b9";     break;
        case c_1eba9c:      HexString = @"#1eba9c";     break;

        default: break;
    }
    
    return [UIColor colorWithHexString:HexString];
}

// constants
const NSInteger MAX_RGB_COLOR_VALUE = 0xff;
const NSInteger MAX_RGB_COLOR_VALUE_FLOAT = 255.0f;

+ (UIColor *)colorWithRGB:(unsigned long) hex {
    return [UIColor colorWithRed:(CGFloat)((hex>>16) & MAX_RGB_COLOR_VALUE) / MAX_RGB_COLOR_VALUE_FLOAT
                           green:(CGFloat)((hex>>8) & MAX_RGB_COLOR_VALUE) / MAX_RGB_COLOR_VALUE_FLOAT
                            blue:(CGFloat)(hex & MAX_RGB_COLOR_VALUE) / MAX_RGB_COLOR_VALUE_FLOAT
                           alpha:1.0];
}

+ (UIColor *)colorWithRGBA:(unsigned long) hex {
    return [UIColor colorWithRed:(CGFloat)((hex>>24) & MAX_RGB_COLOR_VALUE) / MAX_RGB_COLOR_VALUE_FLOAT
                           green:(CGFloat)((hex>>16) & MAX_RGB_COLOR_VALUE) / MAX_RGB_COLOR_VALUE_FLOAT
                            blue:(CGFloat)((hex>>8) & MAX_RGB_COLOR_VALUE) / MAX_RGB_COLOR_VALUE_FLOAT
                           alpha:(CGFloat)((hex) & MAX_RGB_COLOR_VALUE) / MAX_RGB_COLOR_VALUE_FLOAT];
}

+ (UIColor *)colorWithARGB:(unsigned long) hex {
    return [UIColor colorWithRed:(CGFloat)((hex>>16) & MAX_RGB_COLOR_VALUE) / MAX_RGB_COLOR_VALUE_FLOAT
                           green:(CGFloat)((hex>>8) & MAX_RGB_COLOR_VALUE) / MAX_RGB_COLOR_VALUE_FLOAT
                            blue:(CGFloat)(hex & MAX_RGB_COLOR_VALUE) / MAX_RGB_COLOR_VALUE_FLOAT
                           alpha:(CGFloat)((hex>>24) & MAX_RGB_COLOR_VALUE) / MAX_RGB_COLOR_VALUE_FLOAT];
}

+ (UIColor *)colorWithHexString:(NSString *)hexString {
    unsigned long hex;
    
    // chop off hash
    if ([hexString characterAtIndex:0] == '#') {
        hexString = [hexString substringFromIndex:1];
    }
    
    // depending on character count, generate a color
    NSInteger hexStringLength = hexString.length;
    
    if (hexStringLength == 3) {
        // RGB, once character each (each should be repeated)
        hexString = [NSString stringWithFormat:@"%c%c%c%c%c%c", [hexString characterAtIndex:0], [hexString characterAtIndex:0], [hexString characterAtIndex:1], [hexString characterAtIndex:1], [hexString characterAtIndex:2], [hexString characterAtIndex:2]];
        hex = strtoul([hexString UTF8String], NULL, 16);
        
        return [self colorWithRGB:hex];
    } else if (hexStringLength == 4) {
        // RGBA, once character each (each should be repeated)
        hexString = [NSString stringWithFormat:@"%c%c%c%c%c%c%c%c", [hexString characterAtIndex:0], [hexString characterAtIndex:0], [hexString characterAtIndex:1], [hexString characterAtIndex:1], [hexString characterAtIndex:2], [hexString characterAtIndex:2], [hexString characterAtIndex:3], [hexString characterAtIndex:3]];
        hex = strtoul([hexString UTF8String], NULL, 16);
        
        return [self colorWithRGBA:hex];
    } else if (hexStringLength == 6) {
        // RGB
        hex = strtoul([hexString UTF8String], NULL, 16);
        
        return [self colorWithRGB:hex];
    } else if (hexStringLength == 8) {
        // RGBA
        hex = strtoul([hexString UTF8String], NULL, 16);
        
        return [self colorWithRGBA:hex];
    }
    
    // illegal
    CMTLogError(@"Hex string invalid: %@", hexString);
    
    return nil;
}

- (NSString *)hexString {
    const CGFloat *components = CGColorGetComponents(self.CGColor);
    
    NSInteger red = (int)(components[0] * MAX_RGB_COLOR_VALUE);
    NSInteger green = (int)(components[1] * MAX_RGB_COLOR_VALUE);
    NSInteger blue = (int)(components[2] * MAX_RGB_COLOR_VALUE);
    NSInteger alpha = (int)(components[3] * MAX_RGB_COLOR_VALUE);
    
    if (alpha < 255) {
        return [NSString stringWithFormat:@"#%02lx%02lx%02lx%02lx", (long)red, (long)green, (long)blue, (long)alpha];
    }
    
    return [NSString stringWithFormat:@"#%02lx%02lx%02lx", (long)red, (long)green, (long)blue];
}

- (UIImage *)pixelImage {
    UIImage *PixelImage = nil;
    
    CGRect PixelRect = CGRectMake(0, 0, PIXEL, PIXEL);
    UIGraphicsBeginImageContextWithOptions(PixelRect.size, NO, 0);
    CGContextRef Context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(Context, self.CGColor);
    CGContextFillRect(Context, PixelRect);
    
    PixelImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return [PixelImage resizableImageWithCapInsets:UIEdgeInsetsMake(PIXEL, PIXEL, PIXEL, PIXEL)];
}

@end
