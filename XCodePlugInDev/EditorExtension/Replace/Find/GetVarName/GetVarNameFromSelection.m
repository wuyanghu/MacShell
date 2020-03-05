//
//  GetVarNameFromSelection.m
//  EditorExtension
//
//  Created by ruantong on 2019/5/27.
//  Copyright © 2019 wupeng. All rights reserved.
//

#import "GetVarNameFromSelection.h"

@implementation GetVarNameFromSelection

- (VarNameModel *)getVarName{
    NSMutableArray * _orignalLines = [super getOrignalLines];
    XCSourceTextRange * _selection = [super getSelection];
    
    NSString * orignal = _orignalLines[_selection.start.line];
    NSString * varName = [orignal substringWithRange:NSMakeRange(_selection.start.column, _selection.end.column-_selection.start.column)];
    
    NSString * prefix = [self getPreFixFromVar:varName position:_selection.start.column-1];

    return [[VarNameModel alloc] initWithVarName:varName prefix:prefix];
}

@end
