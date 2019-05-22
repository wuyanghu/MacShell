//
//  ConfigMacro.m
//  EC
//
//  Created by ruantong on 2019/5/20.
//  Copyright © 2019 music4kid. All rights reserved.
//

#import "ConfigInfo.h"
#import "OCMapping.h"

@implementation ConfigInfo

+ (NSMutableDictionary *)getConfigDict{
    return [[NSMutableDictionary alloc] initWithDictionary:@{
                                                      Key_ifs:Key_ifs_value,
                                                      Key_ifd:Key_ifd_value,
                                                      Key_ifa:Key_ifa_value}];
}

@end
