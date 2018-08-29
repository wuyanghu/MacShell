//
//  Help.h
//  MacShell
//
//  Created by ruantong on 2018/8/8.
//  Copyright © 2018年 ruantong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

#define kChooseFilePath @"chooseFilePath"//缓存选择文件的路径
#define kArcCommandPath @"arcCommandPath"//arc文件命令所在目录
#define kArcLanguagePath @"arcLanguagePath"//arc使用语言(中文or英文)

#define kCommitInfo @"commitInfo" 

@interface Help : NSObject
+ (NSTask *)runTask:(NSArray *)arguments block:(void(^)(NSString *,NSTask * ))block;
+ (void)runRootTask:(NSArray *)arguments;

+ (NSString*)dictionaryToJson:(NSDictionary *)dic;
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;

+ (NSDictionary *)getAuditInfo;
+ (void)storageAuditInfo:(NSMutableDictionary *)auditInfoDict;
+ (void)storageFilePath:(NSString *)path key:(NSString *)key;
+ (NSString *)getFilePath:(NSString *)key;

+ (NSObject *)getUserDefaultObject:(NSString *)key;
+ (void)storageUserDefaultObject:(NSObject *)obj key:(NSString *)key;

+ (void)openPanel:(NSString *)directory window:(NSWindow *)window block:(void(^)(NSString *))block;

+ (void)getArcLanguage:(void(^)(NSString *))block;
@end
