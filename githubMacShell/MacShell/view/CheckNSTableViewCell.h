//
//  NSTableViewCell.h
//  MacShell
//
//  Created by ruantong on 2018/8/11.
//  Copyright © 2018年 ruantong. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol CheckCellDelegate
-(void)checkAction:(NSButton *)button checkTitle:(NSString *)checkTitle;
@end

@interface CheckNSTableViewCell : NSTableCellView
+ (NSString *)cellReuseIdentifierInfo;
- (void)setCheckTitle:(NSString *)checkTitle state:(NSInteger)state;
@property (nonatomic,weak) id<CheckCellDelegate> delegate;
@end
