//
//  NSTitleTableCellView.m
//  CopyBlockTool
//
//  Created by ruantong on 2019/5/22.
//  Copyright © 2019 wupeng. All rights reserved.
//

#import "TitleTableCellView.h"

@interface TitleTableCellView()

@end

@implementation TitleTableCellView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

+ (NSString *)cellReuseIdentifierInfo{
    return @"cellReuseIdentifierInfo";
}

@end
