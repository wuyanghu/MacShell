//
//  TaskCommand.m
//  CopyBlockTool
//
//  Created by ruantong on 2019/5/22.
//  Copyright © 2019 wupeng. All rights reserved.
//

#import "TaskCommand.h"

@implementation TaskCommand

- (NSString *)executeTask{
    NSArray * runParam = [self getParams];
    NSString * result = [self executeTask:runParam];
    NSLog(@"%@",result);
    return result;
}

- (NSString *)executeTask:(NSArray *)runParam {
    NSTask * task = [[NSTask alloc] init];
    task.launchPath = @"/bin/sh";//文件路径
    task.arguments = runParam;
    task.currentDirectoryPath = [[NSBundle  mainBundle] resourcePath];
    
    NSPipe *outputPipe = [NSPipe pipe];
    [task setStandardOutput:outputPipe];
    [task setStandardError:outputPipe];
    NSFileHandle *readHandle = [outputPipe fileHandleForReading];
    
    [task launch];
    NSData *outputData = [readHandle readDataToEndOfFile];
    NSString * outputString = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];
    
    return outputString;
}

@end
