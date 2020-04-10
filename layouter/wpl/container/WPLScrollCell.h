//
//  WPLScrollCell.h
//  layouterSample
//
//  Created by @toyota-m2k on 2020/04/02.
//  Copyright © 2020 @toyota-m2k. All rights reserved.
//

#import "WPLContainerCell.h"

#if defined(__cplusplus)

class WPLScrollCellParams : public WPLCellParams {
public:
    WPLScrollOrientation _scrollOrientation;
    
    WPLScrollCellParams(WPLScrollOrientation scrollOrientation=WPLScrollOrientationVERT)
    : _scrollOrientation(scrollOrientation) {}
    
    WPLScrollCellParams(const WPLScrollCellParams& src)
    : WPLCellParams(src)
    , _scrollOrientation(src._scrollOrientation) {}
    
    // builder style methods ----
    
    WPLScrollCellParams& margin(const UIEdgeInsets& v) {
        _margin = v;
        return *this;
    }
    WPLScrollCellParams& margin(CGFloat left, CGFloat top, CGFloat right, CGFloat bottom) {
        _margin = MICEdgeInsets(left, top, right, bottom);
        return *this;
    }
    WPLScrollCellParams& requestViewSize(const CGSize& v) {
        _requestViewSize = v;
        return *this;
    }
    WPLScrollCellParams& requestViewSize(CGFloat width, CGFloat height) {
        _requestViewSize = MICSize(width, height);
        return *this;
    }
    WPLScrollCellParams& align(const WPLAlignment& v) {
        _align = v;
        return *this;
    }
    WPLScrollCellParams& align(const WPLCellAlignment align) {
        _align = WPLAlignment(align);
        return *this;
    }
    WPLScrollCellParams& align(const WPLCellAlignment horz, const WPLCellAlignment vert) {
        _align = WPLAlignment(horz, vert);
        return *this;
    }

    WPLScrollCellParams& horzAlign(const WPLCellAlignment v) {
        _align.horz = v;
        return *this;
    }
    
    WPLScrollCellParams& vertAlign(const WPLCellAlignment v) {
        _align.vert = v;
        return *this;
    }

    WPLScrollCellParams& visibility(const WPLVisibility v) {
        _visibility = v;
        return *this;
    }

    WPLScrollCellParams& scrollOrientation(const WPLScrollOrientation v) {
        _scrollOrientation = v;
        return *this;
    }
    
    // Min/Max Width/Height
    WPLScrollCellParams& limitWidth(const WPLMinMax& v) {
        _limitWidth = v;
        return *this;
    }
    WPLScrollCellParams& limitWidth(CGFloat min, CGFloat max) {
        _limitWidth.min = min;
        _limitWidth.max = max;
        return *this;
    }
    WPLScrollCellParams& maxWidth(const CGFloat& v) {
        _limitWidth.max = v;
        return *this;
    }
    WPLScrollCellParams& minWidth(const CGFloat& v) {
        _limitWidth.min = v;
        return *this;
    }
    WPLScrollCellParams& limitHeight(const WPLMinMax& v) {
        _limitHeight = v;
        return *this;
    }
    WPLScrollCellParams& limitHeight(CGFloat min, CGFloat max) {
        _limitHeight.min = min;
        _limitHeight.max = max;
        return *this;
    }
    WPLScrollCellParams& maxHeight(const CGFloat& v) {
        _limitHeight.max = v;
        return *this;
    }
    WPLScrollCellParams& minHeight(const CGFloat& v) {
        _limitHeight.min = v;
        return *this;
    }

};

#endif


@interface WPLScrollCell : WPLContainerCell

@property (nonatomic,readonly) WPLScrollOrientation scrollOrientation;


#if defined(__cplusplus)

- (instancetype) initWithView:(UIView *)view
                         name:(NSString *)name
                       params:(const WPLScrollCellParams&)params;

/**
 * C++版インスタンス生成ヘルパー
 * (Sub-Container 用）
 */
+ (instancetype) scrollCellWithName:(NSString*) name
                             params:(const WPLScrollCellParams&)params;

+ (instancetype) scrollCellWithName:(UIView*)view
                               name:(NSString*) name
                             params:(const WPLScrollCellParams&)params;

#endif

@end


@interface WPLScrollCell (WHRendering) <IWPLCellWH>

@end
