//
//  CpCommand.m
//  CopyBlockTool
//
//  Created by ruantong on 2019/5/22.
//  Copyright © 2019 wupeng. All rights reserved.
//

#import "CpCommand.h"

@implementation CpCommand

- (NSMutableArray *)getParams{
    NSMutableArray * paramArray = [[NSMutableArray alloc] initWithObjects:@"cp.sh", nil];
    NSString * originalPath = [FileCacheManager getDoucumentPath];//工程路径
    [paramArray addObject:originalPath];
    return paramArray;
}

@end
