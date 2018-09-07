//
//  FileCache.h
//  MacShell
//
//  Created by ruantong on 2018/8/9.
//  Copyright © 2018年 ruantong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileCacheManager : NSObject
+ (instancetype)shareInstance;
//异步访问
- (void)readFileAsync:(NSString *)fileName complete:(void (^)(NSString *))complete;
- (void)writeFileAsync:(NSString *)fileName content:(NSString *)content complete:(void (^)(BOOL result))complete;
//同步访问
- (void)writeFileSync:(NSString *)fileName content:(NSString *)content;
- (NSString *)readFileSync:(NSString *)fileName;

- (NSString *)getDoucumentPath;//获取doucument路径
- (void)clearFileCache:(NSArray *)fileNameArr;//清除缓存
@end
