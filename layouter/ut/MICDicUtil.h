//
//  MICDicUtil.h
//  layouter
//
//  Created by @toyota-m2k on 2016/02/05.
//  Copyright  2016年 @toyota-m2k Corporation. All rights reserved.
//

#ifndef MICDicUtil_h
#define MICDicUtil_h

static inline id exorcizeNSNull(id v) {
    return (v!=[NSNull null])?v:nil;
}

static inline id dic_obj(NSDictionary* dic, id key) {
    id r = dic[key];
    return (r!=[NSNull null]) ? r : nil;
}

static inline NSString* dic_string(NSDictionary* dic, id key) {
    id r = dic_obj(dic,key);
    return (nil!=r && [r respondsToSelector:@selector(stringValue)]) ? [r stringValue] : r;
}

static inline NSString* safe_dic_string(NSDictionary* dic, id key) {
    NSString* r = dic_string(dic,key);
    return (nil!=r) ? r : @"";
}

static inline NSDictionary* dic_dictionary(NSDictionary* dic, id key) {
    return dic_obj(dic,key);
}

static inline NSInteger dic_integer(NSDictionary* dic, id key, NSInteger defval) {
    id r = dic_obj(dic,key);
    return (nil!=r && [r respondsToSelector:@selector(integerValue)]) ? [r integerValue] : defval;
}
    
static inline bool dic_bool(NSDictionary* dic, id key, bool defval) {
    id r = dic_obj(dic,key);
    return (nil!=r && [r respondsToSelector:@selector(boolValue)]) ? [r boolValue] : defval;
}

#endif /* MICDicUtil_h */
