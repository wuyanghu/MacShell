//
//  FindVar.m
//  EditorExtension
//
//  Created by ruantong on 2019/5/23.
//  Copyright © 2019 wupeng. All rights reserved.
//

#import "FindVar.h"
#import <XcodeKit/XCSourceTextRange.h>
#import "VarNameModel.h"

@interface FindVar()
{
    NSMutableArray * _orignalLines;
    XCSourceTextRange * _selection;
}
@end

@implementation FindVar

- (instancetype)initWithOrignalLines:(NSMutableArray *)orignalLines selection:(XCSourceTextRange *)selection{
    self = [super init];
    if (self) {
        _orignalLines = orignalLines;
        _selection = selection;
    }
    return self;
}

- (void)findAndReplaceIfCondition{
    if (_selection.start.line != _selection.end.line) {//无论是在变量后面还是选中，起始和结束的行数相同
        return;
    }
    VarNameModel * varNameModel;
    if (_selection.start.line == _selection.end.line && _selection.start.column == _selection.end.column){
        varNameModel = [self getVarNameFromCursor];
    }else{
        varNameModel = [self getVarNameFromSelection];
    }
    NSString * className = [self getClassNameFromVarName:varNameModel.varName];
    NSLog(@"prefix=%@,varName=%@,className=%@",varNameModel.prefix,varNameModel.varName,className);
    if (!className) {
        return;
    }
    
    [self replaceIfConditionPalceHolder:className varNameModel:varNameModel];
}

#pragma mark - 占位符

- (void)replaceIfConditionPalceHolder:(NSString *)className varNameModel:(VarNameModel *)varNameModel {
    for (NSInteger i = _selection.start.line; i<_orignalLines.count; i++) {
        NSString * orignal = _orignalLines[i];
        if([orignal containsString:@"<#statements#>"]){
            NSString * replacePlaceHolder = [orignal stringByReplacingOccurrencesOfString:@"<#statements#>" withString:varNameModel.getPlaceHolder];
            
            NSString * placeClassName = [self findKindOfClass:replacePlaceHolder];
            if(placeClassName){
                NSString * replaceClassName = [replacePlaceHolder stringByReplacingOccurrencesOfString:placeClassName withString:className];
                _orignalLines[i] = replaceClassName;
            }else{
                _orignalLines[i] = replacePlaceHolder;
            }
        }
        if([orignal containsString:@"}"]){
            break;
        }
    }
}

- (NSString *)findKindOfClass:(NSString *)original{
    NSArray * separates = [original componentsSeparatedByString:@" "];
    for (NSString * content in separates) {
        if ([content containsString:@"isKindOfClass:"]) {
            return [content stringByReplacingOccurrencesOfString:@"isKindOfClass:[" withString:@""];
        }
    }
    return nil;
}

#pragma mark - 过滤

- (NSString *)filterSpecialBracket:(NSString *)orignal {
    NSString * leftBracket = [orignal stringByReplacingOccurrencesOfString:@"(" withString:@""];
    NSString * rightBracket = [leftBracket stringByReplacingOccurrencesOfString:@")" withString:@""];
    return rightBracket;
}

- (NSArray *)separatedString:(NSString *)orignal separatedSymbol:(NSString *)separatedSymbol{
    
    NSArray * separated = [orignal componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:separatedSymbol]];
    return separated;
}

#pragma mark - 获取类名

- (NSString *)getClassNameFromProperty:(NSString *)preOrignal {
    NSInteger i = 0;
    NSInteger start = 0;
    NSInteger end = 0;
    
    NSArray * leftMappingArr = @[@")"];
    NSArray * rightMappingArr = @[@"<",@"*"];
    while (i<preOrignal.length) {
        NSString * subStr = [preOrignal substringWithRange:NSMakeRange(i, 1)];
        if ([leftMappingArr containsObject:subStr] ) {
            start = i+1;
        }
        if([rightMappingArr containsObject:subStr]){
            end = i;
            break;
        }
        i++;
    }
    
    NSString * subStr = [preOrignal substringWithRange:NSMakeRange(start, end-start)];
    if (subStr.length>0) {
        subStr = [subStr stringByReplacingOccurrencesOfString:@" " withString:@""];
        return subStr;
    }
    return nil;
}

- (NSString *)getClassNameFromMethodParams:(NSString *)orignal range:(const NSRange *)range varName:(NSString *)varName {
    for (NSInteger j = range->location-1; j>=0; j--) {
        
        NSArray * separatedArray = [self separatedString:orignal separatedSymbol:@":"];
        for (NSString * separated in separatedArray) {
            if (![separated containsString:@"-"] && [separated containsString:varName]) {
                NSString * replaceBr = [self filterSpecialBracket:separated];
                
                NSArray * separatedArray = [self separatedString:replaceBr separatedSymbol:@"*="];//第一个是类型；第二个是变量名称
                NSString * className = separatedArray.firstObject;
                return className;
            }
        }
    }
    return nil;
}
//类型 * 变量名
- (NSString *)getClassNameFromNormal:(NSString *)preOrignal {
    preOrignal = [preOrignal stringByReplacingOccurrencesOfString:@" " withString:@""];
    preOrignal = [preOrignal stringByReplacingOccurrencesOfString:@"*" withString:@""];
    return preOrignal;
}

- (NSString *)getClassNameFromVarName:(NSString *)varName{
    for (NSInteger i = _selection.start.line; i>0; i--) {
        NSString * orignal = _orignalLines[i];
        NSRange range = [orignal rangeOfString:varName];//匹配得到的下标
        
        if (range.length == 0) {
            continue;
        }
        
        NSString * preOrignal = [orignal substringToIndex:range.location];
        
        if ([preOrignal containsString:@"="]) {
            continue;
        }
        
        if ([preOrignal containsString:@"-"]) {
            return [self getClassNameFromMethodParams:orignal range:&range varName:varName];
        }
        
        if ([preOrignal containsString:@"*"]) {
            NSString * className = [self getClassNameFromProperty:preOrignal];
            if(className) return className;
            
            return [self getClassNameFromNormal:preOrignal];
        }
    }
    return nil;
}


#pragma mark - 获取变量名称

//光标在变量后面时获取变量
- (VarNameModel *)getVarNameFromCursor {
    NSString * orignal = _orignalLines[_selection.start.line];
    NSArray * specialChars = @[@" ",@";",@".",@"\n",@"[",@"]",@":",@"_"];
    
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
    NSString * prefix = [self getPreFixFromVar:orignal varName:varName position:i-1];
    return [[VarNameModel alloc] initWithVarName:varName prefix:prefix];
}

//选中变量时获取变量
- (VarNameModel *)getVarNameFromSelection{
    NSString * orignal = _orignalLines[_selection.start.line];
    NSString * varName = [orignal substringWithRange:NSMakeRange(_selection.start.column, _selection.end.column-_selection.start.column)];
    NSString * prefix = [self getPreFixFromVar:orignal varName:varName position:_selection.start.column-1];
    
    return [[VarNameModel alloc] initWithVarName:varName prefix:prefix];
}

#pragma mark - 获取变量前缀

- (NSString *)getPreFixFromVar:(NSString *)orignal varName:(NSString *)varName position:(NSInteger)position{
    NSString * prefix = nil;
    if ([varName containsString:@"_"]) {
        prefix = @"_";
    }else{
        prefix = [orignal substringWithRange:NSMakeRange(position, 1)];
        if ([prefix isEqualToString:@" "]) {
            prefix = @" ";
        }else if ([prefix isEqualToString:@"."]){
            prefix = @".";
        }
    }
    return prefix;
}

@end
