//
//  CheckViewController.h
//  MacShell
//
//  Created by ruantong on 2018/8/11.
//  Copyright © 2018年 ruantong. All rights reserved.
//

#import "ViewController.h"

@protocol CheckVCDelegate
- (void)checkAction:(NSButton *)button checkTitle:(NSString *)checkTitle window:(NSWindow *)window;
@end

@interface CheckViewController : NSViewController
@property (nonatomic,weak) id<CheckVCDelegate> delegate;
@end
