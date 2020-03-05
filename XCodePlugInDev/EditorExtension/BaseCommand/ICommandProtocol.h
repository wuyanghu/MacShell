//
//  IResetImportPortProtocol.h
//  PPImportArrangerExtension
//
//  Created by ruantong on 2019/5/20.
//  Copyright © 2019 Vernon. All rights reserved.
//

#import <XcodeKit/XcodeKit.h>

@protocol ICommandProtocol <NSObject>

@required
- (void)commandMain:(XCSourceEditorCommandInvocation *)invocation completionHandler:(void (^)(NSError * _Nullable nilOrError))completionHandler;
@end
