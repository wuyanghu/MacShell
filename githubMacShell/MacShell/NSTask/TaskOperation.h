//
//  TaskOperation.h
//  MacShell
//
//  Created by ruantong on 2018/8/30.
//  Copyright © 2018年 ruantong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TaskOperation : NSOperation
@property (nonatomic,strong) NSArray * runParam;
@property (nonatomic,strong) NSTask *task;
+ (instancetype)runTaskOperation:(NSArray *)runParam andFinishBlock:(void(^)(NSString *resultStr,NSTask * task))finishBlock;
@end
