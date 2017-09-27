//
//  UIColor+CMTExtension.h
//  MedicalForum
//
//  Created by fenglei on 14/12/16.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (CMTExtension)

typedef NS_ENUM(NSUInteger, ColorHexStringIndex) {
    c_clear,        // 透明色
    c_ffffff,       // 白色
    c_000000,       // 黑色
    c_32c7c2,       // 主色
    c_4766a8,       // 辅助色
    c_151515,       // 字体色
    c_1515157F,     // 字体色50%透明
    c_424242,       // 字体色
    c_9e9e9e,       // 字体色
    c_ababab,       // 字体色
    c_fafafa,       // 首页列表背景色
    c_f5f5f5,       // 导航栏背景色
    c_f5f5f5f5,     // 导航栏背景色96%不透明
    c_f6f6f6,       // 启动图背景色
    c_dddedf,       // 搜索页边框颜色
    c_fdfdfd,       // 搜索页面背景色
    c_5e6971,       // 搜索栏图标下科目名颜色
    c_e7e7e7,       // 列表sectionHeader背景色
    c_eaeaea,       // 列表separator颜色
    c_727272,       // 个人信息中是否认证字体颜色
    c_3b3b3b,       // 个人信息表格分割线
    c_282929,       // 个人信息背景色
    c_f74c31,       // 红色点
    c_dadada,       // 输入框分隔线颜色
    c_d2d2d2,       // 输入框placeholder字色
    c_eeeeee,       // 评论列表背景色
    c_dcdcdc,       // 评论列表分隔线颜色
    c_c3c3c3,       // 个人账号页中,cell分割线颜色
    c_f7f7f7,       // 个人账号也中,表背景色
    c_f07e7e,       // 断网提示视图背景色
    c_fbc36b,       // 网络异常提示,橙色
    c_cfcfcf,       // 关于界面版本号色值
    c_53ae93,       // 引导图背景色
    c_dfdfdf,       // 订阅界面，订阅后按钮背景色色
    c_191919,       // 图片浏览器背景色
    c_d84315,       // 作者排行第一色值
    c_ffca28,       // 作者排行第二色值
    c_cddc39,       // 作者排行第三色值
    c_e51c23,       // 文章列表 专题标注颜色
    c_efeff4,       // 列表背景色
    c_f8f8f9,       // 指南列表边线颜色
    c_3CC6C1,       // 我需要确定按钮颜色
    c_6ABAB8,       // 单个疾病标签背景色
    c_dddddd,       // 积分列表
    c_f14545,       // 积分列表分数红色
    c_4eb357,       // 积分列表分数绿色
    c_46CDC8,       // 标签设置列表选中文字颜色
    c_25C25B,       // 进度条颜色
    c_5B5B5B,       // 积分提示背景
    c_838389,       // 字体颜色
    c_EBEBEE,       // 病例列表分割线
    c_F7F7F7,       // 评论回复框背景色
    c_F5F5F8,       // 字评论背景
    c_dedede,       // 病例详情评论筛选提示分隔线
    c_c30013,       // 直播作者名字
    c_C4C4C4,       // 字数限制字体色
    C_919191,       //发帖取消按钮
    c_00b899,       //小组成员lineView颜色
    c_f5f6f6,     //搜索导航栏背景色
    c_4acbb5,     //论吧搜索页面取消按钮
    c_A3A3A3,     //选择小组类型
    c_bfbfbf,    //小组卡片描述文字颜色
    c_b9b9b9,    //小组卡片描述文字颜色
    c_1eba9c,
   };
UIColor* ColorWithHexStringIndex(ColorHexStringIndex index);

/*usage
 RGB style hex value, alpha set to full
 UIColor *solidColor = [UIColor colorWithHex:0xFF0000];
 */
+ (UIColor *)colorWithRGB:(unsigned long) hex;

/*usage
 RGBA style hex value
 UIColor *solidColor = [UIColor colorWithRGBA:0xFF0000FF];
 UIColor *alphaColor = [UIColor colorWithRGBA:0xFF000099];
 */
+ (UIColor *)colorWithRGBA:(unsigned long) hex;

/*usage
 ARGB style hex value
 UIColor *alphaColor = [UIColor colorWithHex:0x99FF0000];
 */
+ (UIColor *)colorWithARGB:(unsigned long) hex;

/*usage
 UIColor *solidColor = [UIColor colorWithWeb:@"#FF0000"];
 safe to omit # sign as well
 UIColor *solidColor = [UIColor colorWithWeb:@"FF0000"];
 */
+ (UIColor *)colorWithHexString:(NSString *)hexString;

- (NSString *)hexString;

- (UIImage *)pixelImage;

@end
