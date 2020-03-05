//
//  IResetImportPort.m
//  PPImportArrangerExtension
//
//  Created by ruantong on 2019/5/20.
//  Copyright © 2019 Vernon. All rights reserved.
//

#import "ResetImportPort.h"

#define ArrangeSelectedLines @"ArrangeSelectedLines"

@interface ResetImportPort()
{
    NSMutableArray<NSString *> *_classNames;
    BOOL _isSelectedLines;
}
@end

@implementation ResetImportPort

- (void)commandMain:(XCSourceEditorCommandInvocation *)invocation completionHandler:(void (^)(NSError * _Nullable nilOrError))completionHandler{
    _classNames = [[NSMutableArray alloc] init];
    
    NSArray<NSString *> *lines = nil;
    NSInteger firstLine = -1;
    if ([invocation.commandIdentifier hasSuffix:ArrangeSelectedLines]) {
        lines = [self linesFromBufferSections:invocation];
        firstLine = [self getCurrentFileSelections:invocation].firstObject.start.line;
        _isSelectedLines = YES;
    } else {
        lines = [self getCurrentFileLines:invocation];
        _isSelectedLines = NO;
    }
    
    if (!lines || !lines.count) {
        return;
    }
    
    NSMutableArray<NSString *> *importLines = [self getImportInLines:&firstLine lines:lines];
    
    if (!importLines.count) {
        return;
    }
    
    // 先从源文件中移除所有 import 的行
    [self addImport:firstLine importLines:importLines invocation:invocation];
    
}

- (void)addImport:(NSInteger)firstLine importLines:(NSMutableArray<NSString *> *)importLines invocation:(XCSourceEditorCommandInvocation * _Nonnull)invocation {
    [invocation.buffer.lines removeObjectsInArray:importLines];
    NSMutableArray<NSString *> *sortedImportLines = [self resetSortImportLines:importLines];
    
    if (firstLine >= 0 && firstLine < invocation.buffer.lines.count) {
        // 重新插入排好序的 #import 行
        [invocation.buffer.lines insertObjects:sortedImportLines atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(firstLine, sortedImportLines.count)]];
        // 选中所有 #import 行
        [invocation.buffer.selections addObject:[[XCSourceTextRange alloc] initWithStart:XCSourceTextPositionMake(firstLine, 0) end:XCSourceTextPositionMake(firstLine + sortedImportLines.count - 1, sortedImportLines.lastObject.length)]];
    }
}

- (NSMutableArray<NSString *> *)resetSortImportLines:(NSMutableArray<NSString *> *)importLines
{
    NSArray *noRepeatArray = [[NSSet setWithArray:importLines] allObjects];  // 去掉重复的 #import
    NSMutableArray<NSString *> *sortedImports = [[NSMutableArray alloc] initWithArray:[noRepeatArray sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]];
    
    // 引用系统文件在前，用户自定义的文件在后
    NSMutableArray *systemImports = [[NSMutableArray alloc] init];
    for (NSString *line in sortedImports) {
        if ([line containsString:@"<"]) {
            [systemImports addObject:line];
        }
    }
    if (systemImports.count) {
        [sortedImports removeObjectsInArray:systemImports];
        [sortedImports insertObjects:systemImports atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, systemImports.count)]];
    }
    
    // 把当前文件对应的头文件放在最前面
    NSString *currentHeaderLine = nil;
    if (!_isSelectedLines && _classNames.count) {
        for (NSString *className in _classNames) {
            for (NSString *line in sortedImports) {
                if ([line containsString:className]) {
                    currentHeaderLine = line;
                    break;
                }
            }
        }
    }
    if (currentHeaderLine) {
        [sortedImports removeObject:currentHeaderLine];
        [sortedImports insertObject:currentHeaderLine atIndex:0];
    }
    
    return sortedImports;
}

#pragma mark - private method

- (NSMutableArray<NSString *> *)getImportInLines:(NSInteger *)firstLine lines:(NSArray<NSString *> *)lines {
    NSMutableArray<NSString *> *importLines = [[NSMutableArray alloc] init];
    
    for (NSUInteger index = 0; index < lines.count; index++) {
        NSString *line = lines[index];
        NSString *pureLine = [line stringByReplacingOccurrencesOfString:@" " withString:@""];       // 去掉多余的空格，以防被空格干扰没检测到 #import
        // 支持 Objective-C、Swift、C 语言
        if ([pureLine hasPrefix:@"#import"] || [pureLine hasPrefix:@"import"] || [pureLine hasPrefix:@"@class"]
            || [pureLine hasPrefix:@"@import"] || [pureLine hasPrefix:@"#include"]) {
            [importLines addObject:line];
            if (*firstLine == -1) {
                *firstLine = index;      // 记住第一行 #import 所在的行数，用来等下重新插入的位置
            }
        } else if ([pureLine hasPrefix:@"@implementation"]) {
            NSString *className = [pureLine stringByReplacingOccurrencesOfString:@"@implementation" withString:@""];
            className = [className stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            [_classNames addObject:className];
        }
    }
    
    return importLines;
}

@end
