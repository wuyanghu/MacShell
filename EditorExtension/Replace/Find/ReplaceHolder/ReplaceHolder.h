//
//  ReplaceHolder.h
//  EditorExtension
//
//  Created by ruantong on 2019/5/27.
//  Copyright © 2019 wupeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IReplaceCommand.h"
@class VarNameModel;
@class XCSourceTextRange;
NS_ASSUME_NONNULL_BEGIN

@interface ReplaceHolder : NSObject<IReplaceCommand>
- (void)replaceIfConditionPalceHolder:(NSString *)className varNameModel:(VarNameModel *)varNameModel;
@end

NS_ASSUME_NONNULL_END
