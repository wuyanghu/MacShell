//
//  GetVarName.h
//  EditorExtension
//
//  Created by ruantong on 2019/5/27.
//  Copyright © 2019 wupeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XcodeKit/XCSourceTextRange.h>
#import "VarNameModel.h"


NS_ASSUME_NONNULL_BEGIN

@interface GetVarName : NSObject
- (instancetype)initWithOrignalLines:(NSMutableArray *)orignalLines selection:(XCSourceTextRange *)selection;
- (NSString *)getPreFixFromVar:(NSString *)varName position:(NSInteger)position;
- (XCSourceTextRange *)getSelection;
- (NSMutableArray *)getOrignalLines;
@end

@interface GetVarName(Abstract)
- (VarNameModel *)getVarName;
@end

NS_ASSUME_NONNULL_END
