//
//  FileCache.h
//  MacShell
//
//  Created by ruantong on 2018/8/9.
//  Copyright © 2018年 ruantong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileCache : NSObject
+ (void)writeFile:(NSString *)fileName content:(NSString *)content;
+ (NSString *)readFile:(NSString *)fileName;

+ (NSString *)getDoucumentPath;//获取doucument路径
+ (void)clearFileCache:(NSArray *)fileNameArr;//清除缓存
@end
