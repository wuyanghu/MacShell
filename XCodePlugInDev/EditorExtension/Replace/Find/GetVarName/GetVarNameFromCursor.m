//
//  GetVarNameFromCursor.m
//  EditorExtension
//
//  Created by ruantong on 2019/5/27.
//  Copyright © 2019 wupeng. All rights reserved.
//

#import "GetVarNameFromCursor.h"

@implementation GetVarNameFromCursor

- (VarNameModel *)getVarName{
    NSMutableArray * _orignalLines = [super getOrignalLines];
    XCSourceTextRange * _selection = [super getSelection];
    
    NSString * orignal = _orignalLines[_selection.start.line];
    NSArray * specialChars = @[@" ",@";",@".",@"\n",@"[",@"]",@":",@"_",@",",@")",@"{"];
    
    NSInteger i;
    for (i = _selection.start.column-1; i>0; i--) {
        NSString * subStr = [orignal substringWithRange:NSMakeRange(i, 1)];
        if ([specialChars containsObject:subStr]) {
            i++;
            break;
        }
    }
    
    NSInteger j;
    for (j = _selection.start.column-1; j<orignal.length; j++) {
        NSString * subStr = [orignal substringWithRange:NSMakeRange(j, 1)];
        if ([specialChars containsObject:subStr]) {
            break;
        }
    }
    
    NSString * varName = [orignal substringWithRange:NSMakeRange(i, j-i)];
    
    NSString * prefix = [self getPreFixFromVar:varName position:i-1];
    return [[VarNameModel alloc] initWithVarName:varName prefix:prefix];
}

@end
