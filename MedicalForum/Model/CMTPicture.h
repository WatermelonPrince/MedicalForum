//
//  CMTPicture.h
//  MedicalForum
//
//  Created by guanyx on 14/12/11.
//  Copyright (c) 2014年 CMT. All rights reserved.
//

#import "CMTObject.h"

@interface CMTPicture : CMTObject

/* send parameters */

/// pictureFilePath 本地文件路径  string
@property (nonatomic, copy, readwrite) NSString *pictureFilePath;
/// assetRepresentationURL  照片库URL  string
@property (nonatomic, copy, readwrite) NSString *assetRepresentationURL;

/* receive parameters */

@property (nonatomic, copy, readwrite) NSString *picture;

/// picId   图片id    long
@property (nonatomic, copy, readwrite) NSString *picId;
/// picUrl  图片url   string
@property (nonatomic, copy, readwrite) NSString *picUrl;
@property (nonatomic, copy, readwrite) NSString *picFilepath;
/// originFileName  上传文件名称  string
@property (nonatomic, copy, readwrite) NSString *originFileName;
@property (nonatomic, copy, readwrite) NSString *originalFilename;
/// picAttr 图片宽高属性  string
/// 格式：宽度_高度，例如 800_600
@property (nonatomic, copy, readwrite) NSString *picAttr;
/// success 是否上传成功  string
/// true:成功 false:失败
@property (nonatomic, copy, readwrite) NSString *success;
/// errMsg  错误信息    string
@property (nonatomic, copy, readwrite) NSString *errMsg;
/// diseaseExtId    追加描述/结论 id  long
/// 可用该字段判断图片是文章中的图片还是追加描述/结论中的图片。如果该字段为0 表示图片是文章中的
@property (nonatomic, copy, readwrite) NSString *diseaseExtId;

@property (nonatomic, copy)NSString *groupId;
//广告链接
@property (nonatomic,copy) NSString *adPic;
//广告描述
@property(nonatomic,copy)NSString *descption;

@end
