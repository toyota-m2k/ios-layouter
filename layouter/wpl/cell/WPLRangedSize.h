//
//  WPLSizeRange.h
//
//  Created by @toyota-m2k on 2020/04/03.
//  Copyright © 2020 @toyota-m2k. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef struct _WPLMinMax {
    CGFloat min;
    CGFloat max;
} WPLMinMax;

#ifdef __cplusplus
class WPLCMinMax : public WPLMinMax {
public:
    WPLCMinMax() {
        min = CGFLOAT_MIN;
        max = CGFLOAT_MAX;
    }
    WPLCMinMax(CGFloat min_, CGFloat max_) {
        min = min_;
        max = max_;
    }
    WPLCMinMax(const WPLMinMax& s) {
        min = s.min;
        max = s.max;
    }
    WPLCMinMax& normalize() {
        if(min>max) {
            CGFloat v = min;
            min = max;
            max = v;
        }
        return *this;
    }
    bool isMaxSpecified() const {
        return max < CGFLOAT_MAX;
    }
    bool isMinSpecified() const {
        return min > CGFLOAT_MIN;
    }
    bool isSpecified() const {
        return isMaxSpecified()||isMinSpecified();
    }
    
    CGFloat trim(CGFloat s) {
        if(isMaxSpecified()) {
            s = MIN(s, max);
        }
        if(isMinSpecified()) {
            s = MAX(s, min);
        }
        return s;
    }
    
    bool operator == (const WPLMinMax& s) const {
        return min==s.min && max==s.max;
    }
    
    bool operator != (const WPLMinMax& s) const {
        return min!=s.min || max!=s.max;
    }

};
#endif

@interface WPLRangedSize : NSObject

@property (nonatomic) CGFloat min;
@property (nonatomic) CGFloat max;
@property (nonatomic) CGFloat size;

@property (nonatomic,readonly) bool isMinSpecified;
@property (nonatomic,readonly) bool isMaxSpecified;

- (instancetype) initSize:(CGFloat)size min:(CGFloat) min max:(CGFloat)max;

+ (instancetype) rangedSize:(CGFloat)size min:(CGFloat)min;
+ (instancetype) rangedSize:(CGFloat)size max:(CGFloat)max;
+ (instancetype) rangedSize:(CGFloat)size min:(CGFloat)min max:(CGFloat)max;
+ (instancetype) rangedSize:(CGFloat)size span:(WPLMinMax)span;

#ifdef __cplusplus
@property (nonatomic) WPLMinMax span;
+ (CGFloat) toSize:(id)data;
+ (CGFloat) toSize:(id)data span:(WPLMinMax&)span;
#endif

@end
