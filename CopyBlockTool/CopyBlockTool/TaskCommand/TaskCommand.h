//
//  TaskCommand.h
//  CopyBlockTool
//
//  Created by ruantong on 2019/5/22.
//  Copyright © 2019 wupeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FileCacheManager.h"
NS_ASSUME_NONNULL_BEGIN

@interface TaskCommand : NSObject
- (NSString *)executeTask;
@end

@interface TaskCommand(Abstract)
- (NSMutableArray *)getParams;
@end

NS_ASSUME_NONNULL_END
