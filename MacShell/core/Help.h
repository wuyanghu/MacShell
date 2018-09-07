//
//  Help.h
//  MacShell
//
//  Created by ruantong on 2018/8/8.
//  Copyright © 2018年 ruantong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "CommonMacro.h"

@interface Help : NSObject

+ (NSTask *)runTask:(NSArray *)arguments block:(void(^)(NSString *,NSTask * ))block;

//josn与字典转换
+ (NSString*)dictionaryToJson:(NSDictionary *)dic;
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;

//文件存储于读取
+ (void)storageFilePath:(NSString *)path key:(NSString *)key;
+ (NSString *)getFilePath:(NSString *)key;

//userDefault存储与读取
+ (NSObject *)getUserDefaultObject:(NSString *)key;
+ (void)setUserDefaultObject:(NSObject *)obj key:(NSString *)key;

//打开文件夹
+ (void)openPanel:(NSString *)directory window:(NSWindow *)window block:(void(^)(NSString *))block;

//初始化
+ (void)getArcLanguage:(void(^)(NSString *))block;

//提取url
+ (NSString *)extractUrl:(NSString *)content;
//移除字符串中的换行和空格
+ (NSString *)removeSpaceAndNewline:(NSString *)str;
@end
