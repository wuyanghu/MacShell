//
//  FileCache.m
//  MacShell
//
//  Created by ruantong on 2018/8/9.
//  Copyright © 2018年 ruantong. All rights reserved.
//

#import "FileCache.h"

@implementation FileCache


+ (void)writeFile:(NSString *)fileName content:(NSString *)content{
    NSString *dirDoc = [self getDoucumentPath];
    NSString *dirFile = [dirDoc stringByAppendingPathComponent:fileName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
    
    if ( ![fileManager fileExistsAtPath:dirFile]) {
        [fileManager createFileAtPath:dirFile contents:nil attributes:nil];
    }
    [data writeToFile:dirFile atomically:YES];
}

+ (NSString *)readFile:(NSString *)fileName {
    NSString *dirDoc = [self getDoucumentPath];
    NSString *dirFile = [dirDoc stringByAppendingPathComponent:fileName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:dirFile]) {
        NSString *content = [NSString stringWithContentsOfFile:dirFile encoding:NSUTF8StringEncoding error:nil];
        return content;
    }
    return nil;
}

//获取文件沙盒路径
+ (NSString *)getDoucumentPath{
    NSString *dirDoc = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    return dirDoc;
}

//清除缓存
+ (void)clearFileCache:(NSArray *)fileNameArr{
    NSString *documentsDirectory = [self getDoucumentPath];
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    
    for (NSString * fileName in fileNameArr) {
        NSString *MapLayerDataPath = [documentsDirectory stringByAppendingPathComponent:fileName];
        BOOL bRet = [fileMgr fileExistsAtPath:MapLayerDataPath];
        if (bRet) {
            NSError *err;
            [fileMgr removeItemAtPath:MapLayerDataPath error:&err];
        }
    }
}


@end
