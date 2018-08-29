//
//  NSTableViewCell.m
//  MacShell
//
//  Created by ruantong on 2018/8/11.
//  Copyright © 2018年 ruantong. All rights reserved.
//

#import "CheckNSTableViewCell.h"

@interface CheckNSTableViewCell()
@property (weak) IBOutlet NSButton *checkButton;
@property (nonatomic,copy) NSString * checkTitle;
@end

@implementation CheckNSTableViewCell

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void)setCheckTitle:(NSString *)checkTitle state:(NSInteger)state{
    _checkTitle = checkTitle;
    self.checkButton.state = state;
    [self.checkButton setTitle:checkTitle];
}

- (IBAction)checkAction:(id)sender {
    [self.delegate checkAction:(NSButton *)sender checkTitle:_checkTitle];
}


+ (NSString *)cellReuseIdentifierInfo{
    return @"CheckNSTableViewCell";
}

@end
