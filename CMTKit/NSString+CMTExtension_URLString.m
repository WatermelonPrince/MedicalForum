//
//  NSString+CMTExtension_URLString.m
//  MedicalForum
//
//  Created by fenglei on 15/3/26.
//  Copyright (c) 2015年 CMT. All rights reserved.
//

#import "NSString+CMTExtension_URLString.h"
#import "CMTGroupInfoViewController.h"
#import "CMTLiveDetailViewController.h"
#import "CMTLiveViewController.h"
#import "CMTOtherPostListViewController.h"
#import "LiveVideoPlayViewController.h"
#import "CMTLightVideoViewController.h"
#import "MBProgressHUD.h"
#import "CmtMoreVideoViewController.h"
#import "CMTSeriesDetailsViewController.h"
#import "CMTRecordedViewController.h"
#import "CMTBindingViewController.h"
#import "CMTUpgradeViewController.h"
// HTMLScheme
NSString * const CMTNSStringHTMLScheme_FILE = @"file";

// HTMLTagScheme
NSString * const CMTNSStringHTMLTagScheme_CMTOPDR = @"cmtopdr";

// HTMLTagParseKey
NSString * const CMTNSStringHTMLTagParseKey_header = @"header";
NSString * const CMTNSStringHTMLTagParseKey_domain = @"domain";
NSString * const CMTNSStringHTMLTagParseKey_parameters = @"parameters";

// HTMLTagHeader
NSString * const CMTNSStringHTMLTagHeader = @"cmtopdr://";

// HTMLTagDomain
NSString * const CMTNSStringHTMLTagDomain_postDetail = @"postDetail";

// HTMLTagParameter
NSString * const CMTNSStringHTMLTagParameterKey_action = @"action";

NSString * const CMTNSStringHTMLTagParameterKey_authorid = @"authorid";         // CMTNSStringHTMLTagAction_author
NSString * const CMTNSStringHTMLTagParameterKey_nickname = @"nickname";

NSString * const CMTNSStringHTMLTagParameterKey_posttypeid = @"posttypeid";     // CMTNSStringHTMLTagAction_type
NSString * const CMTNSStringHTMLTagParameterKey_posttype = @"posttype";

NSString * const CMTNSStringHTMLTagParameterKey_themeId = @"themeId";           // CMTNSStringHTMLTagAction_themeTag
NSString * const CMTNSStringHTMLTagParameterKey_theme = @"theme";
NSString * const CMTNSStringHTMLTagParameterKey_postId = @"postId";
NSString * const CMTNSStringHTMLTagParameterKey_postTitle = @"postTitle";

NSString * const CMTNSStringHTMLTagParameterKey_diseaseId = @"diseaseId";       // CMTNSStringHTMLTagAction_diseaseTag
NSString * const CMTNSStringHTMLTagParameterKey_disease = @"disease";
NSString * const CMTNSStringHTMLTagParameterKey_level = @"level";
NSString * const CMTNSStringHTMLTagParameterKey_module = @"module";

NSString * const CMTNSStringHTMLTagParameterKey_keyword = @"keyword";           // CMTNSStringHTMLTagAction_searchKeyword

NSString * const CMTNSStringHTMLTagParameterKey_curPic = @"curPic";             // CMTNSStringHTMLTagAction_showPicture
NSString * const CMTNSStringHTMLTagParameterKey_picList = @"picList";
NSString * const CMTNSStringHTMLTagParameterKey_picIndex = @"picIndex";

NSString * const CMTNSStringHTMLTagParameterKey_pdfUrl = @"pdfUrl";             // CMTNSStringHTMLTagAction_openPDF
NSString * const CMTNSStringHTMLTagParameterKey_id = @"id";
NSString * const CMTNSStringHTMLTagParameterKey_size = @"size";

NSString * const CMTNSStringHTMLTagParameterKey_x = @"x";                       // CMTNSStringHTMLTagAction_appendDetailsCoordinate
NSString * const CMTNSStringHTMLTagParameterKey_y = @"y";

NSString * const CMTNSStringHTMLTagParameterKey_title = @"title";               // CMTNSStringHTMLTagAction_share
NSString * const CMTNSStringHTMLTagParameterKey_brief = @"brief";
NSString * const CMTNSStringHTMLTagParameterKey_url = @"url";
NSString * const CMTNSStringHTMLTagParameterKey_sharePic = @"pic";
NSString * const CMTNSStringHTMLTagParameterKey_postid = @"postid";

// HTMLTagAction
NSString * const CMTNSStringHTMLTagAction_author = @"author";
NSString * const CMTNSStringHTMLTagAction_type = @"type";
NSString * const CMTNSStringHTMLTagAction_themeTag = @"themeTag";
NSString * const CMTNSStringHTMLTagAction_diseaseTag = @"diseaseTag";
NSString * const CMTNSStringHTMLTagAction_searchKeyword = @"searchKeyword";
NSString * const CMTNSStringHTMLTagAction_showPicture = @"showPicture";
NSString * const CMTNSStringHTMLTagAction_openPDF = @"openPDF";
NSString * const CMTNSStringHTMLTagAction_additionalDetails = @"additionalDetails";
NSString * const CMTNSStringHTMLTagAction_additionalConclusions = @"additionalConclusions";
NSString * const CMTNSStringHTMLTagAction_zan = @"zan";
NSString * const CMTNSStringHTMLTagAction_login = @"login";
NSString * const CMTNSStringHTMLTagAction_share = @"share";
NSString * const CMTNSStringHTMLTagAction_epaper = @"epaper";
NSString * const CMTNSStringHTMLTagAction_flag = @"flag";
NSString * const CMTNSStringHTMLTagAction_postDetail = @"postDetail";

@implementation NSString (CMTExtension_URLString)

#pragma mark - HTMLTag

+ (NSString *)CMT_HTMLTag_withHeader:(NSString *)header
                              domain:(NSString *)domain
                              action:(NSString *)action
                          parameters:(NSDictionary *)parameters {
    
    NSMutableString *HTMLTag = [NSMutableString stringWithFormat:@"%@%@?%@=%@", header ?: @"", domain ?: @"", CMTNSStringHTMLTagParameterKey_action, action ?: @""];
    for (NSString *key in parameters.allKeys) {
        [HTMLTag appendFormat:@"&%@=%@", key ?: @"", [parameters[key] URLEncodeString] ?: @""];
    }
    
    return [NSString stringWithString:HTMLTag];
}

+ (NSString *)CMT_HTMLTagAuthor_withAuthorid:(NSString *)authorid
                                    nickname:(NSString *)nickname {
    
    return [self CMT_HTMLTag_withHeader:CMTNSStringHTMLTagHeader
                                 domain:CMTNSStringHTMLTagDomain_postDetail
                                 action:CMTNSStringHTMLTagAction_author
                             parameters:@{
                                          CMTNSStringHTMLTagParameterKey_authorid: authorid ?: @"",
                                          CMTNSStringHTMLTagParameterKey_nickname: nickname ?: @"",
                                          }];
}

+ (NSString *)CMT_HTMLTagType_withPosttypeid:(NSString *)posttypeid
                                    posttype:(NSString *)posttype {
    
    return [self CMT_HTMLTag_withHeader:CMTNSStringHTMLTagHeader
                                 domain:CMTNSStringHTMLTagDomain_postDetail
                                 action:CMTNSStringHTMLTagAction_type
                             parameters:@{
                                          CMTNSStringHTMLTagParameterKey_posttypeid: posttypeid ?: @"",
                                          CMTNSStringHTMLTagParameterKey_posttype: posttype ?: @"",
                                          }];
}

+ (NSString *)CMT_HTMLTagThemeTag_withThemeId:(NSString *)themeId
                                        theme:(NSString *)theme
                                       postId:(NSString *)postId
                                    postTitle:(NSString *)postTitle {
    
    return [self CMT_HTMLTag_withHeader:CMTNSStringHTMLTagHeader
                                 domain:CMTNSStringHTMLTagDomain_postDetail
                                 action:CMTNSStringHTMLTagAction_themeTag
                             parameters:@{
                                          CMTNSStringHTMLTagParameterKey_themeId: themeId ?: @"",
                                          CMTNSStringHTMLTagParameterKey_theme: theme ?: @"",
                                          CMTNSStringHTMLTagParameterKey_postId: postId ?: @"",
                                          CMTNSStringHTMLTagParameterKey_postTitle: postTitle ?: @"",
                                          }];
}

+ (NSString *)CMT_HTMLTagDiseaseTag_withDiseaseId:(NSString *)diseaseId
                                          disease:(NSString *)disease
                                            level:(NSString *)level
                                           module:(NSString *)module {
    
    return [self CMT_HTMLTag_withHeader:CMTNSStringHTMLTagHeader
                                 domain:CMTNSStringHTMLTagDomain_postDetail
                                 action:CMTNSStringHTMLTagAction_diseaseTag
                             parameters:@{
                                          CMTNSStringHTMLTagParameterKey_diseaseId: diseaseId ?: @"",
                                          CMTNSStringHTMLTagParameterKey_disease: disease ?: @"",
                                          CMTNSStringHTMLTagParameterKey_level: level ?: @"",
                                          CMTNSStringHTMLTagParameterKey_module: module ?: @"",
                                          }];
}

+ (NSString *)CMT_HTMLTagSearchKeyword_withKeyword:(NSString *)keyword
                                            module:(NSString *)module; {
    
    return [self CMT_HTMLTag_withHeader:CMTNSStringHTMLTagHeader
                                 domain:CMTNSStringHTMLTagDomain_postDetail
                                 action:CMTNSStringHTMLTagAction_searchKeyword
                             parameters:@{
                                          CMTNSStringHTMLTagParameterKey_keyword: keyword ?: @"",
                                          CMTNSStringHTMLTagParameterKey_module: module ?: @"",
                                          }];
}

+ (NSString *)CMT_HTMLTagShowPicture_withCurPic:(NSString *)curPic
                                       picIndex:(NSString *)picIndex {
    
    return [self CMT_HTMLTag_withHeader:CMTNSStringHTMLTagHeader
                                 domain:CMTNSStringHTMLTagDomain_postDetail
                                 action:CMTNSStringHTMLTagAction_showPicture
                             parameters:@{
                                          CMTNSStringHTMLTagParameterKey_curPic: curPic ?: @"",
                                          CMTNSStringHTMLTagParameterKey_picIndex: picIndex ?: @"",
                                          }];
}

- (NSDictionary *)CMT_HTMLTag_parseDictionary {
    if (BEMPTY(self)) {
        return nil;
    }
    
    NSString *header, *domain;
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    @try {
        // header, domain
        NSString *parametersString;
        NSRange headerRange = [self rangeOfString:CMTNSStringHTMLTagHeader options:NSCaseInsensitiveSearch];
        if (headerRange.length > 0) {
            header = [self substringToIndex:headerRange.location + headerRange.length];
            NSString *afterHeader = [self substringFromIndex:headerRange.location + headerRange.length];
            NSRange markRange = [afterHeader rangeOfString:@"?"];
            if (markRange.length > 0) {
                domain = [afterHeader substringToIndex:markRange.location];
                parametersString = [afterHeader substringFromIndex:markRange.location + markRange.length];
            }
            else {
                domain = afterHeader;
            }
        }
        else {
            CMTLogError(@"NSString Parse HTMLTag Error: Wrong Header");
            return nil;
        }
        
        // parameters
        for (NSString *parameterBody in [parametersString componentsSeparatedByString:@"&"]) {
            NSRange equalRang = [parameterBody rangeOfString:@"="];
            if (equalRang.length > 0) {
                NSString *key = [[parameterBody substringToIndex:equalRang.location] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                NSString *value = [[parameterBody substringFromIndex:equalRang.location + equalRang.length] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                [parameters setObject:value forKey:key];
            }
        }
    }
    @catch (NSException *exception) {
        CMTLogError(@"NSString Parse HTMLTag Exception: %@", exception);
        return nil;
    }
    
    return @{
             CMTNSStringHTMLTagParseKey_header: header ?: @"",
             CMTNSStringHTMLTagParseKey_domain: domain ?: @"",
             CMTNSStringHTMLTagParseKey_parameters: parameters ?: @{}
             };
}
- (NSDictionary *)CMT_HTMLTag_parseDictionary:(NSString*)CMTNSstringHTMLTagHeader {
    if (BEMPTY(self)) {
        return nil;
    }
    
    NSString *header, *domain;
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    @try {
        // header, domain
        NSString *parametersString;
        NSRange headerRange = [self rangeOfString:CMTNSstringHTMLTagHeader options:NSCaseInsensitiveSearch];
        if (headerRange.length > 0) {
            header = [self substringToIndex:headerRange.location + headerRange.length];
            NSString *afterHeader = [self substringFromIndex:headerRange.location + headerRange.length];
            NSRange markRange = [afterHeader rangeOfString:@"?"];
            if (markRange.length > 0) {
                domain = [afterHeader substringToIndex:markRange.location];
                parametersString = [afterHeader substringFromIndex:markRange.location + markRange.length];
            }
            else {
                domain = afterHeader;
            }
        }
        else {
            CMTLogError(@"NSString Parse HTMLTag Error: Wrong Header");
            return nil;
        }
        
        // parameters
        for (NSString *parameterBody in [parametersString componentsSeparatedByString:@"&"]) {
            NSRange equalRang = [parameterBody rangeOfString:@"="];
            if (equalRang.length > 0) {
                NSString *key = [[parameterBody substringToIndex:equalRang.location] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                NSString *value = [[parameterBody substringFromIndex:equalRang.location + equalRang.length] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                [parameters setObject:value forKey:key];
            }
        }
    }
    @catch (NSException *exception) {
        CMTLogError(@"NSString Parse HTMLTag Exception: %@", exception);
        return nil;
    }
    
    return @{
             CMTNSStringHTMLTagParseKey_header: header ?: @"",
             CMTNSStringHTMLTagParseKey_domain: domain ?: @"",
             CMTNSStringHTMLTagParseKey_parameters: parameters ?: @{}
             };
}

#pragma mark - URLEncode

- (NSString *)URLEncodeString {
    
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                 kCFAllocatorDefault,
                                                                                 (CFStringRef)self,
                                                                                 NULL,
                                                                                 (CFStringRef)@"!*'();:@&=+$,/?%#[]~！@#￥%……&（）——+《》？：“，。、·】【、；‘-",
                                                                                 kCFStringEncodingUTF8));
}

- (NSString *)URLDecodeString {
    
    return [[self stringByReplacingOccurrencesOfString:@"+" withString:@" "]
            stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

#pragma mark - ImageURL

- (NSString *)imageSuffix {
    
    return [[@"." stringByAppendingString:
             [[self componentsSeparatedByString:@"."] lastObject]]
            lowercaseString];
}
#pragma mark 处理应用内文章链接
-(BOOL)handleWithinArticle:(NSString*)urlString viewController:(CMTBaseViewController*)Controller{
    BOOL flag=NO;
    NSString *postUuid=nil;
    if ([urlString componentsSeparatedByString:@"?"].count>1) {
        NSString *headtag=@"http://";
        if ([urlString hasPrefix:@"https://"]) {
            headtag=@"https://";
        }
        NSDictionary *parseDictionary = [urlString CMT_HTMLTag_parseDictionary:headtag]  ;
        NSDictionary *parameters = parseDictionary[CMTNSStringHTMLTagParseKey_parameters];
        postUuid = parameters[@"uid"];
        if(postUuid.length==0){
            NSArray *array=[urlString componentsSeparatedByString:@"?"];
            NSArray *array2=[array[0] componentsSeparatedByString:@"/"];
            postUuid=[array2.lastObject componentsSeparatedByString:@"."][0];
        }
    }else{
        NSArray *array=[urlString componentsSeparatedByString:@"/"];
        postUuid=[array.lastObject componentsSeparatedByString:@"."][0];
    }
    
    if ([self JudgeLinktype:urlString url:@"media/phone/post/app/"]) {
        
        [Controller setContentState:CMTContentStateLoading];
        Controller.contentBaseView.hidden=NO;
        [[[CMTCLIENT getPostStatistics:@{
                                         @"userId": CMTUSERINFO.userId ?: @"",
                                         @"postUuid": postUuid?: @"",
                                         }]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(CMTPostStatistics *Statistics) {
              [Controller setContentState:CMTContentStateNormal];
            if (Statistics.groupId.integerValue==0) {
                CMTPostDetailCenter *postDetailCenter = [CMTPostDetailCenter postDetailWithPostId:Statistics.postId
                                                                                           isHTML:Statistics.isHTML
                                                                                          postURL:Statistics.url
                                                                                       postModule:Statistics.module
                                                                                   postDetailType:CMTPostDetailTypeHomePostList];
                
                [Controller.navigationController pushViewController:postDetailCenter animated:YES];
                
            }else{
                CMTGroup *group=[[CMTGroup alloc]init];
                group.groupId=Statistics.groupId;
                group.groupName=Statistics.groupName;
                CMTPostDetailCenter *postDetailCenter = [CMTPostDetailCenter postDetailWithPostId:Statistics.postId
                                                                                           isHTML:Statistics.isHTML
                                                                                          postURL:Statistics.url
                                                                                            group:group
                                                                                       postModule:Statistics.module
                                                                                   postDetailType:CMTPostDetailTypeHomePostList];
                
                [Controller.navigationController pushViewController:postDetailCenter animated:YES];
            }
            
        }error:^(NSError *error) {
            if(error.userInfo[@"errmsg"]==nil){
                [Controller toastAnimation:@"获取信息失败"];
            }else{
                [Controller toastAnimation:error.userInfo[@"errmsg"]];
            }
             [Controller setContentState:CMTContentStateNormal];
        } completed:^{
            NSLog(@"请求成功");
        }];
        
        
        
    }else if([self JudgeLinktype:urlString url:@"media/phone/theme/"]){
        [Controller.navigationController pushViewController:
         [[CMTOtherPostListViewController alloc] initWithThemeUIid:postUuid] animated:YES];
        
    }else if([self JudgeLinktype:urlString url:@"media/phone/group/"]){
        [Controller.navigationController pushViewController:
         [[CMTGroupInfoViewController alloc] initWithGroupUuid:postUuid] animated:YES];
        
    }else if([self JudgeLinktype:urlString url:@"media/phone/group/private/"]){
        if (!CMTUSER.login) {
            CMTBindingViewController *loginVC = [CMTBindingViewController shareBindVC];
            loginVC.nextvc = kComment;
            [Controller.navigationController pushViewController:loginVC animated:YES];
        }else if (CMTUSERINFO.roleId.integerValue==0) {
            if (CMTUSERINFO.authStatus.integerValue!=1) {
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"该小组已设置加入权限\n完善信息后可申请加入" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"去完善信息",nil];
                [[alert rac_buttonClickedSignal] subscribeNext:^(NSNumber *index) {
                    if ([index integerValue] == 1) {
                        CMTUpgradeViewController *upgrade=[[CMTUpgradeViewController alloc]init];
                        upgrade.lastVC = @"CMTReadCodeBlind";
                        [Controller.navigationController pushViewController:upgrade animated:YES];
                    }
                }];
                [alert show];
                flag=NO;

            }
        }else{

            [Controller.navigationController pushViewController:
            [[CMTGroupInfoViewController alloc] initWithGroupUuid:postUuid] animated:YES];
        }
    }else if([self JudgeLinktype:urlString url:@"media/phone/wx/live/list/"]){
         [Controller.navigationController pushViewController:[[CMTLiveViewController alloc] initWithliveUuid:postUuid] animated:YES];
        
    }else if([self JudgeLinktype:urlString url:@"media/phone/wx/live/message/"]){
        [Controller.navigationController pushViewController:
         [[CMTLiveDetailViewController alloc] initWithLiveMessageUuid:postUuid liveDetailType:0] animated:YES];
    }else if([self JudgeLinktype:urlString url:@"media/phone/wx/liveClassroom/collegeShare/"]){
        CMTCollegeDetail *college=[[CMTCollegeDetail alloc]init];
        college.collegeId=postUuid;
        CmtMoreVideoViewController *more=[[CmtMoreVideoViewController alloc]initWithCollege:college type:CMTCollCollegeVideo];
        [Controller.navigationController pushViewController:more animated:YES];
        
    }else if([self JudgeLinktype:urlString url:@"media/phone/wx/liveClassroom/theme/detail/"]){
        CMTSeriesDetails *Series=[[CMTSeriesDetails alloc]init];
        Series.themeUuid=postUuid;
        CMTSeriesDetailsViewController *SeriesDetails=[[CMTSeriesDetailsViewController alloc]initWithParam:Series];
        [Controller.navigationController pushViewController:SeriesDetails animated:YES];
        
    }else if([self JudgeLinktype:urlString url:@"media/phone/wx/liveClassroom/detail/"]){
        [self AccessToTheRecorded:postUuid contoller:Controller];
        
    }else if([self JudgeLinktype:urlString url:@"media/phone/gensee/app/0/"]){
        [self dealWithLiveOrOnDemand:postUuid type:@"0" contoller:Controller];
    }else if([self JudgeLinktype:urlString url:@"media/phone/gensee/app/1/"]){
        [self dealWithLiveOrOnDemand:postUuid type:@"1" contoller:Controller];
    }else{
        flag=YES;
    }
    return flag;
}
//处理直播或者点播分享链接
-(void)dealWithLiveOrOnDemand:(NSString*)postUuid type:(NSString*)type contoller:(CMTBaseViewController*)Controller{
    if([Controller getNetworkReachabilityStatus].integerValue==0){
        
        [Controller toastAnimation:@"无法连接到网络，请检查网络设置"];
    }else if ([Controller getNetworkReachabilityStatus].integerValue==1) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"当前非wifi环境下\n是否继续观看课程" message:nil delegate:nil
                                           cancelButtonTitle:@"取消" otherButtonTitles:@"继续观看", nil];
        [[[alert rac_buttonClickedSignal]deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSNumber *index) {
            if ([index integerValue] == 1) {
                [self ViewTheLiveOrOnDemand:postUuid liveType:type contoller:Controller];
            }
        }];
        [alert show];
        
    }else{
        [self ViewTheLiveOrOnDemand:postUuid liveType:type contoller:Controller];
        
    }

}
//兼容http链接
-(BOOL)JudgeLinktype:(NSString*)urlString url:(NSString*)url{
    BOOL flag=NO;
    NSString *defaultClient=@"http://app.medtrib.cn/";
  #ifdef DEBUG
    defaultClient =@"http://topdr.test.medtrib.cn/";
   #else
     defaultClient = @"http://app.medtrib.cn/";
   #endif
    if([urlString hasPrefix:[[CMTClient defaultClient].baseURL.absoluteString stringByAppendingString:url]]||[urlString hasPrefix:[defaultClient stringByAppendingString:url]]){
        flag=YES;
    }
    return flag;
}
//根据录播ID 获取录播详情
-(void)AccessToTheRecorded:(NSString*)postUuid contoller:(CMTBaseViewController*)Controller{
    [MBProgressHUD showHUDAddedTo:Controller.contentBaseView animated:YES];
    NSDictionary *param = @{
                            @"userId":CMTUSERINFO.userId?:@"0",
                            @"coursewareId":postUuid?:@"",
                            };
    [[[CMTCLIENT CMTGetIfRecordedJumpOnDemand:param] deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(CMTLivesRecord *param) {
      
            CMTRecordedViewController *Recorded=[[CMTRecordedViewController alloc]initWithRecordedParam:param];
            [Controller.navigationController pushViewController:Recorded animated:YES];
            [MBProgressHUD hideHUDForView:Controller.contentBaseView animated:YES];
    }error:^(NSError *error) {
        if (error.code>=-1009&&error.code<=-1001) {
            [Controller toastAnimation:@"你的网络不给力"];
        }else{
            NSString *errcode = error.userInfo[CMTClientServerErrorCodeKey];
            [Controller toastAnimation:errcode];
        }
        [MBProgressHUD hideHUDForView:Controller.contentBaseView animated:YES];
        
    } completed:^{
        NSLog(@"完成");
    }];

}
//请求直播uuid 查看直播是否变成点播
-(void)ViewTheLiveOrOnDemand:(NSString*)postUuid liveType:(NSString*)liveType contoller:(CMTBaseViewController*)Controller{
    [MBProgressHUD showHUDAddedTo:Controller.contentBaseView animated:YES];
    NSDictionary *param = @{
                            @"userId":CMTUSERINFO.userId?:@"0",
                            @"liveUuid":postUuid?:@"",
                            @"targetType":@"1",
                            @"liveType":liveType?:@"0"
                            };
    [[[CMTCLIENT CMTGetIfLiveJumpOnDemand:param] deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(CmtLiveOrOnDemand *param) {
        if (param.roominfo!=nil) {
            LiveVideoPlayViewController *LiveVideoPlay=[[LiveVideoPlayViewController alloc]initWithParam:param.roominfo];
            LiveVideoPlay.networkReachabilityStatus=@"2";
            LiveVideoPlay.EnterType=1;
            [Controller.navigationController pushViewController:LiveVideoPlay animated:YES];
        }else{
            CMTLightVideoViewController *light=[[CMTLightVideoViewController alloc]init];
            light.myliveParam=param.videoinfo;
            [Controller.navigationController pushViewController:light animated:YES];
        }
         [MBProgressHUD hideHUDForView:Controller.contentBaseView animated:YES];
    }error:^(NSError *error) {
        if (error.code>=-1009&&error.code<=-1001) {
            [Controller toastAnimation:@"你的网络不给力"];
        }else{
            NSString *errcode = error.userInfo[CMTClientServerErrorCodeKey];
            [Controller toastAnimation:errcode];
        }
         [MBProgressHUD hideHUDForView:Controller.contentBaseView animated:YES];
        
    } completed:^{
        NSLog(@"完成");
    }];

}
-(void)ChangeTabs:(NSString*)type{
    UINavigationController *nav=APPDELEGATE.tabBarController.viewControllers[APPDELEGATE.tabBarController.selectedIndex];
    [nav popToRootViewControllerAnimated:NO];
    if([type isEqualToString:@"post"]||[type isEqualToString:@"theme"]||[type isEqualToString:@"graphicLive"]||[type isEqualToString:@"graphicLiveMessage"]){
        if( APPDELEGATE.tabBarController.selectedIndex!=0){
            APPDELEGATE.tabBarController.selectedIndex=0;
        }
        
    }else if([type isEqualToString:@"group"]||[type isEqualToString:@"privateGroup"]){
        if( APPDELEGATE.tabBarController.selectedIndex!=1){
            APPDELEGATE.tabBarController.selectedIndex=1;
        }
        
    }else{
        if(APPDELEGATE.tabBarController.selectedIndex!=2){
            APPDELEGATE.tabBarController.selectedIndex=2;
        }
    }

}
//处理分享链接
-(void)handleWithinArticleShare:(NSString*)postUuid  type:(NSString*)type{
    if ([type isEqualToString:@"post"]) {
        UINavigationController * nav=APPDELEGATE.tabBarController.viewControllers[APPDELEGATE.tabBarController.selectedIndex];
        [MBProgressHUD showHUDAddedTo:((CMTBaseViewController*)nav.topViewController).contentBaseView animated:YES];
        [[[CMTCLIENT getPostStatistics:@{
                                         @"userId": CMTUSERINFO.userId ?: @"",
                                         @"postUuid": postUuid?: @"",
                                         }]deliverOn:[RACScheduler mainThreadScheduler]]subscribeNext:^(CMTPostStatistics *Statistics) {
             [MBProgressHUD hideHUDForView:((CMTBaseViewController*)nav.topViewController).contentBaseView animated:YES];
            if (Statistics.groupId.integerValue==0) {
                CMTPostDetailCenter *postDetailCenter = [CMTPostDetailCenter postDetailWithPostId:Statistics.postId
                                                                                           isHTML:Statistics.isHTML
                                                                                          postURL:Statistics.url
                                                                                       postModule:Statistics.module
                                                                                   postDetailType:CMTPostDetailTypeHomePostList];
                 APPDELEGATE.tabBarController.selectedIndex=0;
                 CMTBaseViewController *Controller=[self getController:type];
                [Controller.navigationController pushViewController:postDetailCenter animated:YES];
                
                
            }else{
                CMTGroup *group=[[CMTGroup alloc]init];
                group.groupId=Statistics.groupId;
                group.groupName=Statistics.groupName;
                CMTPostDetailCenter *postDetailCenter = [CMTPostDetailCenter postDetailWithPostId:Statistics.postId
                                                                                           isHTML:Statistics.isHTML
                                                                                          postURL:Statistics.url
                                                                                            group:group
                                                                                       postModule:Statistics.module
                                                                                   postDetailType:CMTPostDetailTypeHomePostList];
                APPDELEGATE.tabBarController.selectedIndex=0;
                CMTBaseViewController *Controller=[self getController:type];
                [Controller.navigationController pushViewController:postDetailCenter animated:YES];
            }
            
        }error:^(NSError *error) {
            CMTBaseViewController *Controller=(CMTBaseViewController*)nav.topViewController;
            [MBProgressHUD hideHUDForView:Controller.contentBaseView animated:YES];
            if(error.userInfo[@"errmsg"]==nil){
                [Controller toastAnimation:@"获取信息失败"];
            }else{
                [Controller toastAnimation:error.userInfo[@"errmsg"]];
            }
        } completed:^{
            NSLog(@"请求成功");
        }];
        
        
        
    }else if([type isEqualToString:@"theme"]){
         CMTBaseViewController *Controller=[self getController:type];
        [Controller.navigationController pushViewController:
         [[CMTOtherPostListViewController alloc] initWithThemeUIid:postUuid] animated:YES];
        
    }else if([type isEqualToString:@"group"]){
         CMTBaseViewController *Controller=[self getController:type];
        [Controller.navigationController pushViewController:
         [[CMTGroupInfoViewController alloc] initWithGroupUuid:postUuid] animated:YES];
        
    }else if([type isEqualToString:@"privateGroup"]){
        CMTBaseViewController *Controller=[self getController:type];
        if (!CMTUSER.login) {
            CMTBindingViewController *loginVC = [CMTBindingViewController shareBindVC];
            loginVC.nextvc = kComment;
            [Controller.navigationController pushViewController:loginVC animated:YES];
        }else if (CMTUSERINFO.roleId.integerValue==0) {
            if (CMTUSERINFO.authStatus.integerValue!=1) {
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"该小组已设置加入权限\n完善信息后可申请加入" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"去完善信息",nil];
                [[alert rac_buttonClickedSignal] subscribeNext:^(NSNumber *index) {
                    if ([index integerValue] == 1) {
                        CMTUpgradeViewController *upgrade=[[CMTUpgradeViewController alloc]init];
                        upgrade.lastVC = @"CMTReadCodeBlind";
                        [Controller.navigationController pushViewController:upgrade animated:YES];
                    }
                }];
                [alert show];
            }
        }else{
           [Controller.navigationController pushViewController:
            [[CMTGroupInfoViewController alloc] initWithGroupUuid:postUuid] animated:YES];
        }
    }else if([type isEqualToString:@"graphicLive"]){
         CMTBaseViewController *Controller=[self getController:type];
        [Controller.navigationController pushViewController:[[CMTLiveViewController alloc] initWithliveUuid:postUuid] animated:YES];
        
    }else if([type isEqualToString:@"graphicLiveMessage"]){
        CMTBaseViewController *Controller=[self getController:type];
        [Controller.navigationController pushViewController:
         [[CMTLiveDetailViewController alloc] initWithLiveMessageUuid:postUuid liveDetailType:0] animated:YES];
    }else if([type isEqualToString:@"college"]){
        CMTBaseViewController *Controller=[self getController:type];
        CMTCollegeDetail *college=[[CMTCollegeDetail alloc]init];
        college.collegeId=postUuid;
        CmtMoreVideoViewController *more=[[CmtMoreVideoViewController alloc]initWithCollege:college type:CMTCollCollegeVideo];
        [Controller.navigationController pushViewController:more animated:YES];
        
    }else if([type isEqualToString:@"series"]){
        CMTBaseViewController *Controller=[self getController:type];
        CMTSeriesDetails *Series=[[CMTSeriesDetails alloc]init];
        Series.themeUuid=postUuid;
        CMTSeriesDetailsViewController *SeriesDetails=[[CMTSeriesDetailsViewController alloc]initWithParam:Series];
        [Controller.navigationController pushViewController:SeriesDetails animated:YES];
        
    }else if([type isEqualToString:@"recordedVideo"]){
        CMTBaseViewController *Controller=[self getController:type];
        [self AccessToTheRecorded:postUuid contoller:Controller];
        
    }else if([type isEqualToString:@"liveVideo"]){
        CMTBaseViewController *Controller=[self getController:type];
          [self dealWithLiveOrOnDemand:postUuid type:@"0" contoller:Controller];
    }else if([type isEqualToString:@"demandVideo"]){
        CMTBaseViewController *Controller=[self getController:type];
         [self dealWithLiveOrOnDemand:postUuid type:@"1" contoller:Controller];
    }
}
//获取跳转类
-(CMTBaseViewController*)getController:(NSString*)type{
    [self ChangeTabs:type];
    UINavigationController * nav=APPDELEGATE.tabBarController.viewControllers[APPDELEGATE.tabBarController.selectedIndex];
    CMTBaseViewController *Controller=(CMTBaseViewController*)nav.topViewController;
    return Controller;

}
//获取替换时间格式
- (NSString *)getTimeByDate:(NSDate *)date byProgress:(float)current {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSInteger hour=0;
    if (current / 3600 >= 1) {
        hour =(NSInteger)(current/3600);
        date=[NSDate dateWithTimeIntervalSince1970:current-hour*3600];
        [formatter setDateFormat:@"mm:ss"];
    } else {
        [formatter setDateFormat:@"mm:ss"];
    }
    if (hour>=1) {
        return [NSString stringWithFormat:@"%@%ld:%@",hour>9?@"":@"0",hour,[formatter stringFromDate:date]];
    }else{
        return [NSString stringWithFormat:@"%@:%@",@"00",[formatter stringFromDate:date]];
    }
    return [formatter stringFromDate:date];
}

@end
