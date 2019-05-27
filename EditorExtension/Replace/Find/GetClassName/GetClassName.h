//
//  GetClassName.h
//  EditorExtension
//
//  Created by ruantong on 2019/5/27.
//  Copyright © 2019 wupeng. All rights reserved.
//

#import <Foundation/Foundation.h>
@class XCSourceTextRange;
NS_ASSUME_NONNULL_BEGIN

@interface GetClassName : NSObject
- (instancetype)initWithOrignalLines:(NSMutableArray *)orignalLines selection:(XCSourceTextRange *)selection;
- (NSString *)getClassNameFromVarName:(NSString *)varName;
@end

NS_ASSUME_NONNULL_END
