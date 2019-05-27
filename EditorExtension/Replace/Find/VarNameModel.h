//
//  VarNameModel.h
//  EditorExtension
//
//  Created by ruantong on 2019/5/24.
//  Copyright © 2019 wupeng. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VarNameModel : NSObject
@property (nonatomic,copy) NSString * varName;
@property (nonatomic,copy) NSString * prefix;
- (instancetype)initWithVarName:(NSString *)varName prefix:(NSString * )prefix;
- (NSString *)getPlaceHolder;
@end

NS_ASSUME_NONNULL_END
