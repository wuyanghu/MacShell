//
//  SourceEditorCommand.m
//  EditorExtension
//
//  Created by ruantong on 2019/5/20.
//  Copyright © 2019 wupeng. All rights reserved.
//

#import "SourceEditorCommand.h"
#import "ResetImportPort.h"
#import "HintComment.h"
#import "ReplaceCommand.h"

@implementation SourceEditorCommand

- (void)performCommandWithInvocation:(XCSourceEditorCommandInvocation *)invocation completionHandler:(void (^)(NSError * _Nullable nilOrError))completionHandler
{
    // Implement your command here, invoking the completion handler when done. Pass it nil on success, and an NSError on failure.
    id<ICommandProtocol> main;
    if ([invocation.commandIdentifier hasSuffix:@"ResetSortImport"]) {
        main = [ResetImportPort new];
    }else if ([invocation.commandIdentifier hasSuffix:@"HintComment"]){
        main = [HintComment new];
    }else if ([invocation.commandIdentifier hasSuffix:@"replace"]){
        main = [ReplaceCommand new];
    }
    if (main) {
        [main commandMain:invocation completionHandler:completionHandler];
    }
    completionHandler(nil);
}

@end
