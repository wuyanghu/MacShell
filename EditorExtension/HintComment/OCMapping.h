//
//  OCMapping.h
//  EasyCode
//
//  Created by gao feng on 2016/10/15.
//  Copyright © 2016年 music4kid. All rights reserved.
//

#ifndef OCMapping_h
#define OCMapping_h

#pragma mark - custom

#define Key_ifs @"ifs"
#define Key_ifs_value @"\
if (<#statements#> && [<#statements#> isKindOfClass:[NSString class]] && <#statements#>.length>0) {\n\
<#statements#>\n\
}"

#define Key_ifd @"ifd"
#define Key_ifd_value @"\
if (<#statements#> && [<#statements#> isKindOfClass:[NSDictionary class]]) {\n\
<#statements#>\n\
}"

#define Key_ifa @"ifa"
#define Key_ifa_value @"\
if (<#statements#> && [<#statements#> isKindOfClass:[NSArray class]] && <#statements#>.count>0) {\n\
<#statements#>\n\
}"

#endif /* OCMapping_h */
