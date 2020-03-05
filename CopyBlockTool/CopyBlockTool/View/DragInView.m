//
//  DragInView.m
//  StringResource
//
//  Created by ruantong on 2018/9/18.
//  Copyright © 2018年 yqy. All rights reserved.
//

#import "DragInView.h"

@interface DragInView()
@property(nonatomic,assign)BOOL isDragIn;
@end

@implementation DragInView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    self.layer.borderWidth = 1;
    self.layer.borderColor = [NSColor grayColor].CGColor;
//    [self setNeedsDisplay:YES];
    
    [self registerForDraggedTypes:@[NSFilenamesPboardType]];
    if (_isDragIn) {
        NSLog(@"拖拽了");
    }
}

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender{
    _isDragIn = YES;
    [self setNeedsLayout:YES];
    return NSDragOperationCopy;
}

- (void)draggingExited:(id<NSDraggingInfo>)sender{
    _isDragIn = NO;
    [self setNeedsLayout:YES];
}

- (BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender{
    _isDragIn = NO;
    [self setNeedsLayout:YES];
    return YES;
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender{
    if ([sender draggingSource] != self) {
        NSArray * filePaths = [[sender draggingPasteboard] propertyListForType:NSFilenamesPboardType];
        if(self.delegate){
            [self.delegate dragOpenFile:filePaths];
        }
        
        NSLog(@"文件地址%@",filePaths);
    }
    return YES;
}

@end
