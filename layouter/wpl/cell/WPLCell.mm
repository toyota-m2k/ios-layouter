//
//  WPLCell.m
//  layouterSample
//
//  Created by toyota-m2k on 2019/08/02.
//  Copyright © 2019 toyota-m2k. All rights reserved.
//

#import "WPLCell.h"
#import "MICVar.h"
#import "MICUiRectUtil.h"
#import "MICUiDsCustomButton.h"
#import "WPLContainersL.h"

@implementation WPLCell {
    bool _needsLayout;
    
    MICEdgeInsets _margin;
    WPLVisibility _visibility;
    MICSize _requestViewSize;
    WPLCellAlignment _hAlignment;
    WPLCellAlignment _vAlignment;
    WPLCMinMax _limitWidth;
    WPLCMinMax _limitHeight;
}

@synthesize containerDelegate = _containerDelegate, name = _name, extension = _extension, view = _view;

/**
 * セル移動時のアニメーションのDuration
 *  0: アニメーションしない
 *  -1: 親から継承
 *  >0: Duration
 */
- (CGFloat) animationDuration {
    if(_animationDuration>=0) {
        return _animationDuration;
    }
    if(self.containerDelegate!=nil) {
        return self.containerDelegate.animationDuration;
    }
    return 0;
}

/**
 * 完全な初期化
 */
- (instancetype) initWithView:(UIView*)view
                         name:(NSString*) name
                       margin:(UIEdgeInsets) margin
              requestViewSize:(CGSize) requestViewSize
                    limitWidth:(WPLMinMax) limitWidth
                   limitHeight:(WPLMinMax) limitHeight
                   hAlignment:(WPLCellAlignment)hAlignment
                   vAlignment:(WPLCellAlignment)vAlignment
                   visibility:(WPLVisibility)visibility {
    self = [super init];
    if(nil!=self) {
        _view = view;
        _name = name;
        _margin = margin;
        _hAlignment = hAlignment;
        _vAlignment = vAlignment;
        _limitWidth = limitWidth;
        _limitHeight = limitHeight;
        _requestViewSize = requestViewSize;
        _containerDelegate = nil;
        _extension = nil;
        _visibility = visibility;
        view.hidden = (_visibility != WPLVisibilityVISIBLE);
        _animationDuration = -1;
        [self updateViewSizeOnRequested];
        _needsLayout = true;
    }
    return self;
}

//- (instancetype) initWithView:(UIView*) view
//                         name:(NSString*)name
//                       params:(WPLCellParams) params {
//    return [self initWithView:view name:name margin:params._margin requestViewSize:params._requestViewSize
//                   limitWidth:params._limitWidth limitHeight:params._limitHeight
//                   hAlignment:params._align.horz vAlignment:params._align.vert
//                   visibility:params._visibility];
//}

- (void)setParams:(const WPLCellParams &)params {
    self.margin = params._margin;
    self.hAlignment = params._align.horz;
    self.vAlignment = params._align.vert;
    self.requestViewSize = params._requestViewSize;
    self.visibility = params._visibility;
}

- (WPLCellParams) currentParams {
    return WPLCellParams()
            .margin(self.margin)
            .align(self.hAlignment,self.vAlignment)
            .requestViewSize(self.requestViewSize)
            .visibility(self.visibility);
}

/**
 * C＋＋版　インスタンス生成ヘルパー
 */
+ (instancetype)newCellWithView:(UIView *)view
                           name:(NSString *)name
                         params:(const WPLCellParams&)params {
    return [[self alloc] initWithView:view
                                 name:name
                               margin:params._margin
                      requestViewSize:params._requestViewSize
                           limitWidth:params._limitWidth limitHeight:params._limitHeight
                           hAlignment:params._align.horz
                           vAlignment:params._align.vert
                           visibility:params._visibility];
}

/**
 * セルを破棄
 */
- (void) dispose {
    _view = nil;
    _containerDelegate = nil;
}

/**
 * ビューサイズ（マージンは含まない）
 */
- (CGSize) actualViewSize {
    return _view.frame.size;
}

		/**
 * 要求されたセルサイズ（ゼロなら、viewのサイズに合わせて自動調節）
 */
- (CGSize) requestViewSize {
    return _requestViewSize;
}

- (void) updateViewSizeOnRequested {
    MICRect rc(self.view.frame);
    if(self.requestViewSize.width>0) {
        rc.size.width = self.requestViewSize.width;
    }
    if(self.requestViewSize.height>0) {
        rc.size.height = self.requestViewSize.height;
    }
    self.view.frame = rc;
}

/**
 * セルサイズを指定（ゼロなら、viewのサイズに合わせて自動調節）
 */
- (void) setRequestViewSize:(CGSize) size {
    if(MICSize(_requestViewSize)!=size) {
        _requestViewSize = size;
        [self updateViewSizeOnRequested];
        self.needsLayout = true;
    }
}

- (WPLMinMax)limitWidth {
    return _limitWidth;
}

- (void)setLimitWidth:(WPLMinMax)limitWidth {
    if(_limitWidth!=limitWidth) {
        _limitWidth = limitWidth;
        [self updateViewSizeOnRequested];
        self.needsLayout = true;
    }
}

- (WPLMinMax)limitHeight {
    return _limitHeight;
}

- (void)setLimitHeight:(WPLMinMax)limitHeight {
    if(_limitHeight!=limitHeight) {
        _limitHeight = limitHeight;
        [self updateViewSizeOnRequested];
        self.needsLayout = true;
    }
}

/**
 * レイアウト要求フラグ getter
 */
- (bool) needsLayout {
    return _needsLayout;
}

/**
 * レイアウト要求フラグ setter
 */
- (void) setNeedsLayout:(bool) v {
    if(_needsLayout!=v) {
        _needsLayout = v;
        if(_needsLayout) {
            // 再レイアウトが必要になれば、
            // containerDelegateを呼んで、親にlayoutしてもらう。
            // ルートコンテナを保持するViewは、IContainerCellDelegateを実装し、その onChildCellModified()が呼ばれたら、
            // ルートコンテナのlayout()を実行してコンテナのサイズを確定するとともに、戻り値のsizeを使って、ルートコンテナ自身の配置を調整する。
            [_containerDelegate onChildCellModified:self];
        }
    }
}

/**
 * マージン getter
 */
- (UIEdgeInsets) margin {
    return _margin;
}
/**
 * マージン setter
 */
- (void) setMargin:(UIEdgeInsets)v {
    if(MICEdgeInsets(_margin)!=v) {
        _margin = v;
        self.needsLayout = true;
    }
}

/**
 * 横方向セルアラインメント getter
 */
- (WPLCellAlignment) hAlignment {
    return _hAlignment;
}

/**
 * 横方向セルアラインメント setter
 */
- (void) setHAlignment:(WPLCellAlignment)v {
    if(_hAlignment!=v) {
        _hAlignment = v;
        self.needsLayout = true;
    }
}

/**
 * 縦方向セルアラインメント getter
 */
- (WPLCellAlignment) vAlignment {
    return _vAlignment;
}

/**
 * 縦方向セルアラインメント setter
 */
- (void) setVAlignment:(WPLCellAlignment)v {
    if(_vAlignment!=v) {
        _vAlignment = v;
        self.needsLayout = true;
    }
}

/**
 * 表示・非表示 getter
 */
- (WPLVisibility) visibility {
    return _visibility;
}

/**
 * 表示・非表示 setter
 */
- (void) setVisibility:(WPLVisibility)v {
    if(_visibility!=v) {
        let org = _visibility;
        _visibility = v;
        _view.hidden = (v != WPLVisibilityVISIBLE);
        if(v==WPLVisibilityCOLLAPSED||org==WPLVisibilityCOLLAPSED) {
            self.needsLayout = true;
        }
    }
}

/**
 * 有効・無効 getter
 */
- (bool) enabled {
    if([_view isKindOfClass:UIControl.class]) {
        return ((UIControl*)_view).enabled;
    } else if([_view isKindOfClass:MICUiDsCustomButton.class]) {
        return ((MICUiDsCustomButton*)_view).enabled;
    }
    return false;
}

/**
 * 有効・無効 setter
 */
- (void) setEnabled:(bool)v {
    if([_view isKindOfClass:UIControl.class]) {
        ((UIControl*)_view).enabled = v;
    } else if([_view isKindOfClass:MICUiDsCustomButton.class]) {
        ((MICUiDsCustomButton*)_view).enabled = v;
    }
}

- (CGSize) requestCellSize {
    return [self sizeWithMargin:_requestViewSize];
}

- (CGSize) sizeWithMargin:(CGSize)size {
    MICSize s(size);
    if(s.width>0) {
        s.width += _margin.dw();
    }
    if(s.height>0) {
        s.height += _margin.dh();
    }
    return s;
}

- (CGSize) sizeWithoutMargin:(CGSize)size {
    MICSize s(size);
    if(s.width>0) {
        s.width -= _margin.dw();
        if(s.width<0) {
            s.width = 0;
        }
    }
    if(s.height>0) {
        s.height -= _margin.dh();
        if(s.height<0) {
            s.height = 0;
        }
    }
    return s;
}

- (CGRect) rectWithMargin:(CGRect)rect {
    return MICRect(rect) + self.margin;
}
- (CGRect) rectWithoutMargin:(CGRect)rect {
    return MICRect(rect) - self.margin;
}

- (CGSize) limitSize:(CGSize) size {
    return MICSize(_limitWidth.clip(size.width), _limitHeight.clip(size.height));
}


/**
 * レイアウト準備（仮配置）
 * セル内部の配置を計算し、セルサイズを返す。
 * このあと、親コンテナセルでレイアウトが確定すると、layoutCompleted: が呼び出されるので、そのときに、内部の配置を行う。
 * @param regulatingCellSize    stretch指定のセルサイズを決めるためのヒント(セルマージンを含む)
 *    セルサイズ決定の優先順位
 *      requestedViweSize       regulatingCellSize          内部コンテンツ(view/cell)サイズ
 *      ○ 正値(fixed)                無視                        requestedViewSizeにリサイズ
 *         ゼロ(auto)                 無視                     ○ 元のサイズのままリサイズしない
 *         負値(stretch)              ゼロ (auto)              ○ 元のサイズのままリサイズしない (regulatingCellSize の stretch 指定は無視する)
 *         負値(stretch)           ○ 正値 (fixed)                regulatingCellSize にリサイズ
 *         負値(stretch)              負値 (stretch)              ここではゼロを返し、layoutCompletedでの親コンテナによる指示に従う
 * @return  セルサイズ（マージンを含む
 */
- (CGSize) layoutPrepare:(CGSize) regulatingCellSize {
    // width
    MICSize size(self.requestViewSize);
    MICSize regSize([self sizeWithoutMargin:regulatingCellSize]);
    if(size.width<=0) {
        if(regSize.width>0) {
            size.width = regSize.width;
        } else if(regSize.width<0 && size.width<0){
            size.width = 0;
        } else {
            size.width = self.view.frame.size.width;
        }
    }
    // height
    if(size.height<=0) {
        if(regSize.height>0) {
            size.height = regSize.height;
        } else if(regSize.height<0 && size.height<0){
            size.height = 0;
        } else {
            size.height = self.view.frame.size.height;
        }
    }
    return [self sizeWithMargin:[self limitSize:size]];
}

/**
 * レイアウトを確定する。
 * layoutPrepareが呼ばれた後に呼び出される。
 * @param finalCellRect     確定したセル領域（マージンを含む）
 *
 *  リサイズ＆配置ルール
 *      requestedViweSize       finalCellRect                 内部コンテンツ(view/cell)サイズ
 *      ○ 正値(fixed)                無視                       requestedViewSizeにリサイズし、alignmentに従ってfinalCellRect内に配置
 *         ゼロ(auto)                 無視                    ○ 元のサイズのままリサイズしないで、alignmentに従ってfinalCellRect内に配置
 *         負値(stretch)              ゼロ (auto)             ○ 元のサイズのままリサイズしない、alignmentに従ってfinalCellRect内に配置
 *                                                                (regulatingCellSize の stretch 指定は無視する)
 *         負値(stretch)           ○ 正値 (fixed)               finalCellSizeにリサイズalignmentは無視
 *         （regulatingCellSize!=finalCellRect.sizeの場合は再計算）。
 */
- (void) layoutCompleted:(CGRect) finalCellRect {
    self.needsLayout = false;
    if(self.visibility==WPLVisibilityCOLLAPSED) {
        return;
    }
    MICRect finRect([self rectWithoutMargin:finalCellRect]);
    MICRect viewRect(finRect);
    if(self.requestViewSize.width>=0) { // !stretch
        if(self.requestViewSize.width>0) {
            viewRect.size.width = self.requestViewSize.width;
        } else {
            viewRect.size.width = self.view.frame.size.width;
        }
        if(viewRect.width()<finRect.width()) {
            if(self.hAlignment==WPLCellAlignmentCENTER) {
                viewRect.moveToHCenterOfOuterRect(finRect);
            } else if(self.hAlignment == WPLCellAlignmentEND){
                viewRect.move(finRect.RB().x-viewRect.RB().x, 0);
            }
        }
    }
    if(self.requestViewSize.height>=0) { // !stretch
        if(self.requestViewSize.height>0) {
            viewRect.size.height = self.requestViewSize.height;
        } else {
            viewRect.size.height = self.view.frame.size.height;
        }
        if(viewRect.height()<finRect.height()) {
            if(self.vAlignment==WPLCellAlignmentCENTER) {
                viewRect.moveToVCenterOfOuterRect(finRect);
            } else if(self.vAlignment == WPLCellAlignmentEND){
                viewRect.move(0, finRect.RB().y-viewRect.RB().y);
            }
        }
    }
    MICRect orgFrame(self.view.frame);
    if(viewRect!=orgFrame) {
        CGFloat animDuration = self.animationDuration;
        if(animDuration>0) {
            [UIView animateWithDuration:animDuration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{self.view.frame=viewRect;} completion:nil];
        } else {
            self.view.frame = viewRect;
        }
    }
}


@end

@implementation WPLCell (WHRendering)

/**
 * レンダリング開始を伝える。
 * beginRenderingとendRenderingInRectは必ずペアで呼ばれるが、calcCellWidth/calcCellHeight は
 * 必ずしも呼ばれない。従って、calcCell* の中で状態を保存し、endRenderingで利用するようなコードは不可。
 */
- (void)beginRendering:(WPLRenderingMode)mode {
    // nothing to do.
    // override in sub-classes if needs.
}

/**
 * ビューサイズ（マージンを含まない）を計算
 */
+ (CGFloat)calcViewSizeWithRegulatingSize:(CGFloat) regulatingSize    // マージンを含まない
                            requestedSize:(CGFloat) requestedSize     // マージンを含まない
                                 viewSize:(CGFloat) viewSize {
    if(requestedSize>0) {
        // Any > FIXED
        // Independent | BottomUp
        return requestedSize;
    }
    if(requestedSize<0 && regulatingSize>0) {
        // STRC|FIXED > STRC
        return regulatingSize;
    }
    // AUTO
    return viewSize;

// 上の分岐を詳しく書くと↓
//
//    CGFloat result = 0;
//    if(regulatingSize>0) {
//        // 親が　STRC|FIXED
//        if(requestedSize<0) {
//            // 子がSTRC ... TopDown
//            result = regulatingSize;
//        } else if(requestedSize==0) {
//            // 子がAUTO ... Independent （Viewサイズをそのまま使用）
//            result = viewSize;
//        } else /*requestSize>0*/ {
//            // 子がFIXED ... Independent
//            result = requestedSize;
//        }
//    } else {
//        // 親がAUTO
//        if(requestedSize<0) {
//            // 子がSTRC ... Complex --> AUTOとして扱う
//            result = viewSize;
//        } else if(requestedSize==0) {
//            // 子がAUTO ... BottomUp （Viewサイズをそのまま使用）
//            result = viewSize;
//        } else /*requestSize>0*/ {
//            // 子がFIXED ... BottomUp;
//            result = requestedSize;
//        }
//    }
//    return result;
}

/**
 * セル幅（マージンを含む）を計算
 * @param regulatingWidth   親からのサイズ指定（マージンを含む）
 */
- (CGFloat)calcCellWidth:(CGFloat)regulatingWidth {
    CGFloat margin = MICEdgeInsets(self.margin).dw();
    CGFloat viewWidth = [self.class calcViewSizeWithRegulatingSize:MAX(0,regulatingWidth-margin)
                                                     requestedSize:self.requestViewSize.width
                                                          viewSize:self.view.frame.size.width];
    return WPLCMinMax(self.limitWidth).clip(viewWidth) + margin;
}

/**
 * セル高さ（マージンを含む）を計算
 * @param regulatingHeight   親からのサイズ指定（マージンを含む）
 */
- (CGFloat)calcCellHeight:(CGFloat)regulatingHeight {
    CGFloat margin = MICEdgeInsets(self.margin).dh();
    CGFloat viewHeight = [self.class calcViewSizeWithRegulatingSize:MAX(0,regulatingHeight-margin)
                                                      requestedSize:self.requestViewSize.height
                                                           viewSize:self.view.frame.size.height];
    return WPLCMinMax(self.limitHeight).clip(viewHeight) + margin;
}

- (CGFloat)recalcCellWidth:(CGFloat)regulatingWidth {
    return [self calcCellWidth:regulatingWidth];
}
- (CGFloat)recalcCellHeight:(CGFloat)regulatingHeight {
    return [self calcCellHeight:regulatingHeight];
}

/**
 * セルをalignmentに従って、parentRect内に配置したときのセル領域を計算
 * @param cellSize      マージンをを含まないセルのサイズ
 * @param parentRect    セルを配置可能なマージンを含まない領域
 * @return マージンを含まないセル領域
 */
- (CGRect) alignCellSize:(const MICSize&)cellSize inRect:(const MICRect&) parentRect {
    MICRect cellRect(cellSize);
    // STRC指定の反映
    // STRCは、alignmentではなく、requestedSizeに持たせたので、alignmentの適用前に反映しておく。
    let req = self.requestViewSize;
    if(req.width<0) {
        cellRect.setWidth(WPLCMinMax::clip(self.limitWidth, parentRect.width()));
    }
    if(req.height<0) {
        cellRect.setHeight(WPLCMinMax::clip(self.limitHeight, parentRect.height()));
    }
    switch(self.hAlignment) {
        default:
        case WPLCellAlignmentSTART:
            cellRect.moveLeft(parentRect.left());
            break;
        case WPLCellAlignmentCENTER:
            cellRect.moveToHCenterOfOuterRect(parentRect);
            break;
        case WPLCellAlignmentEND:
            cellRect.moveRight(parentRect.right());
            break;
    }
    switch(self.vAlignment) {
        default:
        case WPLCellAlignmentSTART:
            cellRect.moveTop(parentRect.top());
            break;
        case WPLCellAlignmentCENTER:
            cellRect.moveToVCenterOfOuterRect(parentRect);
            break;
        case WPLCellAlignmentEND:
            cellRect.moveBottom(parentRect.bottom());
            break;
    }
    return cellRect;
}

/**
 * セルの位置、サイズを確定し、ビューを再配置する。
 * @param   finalCellRect  セルを配置可能な矩形領域（親ビュー座標系）
 */
- (void) endRenderingInRect:(CGRect) finalCellRect {
    self.needsLayout = false;
    if(self.visibility==WPLVisibilityCOLLAPSED) {
        return;
    }
    // calcCellWidth/Heightを呼び出して、マージンを含むセルサイズを取得
    MICSize outerCellSize ([self calcCellWidth:0],
                           [self calcCellHeight:0]);

    // 上記のサイズのセルを alignment の指定に従って、finalCellRect 内に配置する。
    MICRect viewRect([self alignCellSize:outerCellSize-self.margin inRect:finalCellRect-self.margin]);
    if(viewRect!=self.view.frame) {
        CGFloat animDuration = self.animationDuration;
        if(animDuration>0) {
            [UIView animateWithDuration:animDuration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{self.view.frame=viewRect;} completion:nil];
        } else {
            self.view.frame = viewRect;
        }
    }
}

@end
