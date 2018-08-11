//
//  Help.h
//  MacShell
//
//  Created by ruantong on 2018/8/8.
//  Copyright © 2018年 ruantong. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kChensong @"chensong"
#define kShezhiqiang @"shezhiqiang"

#define kChooseFilePath @"chooseFilePath"//缓存选择文件的路径

typedef void(^ResultBlock)(NSString * resultStr,NSTask * task);

@interface Help : NSObject
+ (void)runTask:(NSArray *)arguments block:(ResultBlock)block;
+ (void)runRootTask:(NSArray *)arguments;

+ (NSDictionary *)getAuditInfo;
+ (void)storageAuditInfo:(NSMutableDictionary *)auditInfoDict;
+ (void)storageFilePath:(NSString *)path;
+ (NSString *)getFilePath;

@end
