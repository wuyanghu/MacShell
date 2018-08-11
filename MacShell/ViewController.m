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

#import "CheckViewController.h"

@interface ViewController()<NSTextViewDelegate,CheckVCDelegate>
@property (weak) IBOutlet NSButton *chooseDirectoryButton;//工程目录
@property (weak) IBOutlet NSStackView *stackView;
@property (unsafe_unretained) IBOutlet NSTextView *textView; //信息录入框
@property (weak) IBOutlet NSTextField *placeLabel;
@property (weak) IBOutlet NSProgressIndicator *progressIndicatorView;//菊花圈

@property (nonatomic,strong) NSMutableDictionary<NSString *,NSTextField*> * cacheLabelDict;

@property (nonatomic,strong) NSMutableDictionary * auditPersonDictionary;
@property (nonatomic,copy) NSString * chooseFilePath;//选择路径


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.textView.delegate = self;
    [self.chooseDirectoryButton setTitle:self.chooseFilePath?self.chooseFilePath:@"请选择目录"];
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
    
    if (!self.chooseFilePath) {
        [self showAlertView:@"请选择工程目录!"];
        return;
    }
    
    __block NSUInteger chooseAuditCount = 0;
    __block NSString * auditPersonStr = @"";//审核人信息
    
    [self.auditPersonDictionary enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSString * getKey = (NSString *)key;
        if ([obj integerValue] == 0) {
            chooseAuditCount++;
        }else{
            if ([auditPersonStr isEqualToString:@""]) {
                auditPersonStr = getKey;
            }else{
                auditPersonStr = [NSString stringWithFormat:@"%@,%@",auditPersonStr,getKey];
            }
        }
    }];
    
    if (chooseAuditCount == self.auditPersonDictionary.allKeys.count) {
        [self showAlertView:@"请选择审核人员!"];
        return;
    }
    
    NSString * commitInfoStr = self.textView.string;//提交信息
    NSString * projectPathStr = [self.chooseFilePath substringFromIndex:7];//工程路径
    
    [FileCache writeFile:@"settingInfo.txt" content:[NSString stringWithFormat:@"摘要:%@\n测试计划:na\n评审者:%@",commitInfoStr,auditPersonStr]];
    
    NSArray * array = @[@"startAuditScript.sh",commitInfoStr,projectPathStr,[FileCache getDoucumentPath]];
    self.progressIndicatorView.hidden = NO;
    [self.progressIndicatorView startAnimation:nil];
    [Help runTask:array block:^(NSString *resultStr,NSTask * task) {
        dispatch_async(dispatch_get_main_queue(), ^{
            button.enabled = YES;
        });
        [self hideProgressView];
        
        NSString * outputTxt = [FileCache readFile:@"output.txt"];
        NSString * extractUrl = [self extractUrl:outputTxt];
        if (extractUrl) {
            [self showAlertView:[NSString stringWithFormat:@"%@ 已生成并复制到粘贴板",extractUrl]];
        }else{
            [self showAlertView:outputTxt!=nil?outputTxt:resultStr];
        }
    }];

}

- (IBAction)finishAuditAction:(id)sender {
    NSButton * button  = (NSButton *)sender;
    button.enabled = NO;
    
    NSString * projectPathStr = [self.chooseFilePath substringFromIndex:7];//工程路径
    NSArray * array = @[@"finishAuditScript.sh",projectPathStr,[FileCache getDoucumentPath]];
    self.progressIndicatorView.hidden = NO;
    [self.progressIndicatorView startAnimation:nil];
    [Help runTask:array block:^(NSString *resultStr,NSTask * task) {
        dispatch_async(dispatch_get_main_queue(), ^{
            button.enabled = YES;
        });
        [self hideProgressView];
        
        [self showAlertView:resultStr];
    }];
}

- (IBAction)chooseDirectoryAction:(id)sender {
    NSOpenPanel* panel = [NSOpenPanel openPanel];
    [panel setDirectory:self.chooseFilePath];//保存文件路径
    panel.canCreateDirectories = YES;//是否可以创建文件夹
    panel.canChooseDirectories = YES;//是否可以选择文件夹
    panel.canChooseFiles = NO;//是否可以选择文件
    [panel setAllowsMultipleSelection:NO];//是否可以多选
    //显示
    [panel beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger result) {
        //是否点击open 按钮
        if (result == NSModalResponseOK) {
            //NSURL *pathUrl = [panel URL];
            NSString * chooseFilePath = [panel.URLs.firstObject path];
            [self.chooseDirectoryButton setTitle:chooseFilePath];
            
            [FileCache clearFileCache:@[@"output.txt",@"gitdiff.txt",@"commitParam.txt"]];
            [Help storageFilePath:chooseFilePath];
        }
    }];
    
}

- (IBAction)auditListAction:(id)sender {
    [self showAlertCheckVC];
}

#pragma mark - CheckVCDelegate

- (void)checkAction:(NSButton *)button checkTitle:(NSString *)checkTitle{
    NSLog(@"%@-%ld",checkTitle,button.state);
    if (self.cacheLabelDict.allKeys.count==5 && button.state == 1) {
        button.state = 0;
        [self showAlertView:@"审核人最多只能选择5个"];
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
}

#pragma mark - private mothod

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

- (void)showAlertView:(NSString *)messageText{
    if ([NSThread isMainThread]) {
        NSAlert *alert = [NSAlert new];
        [alert addButtonWithTitle:@"确定"];
        [alert setMessageText:messageText];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert beginSheetModalForWindow:[self.view window] completionHandler:^(NSModalResponse returnCode) {
            if(returnCode == NSAlertFirstButtonReturn){
                NSLog(@"确定");
            }
        }];
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            NSAlert *alert = [NSAlert new];
            [alert addButtonWithTitle:@"确定"];
            [alert setMessageText:messageText];
            [alert setAlertStyle:NSWarningAlertStyle];
            [alert beginSheetModalForWindow:[self.view window] completionHandler:^(NSModalResponse returnCode) {
                if(returnCode == NSAlertFirstButtonReturn){
                    NSLog(@"确定");
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
    _chooseFilePath = [Help getFilePath];
    
    return _chooseFilePath;
}

- (NSMutableDictionary *)auditPersonDictionary{
    if (!_auditPersonDictionary) {
        NSDictionary * auditInfoDict = [Help getAuditInfo];
        _auditPersonDictionary = [[NSMutableDictionary alloc] initWithDictionary:auditInfoDict];
    }
    return _auditPersonDictionary;
}

@end
