//
//  WPLRangedSize.m
//
//  Created by @toyota-m2k on 2020/04/03.
//  Copyright © 2020 @toyota-m2k. All rights reserved.
//

#import "WPLRangedSize.h"
#import "MICDicUtil.h"
#import "MICVar.h"


const WPLCMinMax WPLCMinMax::empty() {
    static WPLCMinMax _empty;
    return _empty;
}
/**
 * WPLGridCell の rowDefs/colDefs で使用する、size/min/maxを保持できるクラス。
 * min/max を指定する時は、通常、sizeは、AUTO(0)または、STRC(<0) とする。>0な値をしていした場合はAUTOとして扱う。
 */
@implementation WPLRangedSize

- (instancetype)initSize:(CGFloat)size min:(CGFloat)min max:(CGFloat)max {
    self = [super init];
    if(self!=nil) {
        _size = size;
        _min = min;
        _max = max;
    }
    return self;
}

+ (instancetype)rangedSize:(CGFloat)size min:(CGFloat)min max:(CGFloat)max {
    return [[self alloc] initSize:size min:min max:max];
}

+ (instancetype)rangedSize:(CGFloat)size min:(CGFloat)min {
    return [self rangedSize:size min:min max:CGFLOAT_MAX];
}

+ (instancetype)rangedSize:(CGFloat)size max:(CGFloat)max {
    return [self rangedSize:size min:CGFLOAT_MIN max:max];
}

+ (instancetype) rangedSize:(CGFloat)size span:(WPLMinMax)span {
    return [self rangedSize:size min:span.min max:span.max];
}

+ (instancetype) rangedAutoMin:(CGFloat) min max:(CGFloat)max {
    return [self rangedSize:0 min:min max:max];
}

+ (instancetype) rangedStretch:(CGFloat)scale min:(CGFloat) min max:(CGFloat)max {
    if(scale>0) {
        scale = -scale;
    }
    return [self rangedSize:scale min:min max:max];
}

- (bool)isMaxSpecified {
    return _max < CGFLOAT_MAX;
}

- (bool)isMinSpecified {
    return _min > CGFLOAT_MIN;
}

- (WPLMinMax)span {
    return WPLCMinMax(_min, _max);
}

- (void)setSpan:(WPLMinMax)span {
    _min = span.min;
    _max = span.max;
}

+ (CGFloat)toSize:(id)data {
    if([data isKindOfClass:self.class]) {
        return [(WPLRangedSize*)data size];
    } else if([data isKindOfClass:NSNumber.class]) {
        return number_to_cgfloat(data);
    } else {
        return 0;
    }
}

+ (CGFloat)toSize:(id)data span:(WPLMinMax&)span {
    if([data isKindOfClass:self.class]) {
        let v = (WPLRangedSize*)data;
        span = v.span;
        return [v size];
    } else if([data isKindOfClass:NSNumber.class]) {
        span = WPLCMinMax();
        return number_to_cgfloat(data);
    } else {
        span = WPLCMinMax();
        return 0;
    }
}


@end
