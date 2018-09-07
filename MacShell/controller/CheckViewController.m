//
//  CheckViewController.m
//  MacShell
//
//  Created by ruantong on 2018/8/11.
//  Copyright © 2018年 ruantong. All rights reserved.
//

#import "CheckViewController.h"
#import "CheckNSTableViewCell.h"
#import "Help.h"

@interface CheckViewController ()<NSTableViewDelegate,NSTableViewDataSource,CheckCellDelegate>
@property (nonatomic,strong) NSArray<NSString *> * tableViewDataSourceArr;
@property (nonatomic,strong) NSTableView * tableView;

@property (nonatomic,strong) NSDictionary * auditInfoDict;
@end

@implementation CheckViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    self.title = NSLocalizedString(@"chooseAuditInfo", nil);
    self.view.frame = CGRectMake(0, 0, 250, self.view.frame.size.height);
    [self addView];
}

- (void)addView{
    if (!_tableView) {
       _tableView = [[NSTableView alloc] init];
       _tableView.delegate = self;
       _tableView.dataSource = self;
       [_tableView registerNib:[[NSNib alloc] initWithNibNamed:@"CheckNSTableViewCell" bundle:nil] forIdentifier:[CheckNSTableViewCell cellReuseIdentifierInfo]];

        NSTableColumn * column = [[NSTableColumn alloc] initWithIdentifier:@"field1"];
        column.width = 300;
        [_tableView addTableColumn:column];

        NSScrollView *tableContainerView = [[NSScrollView alloc] initWithFrame:self.view.frame];
        [tableContainerView setDocumentView:_tableView];
        [tableContainerView setDrawsBackground:NO];//不画背景（背景默认画成白色）
        [tableContainerView setHasVerticalScroller:YES];//有垂直滚动条
        //[_tableContainer setHasHorizontalScroller:YES];  //有水平滚动条
        tableContainerView.autohidesScrollers = YES;//自动隐藏滚动条（滚动的时候出现）
        
        [self.view addSubview:tableContainerView];
    }

    [_tableView reloadData];
}

#pragma mark - NSTableView
- (NSInteger)numberOfRowsInTableView:(NSTableView*)tableView{
    return self.tableViewDataSourceArr.count;
}

- (NSView*)tableView:(NSTableView*)tableView viewForTableColumn:(NSTableColumn*)tableColumn row:(NSInteger)row{
    CheckNSTableViewCell *cell = [tableView makeViewWithIdentifier:[CheckNSTableViewCell cellReuseIdentifierInfo] owner:self];
    cell.delegate = self;
    NSString * checkTitle = self.tableViewDataSourceArr[row];
    [cell setCheckTitle:checkTitle state:[self.auditInfoDict[checkTitle] integerValue]];
    return cell;
    
}

-(CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row{
    return 30;
}

- (BOOL)tableView:(NSTableView*)tableView shouldSelectRow:(NSInteger)row{

    NSTableRowView * myRowView = [self.tableView rowViewAtRow:row makeIfNecessary:NO];
    [myRowView setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleRegular];
    [myRowView setEmphasized:NO];
    return YES;
}

#pragma mark - CheckCellDelegate

- (void)checkAction:(NSButton *)button checkTitle:(NSString *)checkTitle{
    [self.delegate checkAction:button checkTitle:checkTitle window:self.view.window];
}

#pragma mark - getter

- (NSDictionary *)auditInfoDict{
    if (!_auditInfoDict) {
        NSDictionary * dict = (NSDictionary *)[Help getUserDefaultObject:kAuditInfoDict];
        _auditInfoDict = [NSDictionary dictionaryWithDictionary:dict];
    }
    return _auditInfoDict;
}

- (NSArray<NSString *> *)tableViewDataSourceArr{
    if (!_tableViewDataSourceArr) {
        _tableViewDataSourceArr = @[@"chensong",@"shezhiqiang",@"wenjianfen",@"yuanrunli",@"xubing",@"yangguang",@"peixujie",@"zhangrui",@"yingqingyuan",@"wupeng"];
    }
    return _tableViewDataSourceArr;
}

@end
