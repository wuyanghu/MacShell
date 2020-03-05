//
//  ConfigMacro.h
//  EC
//
//  Created by ruantong on 2019/5/20.
//  Copyright © 2019 music4kid. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ConfigInfo : NSObject
+ (NSMutableDictionary *)getConfigDict;
@end

NS_ASSUME_NONNULL_END
