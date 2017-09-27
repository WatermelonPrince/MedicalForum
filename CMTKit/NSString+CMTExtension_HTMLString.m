//
//  NSString+CMTExtension_HTMLString.m
//  MedicalForum
//
//  Created by fenglei on 15/6/8.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "NSString+CMTExtension_HTMLString.h"        // header file
#import "SDWebImageManager.h"                       // 图片缓存
#import "SDWebImageOperation.h"                     // 图片缓存Operation
#import "NSArray+CMTExtension.h"

// HTMLTemplate
NSString * const CMTNSStringHTMLTemplate_fileName = @"basic";
NSString * const CMTNSStringHTMLTemplate_caseDetail_fileName = @"basic_case_detail";
NSString * const CMTNSStringHTMLTemplate_fileType = @"html";

// HTMLTemplateDefaultImage
NSString * const CMTNSStringHTMLTemplateDefaultImage_fileName = @"xg_default_icon_click";
NSString * const CMTNSStringHTMLTemplateDefaultImage_fileType = @"png";
NSString * const CMTNSStringHTMLTemplateDefaultAuthorImage = @"face.png";

// HTMLTemplateMark
NSString * const CMTNSStringHTMLTemplateMark_PDF = @"<b class=\"pdf\"></b>";
NSString * const CMTNSStringHTMLTemplateMark_Answer = @"<b class=\"question\"></b>";
NSString * const CMTNSStringHTMLTemplateMark_Vote = @"<b class=\"vote\"></b>";
NSString * const CMTNSStringHTMLTemplateMark_Video = @"<b class=\"video\"></b>";
NSString * const CMTNSStringHTMLTemplateMark_Audio = @"<b class=\"audio\"></b>";


// HTMLTemplateClassName
NSString * const CMTNSStringHTMLTemplateClassName_on = @"on";
NSString * const CMTNSStringHTMLTemplateClassName_on_red = @"on_red";

@implementation NSString (CMTExtension_HTMLString)

#pragma mark - HTMLTemplate <body>

/// 病例详情
+ (NSString *)caseDetailHTMLStringWithPostDetail:(CMTPost *)postDetail
                                        authorId:(NSString *)authorId
                                          author:(NSString *)author
                        imageRequestURLPairArray:(NSMutableArray *)imageRequestURLPairArray {
    
    // 处理作者头像
    NSString *replacedAuthorPictureHTMLString = [self replacedAuthorPictureFilePathWithAuthorPictureURL:postDetail.authorPic
                                                                               imageRequestURLPairArray:imageRequestURLPairArray];
    
    // 处理作者
    NSString *replacedAuthorHTMLString = nil;
    if (!postDetail.module.isPostModuleGuide) {
        replacedAuthorHTMLString = [self CMT_HTMLLabel_withText:author
                                                      className:nil
                                                        HTMLTag:[self CMT_HTMLTagAuthor_withAuthorid:authorId
                                                                                            nickname:author]];
    }
    else {
        replacedAuthorHTMLString = [self CMT_HTMLLabelSpan_withText:author
                                                          className:nil
                                                            HTMLTag:[self CMT_HTMLTagSearchKeyword_withKeyword:author
                                                                                                        module:postDetail.module]];
    }
    
    // 处理类型
    NSString *replacedTypeHTMLString = [self CMT_HTMLLabel_withText:postDetail.postType
                                                          className:nil
                                                            HTMLTag:[self CMT_HTMLTagType_withPosttypeid:postDetail.postTypeId
                                                                                                posttype:postDetail.postType]];
    // 处理文章属性
    NSString *replacedAttrHTMLString = [self replacedAttrHTMLStringWithPostAttr:postDetail.postAttr];
    // 处理文章标签
    NSString *replacedTagHTMLString = [self replacedTagHTMLStringWithThemeTagInfo:@{
                                                                                    @"theme": postDetail.theme ?: @"",
                                                                                    @"themeTag": [self CMT_HTMLTagThemeTag_withThemeId:postDetail.themeId
                                                                                                                                 theme:postDetail.theme
                                                                                                                                postId:postDetail.postId
                                                                                                                             postTitle:postDetail.title] ?: @"",
                                                                                    }
                                                                    diseaseTagArr:postDetail.diseaseTagArr
                                                                       postTagArr:postDetail.postTagArr
                                                                           module:postDetail.module];
    // 处理文章详情内容
    NSString *imageIndex = [NSString stringWithFormat:@"%ld", (long)0];
    NSString *replacedContentHTMLString = [self replacedContentHTMLStringWithContentHTMLString:postDetail.content
                                                                      imageRequestURLPairArray:imageRequestURLPairArray
                                                                                    postModule:postDetail.module
                                                                                imageListCount:postDetail.imageList.count
                                                                                    imageIndex:&imageIndex];
    
    // 处理文章追加
    NSMutableString *replacedAddContentHTMLString = [NSMutableString string];
    NSInteger lastPostDescribeIndex = -1;
    for (NSInteger index = 0; index < postDetail.postDiseaseExtList.count; index++) {
        CMTAddPost *addPost = postDetail.postDiseaseExtList[index];
        if ([addPost.contentType isEqual:@"0"]) {
            lastPostDescribeIndex = index;
        }
    }
    
    for (NSInteger index = 0; index < postDetail.postDiseaseExtList.count; index++) {
        CMTAddPost *addPost = postDetail.postDiseaseExtList[index];
        
        // 处理文章追加内容
        NSString *addPostContentHTMLString = [self replacedContentHTMLStringWithContentHTMLString:addPost.content
                                                                         imageRequestURLPairArray:imageRequestURLPairArray
                                                                                       postModule:postDetail.module
                                                                                   imageListCount:postDetail.imageList.count
                                                                                       imageIndex:&imageIndex];
        // 处理文章追加时间
        NSString *timeStamp = addPost.createTime;
        if (BEMPTY(timeStamp)) {
            timeStamp = addPost.opTime;
        }
        NSString *addPostCreateTime = DATE(timeStamp);
        
        // 追加描述
        if ([addPost.contentType isEqual:@"0"]) {
            NSString *divClass = @"prev";
            // 最后一条描述
            if (index == lastPostDescribeIndex) {
                divClass = @"now";
            }
            // 日期为今天
            if ([addPostCreateTime isEqual:DATE(TIMESTAMP)]) {
                addPostCreateTime = @"今天";
            }
            
            [replacedAddContentHTMLString appendFormat:@"<div class=\"%@\"><em class=\"em\">%@</em>%@</div>", divClass, addPostCreateTime, addPostContentHTMLString];
        }
        // 结论
        else if ([addPost.contentType isEqual:@"1"]) {
            [replacedAddContentHTMLString appendFormat:@"<div class=\"next\"><em class=\"em\">总结</em>%@</div>", addPostContentHTMLString];
        }
    }

    // 处理文章追加样式
    NSString *replacedAddContentDisplayHTMLString = @"style=\"display:block;\"";
    if (BEMPTY(replacedAddContentHTMLString)) {
        replacedAddContentDisplayHTMLString = @"";
    }
    
    // 处理文章追加按钮
    NSString *replacedAppendDetailsHTMLString = @"<a><b></b><b></b><b></b></a>";
    
    // 处理文章详情模版
    NSString *filePath = [[NSBundle mainBundle] pathForResource:CMTNSStringHTMLTemplate_caseDetail_fileName ofType:CMTNSStringHTMLTemplate_fileType];
    NSString *postDetailHTMLString = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    
    postDetailHTMLString = [postDetailHTMLString stringByReplacingOccurrencesOfString:CMTNSStringHTMLTemplateDefaultAuthorImage
                                                                           withString:replacedAuthorPictureHTMLString ?: @""];
    
    postDetailHTMLString = [postDetailHTMLString stringByReplacingOccurrencesOfString:@"{ARTICLE_TITLE}"
                                                                           withString:postDetail.title.HTMLEscapedString ?: @""];
    
    postDetailHTMLString = [postDetailHTMLString stringByReplacingOccurrencesOfString:@"{ARTICLE_DATE}"
                                                                           withString:DATE(postDetail.createTime) ?: @""];
    
    postDetailHTMLString = [postDetailHTMLString stringByReplacingOccurrencesOfString:@"{ARTICLE_AUTHOR}"
                                                                           withString:replacedAuthorHTMLString ?: @""];
    
    postDetailHTMLString = [postDetailHTMLString stringByReplacingOccurrencesOfString:@"{SECTION_NAME}"
                                                                           withString:
                            [NSString stringWithFormat:@"%@%@", replacedTypeHTMLString ?: @"", replacedAttrHTMLString ?: @""]];
    
    postDetailHTMLString = [postDetailHTMLString stringByReplacingOccurrencesOfString:@"{ARTICLE_TAG}"
                                                                           withString:replacedTagHTMLString ?: @""];
    
    postDetailHTMLString = [postDetailHTMLString stringByReplacingOccurrencesOfString:@"{ARTICLE_CONTENT}"
                                                                           withString:replacedContentHTMLString ?: @""];
    
     postDetailHTMLString = [postDetailHTMLString stringByReplacingOccurrencesOfString:@"{ARTICLE_REMIND}"  withString:[self replacedremindPeople:postDetail.atUsers] ];
    
    postDetailHTMLString = [postDetailHTMLString stringByReplacingOccurrencesOfString:@"{ADD_CONTENT}"
                                                                           withString:replacedAddContentHTMLString ?: @""];
    
    postDetailHTMLString = [postDetailHTMLString stringByReplacingOccurrencesOfString:@"{ADD_CONTENT_DISPLAY}"
                                                                           withString:replacedAddContentDisplayHTMLString ?: @""];
    
    postDetailHTMLString = [postDetailHTMLString stringByReplacingOccurrencesOfString:@"{APPEND_DETAILS}"
                                                                           withString:replacedAppendDetailsHTMLString ?: @""];
    
    postDetailHTMLString = [postDetailHTMLString stringByReplacingOccurrencesOfString:@"{CUSTOM_FONTSIZE}"
                                                                           withString:CMTAPPCONFIG.customFontSize ?: @"100"];
    
    // 验证HTMLString
    if (!BEMPTY(postDetailHTMLString)) {
        
        return postDetailHTMLString;
    }
    else {
        CMTLogError(@"HTMLTemplate replace HTMLString Error: Empty HTMLString");
        
        return nil;
    }
}

#pragma mark 详情HTMLString

+ (NSString *)postDetailHTMLStringWithTitle:(NSString *)title
                                       date:(NSString *)date
                                   authorId:(NSString *)authorId
                                     author:(NSString *)author
                                 postTypeId:(NSString *)postTypeId
                                   postType:(NSString *)postType
                                   postAttr:(NSString *)postAttr
                                     module:(NSString *)module
                             customFontSize:(NSString *)customFontSize
                                     postId:(NSString *)postId
                                    themeId:(NSString *)themeId
                                      theme:(NSString *)theme
                              diseaseTagArr:(NSArray *)diseaseTagArr
                                 postTagArr:(NSArray *)postTagArr
                          contentHTMLString:(NSString *)contentHTMLString
                   imageRequestURLPairArray:(NSMutableArray *)imageRequestURLPairArray {
    
    // 处理作者
    NSString *replacedAuthorHTMLString = nil;
    if (!module.isPostModuleGuide) {
        replacedAuthorHTMLString = [self CMT_HTMLLabel_withText:author
                                                     className:nil
                                                       HTMLTag:[self CMT_HTMLTagAuthor_withAuthorid:authorId
                                                                                           nickname:author]];
    }
    else {
        replacedAuthorHTMLString = [self CMT_HTMLLabelSpan_withText:author
                                                          className:nil
                                                            HTMLTag:[self CMT_HTMLTagSearchKeyword_withKeyword:author
                                                                                                        module:module]];
    }
    
    // 处理类型
    NSString *replacedTypeHTMLString = [self CMT_HTMLLabel_withText:postType
                                                          className:nil
                                                            HTMLTag:[self CMT_HTMLTagType_withPosttypeid:postTypeId
                                                                                                posttype:postType]];
    // 处理文章属性
    NSString *replacedAttrHTMLString = [self replacedAttrHTMLStringWithPostAttr:postAttr];
    // 处理文章标签
    NSString *replacedTagHTMLString = [self replacedTagHTMLStringWithThemeTagInfo:@{
                                                                                    @"theme": theme ?: @"",
                                                                                    @"themeTag": [self CMT_HTMLTagThemeTag_withThemeId:themeId
                                                                                                                                 theme:theme
                                                                                                                                postId:postId
                                                                                                                             postTitle:title] ?: @"",
                                                                                    }
                                                                    diseaseTagArr:diseaseTagArr
                                                                       postTagArr:postTagArr
                                                                           module:module];
    // 处理文章详情内容
    NSString *imageIndex = [NSString stringWithFormat:@"%ld", (long)0];
    NSString *replacedContentHTMLString = [self replacedContentHTMLStringWithContentHTMLString:contentHTMLString
                                                                      imageRequestURLPairArray:imageRequestURLPairArray
                                                                                    postModule:module
                                                                                imageListCount:0
                                                                                    imageIndex:&imageIndex];
    
    // 处理文章详情模版
    NSString *filePath = [[NSBundle mainBundle] pathForResource:CMTNSStringHTMLTemplate_fileName ofType:CMTNSStringHTMLTemplate_fileType];
    NSString *postDetailHTMLString = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    
    postDetailHTMLString = [postDetailHTMLString stringByReplacingOccurrencesOfString:@"{ARTICLE_TITLE}"
                                                                           withString:title.HTMLEscapedString ?: @""];
    
    postDetailHTMLString = [postDetailHTMLString stringByReplacingOccurrencesOfString:@"{ARTICLE_DATE}"
                                                                           withString:DATE(date) ?: @""];
    
    postDetailHTMLString = [postDetailHTMLString stringByReplacingOccurrencesOfString:@"{ARTICLE_AUTHOR}"
                                                                           withString:replacedAuthorHTMLString ?: @""];
    
    postDetailHTMLString = [postDetailHTMLString stringByReplacingOccurrencesOfString:@"{SECTION_NAME}"
                                                                           withString:
                            [NSString stringWithFormat:@"%@%@", replacedTypeHTMLString ?: @"", replacedAttrHTMLString ?: @""]];
    
    postDetailHTMLString = [postDetailHTMLString stringByReplacingOccurrencesOfString:@"{ARTICLE_TAG}"
                                                                           withString:replacedTagHTMLString ?: @""];
    
    postDetailHTMLString = [postDetailHTMLString stringByReplacingOccurrencesOfString:@"{ARTICLE_CONTENT}"
                                                                           withString:replacedContentHTMLString ?: @""];
    
    postDetailHTMLString = [postDetailHTMLString stringByReplacingOccurrencesOfString:@"{CUSTOM_FONTSIZE}"
                                                                           withString:customFontSize ?: @"100"];
    
    // 验证HTMLString
    if (!BEMPTY(postDetailHTMLString)) {
        
        return postDetailHTMLString;
    }
    else {
        CMTLogError(@"HTMLTemplate replace HTMLString Error: Empty HTMLString");
        
        return nil;
    }
}

#pragma mark 简单详情HTMLString

+ (NSString *)simplePostDetailHTMLStringWithTitle:(NSString *)title
                                             date:(NSString *)date
                                         authorId:(NSString *)authorId
                                           author:(NSString *)author
                                       postTypeId:(NSString *)postTypeId
                                         postType:(NSString *)postType
                                         postAttr:(NSString *)postAttr
                                           module:(NSString *)module
                                   customFontSize:(NSString *)customFontSize {
    
    return [self postDetailHTMLStringWithTitle:title
                                          date:date
                                      authorId:authorId
                                        author:author
                                    postTypeId:postTypeId
                                      postType:postType
                                      postAttr:postAttr
                                        module:module
                                customFontSize:customFontSize
                                        postId:nil
                                       themeId:nil
                                         theme:nil
                                 diseaseTagArr:nil
                                    postTagArr:nil
                             contentHTMLString:nil
                      imageRequestURLPairArray:nil];
}
#pragma mark处理@提醒某人
+(NSString*)replacedremindPeople:(NSString*)atuser{
    //替换提醒人标签
    NSString *remindString=@"";
    NSArray *remindArray=[NSJSONSerialization JSONObjectWithData: [atuser dataUsingEncoding:NSUTF8StringEncoding]  options:NSJSONReadingMutableLeaves error:nil];
    if ([remindArray count]>0) {
        remindString=@"提醒 ";
    }
    for (NSDictionary *str in remindArray) {
        
        remindString=[remindString stringByAppendingFormat:@"%@,",[str objectForKey:@"nickName"]];
    }
    return  remindString.length>0?[remindString substringToIndex:remindString.length-1]:remindString;
    
}

#pragma mark 处理文章作者头像

+ (NSString *)replacedAuthorPictureFilePathWithAuthorPictureURL:(NSString *)authorPictureURL
                                       imageRequestURLPairArray:(NSMutableArray *)imageRequestURLPairArray {
    if (BEMPTY(authorPictureURL)) {
        return CMTNSStringHTMLTemplateDefaultAuthorImage;
    }
    
    NSString *requestAuthorPictureURL = [UIImage quadrateScaledImageURLWithURL:authorPictureURL width:40.0];
    NSString *authorPictureFilePath = [[SDWebImageManager sharedManager].imageCache defaultCachePathForKey:
                                       [[SDWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:requestAuthorPictureURL]]];
    // 原始图片有缓存
    if ([[NSFileManager defaultManager] fileExistsAtPath:authorPictureFilePath]) {
        return authorPictureFilePath;
    }
    // 原始图片没有缓存
    else {
        authorPictureFilePath = CMTNSStringHTMLTemplateDefaultAuthorImage;
        // 原始图片URL放入请求图片数组
        if ([imageRequestURLPairArray isKindOfClass:[NSMutableArray class]]) {
            [imageRequestURLPairArray addObject:@{authorPictureURL: authorPictureFilePath}];
        }
    }
    
    return authorPictureFilePath;
}

#pragma mark 处理文章属性

/// postAttr 文章属性
/// 0 默认普通文章；1只含pdf；2 ppt文章；3视频；13表示pdf,视频文章等
/// 本期客户端只处理值为1的情况，此时为文章添加pdf标签；其它值均先忽略
+ (NSString *)replacedAttrHTMLStringWithPostAttr:(NSString *)postAttr {
    
    NSMutableString *attrHTMLString = [[NSMutableString alloc] init];
    
    // 文章属性为投票
    if ([postAttr isPostAttrVote]) {
        
        [attrHTMLString appendString:CMTNSStringHTMLTemplateMark_Vote];
    }
    // 文章属性为问答
    if ([postAttr isPostAttrAnswer]) {
        
        [attrHTMLString appendString:CMTNSStringHTMLTemplateMark_Answer];
    }
    // 文章属性为PDF
    if ([postAttr isPostAttrPDF]) {
        
        [attrHTMLString appendString:CMTNSStringHTMLTemplateMark_PDF];
    }
    if ([postAttr isPostAttrOnlyVideo]) {
        [attrHTMLString appendString:CMTNSStringHTMLTemplateMark_Video];
    }else if ([postAttr isPostAttrAudio]&&![postAttr isPostAttrOnlyVideo]) {
        [attrHTMLString appendString:CMTNSStringHTMLTemplateMark_Audio];
    }else if ([postAttr isPostAttrAudio] &&[postAttr isPostAttrOnlyVideo]) {
        [attrHTMLString appendString:CMTNSStringHTMLTemplateMark_Video];
    }
    
    return [NSString stringWithString:attrHTMLString];
}

#pragma mark 处理文章标签

+ (NSString *)replacedTagHTMLStringWithThemeTagInfo:(NSDictionary *)themeTagInfo
                                      diseaseTagArr:(NSArray *)diseaseTagArr
                                         postTagArr:(NSArray *)postTagArr
                                             module:(NSString *)module {
    
    NSMutableString *tagHTMLString = [[NSMutableString alloc] initWithString:@"<div class=\"label\">"];
    
    // 专题标签
    NSString *theme = themeTagInfo[@"theme"];
    NSString *themeTag = themeTagInfo[@"themeTag"];
    if (!BEMPTY(theme) && !BEMPTY(themeTag)) {
        [tagHTMLString appendString:[self CMT_HTMLLabelSpan_withText:theme
                                                           className:CMTNSStringHTMLTemplateClassName_on_red
                                                             HTMLTag:themeTag]];
    }
    
    // 疾病标签
    if (diseaseTagArr.count > 0) {
        for (NSInteger index = 0; index < [diseaseTagArr count]; index++) {
            CMTDiseaseTag *diseaseTag = diseaseTagArr[index];
            if ([diseaseTag isKindOfClass:[CMTDiseaseTag class]]) {
                [tagHTMLString appendString:[self CMT_HTMLLabelSpan_withText:diseaseTag.disease
                                                                   className:CMTNSStringHTMLTemplateClassName_on
                                                                     HTMLTag:[self CMT_HTMLTagDiseaseTag_withDiseaseId:diseaseTag.diseaseId
                                                                                                               disease:diseaseTag.disease
                                                                                                                 level:diseaseTag.level
                                                                                                                module:module]]];
            }
        }
    }
    // 二级标签
    if (postTagArr.count > 0) {
        for (NSInteger index = 0; index < [postTagArr count]; index++) {
            NSString *postTag = postTagArr[index];
            if ([postTag isKindOfClass:[NSString class]]) {
                [tagHTMLString appendString:[self CMT_HTMLLabelSpan_withText:postTag
                                                                   className:nil
                                                                     HTMLTag:[self CMT_HTMLTagSearchKeyword_withKeyword:postTag
                                                                                                                 module:module]]];
            }
        }
    }
    
    [tagHTMLString appendString:@"</div>"];
    
    return [NSString stringWithString:tagHTMLString];
}

#pragma mark 处理文章详情内容

+ (NSString *)replacedContentHTMLStringWithContentHTMLString:(NSString *)contentHTMLString
                                    imageRequestURLPairArray:(NSMutableArray *)imageRequestURLPairArray
                                                  postModule:(NSString *)postModule
                                              imageListCount:(NSInteger)imageListCount
                                                  imageIndex:(NSString **)imageIndex {
    // 详情内容为空
    if (BEMPTY(contentHTMLString)) {
        return @"&nbsp;";
    }
    
    NSMutableString *mutableContentHTMLString = [NSMutableString stringWithString:contentHTMLString];
    NSString *defaultImagePath = [[NSBundle mainBundle] pathForResource:CMTNSStringHTMLTemplateDefaultImage_fileName
                                                                 ofType:CMTNSStringHTMLTemplateDefaultImage_fileType];
    NSMutableArray *imageReplaceURLPairArray = [NSMutableArray array];
    SDWebImageManager *webImageManager = [SDWebImageManager sharedManager];
    
    // 查找图片URL
    @try {
        NSMutableArray *componentsByImg = [NSMutableArray arrayWithArray:[mutableContentHTMLString componentsSeparatedByString:@"img"]];
        [componentsByImg removeObjectAtIndex:0];
        for (NSString *componentByImg in componentsByImg) {
            NSRange srcRange = [componentByImg rangeOfString:@"src"];
            if (srcRange.length > 0) {
                NSMutableArray *componentsBySrc = [NSMutableArray arrayWithArray:[componentByImg componentsSeparatedByString:@"src"]];
                [componentsBySrc removeObjectAtIndex:0];
                BOOL find = NO;
                for (NSString *componentBySrc in componentsBySrc) {
                    if (find == YES) {
                        break;
                    }
                    for (NSString *componentByQuote in [componentBySrc componentsSeparatedByString:@"\""]) {
                        if (find == YES) {
                            break;
                        }
                        // 找到img标签中src属性的原始图片URL
                        NSRange httpSchemeRange = [componentByQuote rangeOfString:@"http:"];
                        if (httpSchemeRange.length > 0) {
                            NSString *originalImageURLString = componentByQuote;
                            NSString *replacedImageURLString = nil;
                            // 确认@90Q缓存图片是否存在
                            NSString *cacheKey = [webImageManager cacheKeyForURL:[NSURL URLWithString:[UIImage fullQualityImageURLWithURL:originalImageURLString]]];
                            NSString *cachePath = [webImageManager.imageCache defaultCachePathForKey:cacheKey];
                            // @90Q缓存图片存在
                            if ([[NSFileManager defaultManager] fileExistsAtPath:cachePath]) {
                                // 将原始图片URL替换为@90Q缓存图片路径 并添加onclick
                                replacedImageURLString = [originalImageURLString CMT_HTMLImgSrc_ByPlacedWithImagePath:cachePath imageIndex:*imageIndex];
                            }
                            // @90Q缓存图片不存在
                            else {
                                // 病例模块
                                if ([postModule isPostModuleCase]) {
                                    // 确认@40Q并指定宽度截取的缓存图片是否存在
                                    CGFloat imageWidth = (SCREEN_WIDTH - 70.0)/4.0;
                                    if (imageListCount == 1) {
                                        imageWidth = (imageWidth*3.0 + 30.0)/2.0;
                                    }
                                    else if (imageListCount == 2 || imageListCount == 4) {
                                        imageWidth = (imageWidth*3.0 + 10.0)/2.0;
                                    }
                                    cacheKey = [webImageManager cacheKeyForURL:
                                                [NSURL URLWithString:[UIImage lowQualityImageURLWithURL:originalImageURLString contentSize:CGSizeMake(imageWidth, imageWidth)]]];
                                }
                                // 其他模块
                                else {
                                    // 确认@40Q缓存图片是否存在
                                    cacheKey = [webImageManager cacheKeyForURL:[NSURL URLWithString:[UIImage lowQualityImageURLWithURL:originalImageURLString]]];
                                }
                                cachePath = [webImageManager.imageCache defaultCachePathForKey:cacheKey];
                                // @40Q缓存图片存在
                                if ([[NSFileManager defaultManager] fileExistsAtPath:cachePath]) {
                                    // 将原始图片URL替换为@40Q缓存图片路径 并添加onclick
                                    replacedImageURLString = [originalImageURLString CMT_HTMLImgSrc_ByPlacedWithImagePath:cachePath imageIndex:*imageIndex];
                                }
                                // 缓存图片不存在
                                else {
                                    // 将原始图片URL替换为默认图片路径 并添加onclick
                                    replacedImageURLString = [originalImageURLString CMT_HTMLImgSrc_ByPlacedWithDefaultImagePath:defaultImagePath imageIndex:*imageIndex];
                                    // 原始图片URL放入请求图片数组
                                    if ([imageRequestURLPairArray isKindOfClass:[NSMutableArray class]]) {
                                        [imageRequestURLPairArray addObject:@{originalImageURLString: replacedImageURLString}];
                                    }
                                }
                            }
                            // 替换图片路径放入替换图片数组
                            [imageReplaceURLPairArray addObject:@{originalImageURLString: replacedImageURLString}];
                            *imageIndex = [NSString stringWithFormat:@"%ld", (long)((*imageIndex).integerValue + 1)];
                            find = YES;
                        }
                    }
                }
            }
        }
    }
    @catch (NSException *exception) {
        mutableContentHTMLString = [NSMutableString stringWithString:contentHTMLString];
        CMTLogError(@"HTMLTemplate Find 'img' Tag Exception: %@", exception);
    }
    
    // 替换图片
    @try {
        NSMutableSet *lookupSet = [[NSMutableSet alloc] init];
        for (int index = 0; index < [imageReplaceURLPairArray count]; index++) {
            NSDictionary *imageReplaceURLPair = imageReplaceURLPairArray[index];
            // 原始图片URL
            NSString *originalImageURLString = [[imageReplaceURLPair allKeys] objectAtIndex:0];
            
            // 重复的原始图片URL(多张相同图片)只替换一次
            if (![lookupSet containsObject:originalImageURLString]) {
                [lookupSet addObject:originalImageURLString];
                // 被替换的路径
                NSString *replacedImageURLString = imageReplaceURLPair[originalImageURLString];
                [mutableContentHTMLString replaceOccurrencesOfString:originalImageURLString
                                                          withString:replacedImageURLString
                                                             options:NSCaseInsensitiveSearch
                                                               range:NSMakeRange(0, [mutableContentHTMLString length])];
            }
        }
    }
    @catch (NSException *exception) {
        mutableContentHTMLString = [NSMutableString stringWithString:contentHTMLString];
        CMTLogError(@"HTMLTemplate replace 'img' Tag Exception: %@", exception);
    }
    
    return [NSString stringWithString:mutableContentHTMLString];
}

#pragma mark - HTMLTemplate <img>

- (NSString *)CMT_HTMLImgSrc_ByPlacedWithImagePath:(NSString *)imagePath
                                        imageIndex:(NSString *)imageIndex {
    
    return [NSString stringWithFormat:@"%@\" onclick=\"javascript:window.location.href='%@'",
            imagePath ?: @"",
            [NSString CMT_HTMLTagShowPicture_withCurPic:self
                                               picIndex:imageIndex]];
}

- (NSString *)CMT_HTMLImgSrc_ByPlacedWithDefaultImagePath:(NSString *)defaultImagePath
                                               imageIndex:(NSString *)imageIndex {
    
    return [NSString stringWithFormat:@"%@\" ori-src=\"%@\" onclick=\"javascript:window.location.href='%@'",
            defaultImagePath ?: @"",
            self,
            [NSString CMT_HTMLTagShowPicture_withCurPic:self
                                               picIndex:imageIndex]];
}

#pragma mark - HTMLTemplate <a>

+ (NSString *)CMT_HTMLLabel_withText:(NSString *)text
                           className:(NSString *)className
                             HTMLTag:(NSString *)HTMLTag {
    
    NSString *replacedClassHTMLString = @"";
    if (!BEMPTY(className)) {
        replacedClassHTMLString = [NSString stringWithFormat:@"class=\"%@\"", className ?: @""];
    }
    
    return [NSString stringWithFormat:@"<a %@ href=\"%@\">%@</a>",
            replacedClassHTMLString,
            HTMLTag ?: @"",
            text.HTMLEscapedString ?: @""];
}

+ (NSString *)CMT_HTMLLabelSpan_withText:(NSString *)text
                               className:(NSString *)className
                                 HTMLTag:(NSString *)HTMLTag {
    
    return [NSString stringWithFormat:@"<span>%@</span>",
            [self CMT_HTMLLabel_withText:text className:className HTMLTag:HTMLTag]];
}

#pragma mark - HTMLEscape

- (NSDictionary *)specialCharactersRepresentation {
    static NSDictionary *specialCharactersRepresentation = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        specialCharactersRepresentation = @{
                                            @"&": @"&amp;",
                                            @"<": @"&lt;",
                                            @">": @"&gt;",
                                            @"\"": @"&#034;",
                                            @"\'": @"&#039",
                                            };
    });
    
    return specialCharactersRepresentation;
}

- (NSString *)HTMLEscapedString {
    
    NSMutableString *HTMLEscapedString = [[NSMutableString alloc] init];
    NSString *buffer = [self copy];
    
    for (NSInteger index = 0; index < buffer.length; index++) {
        NSString *character = [buffer substringWithRange:(NSRange){index, 1}];
        NSString *escapedCharacter = [self specialCharactersRepresentation][character];
        if (escapedCharacter == nil) {
            [HTMLEscapedString appendString:character];
        }
        else {
            [HTMLEscapedString appendString:escapedCharacter];
        }
    }
    
    return [NSString stringWithString:HTMLEscapedString];
}

- (NSString *)HTMLUnEscapedString {
   
    NSMutableString *HTMLUnEscapedString = [[NSMutableString alloc] initWithString:self];

    for (NSString *escapedString in [[self specialCharactersRepresentation] allValues]) {
        [HTMLUnEscapedString replaceOccurrencesOfString:escapedString
                                             withString:[[[self specialCharactersRepresentation] allKeysForObject:escapedString] firstObject]
                                                options:NSCaseInsensitiveSearch
                                                  range:(NSRange){0, HTMLUnEscapedString.length}];
    }
    
    return [NSString stringWithString:HTMLUnEscapedString];
}
//UTF-8 编码
- (NSString *)encodeToPercentEscapeString{
    // Encode all the reserved characters, per RFC 3986
    // (<http://www.ietf.org/rfc/rfc3986.txt>)
    NSString *outputStr = (NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                            (CFStringRef)self,
                                            NULL,
                                            (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                            kCFStringEncodingUTF8));
    return outputStr;
}
//解码
-(NSString *)URLDecodedString:(NSString *)str
{
    NSString *decodedString=(__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (__bridge CFStringRef)str, CFSTR(""), CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    
    return decodedString;
}
//UTF-8解码 超链接
- (NSString *)decodeFromPercentEscapeString
{
    NSMutableString *outputStr = [NSMutableString stringWithString:self];
    [outputStr replaceOccurrencesOfString:@"+"
                               withString:@" "
                                  options:NSLiteralSearch
                                    range:NSMakeRange(0, [outputStr length])];
    
    return [outputStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}  @end
