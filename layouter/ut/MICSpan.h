//
//  MICSpan
//  最大値/最小値を管理するクラス
//
//  Created by @toyota-m2k on 2014/11/12.
//  Copyright (c) 2014年 @toyota-m2k. All rights reserved.
//

#import <UIKit/UIKit.h>

#if defined(__cplusplus)

template <typename T> inline T MICMaxValue();
template <> inline NSInteger MICMaxValue() {
    return NSIntegerMax;
}
template <> inline NSUInteger MICMaxValue() {
    return NSUIntegerMax;
}
template <> inline CGFloat MICMaxValue() {
    return CGFLOAT_MAX;
}
template <> inline int MICMaxValue() {
    return INT_MAX;
}
template <> inline uint MICMaxValue() {
    return UINT_MAX;
}

template <typename T> inline T MICMinValue();
template <> inline NSInteger MICMinValue() {
    return NSIntegerMin;
}
template <> inline NSUInteger MICMinValue() {
    return 0;
}
template <> inline CGFloat MICMinValue() {
    return CGFLOAT_MIN;
}
template <> inline int MICMinValue() {
    return INT_MIN;
}
template <> inline uint MICMinValue() {
    return 0;
}

/**
 * 最大値/最小値を管理するクラス
 */
template<typename T> class MICSpan {
protected:
    T _min;           ///< 最小値
    T _max;           ///< 最大値

public:
    /**
     * デフォルトコンストラクタ
     */
    MICSpan<T>() {
        reset();
    }
    /**
     * 最小値と最大値を与えて初期化
     */
    MICSpan<T>(T min, T max) {
        set(min,max);
    }
    
    bool isMaxSpacified() {
        return _max < MICMaxValue<T>();
    }
    bool isMinSpecified() {
        return _min > MICMinValue<T>();
    }
//    /**
//     * コピーコンストラクタ
//     */
//    MICSpan<T>(const MICSpan<T>& s) {
//        _min = s._min;
//        _max = s._max;
//    }
    /**
     * 最小値を取得
     */
    T min() const {
        return _min;
    }
    /**
     * 最大値を取得
     */
    T max() const {
        return _max;
    }
    
    /**
     * スパン（最大値ー最小値）を取得
     */
    T span() const {
        return _max - _min;
    }
    
    /**
     * 最大値＞最小値となることを保証する    bool reset() {
         _min = MICMinValue<T>();
         _max = MICMaxValue<T>();
     }
     

     */
    MICSpan<T>& normalize() {
        if(_min>_max) {
            T a = _min;
            _min = _max;
            _max = a;
        }
        return *this;
    }
    
    void reset() {
        _min = MICMinValue<T>();
        _max = MICMaxValue<T>();
    }

    /**
     * 最小値、最大値を設定
     */
    MICSpan<T>& set(T min, T max) {
        _min = min;
        _max = max;
        return normalize();
    }
    
    /**
     * 最小値を単純に設定
     *  最小値を変更したら（必要に応じて） normalize() または setMaxBySpan()を呼ぶこと。
     */
    MICSpan<T>& _setMin(T min) {
        _min = min;
        return *this;
    }

    MICSpan<T>& setMin(T min) {
        _min = min;
        return normalize();
    }
    
    /**
     * 最大値を単純に設定
     *  最大値を変更したら（必要に応じて） normalize() または setMinBySpan()を呼ぶこと。
     */
    MICSpan<T>& _setMax(T max) {
        _max = max;
        return *this;
    }
    
    MICSpan<T>& setMax(T max) {
        _max = max;
        return normalize();
    }
    
    /**
     * スパン（最大値ー最小値の値）を与えて、最小値を変更する。
     */
    MICSpan<T>& setMinBySpan(T span) {
        _min = _max - span;
        return normalize();
    }
    /**
     * スパン（最大値ー最小値の値）を与えて、最大値を変更する。
     */
    MICSpan<T>& setMaxBySpan(T span) {
        _max = _min + span;
        return normalize();
    }
    
    /**
     * 与えられた値で、min/max 値を更新する。
     */
    MICSpan<T>& update(T v) {
        if(v < _min) {
            _min = v;
        }
        if(_max<v) {
            _max = v;
        }
        return *this;
    }
    
    /**
     * 与えられた値を、最大値／最小値の範囲でクリップして返す。
     * @param v 入力
     * @return 引数vをSpanの範囲でクリップした値
     */
    T limit(T v) const {
        if(v < _min) {
            return _min;
        } else if( _max < v) {
            return _max;
        } else {
            return v;
        }
    }
    
    /**
     * 与えられたSpanを、このオブジェクトの最大値／最小値の範囲でクリップして返す。
     * @param v  入力・出力値
     * @return 引数をvの最大値・最小値を、このオブジェクトのSpanの範囲でクリップした値
     */
    MICSpan<T>& limit(MICSpan<T>& v) const {
        v._min = limit(v._min);
        v._max = limit(v._max);
        return v;
    }

    /**
     * このオブジェクトの最大値・最小値を、引数limの範囲でクリップする。
     *  limit()の方向が逆転した版
     *
     * @param lim 制限値を保持した入力
     * @return *this
     */
    MICSpan<T>& limitBy(const MICSpan<T>& lim) {
        return lim.limit(*this);
    }
    
    static T limit(T min, T max, T v) {
        return MICSpan<T>(min,max).limit(v);
    }
};

/**
 * CGFloat の min/max 管理
 */
class MICSpanF : public MICSpan<CGFloat> {
public:
    /** 空の範囲のインスタンスを作成：update()して、spanを構築していくことを想定 */
    MICSpanF() {_min=CGFLOAT_MAX;_max=CGFLOAT_MIN; }
    /** 有効な範囲を指定してインスタンスを作成 */
    MICSpanF(CGFloat min, CGFloat max):MICSpan<CGFloat>(min,max) {}
    /** コピーコンストラクタ */
    MICSpanF(const MICSpanF& src):MICSpan<CGFloat>(src.min(), src.max()) {}
};

/**
 * NSInteger の min/max 管理
 */
typedef MICSpan<NSInteger> MICSpanI;

//class MICSpanI : public MICSpan<NSInteger> {
//public:
//    /** 空の範囲のインスタンスを作成：update()して、spanを構築していくことを想定 */
//    MICSpanI() {_min=NSIntegerMax;_max=NSIntegerMin; }
//    /** 有効な範囲を指定してインスタンスを作成 */
//    MICSpanI(NSInteger min, NSInteger max):MICSpan<NSInteger>(min,max) {}
//    /** コピーコンストラクタ */
//    MICSpanI(const MICSpanI& src):MICSpan<NSInteger>(src.min(), src.max()) {}
//};

/**
 * NSUInteger の min/max 管理
 */
typedef MICSpan<NSUInteger> MICSpanU;

//class MICSpanU : public MICSpan<NSUInteger> {
//public:
//    /** 空の範囲のインスタンスを作成：update()して、spanを構築していくことを想定 */
//    MICSpanU() {_min=NSUIntegerMax; _max=0; }
//    /** 有効な範囲を指定してインスタンスを作成 */
//    MICSpanU(NSUInteger min, NSUInteger max):MICSpan<NSUInteger>(min,max) {}
//    /** コピーコンストラクタ */
//    MICSpanU(const MICSpanU& src):MICSpan<NSUInteger>(src.min(), src.max()) {}
//};

/**
 * int の min/max 管理
 */
typedef MICSpan<int> MICSpanInt;

//class MICSpanInt : public MICSpan<int> {
//public:
//    /** 空の範囲のインスタンスを作成：update()して、spanを構築していくことを想定 */
//    MICSpanInt() {_min=INT_MAX;_max=INT_MIN; }
//    /** 有効な範囲を指定してインスタンスを作成 */
//    MICSpanInt(int min, int max):MICSpan<int>(min,max) {}
//    /** コピーコンストラクタ */
//    MICSpanInt(const MICSpanInt& src):MICSpan<int>(src.min(), src.max()) {}
//};

/**
 * NSRangeのラッパ。
 */
class MICRange : public NSRange {
public:
    MICRange() {
        location = length = 0;
    }
    MICRange(NSUInteger loc, NSUInteger len) {
        location = loc;
        length = len;
    }
    MICRange(const NSRange& s) {
        location = s.location;
        length = s.length;
    }
    MICRange(const MICSpanU& s) {
        location = s.min();
        length = s.span()+1;
        
    }
    
    MICRange& set(NSUInteger loc, NSUInteger len) {
        location = loc;
        length = len;
        return *this;
    }

    MICRange& set(const MICSpanU& s) {
        location = s.min();
        length = s.span()+1;
        return *this;
    }
    
    MICRange& setStartEnd(NSUInteger s, NSUInteger e) {
        return set(MICSpanU(s,e));
    }
    
    bool equals(const NSRange& r) const {
        return NSEqualRanges(r,*this);
    }
    bool operator == (const NSRange& r) const {
        return equals(r);
    }
    
    bool contains(NSUInteger loc) const {
        return YES== NSLocationInRange(loc, *this);
    }

    MICRange& unionRange(const NSRange& r) {
        *this = NSUnionRange(*this, r);
        return *this;
    }
    static MICRange unionRange(const NSRange& r1, const NSRange& r2) {
        return NSUnionRange(r1,r2);
    }

    MICRange& intersectRange(const NSRange& r) {
        *this = NSIntersectionRange(*this, r);
        return *this;
    }
    static MICRange intersectRange(const NSRange& r1, const NSRange& r2) {
        return NSIntersectionRange(r1,r2);
    }
};


#endif
