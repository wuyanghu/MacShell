//
//  IReplaceHolder.h
//  EditorExtension
//
//  Created by ruantong on 2019/5/27.
//  Copyright © 2019 wupeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XCSourceTextRange;

@protocol IReplaceCommand <NSObject>

@required
- (instancetype)initWithOrignalLines:(NSMutableArray *)orignalLines selection:(XCSourceTextRange *)selection;

@end

