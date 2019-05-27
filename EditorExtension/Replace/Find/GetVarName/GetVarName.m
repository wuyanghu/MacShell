//
//  GetVarName.m
//  EditorExtension
//
//  Created by ruantong on 2019/5/27.
//  Copyright © 2019 wupeng. All rights reserved.
//

#import "GetVarName.h"

@interface GetVarName()
{
    NSMutableArray * _orignalLines;
    XCSourceTextRange * _selection;
}
@end

@implementation GetVarName

- (instancetype)initWithOrignalLines:(NSMutableArray *)orignalLines selection:(XCSourceTextRange *)selection{
    self = [super init];
    if (self) {
        _orignalLines = orignalLines;
        _selection = selection;
    }
    return self;
}

- (NSMutableArray *)getOrignalLines{
    return _orignalLines;
}

- (XCSourceTextRange *)getSelection{
    return _selection;
}

- (NSString *)getPreFixFromVar:(NSString *)varName position:(NSInteger)position{
    NSString * orignal = _orignalLines[_selection.start.line];

    NSString * prefix = nil;
    if ([varName containsString:@"_"]) {
        prefix = @"_";
    }else{
        prefix = [orignal substringWithRange:NSMakeRange(position, 1)];
    }
    return prefix;
}

@end
