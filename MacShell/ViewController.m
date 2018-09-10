//
//  ViewController.m
//  MacShell
//
//  Created by ruantong on 2018/8/4.
//  Copyright © 2018年 ruantong. All rights reserved.
//

#import "ViewController.h"
#import "Help.h"
#import "FileCacheManager.h"
#import <Foundation/Foundation.h>
#import "CheckViewController.h"
#import "MonitorFileChangeHelp.h"
#import "TaskOperationManager.h"

@interface ViewController()<NSTextViewDelegate,CheckVCDelegate>
@property (weak) IBOutlet NSButtonCell *arcCommandDirectoryButton;//arc工程所在目录

@property (weak) IBOutlet NSButton *startAuditButton;
@property (weak) IBOutlet NSButton *finishAuditButton;

@property (weak) IBOutlet NSButton *isCommitProjButton;
@property (weak) IBOutlet NSButton *chineseButton;//中文
@property (weak) IBOutlet NSButton *englishButton;//英文

@property (weak) IBOutlet NSButton *chooseDirectoryButton;//工程目录
@property (weak) IBOutlet NSStackView *stackView;
@property (unsafe_unretained) IBOutlet NSTextView *textView; //信息录入框
@property (weak) IBOutlet NSTextField *placeLabel;
@property (weak) IBOutlet NSProgressIndicator *progressIndicatorView;//菊花圈

@property (weak) IBOutlet NSTextField *commitLabel;
@property (weak) IBOutlet NSTextField *arcLabel;
@property (weak) IBOutlet NSTextField *pullLabel;
@property (weak) IBOutlet NSTextField *pushLabel;
@property (nonatomic,strong) NSMutableDictionary * commitProgressDict;

@property (nonatomic,strong) NSMutableDictionary<NSString *,NSTextField*> * cacheLabelDict;

@property (nonatomic,strong) NSMutableDictionary * auditPersonDictionary;
@property (nonatomic,copy) NSString * chooseFilePath;//选择路径
@property (nonatomic,copy) NSString * arcCommandPath;
@property (nonatomic,copy) NSString * auditPersonStr;//审核人信息
@property (nonatomic,copy) NSString * commitInfoStr;//commit信息
@property (nonatomic,strong) MonitorFileChangeHelp *fileMonitor;

@property (weak) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (unsafe_unretained) IBOutlet NSTextView *logTextView;

@end

@implementation ViewController

//初始化数据
- (void)initData{
    /*
     语言初始化
     */
    [self getAndSetArcLanguage];
    
    /*
     是否提交xcodeproj初始化
     */
    NSNumber * isCommitXcodeproj = (NSNumber *)[Help getUserDefaultObject:kIsCommitXcodeproj];
    if(isCommitXcodeproj){
        [self.isCommitProjButton setState:[isCommitXcodeproj integerValue]];
    }else{
        [self.isCommitProjButton setState:1];
        [Help setUserDefaultObject:@(1) key:kIsCommitXcodeproj];
    }
    
    /*
     日志初始化
     */
    [[FileCacheManager shareInstance] readFileAsync:kLogTxt complete:^(NSString * logtxtContent) {
        if(!logtxtContent){
            [[FileCacheManager shareInstance] writeFileAsync:kLogTxt content:@"" complete:^(BOOL result) {
                
            }];
        }
        
        self.logTextView.editable = NO;
        
        if (logtxtContent){
            self.logTextView.string = logtxtContent;
        }else{
            self.logTextView.string = NSLocalizedString(@"logOutput", nil);
        }
    }];
    
    /*
     commit信息初始化
     */
    NSString * commitInfo = (NSString *)[Help getUserDefaultObject:kCommitInfo];
    if (commitInfo && ![commitInfo isEqualToString:@""]) {
        self.textView.string = commitInfo;
        self.placeLabel.hidden = YES;
    }
    self.textView.delegate = self;
    
    /*
     审核人信息初始化
     */
    NSDictionary * auditInfoDict = (NSDictionary *)[Help getUserDefaultObject:kAuditInfoDict];
    [auditInfoDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSInteger value = [obj integerValue];
        NSString * key1 = (NSString *)key;
        if (value == 1) {
            NSTextField * label = [self createLabel:key1];
            [self.stackView addView:label inGravity:NSStackViewGravityLeading];
            [self.cacheLabelDict setObject:label forKey:key1];
        }
    }];
    
    /*
     提交代码进度初始化
     */
    
    NSString * progressCommitValue = self.commitProgressDict[kProgressCommitKey];
    if([progressCommitValue isEqualToString:@"1"]){
        self.commitLabel.backgroundColor = kCommitAfterColor;
    }
    
    NSString * progressArcUrlValue = self.commitProgressDict[kProgressArcUrlKey];
    if([progressArcUrlValue isEqualToString:@"1"]){
        self.arcLabel.backgroundColor = kCommitAfterColor;
    }
    
    NSString * progressPushValue = self.commitProgressDict[kProgressPushKey];
    if([progressPushValue isEqualToString:@"1"]){
        self.pushLabel.backgroundColor = kCommitAfterColor;
    }
    
    NSString * progressPullValue = self.commitProgressDict[kProgressPullKey];
    if([progressPullValue isEqualToString:@"1"]){
        self.pullLabel.backgroundColor = kCommitAfterColor;
    }
    /*
     监听log.txt文件变化
     */
    
    [self listeningLogFile];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    
    [self.arcCommandDirectoryButton setTitle:self.arcCommandPath?self.arcCommandPath:NSLocalizedString(@"chooseArcPath", nil)];
    [self.chooseDirectoryButton setTitle:self.chooseFilePath?self.chooseFilePath:NSLocalizedString(@"chooseProjectPath", nil)];
    //12345678
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

- (void)dealloc{
    [self cancelListeningLogFile];
}

#pragma mark - action

- (IBAction)startAuditAction:(id)sender {
    
    NSButton * button = (NSButton *)sender;
    button.enabled = NO;
    
    if(![self isCheckStartAudit]){
        button.enabled = YES;
        return;
    }
    
    [[FileCacheManager shareInstance] writeFileSync:kLogTxt content:@""];

    NSString * arcCommandPathStr = [self.arcCommandPath substringFromIndex:7];//arc命令路径
    
    NSString * language = (NSString *)[Help getUserDefaultObject:kArcLanguagePath];
    if ([language isEqualToString:NSLocalizedString(@"chinese", nil)]) {
        [[FileCacheManager shareInstance] writeFileSync:@"settingInfo.txt" content:[NSString stringWithFormat:@"摘要:%@\n测试计划:na\n评审者:%@",_commitInfoStr,_auditPersonStr]];
    }else{
        [[FileCacheManager shareInstance] writeFileSync:@"settingInfo.txt" content:[NSString stringWithFormat:@"Summary:%@\nTest Plan:NA\nReviewers:%@",_commitInfoStr,_auditPersonStr]];
    }
    
    NSMutableArray * paramsArray = [self getShellComParams:@"startAuditScript.sh"];
    [paramsArray addObject:@"1"];
    [paramsArray addObject:_commitInfoStr];
    [paramsArray addObject:arcCommandPathStr];
    
    [self showProgressView];
    
    self.commitLabel.backgroundColor = kCommitBeforeColor;
    self.pullLabel.backgroundColor = kCommitBeforeColor;
    self.pushLabel.backgroundColor = kCommitBeforeColor;
    self.arcLabel.backgroundColor = kCommitBeforeColor;
    [self.commitProgressDict setObject:@"0" forKey:kProgressCommitKey];
    [self.commitProgressDict setObject:@"0" forKey:kProgressArcUrlKey];
    [self.commitProgressDict setObject:@"0" forKey:kProgressPullKey];
    [self.commitProgressDict setObject:@"0" forKey:kProgressPushKey];
    [Help setUserDefaultObject:self.commitProgressDict key:kCommitProgressDict];

    TaskOperationManager * taskManager = [TaskOperationManager shareManager];
    [taskManager addTaskOperationToQueue:[paramsArray copy] andFinishBlock:^(NSString *resultStr, NSTask *task) {
        NSLog(@"%@",resultStr);
        if([resultStr containsString:NSLocalizedString(@"commitSuccess", nil)]){
            self.commitLabel.backgroundColor = kCommitAfterColor;
            [self.commitProgressDict setObject:@"1" forKey:kProgressCommitKey];
            [Help setUserDefaultObject:self.commitProgressDict key:kCommitProgressDict];
        }
    }];

    [paramsArray replaceObjectAtIndex:3 withObject:@"2"];
    [taskManager addTaskOperationToQueue:[paramsArray copy] andFinishBlock:^(NSString *resultStr, NSTask *task) {
        button.enabled = YES;
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        
        [self hideProgressView];
        NSString * extractUrl = [Help extractUrl:resultStr];
        if (extractUrl) {
            [self showAlertView:[NSString stringWithFormat:@"%@ 已生成并复制到粘贴板",extractUrl] window:nil];
            self.arcLabel.backgroundColor = kCommitAfterColor;
            [self.commitProgressDict setObject:@"1" forKey:kProgressArcUrlKey];
            [Help setUserDefaultObject:self.commitProgressDict key:kCommitProgressDict];
        }else{
            [self showAlertView:NSLocalizedString(@"referLog", nil) window:nil];
        }
    }];

    [self performSelector:@selector(cancelTask:) withObject:button afterDelay:60.0f];

}

- (IBAction)finishAuditAction:(id)sender {
    
    [[FileCacheManager shareInstance] writeFileSync:kLogTxt content:@""];
    
    NSButton * button  = (NSButton *)sender;
    button.enabled = NO;
    
    NSString * arcCommandPathStr = [self.arcCommandPath substringFromIndex:7];//arc命令路径
    
    NSMutableArray * paramsArray = [self getShellComParams:@"finishAuditScript.sh"];
    [paramsArray addObject:@"1"];
    [paramsArray addObject:arcCommandPathStr];
    [self showProgressView];

    self.pullLabel.backgroundColor = kCommitBeforeColor;
    self.pushLabel.backgroundColor = kCommitBeforeColor;
    [self.commitProgressDict setObject:@"0" forKey:kProgressPullKey];
    [self.commitProgressDict setObject:@"0" forKey:kProgressPushKey];
    TaskOperationManager * taskManager = [TaskOperationManager shareManager];
    [taskManager addTaskOperationToQueue:[paramsArray copy] andFinishBlock:^(NSString *resultStr, NSTask *task) {
        //拉取代码
        if([resultStr containsString:NSLocalizedString(@"pullSuccess", nil)]){
            self.pullLabel.backgroundColor = kCommitAfterColor;
            [self.commitProgressDict setObject:@"1" forKey:kProgressPullKey];
            [Help setUserDefaultObject:self.commitProgressDict key:kCommitProgressDict];
        }
    }];
    
    [paramsArray replaceObjectAtIndex:3 withObject:@"2"];
    [taskManager addTaskOperationToQueue:[paramsArray copy] andFinishBlock:^(NSString *resultStr, NSTask *task) {
        //推送代码
        button.enabled = YES;
        [NSObject cancelPreviousPerformRequestsWithTarget:self];

        [self hideProgressView];
        if ([resultStr containsString:NSLocalizedString(@"pushSuccess", nil)]){
            self.pushLabel.backgroundColor = kCommitAfterColor;
            [self.commitProgressDict setObject:@"1" forKey:kProgressPushKey];
            
            self.textView.string = @"";
            self.placeLabel.hidden = NO;
            [Help setUserDefaultObject:@"" key:kCommitInfo];
            [Help setUserDefaultObject:self.commitProgressDict key:kCommitProgressDict];
            [self showAlertView:NSLocalizedString(@"pushSuccess", nil) window:nil];
        }else{
            [self showAlertView:NSLocalizedString(@"referLog", nil) window:nil];
        }
        
    }];
    
    [self performSelector:@selector(cancelTask:) withObject:button afterDelay:60.0f];
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
    
        [[FileCacheManager shareInstance] clearFileCache:@[@"output.txt",@"gitdiff.txt"]];
        [Help storageFilePath:path key:kChooseFilePath];
    }];
}

- (IBAction)isXcodeprojAction:(id)sender {
    NSButton * button = (NSButton *)sender;
    [Help setUserDefaultObject:@(button.state) key:kIsCommitXcodeproj];
    
    TaskOperationManager * taskManager = [TaskOperationManager shareManager];
    NSMutableArray * paramArray = [self getShellComParams:@"gitignoreScript.sh"];
    if(button.state == 1){
        [paramArray addObject:@"1"];
    }else{
        [paramArray addObject:@"0"];
    }
    
    [taskManager addTaskOperationToQueue:paramArray andFinishBlock:^(NSString *resultStr, NSTask *task) {
        NSLog(@"%@",resultStr);
    }];
}

- (IBAction)auditListAction:(id)sender {
    [self showAlertCheckVC];
}

- (IBAction)chineseAction:(id)sender {
    self.englishButton.state = !self.chineseButton.state;
    [Help setUserDefaultObject:NSLocalizedString(@"chinese", nil) key:kArcLanguagePath];
}

- (IBAction)englistAction:(id)sender {
    self.chineseButton.state = !self.englishButton.state;
    [Help setUserDefaultObject:@"English" key:kArcLanguagePath];
}

- (IBAction)showLogAction:(id)sender {
    NSButton * button = (NSButton *)sender;
    
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
        [self showAlertView:NSLocalizedString(@"chooseMaxAuditCount", nil) window:window];
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
    [Help setUserDefaultObject:self.auditPersonDictionary key:kAuditInfoDict];
}

#pragma mark - NSTextViewDelegate

- (void)textDidChange:(NSNotification *)notification{
    NSTextView * textView = (NSTextView *)notification.object;
    if ([textView.string isEqualToString:@""]) {
        self.placeLabel.hidden = NO;
    }else{
        self.placeLabel.hidden = YES;
    }
    [Help setUserDefaultObject:textView.string key:kCommitInfo];
}

#pragma mark - private mothod

//检查审核信息是否合格
- (BOOL)isCheckStartAudit{
    if (!self.arcCommandPath){
        [self showAlertView:NSLocalizedString(@"chooseArcPath", nil) window:nil];
        return NO;
    }
    
    if (!self.chooseFilePath) {
        [self showAlertView:NSLocalizedString(@"chooseProjectPath", nil) window:nil];
        return NO;
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
        [self showAlertView:NSLocalizedString(@"chooseMinAuditCount", nil) window:nil];
        return NO;
    }
    
    NSString * commitInfoStr = [Help removeSpaceAndNewline:self.textView.string];
    if ([commitInfoStr isEqualToString:@""] || !commitInfoStr) {
        [self showAlertView:NSLocalizedString(@"printCommitInfo", nil) window:nil];
        return NO;
    }
    _auditPersonStr = auditPersonStr;
    _commitInfoStr = commitInfoStr;
    return YES;
}

- (void)listeningLogFile{
    NSString * logtxt = kLogTxt;
    
    if (!_fileMonitor) {
        _fileMonitor = [MonitorFileChangeHelp new];
    }
    NSString * path = [NSString stringWithFormat:@"%@/%@",[[FileCacheManager shareInstance] getDoucumentPath],logtxt];
    [_fileMonitor watcherForPath:path block:^(NSInteger type) {
        NSString * logContent = [[FileCacheManager shareInstance] readFileSync:logtxt];
        self.logTextView.string = logContent?logContent:@"";
    }];
}

- (void)cancelListeningLogFile{
    [_fileMonitor cancelListeningLogFile];
}

- (void)getAndSetArcLanguage{
    NSString * language = (NSString *)[Help getUserDefaultObject:kArcLanguagePath];
    if (!language) {
        [Help getArcLanguage:^(NSString * languageParm) {
            [Help setUserDefaultObject:languageParm key:kArcLanguagePath];
            
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

- (void)cancelTask:(NSButton *)button{
    [self hideProgressView];
    
    button.enabled = YES;
    
    TaskOperationManager * taskManager = [TaskOperationManager shareManager];
    [taskManager cancelOperation];
    [self showRestartAlertView:NSLocalizedString(@"shellRunTimeOutTypAgain", nil) window:nil button:button];
}
    
- (void)showProgressView{
    self.progressIndicatorView.hidden = NO;
    [self.progressIndicatorView startAnimation:nil];
}

- (void)hideProgressView{
    [self.progressIndicatorView stopAnimation:nil];
    self.progressIndicatorView.hidden = YES;
}

- (void)showRestartAlertView:(NSString *)messageText window:(NSWindow *)window button:(NSButton *)button{
    if (!window) {
        window = self.view.window;
    }
    NSAlert *alert = [NSAlert new];
    [alert addButtonWithTitle:NSLocalizedString(@"retry", nil)];
    [alert addButtonWithTitle:NSLocalizedString(@"cancel", nil)];
    [alert setMessageText:messageText];
    [alert setAlertStyle:NSInformationalAlertStyle];
    [alert beginSheetModalForWindow:window completionHandler:^(NSModalResponse returnCode) {
        if(returnCode == NSAlertFirstButtonReturn){
            NSLog(@"重试");
            if(button == self.startAuditButton){
                [self startAuditAction:button];
            }else if(button == self.finishAuditButton){
                [self finishAuditAction:button];
            }
            
        }else if(returnCode == NSAlertSecondButtonReturn){
            NSLog(@"取消");
        }
    }];
}
    
- (void)showAlertView:(NSString *)messageText window:(NSWindow *)window{
    if (!window) {
        window = self.view.window;
    }
    NSAlert *alert = [NSAlert new];
    [alert addButtonWithTitle:NSLocalizedString(@"sure", nil)];
    [alert setMessageText:messageText];
    [alert setAlertStyle:NSInformationalAlertStyle];
    [alert beginSheetModalForWindow:window completionHandler:^(NSModalResponse returnCode) {
        if(returnCode == NSAlertFirstButtonReturn){
            NSLog(@"确定");
        }
    }];
}

#pragma mark - getter

- (NSMutableDictionary *)commitProgressDict{
    if(!_commitProgressDict){
        NSDictionary * commitDict = (NSDictionary *)[Help getUserDefaultObject:kCommitProgressDict];
        _commitProgressDict = [[NSMutableDictionary alloc] initWithDictionary:commitDict];
    }
    return _commitProgressDict;
}

- (NSMutableArray *)getShellComParams:(NSString *)shellName{
    /*
        脚本前几个固定参数
        参数1:脚本名
        参数2:工程路径
        参数3:缓存路径
     */
    NSString * projectPath = [self.chooseFilePath substringFromIndex:7];//工程路径
    NSString * sandboxPath = [[FileCacheManager shareInstance] getDoucumentPath];
    NSMutableArray * paramArray = [[NSMutableArray alloc] initWithArray:@[shellName,projectPath,sandboxPath]];
    return paramArray;
}

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
        NSDictionary * auditInfoDict = (NSDictionary *)[Help getUserDefaultObject:kAuditInfoDict];
        _auditPersonDictionary = [[NSMutableDictionary alloc] initWithDictionary:auditInfoDict];
    }
    return _auditPersonDictionary;
}

@end
