//
//  UnzipCommand.h
//  CopyBlockTool
//
//  Created by ruantong on 2019/5/22.
//  Copyright © 2019 wupeng. All rights reserved.
//

#import "TaskCommand.h"

NS_ASSUME_NONNULL_BEGIN

@interface UnzipCommand : TaskCommand
- (instancetype)initWithProjectPath:(NSString *)projectPath;
@end

NS_ASSUME_NONNULL_END
