//
//  WPLCell.h
//  layouterSample
//
//  Created by toyota-m2k on 2019/08/02.
//  Copyright © 2019 toyota-m2k. All rights reserved.
//

#import "WPLCellDef.h"
#import "MICUiRectUtil.h"

#if defined(__cplusplus)

class WPLAlignment {
public:
    WPLCellAlignment horz;
    WPLCellAlignment vert;
    
    WPLAlignment() {
        horz = WPLCellAlignmentSTART;
        vert = WPLCellAlignmentSTART;
    }
    
    WPLAlignment(WPLCellAlignment horizontal, WPLCellAlignment vertical) {
        horz = horizontal;
        vert = vertical;
    }
    
    WPLAlignment(WPLCellAlignment align) {
        horz = vert = align;
    }
    
    WPLAlignment(const WPLAlignment& src) {
        horz = src.horz;
        vert = src.vert;
    }
};

class WPLCellParams {
public:
    MICEdgeInsets _margin;
    MICSize _requestViewSize;
    WPLAlignment _align;
    WPLVisibility _visibility;
    WPLCMinMax _limitWidth;
    WPLCMinMax _limitHeight;
    
    /**
     * Constructor with full-parameters
     */
    WPLCellParams()
    : _visibility(WPLVisibilityVISIBLE)
    {}
    
    /**
     * Copy constructor
     */
    WPLCellParams(const WPLCellParams& src)
    : _margin(src._margin)
    , _requestViewSize(src._requestViewSize)
    , _align(src._align)
    , _visibility(src._visibility)
    , _limitWidth(src._limitWidth)
    , _limitHeight(src._limitHeight)
    {}
    
    // builder style methods ----
    
    WPLCellParams& margin(const UIEdgeInsets& v) {
        _margin = v;
        return *this;
    }
    WPLCellParams& margin(CGFloat left, CGFloat top, CGFloat right, CGFloat bottom) {
        _margin = MICEdgeInsets(left, top, right, bottom);
        return *this;
    }
    WPLCellParams& requestViewSize(const CGSize& v) {
        _requestViewSize = v;
        return *this;
    }
    WPLCellParams& requestViewSize(CGFloat width, CGFloat height) {
        _requestViewSize = MICSize(width, height);
        return *this;
    }

    WPLCellParams& align(const WPLAlignment& v) {
        _align = v;
        return *this;
    }
    WPLCellParams& align(const WPLCellAlignment align) {
        _align = WPLAlignment(align);
        return *this;
    }
    WPLCellParams& align(const WPLCellAlignment horz, const WPLCellAlignment vert) {
        _align = WPLAlignment(horz, vert);
        return *this;
    }

    WPLCellParams& horzAlign(const WPLCellAlignment v) {
        _align.horz = v;
        return *this;
    }
    
    WPLCellParams& vertAlign(const WPLCellAlignment v) {
        _align.vert = v;
        return *this;
    }

    
    WPLCellParams& visibility(const WPLVisibility v) {
        _visibility = v;
        return *this;
    }
    
    // Min/Max Width/Height
    WPLCellParams& limitWidth(const WPLMinMax& v) {
        _limitWidth = v;
        return *this;
    }
    WPLCellParams& limitWidth(CGFloat min, CGFloat max) {
        _limitWidth.min = min;
        _limitWidth.max = max;
        return *this;
    }
    WPLCellParams& maxWidth(CGFloat v) {
        _limitWidth.max = v;
        return *this;
    }
    WPLCellParams& minWidth(CGFloat v) {
        _limitWidth.min = v;
        return *this;
    }
    WPLCellParams& limitHeight(const WPLMinMax& v) {
        _limitHeight = v;
        return *this;
    }
    WPLCellParams& limitHeight(CGFloat min, CGFloat max) {
        _limitHeight.min = min;
        _limitHeight.max = max;
        return *this;
    }
    WPLCellParams& maxHeight(CGFloat v) {
        _limitHeight.max = v;
        return *this;
    }
    WPLCellParams& minHeight(CGFloat v) {
        _limitHeight.min = v;
        return *this;
    }
};

#endif

/**
 * ICell i/f を実装した、セルの基底クラス
 * ReadOnly や Value を持たないビュー(UIView,UIButtonなど)は、このセルを利用可。
 */

@interface WPLCell : NSObject<IWPLCell>

/**
 * セル移動時のアニメーションのDuration
 *  0: アニメーションしない
 *  -1: 親から継承
 *  >0: Duration
 */
@property (nonatomic) CGFloat animationDuration;


- (instancetype) initWithView:(UIView*)view
                         name:(NSString*) name
                       margin:(UIEdgeInsets) margin
              requestViewSize:(CGSize) requestViewSize
                   limitWidth:(WPLMinMax) limitWidth
                  limitHeight:(WPLMinMax) limitHeight
                   hAlignment:(WPLCellAlignment)hAlignment
                   vAlignment:(WPLCellAlignment)vAlignment
                   visibility:(WPLVisibility)visibility;

#if defined(__cplusplus)

+ (instancetype) newCellWithView:(UIView*) view
                            name:(NSString*) name
                          params:(const WPLCellParams&) params;

// サブクラスで定義するWPLCellParams派生クラスを引数にとるコンストラクタと衝突するので、これは定義しない。
//- (instancetype) initWithView:(UIView*) view
//                         name:(NSString*)name
//                       params:(WPLCellParams) params;


- (void) setParams:(const WPLCellParams&) params;
- (WPLCellParams) currentParams;

#endif

//@property (nonatomic,readonly) CGSize requestCellSize;
//
//- (CGSize) sizeWithMargin:(CGSize)size;
//- (CGSize) sizeWithoutMargin:(CGSize)size;
//- (CGRect) rectWithMargin:(CGRect)rect;
//- (CGRect) rectWithoutMargin:(CGRect)rect;
//
//- (CGSize) limitSize:(CGSize) size;

@end

