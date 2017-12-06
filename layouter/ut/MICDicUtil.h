//
//  MICDicUtil.h
//  ios-layouter
//
//  Created by 豊田 光樹 on 2016/02/05.
//  Copyright  2016年 M.TOYOTA Corporation. All rights reserved.
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
    return dic_obj(dic,key);
}

static inline NSString* safe_dic_string(NSDictionary* dic, id key) {
    NSString* r = dic_string(dic,key);
    return (nil!=r) ? r : @"";
}

static inline NSDictionary* dic_dictionary(NSDictionary* dic, id key) {
    return dic_obj(dic,key);
}

#if defined(__cplusplus)
inline NSInteger dic_integer(NSDictionary* dic, id key, NSInteger defval=0) {
#else
static inline NSInteger dic_integer(NSDictionary* dic, id key, NSInteger defval) {
#endif
    NSNumber* r = dic_obj(dic,key);
    return (nil!=r) ? [r integerValue] : defval;
}

#endif /* MICDicUtil_h */
