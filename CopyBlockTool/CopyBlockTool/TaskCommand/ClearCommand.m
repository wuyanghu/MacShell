//
//  ClearCommand.m
//  CopyBlockTool
//
//  Created by ruantong on 2019/5/22.
//  Copyright © 2019 wupeng. All rights reserved.
//

#import "ClearCommand.h"

@implementation ClearCommand

- (NSMutableArray *)getParams{
    NSString * originalPath = [FileCacheManager getDoucumentPath];//工程路径
    NSMutableArray * paramArray = [[NSMutableArray alloc] initWithObjects:@"rm.sh",originalPath, nil];
    return paramArray;
}

@end
