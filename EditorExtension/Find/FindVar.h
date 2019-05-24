//
//  FindVar.h
//  EditorExtension
//
//  Created by ruantong on 2019/5/23.
//  Copyright © 2019 wupeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XCSourceTextRange;

NS_ASSUME_NONNULL_BEGIN

@interface FindVar : NSObject
- (instancetype)initWithOrignalLines:(NSMutableArray *)orignalLines selection:(XCSourceTextRange *)selection;
- (void)findAndReplaceIfCondition;
@end

NS_ASSUME_NONNULL_END
