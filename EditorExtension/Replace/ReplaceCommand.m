//
//  ReplaceCommand.m
//  EditorExtension
//
//  Created by ruantong on 2019/5/23.
//  Copyright © 2019 wupeng. All rights reserved.
//

#import "ReplaceCommand.h"
#import "FindVar.h"

@interface ReplaceCommand()
{
    FindVar * _findVar;
}
@end

@implementation ReplaceCommand

- (instancetype)init{
    self = [super init];
    if (self) {
        _findVar = [FindVar new];
    }
    return self;
}

- (void)commandMain:(XCSourceEditorCommandInvocation *)invocation completionHandler:(void (^)(NSError * _Nullable))completionHandler{
    XCSourceTextRange *selection = [super getCurrentFileSelections:invocation].firstObject;
    NSMutableArray* lines = [super getCurrentFileLines:invocation];
    
    if (selection.start.line > lines.count-1) {
        return;
    }
    _findVar = [[FindVar alloc] initWithOrignalLines:lines selection:selection];
    [_findVar findAndReplaceIfCondition];
    
}

@end
