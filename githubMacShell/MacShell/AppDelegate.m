//
//  AppDelegate.m
//  MacShell
//
//  Created by ruantong on 2018/8/4.
//  Copyright © 2018年 ruantong. All rights reserved.
//

#import "AppDelegate.h"
#import "Help.h"

@interface AppDelegate ()
@property (nonatomic,strong) NSWindow * window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    self.window = [NSApplication sharedApplication].keyWindow;
    [[self.window standardWindowButton:NSWindowZoomButton] setHidden:YES];
    //1
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (IBAction)closeWindowAction:(id)sender {
    [self.window close];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag{
    if(!flag){
        [self.window makeKeyAndOrderFront:self];
        return YES;
    }
    return NO;
}

@end
