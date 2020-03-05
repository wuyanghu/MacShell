//
//  BaseCommand.m
//  EditorExtension
//
//  Created by ruantong on 2019/5/21.
//  Copyright © 2019 wupeng. All rights reserved.
//

#import "BaseCommand.h"

@implementation BaseCommand

- (NSMutableArray<NSString *> *)getCurrentFileLines:(XCSourceEditorCommandInvocation *)invocation{
    return invocation.buffer.lines;
}

- (NSMutableArray<XCSourceTextRange *> *)getCurrentFileSelections:(XCSourceEditorCommandInvocation *)invocation{
    return invocation.buffer.selections;
}

- (NSArray<NSString *> *)linesFromBufferSections:(XCSourceEditorCommandInvocation *)invocation{
    XCSourceTextRange * textRange = invocation.buffer.selections.firstObject;
    NSRange selectedLineRange = NSMakeRange(textRange.start.line, textRange.end.line - textRange.start.line + 1);
    
    return [invocation.buffer.lines subarrayWithRange:selectedLineRange];
}

@end
