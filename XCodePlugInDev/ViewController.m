//
//  ViewController.m
//  XCodePlugInDev
//
//  Created by ruantong on 2019/5/20.
//  Copyright © 2019 wupeng. All rights reserved.
//

#import "ViewController.h"
#import "DetailWindowController.h"
#import "ESharedUserDefault.h"
#import "EShortcutEntryModel.h"

@interface ViewController()<NSTableViewDataSource, NSTableViewDelegate, DetailWindowEditorDelegate,NSWindowDelegate>
@property (nonatomic, strong) NSMutableDictionary*                  mappingDic;
@property (nonatomic, strong) NSMutableArray<EShortcutEntryModel *>*                       mappingList;

@property (nonatomic, strong) NSImage*                 imgEdit;
@property (nonatomic, strong) NSImage*                 imgAdd;
@property (nonatomic, strong) NSImage*                 imgRemove;

@property (nonatomic, strong) DetailWindowController*               detailEditor;

@property (nonatomic, strong) IBOutlet NSTableView*           tableView;

@end

@implementation ViewController

#pragma mark - lifeCycle

- (instancetype)initWithCoder:(NSCoder *)coder{
    self = [super initWithCoder:coder];
    if (self) {
        [self initEditorWindow];
    }
    return self;
}

- (void)awakeFromNib{
    [super awakeFromNib];
}

- (void)initEditorWindow {
    
    self.imgEdit = [NSImage imageNamed:@"edit"];
    self.imgAdd = [NSImage imageNamed:@"add"];
    self.imgRemove = [NSImage imageNamed:@"remove"];
    
    self.mappingList = @[].mutableCopy;
    
    self.mappingDic = [_UD readMappingForOC].mutableCopy;
    
    NSArray* keys = self.mappingDic.allKeys;
    keys = [keys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSString* str1 = obj1;
        NSString* str2 = obj2;
        return [str1 compare:str2];
    }];
    for (NSString* key in keys) {
        EShortcutEntryModel* entry = [EShortcutEntryModel new];
        entry.key = key;
        entry.code = _mappingDic[key];
        [_mappingList addObject:entry];
    }
    [self sortMappingList];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleNone];
    dispatch_async(dispatch_get_main_queue(), ^{
        [_tableView reloadData];
    });
}

#pragma mark - tableView

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification {
    NSInteger selectedRow = [_tableView selectedRow];
    NSTableRowView *myRowView = [_tableView rowViewAtRow:selectedRow makeIfNecessary:NO];
    [myRowView setEmphasized:NO];
    
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    // Get a new ViewCell
    NSTableCellView *cellView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    EShortcutEntryModel* entry = _mappingList[row];
    
    if( [tableColumn.identifier isEqualToString:@"cShortcut"] )
    {
        cellView.textField.stringValue = entry.key;
        return cellView;
    }
    if( [tableColumn.identifier isEqualToString:@"cCode"] )
    {
        cellView.textField.stringValue = entry.code;
        cellView.textField.textColor = [NSColor colorWithWhite:0.5 alpha:1];
        return cellView;
    }
    if( [tableColumn.identifier isEqualToString:@"cEditCode"] )
    {
        NSButton* btn = (NSButton*)cellView;
        btn.image = _imgEdit;
        [btn setTarget:self];
        [btn setAction:@selector(onEditCodeClick:)];
        return cellView;
    }
    if( [tableColumn.identifier isEqualToString:@"cAdd"] )
    {
        NSButton* btn = (NSButton*)cellView;
        btn.image = _imgAdd;
        [btn setTarget:self];
        [btn setAction:@selector(onAddEntryClick:)];
        return cellView;
    }
    if( [tableColumn.identifier isEqualToString:@"cRemove"] )
    {
        NSButton* btn = (NSButton*)cellView;
        btn.image = _imgRemove;
        [btn setTarget:self];
        [btn setAction:@selector(onRemoveEntryClick:)];
        return cellView;
    }
    
    return cellView;
}


- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [self.mappingList count];
}

#pragma mark - action

- (void)onEditCodeClick:(id)sender
{
    NSButton* btn = sender;
    NSInteger row = [_tableView rowForView:btn];
    EShortcutEntryModel* entry = _mappingList[row];
    if (entry) {
        [self.detailEditor initWithMappingEntry:entry];
        self.detailEditor.editMode = DetailEditorModeUpdate;
        [self.detailEditor showWindow:self];
    }
}

- (void)onAddEntryClick:(id)sender
{
    EShortcutEntryModel* entry = [EShortcutEntryModel new];
    [self.detailEditor initWithMappingEntry:entry];
    self.detailEditor.editMode = DetailEditorModeInsert;
    [self.detailEditor showWindow:self];
}

- (void)onRemoveEntryClick:(id)sender
{
    NSButton* btn = sender;
    NSInteger row = [_tableView rowForView:btn];
    EShortcutEntryModel* entry = _mappingList[row];
    if (entry) {
        [_mappingList removeObject:entry];
        [self sortMappingList];
        [_tableView reloadData];
        
        [self saveMapping];
    }
}

#pragma mark - getter

- (DetailWindowController*)detailEditor
{
    if (_detailEditor == nil) {
        self.detailEditor = [[DetailWindowController alloc] initWithWindowNibName:@"DetailWindowController"];
        _detailEditor.delegate = self;
    }
    return _detailEditor;
}

#pragma mark - DetailWindowEditorDelegate
- (void)onEntryInserted:(EShortcutEntryModel*)entry {
    if (entry.key.length > 0 && entry.code.length > 0) {
        [_mappingList addObject:entry];
        [self sortMappingList];
        [_tableView reloadData];
        
        [self saveMapping];
    }
}

- (void)onEntryUpdated:(EShortcutEntryModel*)entry {
    [self sortMappingList];
    [_tableView reloadData];
    
    [self saveMapping];
}

- (void)windowWillClose:(NSNotification *)notification
{
    [self saveMapping];
}

#pragma mark - Other
- (void)saveMapping
{
    NSMutableDictionary* newMapping = @{}.mutableCopy;
    for (EShortcutEntryModel* entry in _mappingList) {
        [newMapping setObject:entry.code forKey:entry.key];
    }
    [_UD saveMappingForOC:newMapping];
}

- (void)sortMappingList
{
    [_mappingList sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        EShortcutEntryModel* entry1 = obj1;
        EShortcutEntryModel* entry2 = obj2;
        return [entry1.key compare:entry2.key];
    }];
}


@end
