//
//  GetClassName.m
//  EditorExtension
//
//  Created by ruantong on 2019/5/27.
//  Copyright © 2019 wupeng. All rights reserved.
//

#import "GetClassName.h"
#import <XcodeKit/XCSourceTextRange.h>

@interface GetClassName()
{
    NSMutableArray * _orignalLines;
    XCSourceTextRange * _selection;
}
@end

@implementation GetClassName

- (instancetype)initWithOrignalLines:(NSMutableArray *)orignalLines selection:(XCSourceTextRange *)selection{
    self = [super init];
    if (self) {
        _orignalLines = orignalLines;
        _selection = selection;
    }
    return self;
}

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

@end
