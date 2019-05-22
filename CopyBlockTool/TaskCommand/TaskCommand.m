//
//  TaskCommand.m
//  CopyBlockTool
//
//  Created by ruantong on 2019/5/22.
//  Copyright © 2019 wupeng. All rights reserved.
//

#import "TaskCommand.h"
#import "TaskHelp.h"

@implementation TaskCommand

- (NSString *)executeTask{
    NSArray * runParam = [self getParams];
    NSString * result = [TaskHelp executeTask:runParam];
    NSLog(@"%@",result);
    return result;
}

@end
