//
//  WPLObservableMutableData.m
//  WP Layouter
//
//  Created by toyota-m2k on 2019/08/02.
//  Copyright © 2019 toyota-m2k. All rights reserved.
//

#import "WPLObservableMutableData.h"

/**
 * 最も一般的な監視可能オブジェクト
 */
@implementation WPLObservableMutableData {
    id _value;
}

- (id) value {
    return _value;
}

- (void) setValue:(id) v {
    if(![_value isEqual:v]) {
        _value  = v;
        [self valueChanged];
    }
}

- (instancetype) init {
    self = [super init];
    if(self!=nil) {
        _value = nil;
    }
    return self;
}

- (void)setIntegerValue:(NSInteger)v {
    [self setValue:[NSNumber numberWithInteger:v]];
}

- (void) setIntValue:(int)v {
    [self setValue:[NSNumber numberWithInt:v]];
}

- (void) setBoolValue:(bool)v {
    [self setValue:[NSNumber numberWithBool:v]];
}

- (void) setFloatValue:(CGFloat) v {
    [self setValue:[NSNumber numberWithDouble:v]];
}

- (void) setDoubleValue:(double) v {
    [self setValue:[NSNumber numberWithDouble:v]];
}

- (void) setStringValue:(NSString*)v {
    [self setValue:v];
}


+ (instancetype) dataWithIntValue:(int)v {
    WPLObservableMutableData* r = [[self alloc] init];
    [r setIntValue:v];
    return r;
}

+ (instancetype) dataWithIntegerValue:(NSInteger)v {
    WPLObservableMutableData* r = [[self alloc] init];
    [r setIntegerValue:v];
    return r;
}

+ (instancetype) dataWithBoolValue:(bool)v {
    WPLObservableMutableData* r = [[self alloc] init];
    [r setBoolValue:v];
    return r;
}
+ (instancetype) dataWithFloatValue:(CGFloat)v {
    WPLObservableMutableData* r = [[self alloc] init];
    [r setFloatValue:v];
    return r;
}
+ (instancetype) dataWithDoubleValue:(double)v {
    WPLObservableMutableData* r = [[self alloc] init];
    [r setDoubleValue:v];
    return r;
}
+ (instancetype) dataWithStringValue:(NSString*)v {
    WPLObservableMutableData* r = [[self alloc] init];
    [r setStringValue:v];
    return r;
}
+ (instancetype) dataWithValue:(id)v {
    WPLObservableMutableData* r = [[self alloc] init];
    r.value = v;
    return r;
}

@end
