//
//  FileCache.m
//  MacShell
//
//  Created by ruantong on 2018/8/9.
//  Copyright © 2018年 ruantong. All rights reserved.
//

#import "FileCacheManager.h"

//线程队列名称
static char *queueName = "fileManagerQueue";

@interface FileCacheManager()
{
    dispatch_queue_t _queue;//读写队列
}
@end

@implementation FileCacheManager

+ (instancetype)shareInstance
{
    static id instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

- (instancetype)init
{
    if(self = [super init]) {
        _queue = dispatch_queue_create(queueName, DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}


- (void)readFileAsync:(NSString *)fileName complete:(void (^)(NSString *))complete
{
    dispatch_async(_queue, ^{
        NSString *dirDoc = [self getDoucumentPath];
        NSString *dirFile = [dirDoc stringByAppendingPathComponent:fileName];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:dirFile]) {
            NSString *content = [NSString stringWithContentsOfFile:dirFile encoding:NSUTF8StringEncoding error:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (complete) {
                    complete(content);
                }
            });
        }
    });
}

- (void)writeFileAsync:(NSString *)fileName content:(NSString *)content complete:(void (^)(BOOL result))complete
{
    __block BOOL result = NO;
    dispatch_barrier_async(_queue, ^{
        NSString *dirDoc = [self getDoucumentPath];
        NSString *dirFile = [dirDoc stringByAppendingPathComponent:fileName];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
        
        if (![fileManager fileExistsAtPath:dirDoc]) {
            [fileManager createDirectoryAtPath:dirDoc withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        if (![fileManager fileExistsAtPath:dirFile]) {
            [fileManager createFileAtPath:dirFile contents:nil attributes:nil];
        }
        result = [data writeToFile:dirFile atomically:YES];
 
        if (complete) {
            complete(result);
        }
    });
    
}

- (void)writeFileSync:(NSString *)fileName content:(NSString *)content{
    __block BOOL result = NO;
    dispatch_barrier_sync(_queue, ^{
        NSString *dirDoc = [self getDoucumentPath];
        NSString *dirFile = [dirDoc stringByAppendingPathComponent:fileName];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
        
        if (![fileManager fileExistsAtPath:dirDoc]) {
            [fileManager createDirectoryAtPath:dirDoc withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        if (![fileManager fileExistsAtPath:dirFile]) {
            [fileManager createFileAtPath:dirFile contents:nil attributes:nil];
        }
        result = [data writeToFile:dirFile atomically:YES];
    });

}

- (NSString *)readFileSync:(NSString *)fileName {
    __block NSString * content;
    dispatch_sync(_queue, ^{
        NSString *dirDoc = [self getDoucumentPath];
        NSString *dirFile = [dirDoc stringByAppendingPathComponent:fileName];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:dirFile]) {
            content = [NSString stringWithContentsOfFile:dirFile encoding:NSUTF8StringEncoding error:nil];
        }
    });
    
    return content;
}

//获取文件沙盒路径
- (NSString *)getDoucumentPath{
    NSString *dirDoc = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *dirFile = [dirDoc stringByAppendingPathComponent:@"MacShell"];
    return dirFile;
}

//清除缓存
- (void)clearFileCache:(NSArray *)fileNameArr{
    dispatch_sync(_queue, ^{
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
    });
}


@end
