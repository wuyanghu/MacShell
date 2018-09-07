//
//  TaskOperationManager.m
//  MacShell
//
//  Created by ruantong on 2018/8/30.
//  Copyright © 2018年 ruantong. All rights reserved.
//

#import "TaskOperationManager.h"
#import "TaskOperation.h"

@interface TaskOperationManager()
@property (nonatomic,strong) NSOperationQueue * taskQueue;
@end

@implementation TaskOperationManager

+ (instancetype)shareManager {
    static TaskOperationManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (instancetype)init{
    self = [super init];
    if(self){
        self.taskQueue = [[NSOperationQueue alloc] init];
        self.taskQueue.maxConcurrentOperationCount=1;
    }
    return self;
}

- (void)addTaskOperationToQueue:(NSArray *)runParams andFinishBlock:(void(^)(NSString *resultStr,NSTask * task))finishBlock{
    TaskOperation * taskOperation = [TaskOperation runTaskOperation:runParams andFinishBlock:finishBlock];
    [self.taskQueue addOperation:taskOperation];
    
//    [taskOperation addObserver:self forKeyPath:@"isExecuting" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    [taskOperation addObserver:self forKeyPath:@"finished" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
}

- (void)cancelOperation{
    NSLog(@"cancelOperation");
    [self.taskQueue cancelAllOperations];
    self.taskQueue.suspended = YES;
    //中断正在耗时的任务
    for(int i=0;i<self.taskQueue.operations.count;i++){
        TaskOperation * taskOperation = self.taskQueue.operations[i];
        if(taskOperation.isExecuting){
            [taskOperation.task terminate];
        }
    }
   
    self.taskQueue = [[NSOperationQueue alloc] init];
    self.taskQueue.maxConcurrentOperationCount=1;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    TaskOperation * taskOperation = (TaskOperation *)object;
    if([keyPath isEqualToString:@"isExecuting"]){
        NSLog(@"%@",keyPath);
    }else if([keyPath isEqualToString:@"finished"]){
        NSLog(@"%@-%@-%ld",taskOperation.runParam[0],keyPath,self.taskQueue.operations.count);
    }
    
}

@end
