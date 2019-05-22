//
//  NSTitleTableCellView.h
//  CopyBlockTool
//
//  Created by ruantong on 2019/5/22.
//  Copyright © 2019 wupeng. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface TitleTableCellView : NSTableCellView
+ (NSString *)cellReuseIdentifierInfo;
@property (weak) IBOutlet NSTextFieldCell *titleLabel;

@end

NS_ASSUME_NONNULL_END
