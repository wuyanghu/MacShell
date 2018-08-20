//
//  ViewController.m
//  MacShell
//
//  Created by ruantong on 2018/8/4.
//  Copyright © 2018年 ruantong. All rights reserved.
//

#import "ViewController.h"
#import "Help.h"
#import "FileCache.h"
#import <Foundation/Foundation.h>
#import "CheckViewController.h"
#import "MonitorFileChangeHelp.h"

@interface ViewController()<NSTextViewDelegate,CheckVCDelegate>
@property (weak) IBOutlet NSButtonCell *arcCommandDirectoryButton;//arc工程所在目录
@property (weak) IBOutlet NSButton *chineseButton;
@property (weak) IBOutlet NSButton *englishButton;

@property (weak) IBOutlet NSButton *chooseDirectoryButton;//工程目录
@property (weak) IBOutlet NSStackView *stackView;
@property (unsafe_unretained) IBOutlet NSTextView *textView; //信息录入框
@property (weak) IBOutlet NSTextField *placeLabel;
@property (weak) IBOutlet NSProgressIndicator *progressIndicatorView;//菊花圈

@property (nonatomic,strong) NSMutableDictionary<NSString *,NSTextField*> * cacheLabelDict;

@property (nonatomic,strong) NSMutableDictionary * auditPersonDictionary;
@property (nonatomic,copy) NSString * chooseFilePath;//选择路径
@property (nonatomic,copy) NSString * arcCommandPath;

@property (nonatomic,strong) MonitorFileChangeHelp *fileMonitor;

@property (weak) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (unsafe_unretained) IBOutlet NSTextView *logTextView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //1
    //分支2
    //test1 amend
    [self getAndSetArcLanguage];
    
    self.logTextView.editable = NO;
    self.logTextView.string = @"log日志输出";
    NSString * commitInfo = (NSString *)[Help getUserDefaultObject:kCommitInfo];
    if (commitInfo && ![commitInfo isEqualToString:@""]) {
        self.textView.string = commitInfo;
        self.placeLabel.hidden = YES;
    }
    self.textView.delegate = self;
    [self.arcCommandDirectoryButton setTitle:self.arcCommandPath?self.arcCommandPath:@"请选择arc所在目录"];
    [self.chooseDirectoryButton setTitle:self.chooseFilePath?self.chooseFilePath:@"请选择工程目录"];
    // Do any additional setup after loading the view
    NSDictionary * auditInfoDict = [Help getAuditInfo];
    [auditInfoDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSInteger value = [obj integerValue];
        NSString * key1 = (NSString *)key;
        if (value == 1) {
            NSTextField * label = [self createLabel:key1];
            [self.stackView addView:label inGravity:NSStackViewGravityLeading];
            [self.cacheLabelDict setObject:label forKey:key1];
        }
    }];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    // Update the view, if already loaded.
}

- (NSTextField *)createLabel:(NSString *)text{
    NSTextField * label = [[NSTextField alloc]init];
    label.editable = NO;
    label.bordered = NO; //不显示边框
    label.backgroundColor = [NSColor clearColor]; //控件背景色
    label.textColor = [NSColor blackColor];  //文字颜色
    label.stringValue = text;
    return label;
}

- (void)showAlertCheckVC{
    CheckViewController * checkVC = [[CheckViewController alloc] initWithNibName:@"CheckViewController" bundle:nil];
    checkVC.delegate = self;
    [[NSApplication sharedApplication].keyWindow.contentViewController presentViewControllerAsModalWindow:checkVC];;
}

#pragma mark - action

- (IBAction)startAuditAction:(id)sender {
    NSButton * button = (NSButton *)sender;
    button.enabled = NO;
    
    if (!self.arcCommandPath){
        button.enabled = YES;
        [self showAlertView:@"请选择arc命令目录!" window:nil];
        return;
    }
    
    if (!self.chooseFilePath) {
        button.enabled = YES;
        [self showAlertView:@"请选择工程目录!" window:nil];
        return;
    }
    
    __block NSUInteger chooseAuditCount = 0;
    __block NSString * auditPersonStr = @"";//审核人信息
    
    [self.auditPersonDictionary enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSString * getKey = (NSString *)key;
        if ([obj integerValue] == 1) {
            chooseAuditCount++;
            if ([auditPersonStr isEqualToString:@""]) {
                auditPersonStr = getKey;
            }else{
                auditPersonStr = [NSString stringWithFormat:@"%@,%@",auditPersonStr,getKey];
            }
        }
    }];
    
    if (chooseAuditCount < 3) {
        button.enabled = YES;
        [self showAlertView:@"审核人员至少3个!" window:nil];
        return;
    }
    
    NSString * commitInfoStr = @"";
    NSArray * commitInfoArr = [self.textView.string componentsSeparatedByString:@"\n"];//提交信息
    for (NSString * info in commitInfoArr) {
        commitInfoStr = [NSString stringWithFormat:@"%@%@",commitInfoStr,info];
    }
    
    if ([commitInfoStr isEqualToString:@""]) {
        button.enabled = YES;
        [self showAlertView:@"请输入commit信息" window:nil];
        return;
    }
    
    NSString * projectPathStr = [self.chooseFilePath substringFromIndex:7];//工程路径
    NSString * arcCommandPathStr = [self.arcCommandPath substringFromIndex:7];//arc命令路径
    
    NSString * language = (NSString *)[Help getUserDefaultObject:kArcLanguagePath];
    if ([language isEqualToString:NSLocalizedString(@"chinese", nil)]) {
        [FileCache writeFile:@"settingInfo.txt" content:[NSString stringWithFormat:@"摘要:%@\n测试计划:na\n评审者:%@",commitInfoStr,auditPersonStr]];
    }else{
        [FileCache writeFile:@"settingInfo.txt" content:[NSString stringWithFormat:@"Summary:%@\nTest Plan:na\nReviewers:%@",commitInfoStr,auditPersonStr]];
    }
    
    NSArray * array = @[@"startAuditScript.sh",commitInfoStr,projectPathStr,[FileCache getDoucumentPath],arcCommandPathStr];
    self.progressIndicatorView.hidden = NO;
    [self.progressIndicatorView startAnimation:nil];
    
    [self listeningLogFile];
    
    NSTask * task = [Help runTask:array block:^(NSString *resultStr,NSTask * task) {
        dispatch_async(dispatch_get_main_queue(), ^{
            button.enabled = YES;
            [NSObject cancelPreviousPerformRequestsWithTarget:self];
            [self cancelListeningLogFile];
        });
        [self hideProgressView];
        
        NSString * outputTxt = [FileCache readFile:@"output.txt"];
        NSString * extractUrl = [self extractUrl:outputTxt];
        if (extractUrl) {
            [self showAlertView:[NSString stringWithFormat:@"%@ 已生成并复制到粘贴板",extractUrl] window:nil];
        }else{
            NSString * message = @"";
            if (outputTxt){
                message = outputTxt;
            }else{
                if(resultStr){
                    message = resultStr;
                }
            }
            if (![message isEqualToString:@""]) {
                [self showAlertView:message window:nil];
            }
        }
    }];
    [self performSelector:@selector(cancelTask:) withObject:task afterDelay:60.0f];

}

- (IBAction)finishAuditAction:(id)sender {
    
    NSButton * button  = (NSButton *)sender;
    button.enabled = NO;
    
    NSString * projectPathStr = [self.chooseFilePath substringFromIndex:7];//工程路径
    NSArray * array = @[@"finishAuditScript.sh",projectPathStr,[FileCache getDoucumentPath]];
    self.progressIndicatorView.hidden = NO;
    [self.progressIndicatorView startAnimation:nil];
    NSTask * task = [Help runTask:array block:^(NSString *resultStr,NSTask * task) {
        dispatch_async(dispatch_get_main_queue(), ^{
            button.enabled = YES;
            [NSObject cancelPreviousPerformRequestsWithTarget:self];
            if (resultStr && ![resultStr isEqualToString:@""]) {
                self.textView.string = @"";
                self.placeLabel.hidden = NO;
                [Help storageUserDefaultObject:@"" key:kCommitInfo];
            }
        });
        [self hideProgressView];
        if (resultStr) {
            [self showAlertView:resultStr window:nil];
        }
    }];
    [self performSelector:@selector(cancelTask:) withObject:task afterDelay:60.0f];
}

- (IBAction)arcCommandDirectoryAction:(id)sender {
    [Help openPanel:self.arcCommandPath window:self.view.window block:^(NSString * path) {
        [self.arcCommandDirectoryButton setTitle:path];
        [Help storageFilePath:path key:kArcCommandPath];
    }];
}
    
    
- (IBAction)chooseDirectoryAction:(id)sender {
    [Help openPanel:self.chooseFilePath window:self.view.window block:^(NSString * path) {
        [self.chooseDirectoryButton setTitle:path];
    
        [FileCache clearFileCache:@[@"output.txt",@"gitdiff.txt",@"commitParam.txt"]];
        [Help storageFilePath:path key:kChooseFilePath];
    }];
}

- (IBAction)auditListAction:(id)sender {
    [self showAlertCheckVC];
}

- (IBAction)chineseAction:(id)sender {
    self.englishButton.state = !self.chineseButton.state;
    [Help storageUserDefaultObject:NSLocalizedString(@"chinese", nil) key:kArcLanguagePath];
}

- (IBAction)englistAction:(id)sender {
    self.chineseButton.state = !self.englishButton.state;
    [Help storageUserDefaultObject:@"English" key:kArcLanguagePath];
}

- (IBAction)showLogAction:(id)sender {
    NSButton * button = (NSButton *)sender;
    NSLog(@"%ld",button.state);
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:0.2];
    [self.bottomConstraint.animator setConstant:button.state == 1?180:20];
    [NSAnimationContext endGrouping];
    
}


#pragma mark - CheckVCDelegate

- (void)checkAction:(NSButton *)button checkTitle:(NSString *)checkTitle window:(NSWindow *)window{
    NSLog(@"%@-%ld",checkTitle,button.state);
    if (self.cacheLabelDict.allKeys.count==5 && button.state == 1) {
        button.state = 0;
        [self showAlertView:@"审核人最多只能选择5个" window:window];
        return;
    }
   
    if (button.state == 1) {
        NSTextField * label = [self createLabel:checkTitle];
        [self.stackView addView:label inGravity:NSStackViewGravityLeading];
        [self.cacheLabelDict setObject:label forKey:checkTitle];
    }else{
        NSTextField * label = self.cacheLabelDict[checkTitle];
        [self.stackView removeView:label];
        [self.cacheLabelDict removeObjectForKey:checkTitle];
    }
    [self.auditPersonDictionary setObject:@(button.state) forKey:checkTitle];
    [Help storageAuditInfo:self.auditPersonDictionary];
}

#pragma mark - NSTextViewDelegate

- (void)textDidChange:(NSNotification *)notification{
    NSTextView * textView = (NSTextView *)notification.object;
    if ([textView.string isEqualToString:@""]) {
        self.placeLabel.hidden = NO;
    }else{
        self.placeLabel.hidden = YES;
    }
    [Help storageUserDefaultObject:textView.string key:kCommitInfo];
}

#pragma mark - private mothod

- (void)listeningLogFile{
    [FileCache writeFile:@"log.txt" content:@""];
    if (!_fileMonitor) {
        _fileMonitor = [MonitorFileChangeHelp new];
    }
    NSString * path = [NSString stringWithFormat:@"%@/%@",[FileCache getDoucumentPath],@"log.txt"];
    [_fileMonitor watcherForPath:path block:^(NSInteger type) {
        NSString * logContent = [FileCache readFile:@"log.txt"];
        self.logTextView.string = logContent;
    }];
}

- (void)cancelListeningLogFile{
    [_fileMonitor cancelListeningLogFile];
}

- (void)getAndSetArcLanguage{
    NSString * language = (NSString *)[Help getUserDefaultObject:kArcLanguagePath];
    if (!language) {
        [Help getArcLanguage:^(NSString * languageParm) {
            [Help storageUserDefaultObject:languageParm key:kArcLanguagePath];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([languageParm isEqualToString:NSLocalizedString(@"chinese", nil)]) {
                    self.chineseButton.state = 1;
                    self.englishButton.state = 0;
                }else{
                    self.chineseButton.state = 0;
                    self.englishButton.state = 1;
                }
            });
        }];
    }else{
        if ([language isEqualToString:NSLocalizedString(@"chinese", nil)]) {
            self.chineseButton.state = 1;
            self.englishButton.state = 0;
        }else{
            self.chineseButton.state = 0;
            self.englishButton.state = 1;
        }
    }
}

- (void)cancelTask:(NSTask *)task{
    NSLog(@"cancelTask");
    if (task.isRunning) {
        [self showAlertView:@"脚本运行超时" window:nil];
        [task terminate];
    }
}

- (void)hideProgressView{
    if ([NSThread isMainThread]) {
        [self.progressIndicatorView stopAnimation:nil];
        self.progressIndicatorView.hidden = YES;
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.progressIndicatorView stopAnimation:nil];
            self.progressIndicatorView.hidden = YES;
        });
    }
}

- (void)showAlertView:(NSString *)messageText window:(NSWindow *)window{
    if ([NSThread isMainThread]) {
        if (!window) {
            window = self.view.window;
        }
        NSAlert *alert = [NSAlert new];
        [alert addButtonWithTitle:@"确定"];
        [alert setMessageText:messageText];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert beginSheetModalForWindow:window completionHandler:^(NSModalResponse returnCode) {
            if(returnCode == NSAlertFirstButtonReturn){
                NSLog(@"确定");
            }
        }];
    }else{
        __block NSWindow * window2 = window;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!window2) {
                window2 = self.view.window;
            }
            NSAlert *alert = [NSAlert new];
            [alert addButtonWithTitle:@"确定"];
            [alert setMessageText:messageText];
            [alert setAlertStyle:NSWarningAlertStyle];
            [alert beginSheetModalForWindow:window2 completionHandler:^(NSModalResponse returnCode) {
                if(returnCode == NSAlertFirstButtonReturn){
                    NSLog(@"确定");
                    window2 = nil;
                }
            }];
        });
    }
}

//提取url
- (NSString *)extractUrl:(NSString *)content{
    if ([content containsString:@"URI: http://"]) {
        NSError *error;
        NSString *regulaStr = @"\\bhttp?://[a-zA-Z0-9\\-.]+(?::(\\d+))?(?:(?:/[a-zA-Z0-9\\-._?,'+\\&%$=~*!():@\\\\]*)+)?";
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regulaStr
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:&error];
        NSArray *arrayOfAllMatches = [regex matchesInString:content options:0 range:NSMakeRange(0, [content length])];
        
        for (NSTextCheckingResult *match in arrayOfAllMatches)
        {
            NSString* substringForMatch = [content substringWithRange:match.range];
            return substringForMatch;
        }
    }
    return nil;
}

#pragma mark - getter

- (NSMutableDictionary<NSString *,NSTextField *> *)cacheLabelDict{
    if (!_cacheLabelDict) {
        _cacheLabelDict = [[NSMutableDictionary alloc] init];
    }
    return _cacheLabelDict;
}

- (NSString *)chooseFilePath{
    _chooseFilePath = [Help getFilePath:kChooseFilePath];
    
    return _chooseFilePath;
}
    
- (NSString *)arcCommandPath{
    _arcCommandPath = [Help getFilePath:kArcCommandPath];
    
    return _arcCommandPath;
}
    
- (NSMutableDictionary *)auditPersonDictionary{
    if (!_auditPersonDictionary) {
        NSDictionary * auditInfoDict = [Help getAuditInfo];
        _auditPersonDictionary = [[NSMutableDictionary alloc] initWithDictionary:auditInfoDict];
    }
    return _auditPersonDictionary;
}

@end
