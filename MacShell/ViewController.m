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

@interface ViewController()
@property (unsafe_unretained) IBOutlet NSTextView *textView; //信息录入框
@property (weak) IBOutlet NSButton *chooseDirectoryButton;//工程目录

@property (weak) IBOutlet NSButtonCell *chensongButtonCell;
@property (weak) IBOutlet NSButtonCell *shezhiqiangButtonCell;
@property (weak) IBOutlet NSButtonCell *yuanrunliButtonCell;

@property (weak) IBOutlet NSProgressIndicator *progressIndicatorView;//菊花圈

@property (nonatomic,strong) NSMutableDictionary * auditPersonDictionary;

@property (nonatomic,copy) NSString * chooseFilePath;//选择路径

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //1
    //2
    
    [self.chooseDirectoryButton setTitle:self.chooseFilePath?self.chooseFilePath:@"请选择目录"];
    // Do any additional setup after loading the view.
    self.chensongButtonCell.state = [self.auditPersonDictionary[kChensong] intValue];
    self.shezhiqiangButtonCell.state = [self.auditPersonDictionary[kShezhiqiang] intValue];
    self.yuanrunliButtonCell.state = [self.auditPersonDictionary[kYuanrunli] intValue];
    
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

#pragma mark - action

- (IBAction)startAuditAction:(id)sender {
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
    NSString * projectPathStr = [self.chooseFilePath substringFromIndex:7];//工程路径
    NSArray * array = @[@"finishAuditScript.sh",projectPathStr,[FileCache getDoucumentPath]];
    self.progressIndicatorView.hidden = NO;
    [self.progressIndicatorView startAnimation:nil];
    [Help runTask:array block:^(NSString *resultStr,NSTask * task) {
        [self hideProgressView];
        
        [self showAlertView:resultStr];
    }];
}

- (IBAction)chooseDirectoryAction:(id)sender {
    NSOpenPanel* panel = [NSOpenPanel openPanel];
    [panel setDirectory:NSHomeDirectory()];//保存文件路径
    panel.canCreateDirectories = YES;//是否可以创建文件夹
    panel.canChooseDirectories = YES;//是否可以选择文件夹
    panel.canChooseFiles = NO;//是否可以选择文件
    [panel setAllowsMultipleSelection:NO];//是否可以多选
    panel.directoryURL = [NSURL URLWithString:self.chooseFilePath];
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

- (IBAction)chensongAction:(id)sender {
    NSLog(@"state=%ld",self.chensongButtonCell.state);
    [self.auditPersonDictionary setObject:@(self.chensongButtonCell.state) forKey:kChensong];
    [Help storageAuditInfo:self.auditPersonDictionary];
}

- (IBAction)shezhiqiangAction:(id)sender {
    NSLog(@"state=%ld",self.shezhiqiangButtonCell.state);
    [self.auditPersonDictionary setObject:@(self.shezhiqiangButtonCell.state) forKey:kShezhiqiang];
    [Help storageAuditInfo:self.auditPersonDictionary];
}

- (IBAction)yuanrunliAction:(id)sender {
    NSLog(@"state=%ld",self.yuanrunliButtonCell.state);
    [self.auditPersonDictionary setObject:@(self.yuanrunliButtonCell.state) forKey:kYuanrunli];
    [Help storageAuditInfo:self.auditPersonDictionary];
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
