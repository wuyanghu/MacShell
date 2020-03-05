//
//  DragInView.h
//  StringResource
//
//  Created by ruantong on 2018/9/18.
//  Copyright © 2018年 yqy. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol DragInViewDelegate
- (void)dragOpenFile:(NSArray *)pathArr;
@end

@interface DragInView : NSView
@property (nonatomic,weak) id<DragInViewDelegate> delegate;
@end
