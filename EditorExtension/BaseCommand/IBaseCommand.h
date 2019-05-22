//
//  IBaseCommand.h
//  EditorExtension
//
//  Created by ruantong on 2019/5/21.
//  Copyright © 2019 wupeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XcodeKit/XcodeKit.h>

@protocol IBaseCommand <NSObject>

@required
- (NSMutableArray<NSString *> *)getCurrentFileLines:(XCSourceEditorCommandInvocation *)invocation;
- (NSMutableArray<XCSourceTextRange *> *)getCurrentFileSelections:(XCSourceEditorCommandInvocation *)invocation;
- (NSArray<NSString *> *)linesFromBufferSections:(XCSourceEditorCommandInvocation *)invocation;
@end

