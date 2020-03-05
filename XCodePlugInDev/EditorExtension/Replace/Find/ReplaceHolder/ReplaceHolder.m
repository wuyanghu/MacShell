//
//  ReplaceHolder.m
//  EditorExtension
//
//  Created by ruantong on 2019/5/27.
//  Copyright © 2019 wupeng. All rights reserved.
//

#import "ReplaceHolder.h"
#import <XcodeKit/XCSourceTextRange.h>
#import "VarNameModel.h"

@interface ReplaceHolder ()
{
    NSMutableArray * _orignalLines;
    XCSourceTextRange * _selection;
}
@end

@implementation ReplaceHolder

- (instancetype)initWithOrignalLines:(NSMutableArray *)orignalLines selection:(XCSourceTextRange *)selection{
    self = [super init];
    if (self) {
        _orignalLines = orignalLines;
        _selection = selection;
    }
    return self;
}

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

@end
