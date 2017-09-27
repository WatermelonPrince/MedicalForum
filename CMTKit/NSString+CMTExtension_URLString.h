//
//  NSString+CMTExtension_URLString.h
//  MedicalForum
//
//  Created by fenglei on 15/3/26.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMTBaseViewController.h"

/* HTMLTag */

// HTMLScheme
FOUNDATION_EXPORT NSString * const CMTNSStringHTMLScheme_FILE;

// HTMLTagScheme
FOUNDATION_EXPORT NSString * const CMTNSStringHTMLTagScheme_CMTOPDR;

// HTMLTagParseKey
FOUNDATION_EXPORT NSString * const CMTNSStringHTMLTagParseKey_header;
FOUNDATION_EXPORT NSString * const CMTNSStringHTMLTagParseKey_domain;
FOUNDATION_EXPORT NSString * const CMTNSStringHTMLTagParseKey_parameters;

// HTMLTagHeader
FOUNDATION_EXPORT NSString * const CMTNSStringHTMLTagHeader;

// HTMLTagDomain
FOUNDATION_EXPORT NSString * const CMTNSStringHTMLTagDomain_postDetail;

// HTMLTagParameter
FOUNDATION_EXPORT NSString * const CMTNSStringHTMLTagParameterKey_action;

FOUNDATION_EXPORT NSString * const CMTNSStringHTMLTagParameterKey_authorid;     // CMTNSStringHTMLTagAction_author
FOUNDATION_EXPORT NSString * const CMTNSStringHTMLTagParameterKey_nickname;

FOUNDATION_EXPORT NSString * const CMTNSStringHTMLTagParameterKey_posttypeid;   // CMTNSStringHTMLTagAction_type
FOUNDATION_EXPORT NSString * const CMTNSStringHTMLTagParameterKey_posttype;

FOUNDATION_EXPORT NSString * const CMTNSStringHTMLTagParameterKey_themeId;      // CMTNSStringHTMLTagAction_themeTag
FOUNDATION_EXPORT NSString * const CMTNSStringHTMLTagParameterKey_theme;
FOUNDATION_EXPORT NSString * const CMTNSStringHTMLTagParameterKey_postId;
FOUNDATION_EXPORT NSString * const CMTNSStringHTMLTagParameterKey_postTitle;

FOUNDATION_EXPORT NSString * const CMTNSStringHTMLTagParameterKey_diseaseId;    // CMTNSStringHTMLTagAction_diseaseTag
FOUNDATION_EXPORT NSString * const CMTNSStringHTMLTagParameterKey_disease;
FOUNDATION_EXPORT NSString * const CMTNSStringHTMLTagParameterKey_level;
FOUNDATION_EXPORT NSString * const CMTNSStringHTMLTagParameterKey_module;

FOUNDATION_EXPORT NSString * const CMTNSStringHTMLTagParameterKey_keyword;      // CMTNSStringHTMLTagAction_searchKeyword

FOUNDATION_EXPORT NSString * const CMTNSStringHTMLTagParameterKey_curPic;       // CMTNSStringHTMLTagAction_showPicture
FOUNDATION_EXPORT NSString * const CMTNSStringHTMLTagParameterKey_picList;
FOUNDATION_EXPORT NSString * const CMTNSStringHTMLTagParameterKey_picIndex;

FOUNDATION_EXPORT NSString * const CMTNSStringHTMLTagParameterKey_pdfUrl;       // CMTNSStringHTMLTagAction_openPDF
FOUNDATION_EXPORT NSString * const CMTNSStringHTMLTagParameterKey_id;
FOUNDATION_EXPORT NSString * const CMTNSStringHTMLTagParameterKey_size;

FOUNDATION_EXPORT NSString * const CMTNSStringHTMLTagParameterKey_x;            // CMTNSStringHTMLTagAction_appendDetailsCoordinate
FOUNDATION_EXPORT NSString * const CMTNSStringHTMLTagParameterKey_y;

FOUNDATION_EXPORT NSString * const CMTNSStringHTMLTagParameterKey_title;        // CMTNSStringHTMLTagAction_share
FOUNDATION_EXPORT NSString * const CMTNSStringHTMLTagParameterKey_brief;
FOUNDATION_EXPORT NSString * const CMTNSStringHTMLTagParameterKey_url;
FOUNDATION_EXPORT NSString * const CMTNSStringHTMLTagParameterKey_postid;
FOUNDATION_EXPORT NSString * const CMTNSStringHTMLTagParameterKey_sharePic;


// HTMLTagAction
FOUNDATION_EXPORT NSString * const CMTNSStringHTMLTagAction_author;
FOUNDATION_EXPORT NSString * const CMTNSStringHTMLTagAction_type;
FOUNDATION_EXPORT NSString * const CMTNSStringHTMLTagAction_themeTag;
FOUNDATION_EXPORT NSString * const CMTNSStringHTMLTagAction_diseaseTag;
FOUNDATION_EXPORT NSString * const CMTNSStringHTMLTagAction_searchKeyword;
FOUNDATION_EXPORT NSString * const CMTNSStringHTMLTagAction_showPicture;
FOUNDATION_EXPORT NSString * const CMTNSStringHTMLTagAction_openPDF;
FOUNDATION_EXPORT NSString * const CMTNSStringHTMLTagAction_additionalDetails;
FOUNDATION_EXPORT NSString * const CMTNSStringHTMLTagAction_additionalConclusions;
FOUNDATION_EXPORT NSString * const CMTNSStringHTMLTagAction_zan;
FOUNDATION_EXPORT NSString * const CMTNSStringHTMLTagAction_login;
FOUNDATION_EXPORT NSString * const CMTNSStringHTMLTagAction_share;
FOUNDATION_EXPORT NSString * const CMTNSStringHTMLTagAction_flag;
FOUNDATION_EXPORT NSString * const CMTNSStringHTMLTagAction_epaper;
FOUNDATION_EXPORT NSString * const CMTNSStringHTMLTagAction_postDetail;

@interface NSString (CMTExtension_URLString)

/* HTMLTag */

/// 创建一个HTML动作标签
+ (NSString *)CMT_HTMLTag_withHeader:(NSString *)header
                              domain:(NSString *)domain
                              action:(NSString *)action
                          parameters:(NSDictionary *)parameters;
/// 文章'作者'动作标签
+ (NSString *)CMT_HTMLTagAuthor_withAuthorid:(NSString *)authorid
                                    nickname:(NSString *)nickname;
/// 文章'类型'动作标签
+ (NSString *)CMT_HTMLTagType_withPosttypeid:(NSString *)posttypeid
                                    posttype:(NSString *)posttype;
/// 文章'专题标签'动作标签
+ (NSString *)CMT_HTMLTagThemeTag_withThemeId:(NSString *)themeId
                                        theme:(NSString *)theme
                                       postId:(NSString *)postId
                                    postTitle:(NSString *)postTitle;
/// 文章'疾病标签'动作标签
+ (NSString *)CMT_HTMLTagDiseaseTag_withDiseaseId:(NSString *)diseaseId
                                          disease:(NSString *)disease
                                            level:(NSString *)level
                                           module:(NSString *)module;
/// 文章'二级标签'动作标签
+ (NSString *)CMT_HTMLTagSearchKeyword_withKeyword:(NSString *)keyword
                                            module:(NSString *)module;
/// 静态文章'图片'动作标签
+ (NSString *)CMT_HTMLTagShowPicture_withCurPic:(NSString *)curPic
                                       picIndex:(NSString *)picIndex;

/// 解析HTML动作标签'self'
- (NSDictionary *)CMT_HTMLTag_parseDictionary;
- (NSDictionary *)CMT_HTMLTag_parseDictionary:(NSString*)CMTNSstringHTMLTagHeader;

/* URLEncode */

/// URLEncode
- (NSString *)URLEncodeString;
/// URLDecode
- (NSString *)URLDecodeString;

/* ImageURL */

- (NSString *)imageSuffix;
-(BOOL)handleWithinArticle:(NSString*)urlString viewController:(CMTBaseViewController*)Controller;
//处理分享链接
-(void)handleWithinArticleShare:(NSString*)postUuid  type:(NSString*)type;
- (NSString *)getTimeByDate:(NSDate *)date byProgress:(float)current;
//判断链接是否正确
-(BOOL)JudgeLinktype:(NSString*)urlString url:(NSString*)url;
@end
