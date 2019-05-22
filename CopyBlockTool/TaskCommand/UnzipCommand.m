//
//  UnzipCommand.m
//  CopyBlockTool
//
//  Created by ruantong on 2019/5/22.
//  Copyright © 2019 wupeng. All rights reserved.
//

#import "UnzipCommand.h"
#import "FileCacheManager.h"

@interface UnzipCommand()
{
    NSString * _projectPath;
}
@end

@implementation UnzipCommand

- (instancetype)initWithProjectPath:(NSString *)projectPath{
    self = [super init];
    if (self) {
        _projectPath = projectPath;
    }
    return self;
}

- (NSMutableArray *)getParams{
    NSMutableArray * paramArray = [[NSMutableArray alloc] initWithObjects:@"unzip.sh", nil];
    NSString * sandboxPath = [FileCacheManager getDoucumentPath];
    [paramArray addObject:_projectPath];
    [paramArray addObject:sandboxPath];
    
    return paramArray;
}

@end
