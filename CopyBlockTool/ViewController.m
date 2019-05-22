//
//  ViewController.m
//  CopyBlockTool
//
//  Created by ruantong on 2019/5/22.
//  Copyright © 2019 wupeng. All rights reserved.
//

#import "ViewController.h"
#import "DragInView.h"
#import "FileCacheManager.h"
#import "XMLDictionary.h"
#import "TitleTableCellView.h"
#import "ClearCommand.h"
#import "UnzipCommand.h"
#import "CpCommand.h"

@interface ViewController()<DragInViewDelegate,NSTableViewDataSource,NSTableViewDelegate>
@property (weak) IBOutlet DragInView *dragInView;
@property (weak) IBOutlet NSTableView *tableView;

@property (nonatomic,strong) NSArray * tableViewDatas;
@end

@implementation ViewController

#pragma mark - lifeCycle

- (instancetype)initWithCoder:(NSCoder *)coder{
    self = [super initWithCoder:coder];
    if (self) {
        _tableViewDatas = [self getTitlesFromFiles];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dragInView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    // Do any additional setup after loading the view.
    [self.tableView registerNib:[[NSNib alloc] initWithNibNamed:@"TitleTableCellView" bundle:nil] forIdentifier:[TitleTableCellView cellReuseIdentifierInfo]];
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return self.tableViewDatas.count;
}

- (NSView*)tableView:(NSTableView*)tableView viewForTableColumn:(NSTableColumn*)tableColumn row:(NSInteger)row{
    TitleTableCellView *cell = [tableView makeViewWithIdentifier:[TitleTableCellView cellReuseIdentifierInfo] owner:self];
    cell.titleLabel.stringValue = self.tableViewDatas[row];

    return cell;
    
}

#pragma mark - action

- (IBAction)selectAction:(id)sender {
    [self openPanel];
}

- (IBAction)updateAction:(id)sender {
    TaskCommand * cpTask = [CpCommand new];
    [cpTask executeTask];
}

#pragma mark - DragInViewDelegate

- (void)dragOpenFile:(NSArray *)pathArr{
    [self openZipFile:pathArr];
}

#pragma mark - private method

- (void)openPanel {
    NSOpenPanel* panel = [NSOpenPanel openPanel];
    panel.canCreateDirectories = YES;//是否可以创建文件夹
    panel.canChooseDirectories = YES;//是否可以选择文件夹
    panel.canChooseFiles = YES;//是否可以选择文件
    [panel setAllowsMultipleSelection:NO];//是否可以多选
    //显示
    [panel beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger result) {
        //是否点击open 按钮
        if (result == NSModalResponseOK) {
            [self openZipFile:panel.URLs];
        }
    }];
}

- (void)openZipFile:(NSArray *)pathArr {
    TaskCommand * clearTask = [ClearCommand new];
    [clearTask executeTask];
    
    TaskCommand * unzipTask = [[UnzipCommand alloc] initWithProjectPath:pathArr.firstObject];
    [unzipTask executeTask];

    _tableViewDatas = [self getTitlesFromFiles];
    [self.tableView reloadData];
}

- (NSArray *)getTitlesFromFiles {
    NSMutableArray<NSString *> * titles = [NSMutableArray new];
    NSArray * files = [FileCacheManager getPathAllFile];
    for (NSString * path in files) {
        FileCacheManager * cacheManager = [FileCacheManager shareInstance];
        NSString * content = [cacheManager readFileSync:path];
        
        XMLDictionaryParser *parser=[[XMLDictionaryParser alloc]init];
        NSDictionary * dic=[parser dictionaryWithString:content];
        NSArray * titleArray =  dic[@"dict"][@"string"];
        NSString * title = titleArray.lastObject;
        if(title){
            [titles addObject:title];
        }
    }
    return titles;
}

@end
