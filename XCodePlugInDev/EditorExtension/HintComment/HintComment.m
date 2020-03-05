//
//  HintComment.m
//  EditorExtension
//
//  Created by ruantong on 2019/5/20.
//  Copyright © 2019 wupeng. All rights reserved.
//

#import "HintComment.h"
#import "ConfigInfo.h"
#import "ESharedUserDefault.h"

@interface HintComment()
@property (nonatomic, strong) NSMutableDictionary * mappingOC;
@end

@implementation HintComment

#pragma mark - ICommandProtocol

- (void)commandMain:(XCSourceEditorCommandInvocation *)invocation completionHandler:(void (^)(NSError * _Nullable))completionHandler{
    [self handleInvocation:invocation];
}

- (BOOL)handleInvocation:(XCSourceEditorCommandInvocation *)invocation {
    
    //read from NSUserDefault each time
    [self clearMapping];
    
    [self readShareDict];
    
    XCSourceTextRange *selection = [super getCurrentFileSelections:invocation].firstObject;
    NSMutableArray* lines = [super getCurrentFileLines:invocation];
    
    if (selection.start.line > lines.count-1) {
        return NO;
    }
    
    NSString* originalLine = lines[selection.start.line];
    
    int matchLength = 8;//max match length for shortcut
    while (matchLength >= 1) {
        if (selection.end.column-matchLength >= 0)
        {
            NSRange targetRange = NSMakeRange(selection.end.column-matchLength, matchLength);
            NSString* lastNStr = [originalLine substringWithRange:targetRange];
            NSString* matchedVal = [self.mappingOC objectForKey:lastNStr];
            if (matchedVal.length > 0) {
                [self linesToInsert:selection.start.line lines:lines targetRange:targetRange];
                [self setCursorPosition:matchLength selection:selection];
                break;
            }
        }
        matchLength --;
    }
    
    return YES;
}

#pragma mark - private method

- (NSString *)getStrPreBlankWithLastNStr:(NSString *)lastNStr originalLine:(NSString *)originalLine {
    NSString* indentStr = @"";
    
    NSUInteger numberOfSpaceIndent = [originalLine rangeOfString:lastNStr].location;
    while (numberOfSpaceIndent>0) {
        indentStr = [indentStr stringByAppendingString:@" "];
        numberOfSpaceIndent --;
    }
    return indentStr;
}

- (void)linesToInsert:(NSInteger)index lines:(NSMutableArray *)lines targetRange:(NSRange)targetRange {

    NSString * originalLine = lines[index];
    
    NSString* lastNStr = [originalLine substringWithRange:targetRange];
    
    NSArray * linesToInsertArr = [self insertArrFormLastNStr:lastNStr];
    
    lines[index] = [originalLine stringByReplacingOccurrencesOfString:lastNStr
                                                           withString:linesToInsertArr[0]
                                                              options:NSBackwardsSearch
                                                                range:targetRange];
    
    NSString* blankStr = [self getStrPreBlankWithLastNStr:lastNStr originalLine:originalLine];
    //insert the rest
    for (int i = 1; i < linesToInsertArr.count; i ++) {
        NSString* lineToInsert = linesToInsertArr[i];
        //indent
        lineToInsert = [NSString stringWithFormat:@"%@%@", blankStr, lineToInsert];
        [lines insertObject:lineToInsert atIndex:index+i];
    }
}

- (void)clearMapping
{
    self.mappingOC = nil;
    
    [_UD clearMapping];
}

- (void)readShareDict {
    NSDictionary * readDict = [_UD readMappingForOC];
    [self.mappingOC setValuesForKeysWithDictionary:readDict];
}

- (NSArray *)insertArrFormLastNStr:(NSString *)lastNStr {
    NSString* matchedVal = [self.mappingOC objectForKey:lastNStr];
    NSArray * linesToInsertArr = [matchedVal componentsSeparatedByString:@"\n"];
    return linesToInsertArr;
}

- (void)setCursorPosition:(int)matchLength selection:(XCSourceTextRange *)selection {
    selection.start = XCSourceTextPositionMake(selection.start.line, selection.start.column-matchLength);
    selection.end = selection.start;
}

#pragma mark - getter

- (NSMutableDictionary*)mappingOC
{
    if (!_mappingOC) {
        _mappingOC = [ConfigInfo getConfigDict];
    }
    return _mappingOC;
}

@end
