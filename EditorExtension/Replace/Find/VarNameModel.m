//
//  VarNameModel.m
//  EditorExtension
//
//  Created by ruantong on 2019/5/24.
//  Copyright © 2019 wupeng. All rights reserved.
//

#import "VarNameModel.h"

@implementation VarNameModel

- (instancetype)initWithVarName:(NSString *)varName prefix:(NSString * )prefix{
    self = [super init];
    if (self) {
        _varName = varName;
        _prefix = prefix;
    }
    return self;
}

- (NSString *)getPlaceHolder{
    if ([_prefix isEqualToString:@"."]) {
        return [NSString stringWithFormat:@"self.%@",_varName];
    }else if ([_prefix isEqualToString:@"_"]){
        return [NSString stringWithFormat:@"_%@",_varName];
    }
    return _varName;
}

@end
