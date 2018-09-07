//
//  TaskOperationManager.h
//  MacShell
//
//  Created by ruantong on 2018/8/30.
//  Copyright © 2018年 ruantong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TaskOperationManager : NSObject
+ (instancetype)shareManager;
- (void)addTaskOperationToQueue:(NSArray *)runParams andFinishBlock:(void(^)(NSString *resultStr,NSTask * task))finishBlock;
- (void)cancelOperation;
@end
