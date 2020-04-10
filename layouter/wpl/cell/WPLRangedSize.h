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
    WPLCMinMax& setMin(CGFloat min_) {
        min = min_;
        return normalize();
    }
    WPLCMinMax& setMax(CGFloat max_) {
        max = max_;
        return normalize();
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
    
    static CGFloat clip(const WPLMinMax& r, CGFloat s) {
        if(r.max<CGFLOAT_MAX) {
            s = MIN(s, r.max);
        }
        if(r.min>CGFLOAT_MIN) {
            s = MAX(s, r.min);
        }
        return s;
    }
    
    CGFloat clip(CGFloat s) const {
        return clip(*this, s);
    }

    bool operator == (const WPLMinMax& s) const {
        return min==s.min && max==s.max;
    }
    
    bool operator != (const WPLMinMax& s) const {
        return min!=s.min || max!=s.max;
    }
    
    WPLCMinMax intersect(const WPLMinMax& s) const {
        if(max<s.min || min>s.max) {
            // 重なりがなければ、this側を採用
            return *this;
        }
        return WPLCMinMax(MAX(min,s.min), MIN(max,s.max));
    }

    static inline WPLCMinMax intersect(const WPLMinMax& a, const WPLMinMax& b) {
        WPLCMinMax r(a);
        if(a.max<b.min || b.max <a.min) {
            // 重なりがなければ第１引数を採用
            return r;
        }
        return r.intersect(b);
    }
    
    static const WPLCMinMax empty();
};





#endif

@interface WPLRangedSize : NSObject

@property (nonatomic) CGFloat min;
@property (nonatomic) CGFloat max;
@property (nonatomic) CGFloat size;

@property (nonatomic,readonly) bool isMinSpecified;
@property (nonatomic,readonly) bool isMaxSpecified;

- (instancetype)init    NS_UNAVAILABLE;
+ (instancetype)new     NS_UNAVAILABLE;

//- (instancetype) initSize:(CGFloat)size min:(CGFloat) min max:(CGFloat)max;

//+ (instancetype) rangedSize:(CGFloat)size min:(CGFloat)min;
//+ (instancetype) rangedSize:(CGFloat)size max:(CGFloat)max;
//+ (instancetype) rangedSize:(CGFloat)size min:(CGFloat)min max:(CGFloat)max;
//+ (instancetype) rangedSize:(CGFloat)size span:(WPLMinMax)span;

+ (instancetype) rangedAutoMin:(CGFloat) min max:(CGFloat)max;
+ (instancetype) rangedStretchMin:(CGFloat) min max:(CGFloat)max;

#ifdef __cplusplus
@property (nonatomic) WPLMinMax span;
+ (CGFloat) toSize:(id)data;
+ (CGFloat) toSize:(id)data span:(WPLMinMax&)span;
#endif

@end

