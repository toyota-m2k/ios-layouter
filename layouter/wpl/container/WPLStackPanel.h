//
//  WPLStackPanel.h
//  WP Layouter
//
//  Created by Mitsuki Toyota on 2019/08/03.
//  Copyright © 2019 Mitsuki Toyota. All rights reserved.
//
#import "WPLContainerCell.h"

/**
 * StackPanel の伸長方向
 */
typedef enum _WPLOrientation {
    WPLOrientationHORIZONTAL,
    WPLOrientationVERTICAL,
} WPLOrientation;

#if defined(__cplusplus)

class WPLStackPanelParams : public WPLCellParams {
public:
    WPLOrientation _orientation;
    CGFloat _cellSpacing;
    
    WPLStackPanelParams(WPLOrientation orientation=WPLOrientationVERTICAL, MICEdgeInsets margin=MICEdgeInsets(), MICSize requestViewSize=MICSize(), WPLAlignment align=WPLAlignment(), CGFloat cellSpacing=0, WPLVisibility visibility=WPLVisibilityVISIBLE)
    : WPLCellParams(margin,requestViewSize,align,visibility)
    , _orientation(orientation)
    , _cellSpacing(cellSpacing) {}
    
    WPLStackPanelParams(const WPLStackPanelParams& src)
    : WPLCellParams(src)
    , _orientation(src._orientation) {}
    
    // builder style methods ----
    
    WPLStackPanelParams& margin(const UIEdgeInsets& v) {
        _margin = v;
        return *this;
    }
    WPLCellParams& margin(CGFloat left, CGFloat top, CGFloat right, CGFloat bottom) {
        _margin = MICEdgeInsets(left, top, right, bottom);
        return *this;
    }
    WPLStackPanelParams& requestViewSize(const CGSize& v) {
        _requestViewSize = v;
        return *this;
    }
    WPLStackPanelParams& requestViewSize(CGFloat width, CGFloat height) {
        _requestViewSize = MICSize(width, height);
        return *this;
    }
    WPLStackPanelParams& align(const WPLAlignment& v) {
        _align = v;
        return *this;
    }

    WPLStackPanelParams& horzAlign(const WPLCellAlignment v) {
        _align.horz = v;
        return *this;
    }
    
    WPLStackPanelParams& vertAlign(const WPLCellAlignment v) {
        _align.vert = v;
        return *this;
    }

    WPLStackPanelParams& visibility(const WPLVisibility v) {
        _visibility = v;
        return *this;
    }

    WPLStackPanelParams& orientation(const WPLOrientation v) {
        _orientation = v;
        return *this;
    }
    
    WPLStackPanelParams& cellSpacing(const NSInteger v) {
        _cellSpacing = v;
        return *this;
    }
};

#endif



/**
 * StackPanel セル-コンテナ クラス
 */
@interface WPLStackPanel : WPLContainerCell

// properties
@property (nonatomic) WPLOrientation orientation;
@property (nonatomic) CGFloat cellSpacing;

/**
 * StackPanel の正統なコンストラクタ
 */
- (instancetype) initWithView:(UIView*)view
                         name:(NSString*) name
                       margin:(UIEdgeInsets) margin
              requestViewSize:(CGSize) requestViewSize
                   hAlignment:(WPLCellAlignment)hAlignment
                   vAlignment:(WPLCellAlignment)vAlignment
                   visibility:(WPLVisibility)visibility
            containerDelegate:(id<IWPLContainerCellDelegate>)containerDelegate
                  orientation:(WPLOrientation) orientation
                  cellSpacing:(CGFloat)cellSpacing;

/**
 * インスタンス生成ヘルパー
 * StackPanel用のUIViewは、自動的に作成され、superviewにaddSubviewされる。
 */
+ (instancetype) stackPanelWithName:(NSString*) name
                             margin:(UIEdgeInsets) margin
                    requestViewSize:(CGSize) requestViewSize
                         hAlignment:(WPLCellAlignment)hAlignment
                         vAlignment:(WPLCellAlignment)vAlignment
                         visibility:(WPLVisibility)visibility
                  containerDelegate:(id<IWPLContainerCellDelegate>)containerDelegate
                        orientation:(WPLOrientation) orientation
                        cellSpacing:(CGFloat)cellSpacing
                          superview:(UIView*)superview;

#if defined(__cplusplus)
/**
 * C++版インスタンス生成ヘルパー
 * (Root Container 用）
 */
+ (instancetype) stackPanelWithName:(NSString*) name
                             params:(const WPLStackPanelParams&)params
                          superview:(UIView*)superview
                  containerDelegate:(id<IWPLContainerCellDelegate>)containerDelegate;

/**
 * C++版インスタンス生成ヘルパー
 * (Sub-Container 用）
 */
+ (instancetype) stackPanelWithName:(NSString*) name
                             params:(const WPLStackPanelParams&)params;

#endif

@end
