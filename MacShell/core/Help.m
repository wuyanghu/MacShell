//
//  Help.m
//  MacShell
//
//  Created by ruantong on 2018/8/8.
//  Copyright © 2018年 ruantong. All rights reserved.
//

#import "Help.h"
#import "STPrivilegedTask.h"
#import "AFNetworking.h"

@implementation Help

#pragma mark - 脚本调用
+ (NSTask *)runTask:(NSArray *)arguments block:(void(^)(NSString *,NSTask *))block{
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
    
    return task;
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

#pragma mark - json与字典转换

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

+ (NSString*)dictionaryToJson:(NSDictionary *)dic{
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}
    
#pragma mark - 文件选择
+ (void)openPanel:(NSString *)directory window:(NSWindow *)window block:(void(^)(NSString *))block{
    NSOpenPanel* panel = [NSOpenPanel openPanel];
    [panel setDirectory:directory];//保存文件路径
    panel.canCreateDirectories = YES;//是否可以创建文件夹
    panel.canChooseDirectories = YES;//是否可以选择文件夹
    panel.canChooseFiles = NO;//是否可以选择文件
    [panel setAllowsMultipleSelection:NO];//是否可以多选
    //显示
    [panel beginSheetModalForWindow:window completionHandler:^(NSInteger result) {
        //是否点击open 按钮
        if (result == NSModalResponseOK) {
            NSString * path = [panel.URLs.firstObject path];
            block(path);
        }
    }];
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
        NSDictionary * initAuditInfoDict = @{kChensong:@"1",kShezhiqiang:@"1"};
        [self storageAuditInfo:[[NSMutableDictionary alloc] initWithDictionary:initAuditInfoDict]];
        return initAuditInfoDict;
    }
    return auditInfoDict;
}

//缓存选择文件路径
+ (void)storageFilePath:(NSString *)path key:(NSString *)key{
    path = [NSString stringWithFormat:@"file://%@",path];
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSURL * pathUrl = [NSURL URLWithString:path];
    [pathUrl startAccessingSecurityScopedResource];
    
    NSError *error = nil;
    NSData *bookmarkData = [pathUrl bookmarkDataWithOptions:NSURLBookmarkCreationWithSecurityScope includingResourceValuesForKeys:nil relativeToURL:nil error:&error];
    
    [pathUrl stopAccessingSecurityScopedResource];
    if (!error) {
        [userDefaults setObject:bookmarkData forKey:key];
        [userDefaults synchronize];
    }
    
}
//获取文件路径
+ (NSString *)getFilePath:(NSString *)key{
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSData * pathData = [userDefaults objectForKey:key];
    
    BOOL bookmarkDataIsStale;
    NSURL *allowedUrl = [NSURL URLByResolvingBookmarkData:pathData options:NSURLBookmarkResolutionWithSecurityScope relativeToURL:nil bookmarkDataIsStale:&bookmarkDataIsStale error:NULL];
    [allowedUrl startAccessingSecurityScopedResource];
    return [allowedUrl absoluteString];
}

+ (void)storageUserDefaultObject:(NSObject *)obj key:(NSString *)key{
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    if (obj && key) {
        [userDefaults setObject:obj forKey:key];
        [userDefaults synchronize];
    }
}

+ (NSObject *)getUserDefaultObject:(NSString *)key{
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    if (key) {
        NSObject * object = [userDefaults objectForKey:key];
        return object;
    }
    return nil;
}

#pragma mark - arc语言
+ (void)getArcLanguage:(void(^)(NSString *))block{
    [Help runTask:@[@"gettoken.sh"] block:^(NSString * outputStr, NSTask * task) {
        NSArray *array = [outputStr componentsSeparatedByString:@"\n"];
        if (array.count>1) {
            NSString * jsonStr = array[1];
            NSDictionary * dict = [Help dictionaryWithJsonString:jsonStr];
            NSString * token = dict[@"hosts"][@"http://112.13.170.228:8089/api/"][@"token"];
            NSLog(@"token=%@",token);
            if (!token) {
                return ;
            }
            NSDictionary * params = @{@"revision_id":@"",@"edit":@"create",@"fields":@[],@"__conduit__":@{@"token":token}};
            NSString * paramStr = [Help dictionaryToJson:params];
            NSDictionary * paramDict = @{@"params":paramStr,@"output":@"json",@"__conduit__":@"1"};
            
            AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]init];
            
            [manager GET:@"http://112.13.170.228:8089/api/differential.getcommitmessage" parameters:paramDict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                NSDictionary * responseDict = (NSDictionary *)responseObject;
                if (responseDict) {
                    NSString * result = responseDict[@"result"];
                    if ([result containsString:@"摘要:"]) {
                        block(NSLocalizedString(@"chinese", nil));
                    }else if ([result containsString:@"Summary:"]){
                        block(@"English");
                    }
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                NSLog(@"请求失败--%@",error);
            }];
            
        }
    }];
    
}

@end
