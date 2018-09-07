//
//  CommonMacro.h
//  MacShell
//
//  Created by ruantong on 2018/9/4.
//  Copyright © 2018年 ruantong. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kChooseFilePath @"chooseFilePath"//缓存选择文件的路径
#define kArcCommandPath @"arcCommandPath"//arc文件命令所在目录
#define kArcLanguagePath @"arcLanguagePath"//arc使用语言(中文or英文)

#define kIsCommitXcodeproj @"isCommitXcodeproj"
#define kCommitInfo @"commitInfo" //commit信息
#define kAuditInfoDict @"auditInfoDict"//审核人信息

#define kCommitProgressDict @"commitProgressDict"
#define kProgressCommitKey @"progressCommitKey"
#define kProgressArcUrlKey @"progressArcUrlKey"
#define kProgressPullKey @"progressPullKey"
#define kProgressPushKey @"progressPushKey"

#define kCommitBeforeColor [NSColor redColor]
#define kCommitAfterColor [NSColor greenColor]

#define kLogTxt @"log.txt"
