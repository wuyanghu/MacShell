//
//  TaskOperation.m
//  MacShell
//
//  Created by ruantong on 2018/8/30.
//  Copyright © 2018年 ruantong. All rights reserved.
//

#import "TaskOperation.h"
#import "Help.h"

@interface TaskOperation()
@property (assign, nonatomic, getter = isFinished) BOOL finished;
@property (assign, nonatomic, getter = isExecuting) BOOL executing;

@property(copy,nonatomic) void(^finishBlock)(NSString *resultStr,NSTask * task);
@end

@implementation TaskOperation
@synthesize finished = _finished, executing = _executing;

- (void)start {
    @synchronized (self) {
        self.executing = YES;
        if (self.isCancelled) {
            self.executing = NO;
            self.finished = YES;
            return;
        }
        NSTask *task = [[NSTask alloc] init];
        _task = task;
        task.launchPath = @"/bin/sh";//文件路径
        task.arguments = self.runParam;
        task.currentDirectoryPath = [[NSBundle  mainBundle] resourcePath];
        
        NSPipe *outputPipe = [NSPipe pipe];
        [task setStandardOutput:outputPipe];
        [task setStandardError:outputPipe];
        NSFileHandle *readHandle = [outputPipe fileHandleForReading];
        
        [task launch];
        NSData *outputData = [readHandle readDataToEndOfFile];
        NSString *outputString = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];
        if (self.isCancelled) {
            self.executing = NO;
            self.finished = YES;
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.finishBlock(outputString,task);
            self.executing = NO;
            self.finished = YES;
        });
        
    }
}

- (void)setFinished:(BOOL)finished {
    [self willChangeValueForKey:@"isFinished"];
    _finished = finished;
    [self didChangeValueForKey:@"isFinished"];
}

- (void)setExecuting:(BOOL)executing {
    [self willChangeValueForKey:@"isExecuting"];
    _executing = executing;
    [self didChangeValueForKey:@"isExecuting"];
}

- (BOOL)isAsynchronous {
    return YES;
}

- (void)dealloc{
    NSLog(@"TaskOperation dealloc");
}

+ (instancetype)runTaskOperation:(NSArray *)runParam andFinishBlock:(void(^)(NSString *resultStr,NSTask * task))finishBlock{
    TaskOperation * taskOperation = [[TaskOperation alloc] init];
    taskOperation.runParam = runParam;
    taskOperation.finishBlock = finishBlock;
    return taskOperation;
}

@end
