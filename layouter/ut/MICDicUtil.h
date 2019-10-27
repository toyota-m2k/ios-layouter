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

static inline CGFloat dic_float(NSDictionary* dic, id key, CGFloat defval) {
    id r = dic_obj(dic,key);
#if CGFLOAT_IS_DOUBLE
    return (nil!=r && [r respondsToSelector:@selector(doubleValue)]) ? [r doubleValue] : defval;
#else
    return (nil!=r && [r respondsToSelector:@selector(floatValue)]) ? [r floatValue] : defval;
#endif
}

#if defined(__cplusplus)
class MICMap {
private:
    NSDictionary* _dic;
    NSMutableDictionary* _mdic;
    MICMap(NSUInteger capacity=16) {
        _mdic = [NSMutableDictionary dictionaryWithCapacity:capacity];
        _dic = _mdic;
    }
    MICMap(NSDictionary* src) {
        _dic = src;
        _mdic = nil;
        if([src isKindOfClass:NSMutableDictionary.class]) {
            _mdic = (NSMutableDictionary*)src;
        }
    }
    
    id rawGetAt(id key) const  {
        return (_dic!=nil) ? _dic[key] : nil;
    }
    
    id objectAt(id key) const  {
        return dic_obj(_dic, key);
    }
    
    NSString* stringAt(id key) const  {
        return dic_string(_dic, key);
    }
    NSString* safeStringAt(id key) const  {
        return safe_dic_string(_dic, key);
    }
    
    NSInteger integerAt(id key, NSInteger def=0) const  {
        return dic_integer(_dic, key, def);
    }
    
    CGFloat floatAt(id key, CGFloat def=0) const  {
        return dic_float(_dic, key, def);
    }
    
    bool boolAt(id key, bool def=false) const {
        return dic_bool(_dic, key, def);
    }
    
    MICMap& setAt(id key, id value) {
        [_mdic setObject:value forKey:key];
        return *this;
    }
    
    MICMap& setIntegerAt(id key, NSInteger value) {
        setAt(key, @(value));
        return *this;
    }
    MICMap& setFloatAt(id key, CGFloat value) {
        setAt(key, @(value));
        return *this;
    }
    MICMap& setBoolAt(id key, bool value) {
        setAt(key, @(value));
        return *this;
    }
    
    MICMap& removeAt(id key) {
        [_mdic removeObjectForKey:key];
        return *this;
    }
};

#endif

#endif /* MICDicUtil_h */
