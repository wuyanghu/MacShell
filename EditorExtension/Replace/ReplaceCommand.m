//
//  ReplaceCommand.m
//  EditorExtension
//
//  Created by ruantong on 2019/5/23.
//  Copyright © 2019 wupeng. All rights reserved.
//

#import "ReplaceCommand.h"
#import "GetVarNameFromCursor.h"
#import "GetVarNameFromSelection.h"
#import "GetClassName.h"
#import "ReplaceHolder.h"

@interface ReplaceCommand()
{
    GetVarName * _getVarName;
    GetClassName * _getClassName;
    ReplaceHolder * _replaceHolder;
}
@end

@implementation ReplaceCommand

- (instancetype)init{
    self = [super init];
    if (self) {

    }
    return self;
}

- (void)commandMain:(XCSourceEditorCommandInvocation *)invocation completionHandler:(void (^)(NSError * _Nullable))completionHandler{
    XCSourceTextRange *selection = [super getCurrentFileSelections:invocation].firstObject;
    NSMutableArray* lines = [super getCurrentFileLines:invocation];
    
    if (selection.start.line > lines.count-1 || selection.start.line != selection.end.line) {
        return;
    }
    
    [self initWithLines:lines selection:selection];
    [self findAndReplaceIfCondition];
}

- (void)initWithLines:(NSMutableArray *)orignalLines selection:(XCSourceTextRange *)selection{
    if (selection.start.line == selection.end.line && selection.start.column == selection.end.column){
        _getVarName = [[GetVarNameFromCursor alloc] initWithOrignalLines:orignalLines selection:selection];
    }else{
        _getVarName = [[GetVarNameFromSelection alloc] initWithOrignalLines:orignalLines selection:selection];
    }
    
    _getClassName = [[GetClassName alloc] initWithOrignalLines:orignalLines selection:selection];
    _replaceHolder = [[ReplaceHolder alloc] initWithOrignalLines:orignalLines selection:selection];

}

- (void)findAndReplaceIfCondition{
    
    VarNameModel * varNameModel = [_getVarName getVarName];
    NSString * className = [_getClassName getClassNameFromVarName:varNameModel.varName];
    
    NSLog(@"prefix=%@,varName=%@,className=%@",varNameModel.prefix,varNameModel.varName,className);
    if (!className) {
        return;
    }
    [_replaceHolder replaceIfConditionPalceHolder:className varNameModel:varNameModel];
}

@end
