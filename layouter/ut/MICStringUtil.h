//
//  MICStringUtil.h
//  NSString/NSMutableStringをC++ちっくに扱えるようにしたい。
//
//  Created by @toyota-m2k on 2014/11/12.
//  Copyright (c) 2014年 @toyota-m2k. All rights reserved.
//

#import <UIKit/UiKit.h>

#if defined(__cplusplus)

class MICString {
private:
    NSString* _str;
public:
    MICString() {
        _str = @"";
    }
    MICString(NSString* src) {
        _str = (nil!=src) ? src : @"";
    }
    ~MICString() {
        _str = nil;
    }
    MICString(NSString* format, ...) {
        va_list arg;
        va_start(arg, format);
        _str = [[NSString alloc] initWithFormat:format arguments:arg];
    }
    
    MICString& append(NSString* src) {
        _str = [_str stringByAppendingString:src];
        return *this;
    }
    
    MICString& format(NSString* format, ...) {
        va_list arg;
        va_start(arg, format);
        _str = [[NSString alloc] initWithFormat:format arguments:arg];
        return *this;
    }
    
    MICString& appendFormat(NSString* format, ...) {
        va_list arg;
        va_start(arg, format);
        append([[NSString alloc] initWithFormat:format arguments:arg]);
        return *this;
    }
    
    MICString& trim() {
        _str = [_str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        return *this;
    }
    
    operator NSString* () {
        return _str;
    }
    
    MICString& operator +=(NSString* src) {
        return append(src);
    }
    
    bool operator ==(NSString* src) const {
        return [_str isEqualToString:src];
    }
    
    bool operator !=(NSString* src) const {
        return ![_str isEqualToString:src];
    }
};

class MICStringBuffer {
private:
    NSMutableString* _buff;
public:
    MICStringBuffer() {
        _buff = [[NSMutableString alloc] init];
    }
    MICStringBuffer(NSUInteger capacity) {
        _buff = [[NSMutableString alloc] initWithCapacity:capacity];
    }
    MICStringBuffer(NSString* src) {
        _buff = [[NSMutableString alloc] initWithString:src];
    }
    MICStringBuffer(NSString* src, NSUInteger capacity) {
        _buff = [[NSMutableString alloc] initWithCapacity:capacity];
        set(src);
    }
    ~MICStringBuffer(){
        _buff = nil;
    }
    
    MICStringBuffer& set(NSString* src) {
        [_buff setString:src];
        return *this;
    }

    MICStringBuffer& append(NSString* src) {
        [_buff appendString:src];
        return *this;
    }
    
    MICStringBuffer& insert(NSString* src, NSUInteger index) {
        [_buff insertString:src atIndex:index];
        return *this;
    }
    

    operator NSString* () const {
        return _buff;
    }
    operator NSMutableString* () const {
        return _buff;
    }
    MICStringBuffer& operator +=(NSString* str) {
        return append(str);
    }
};

inline NSString* MICTrimString(NSString* str) {
    return [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}
#else

#define MICTrimString(str)  [(str) stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]

#endif

