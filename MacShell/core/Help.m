//
//  Help.m
//  MacShell
//
//  Created by ruantong on 2018/8/8.
//  Copyright © 2018年 ruantong. All rights reserved.
//

#import "Help.h"
#import "STPrivilegedTask.h"

@implementation Help

#pragma mark - 脚本调用
+ (void)runTask:(NSArray *)arguments block:(ResultBlock)block{
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = @"/bin/sh";//文件路径
    task.arguments = arguments;
    task.currentDirectoryPath = [[NSBundle  mainBundle] resourcePath];
    
    NSPipe *outputPipe = [NSPipe pipe];
    [task setStandardOutput:outputPipe];
    [task setStandardError:outputPipe];
    NSFileHandle *readHandle = [outputPipe fileHandleForReading];
    task.terminationHandler = ^(NSTask * task) {
        NSData *outputData = [readHandle readDataToEndOfFile];
        NSString *outputString = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];
        block(outputString,task);
    };
    
    [task launch];
}


+ (void)runRootTask:(NSArray *)arguments{
    STPrivilegedTask *privilegedTask = [[STPrivilegedTask alloc] init];
    
    NSString *launchPath = @"/bin/sh";//文件路径;
    [privilegedTask setLaunchPath:launchPath];
    [privilegedTask setArguments:arguments];
    [privilegedTask setCurrentDirectoryPath:[[NSBundle mainBundle] resourcePath]];
    
    //set it off
    OSStatus err = [privilegedTask launch];
    if (err != errAuthorizationSuccess) {
        if (err == errAuthorizationCanceled) {
            NSLog(@"User cancelled");
            return;
        }  else {
            NSLog(@"Something went wrong: %d", (int)err);
            // For error codes, see http://www.opensource.apple.com/source/libsecurity_authorization/libsecurity_authorization-36329/lib/Authorization.h
        }
    }
    
    [privilegedTask waitUntilExit];
    
    // Success!  Now, start monitoring output file handle for data
    NSFileHandle *readHandle = [privilegedTask outputFileHandle];
    NSData *outputData = [readHandle readDataToEndOfFile];
    NSString *outputString = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];
    
    NSLog(@"outputString=%@",outputString);
    NSLog(@"status=%d",privilegedTask.terminationStatus);// 终端状态
}

#pragma mark - 存储

//存储审核人信息
+ (void)storageAuditInfo:(NSMutableDictionary *)auditInfoDict{
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:auditInfoDict forKey:@"auditInfoDict"];
    [userDefaults synchronize];
}

//获取审核人信息
+ (NSDictionary *)getAuditInfo{
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary * auditInfoDict = [userDefaults objectForKey:@"auditInfoDict"];
    if (!auditInfoDict) {
        NSDictionary * initAuditInfoDict = @{kChensong:@"1",kShezhiqiang:@"1",kYuanrunli:@"1"};
        [self storageAuditInfo:[[NSMutableDictionary alloc] initWithDictionary:initAuditInfoDict]];
        return initAuditInfoDict;
    }
    return auditInfoDict;
}

//缓存选择文件路径
+ (void)storageFilePath:(NSString *)path{
    path = [NSString stringWithFormat:@"file://%@",path];
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSURL * pathUrl = [NSURL URLWithString:path];
    [pathUrl startAccessingSecurityScopedResource];
    
    NSError *error = nil;
    NSData *bookmarkData = [pathUrl bookmarkDataWithOptions:NSURLBookmarkCreationWithSecurityScope includingResourceValuesForKeys:nil relativeToURL:nil error:&error];
    
    [pathUrl stopAccessingSecurityScopedResource];
    if (!error) {
        [userDefaults setObject:bookmarkData forKey:kChooseFilePath];
        [userDefaults synchronize];
    }
    
}
//获取文件路径
+ (NSString *)getFilePath{
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSData * pathData = [userDefaults objectForKey:kChooseFilePath];
    
    BOOL bookmarkDataIsStale;
    NSURL *allowedUrl = [NSURL URLByResolvingBookmarkData:pathData options:NSURLBookmarkResolutionWithSecurityScope relativeToURL:nil bookmarkDataIsStale:&bookmarkDataIsStale error:NULL];
    [allowedUrl startAccessingSecurityScopedResource];
    return [allowedUrl absoluteString];
}

@end
