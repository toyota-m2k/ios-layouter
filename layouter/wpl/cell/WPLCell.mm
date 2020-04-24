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

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ (%@)", self.name, NSStringFromClass(self.class)];
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

#pragma mark - Rendering

/**
 * レンダリング開始を伝える。
 * beginRenderingとendRenderingは必ずペアで呼ばれるが、calcCellWidth/calcCellHeight は
 * 必ずしも呼ばれない。従って、calcCell* の中で状態を保存し、endRenderingで利用するようなコードは不可。
 */
- (void)beginRendering:(WPLRenderingMode)mode {
    // nothing to do.
    // override in sub-classes if needs.
}

class BCAccessor {
public:
    enum Orientation { HORZ, VERT };
private:
    Orientation orientation;
public:
    BCAccessor(Orientation orientation_) {
        orientation = orientation_;
    }
    CGFloat requestedSize(id<IWPLCell> cell) const {
        if(orientation==HORZ) {
            return cell.requestViewSize.width;
        } else {
            return cell.requestViewSize.height;
        }
    }
    
    CGFloat viewSize(id<IWPLCell> cell) const {
        if(orientation==HORZ) {
            return cell.view.frame.size.width;
        } else {
            return cell.view.frame.size.height;
        }
    }
    
    NSString* orientationName() const {
        if(orientation==HORZ) {
            return @"X";
        } else {
            return @"Y";
        }
    }
};

- (CGFloat) calcCellSize:(CGFloat) regulatingSize    // マージンを含まない
                     acc:(const BCAccessor&) acc {
    let requestedSize = acc.requestedSize(self);
    if(requestedSize>0) {
        // Any > FIXED
        // Independent | BottomUp
        return requestedSize;
    } else if(regulatingSize>0 && requestedSize<0) {
        // STRC|FIXED > STRC
        // TopDown
        return regulatingSize;
    } else if(regulatingSize==0 && requestedSize<0) {
        // AUTO > STRC ... 問題のやつ
        WPLOG(@"WPL-CAUTION:%@ -<%@>- AUTO > STRC", self.description, acc.orientationName());
    } else {
        // Any > AUTO
    }
    return acc.viewSize(self);
}

/**
 * ビューサイズ（マージンを含まない）を計算
 */
//+ (CGFloat)calcViewSizeWithRegulatingSize:(CGFloat) regulatingSize    // マージンを含まない
//                            requestedSize:(CGFloat) requestedSize     // マージンを含まない
//                                 viewSize:(CGFloat) viewSize {
//    if(requestedSize>0) {
//        // Any > FIXED
//        // Independent | BottomUp
//        return requestedSize;
//    }
//    if(regulatingSize>0 && requestedSize<0) {
//        // STRC|FIXED > STRC
//        return regulatingSize;
//    }
//    // AUTO
//    return viewSize;

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
//}

/**
 * セル幅（マージンを含む）を計算
 * @param regulatingWidth   親からのサイズ指定（マージンを含む）
 */
- (CGFloat)calcCellWidth:(CGFloat)regulatingWidth {
    BCAccessor acc(BCAccessor::HORZ);
    CGFloat margin = MICEdgeInsets(self.margin).dw();
    CGFloat viewWidth = [self calcCellSize:MAX(0,regulatingWidth-margin)
                                       acc:acc];
    return WPLCMinMax(self.limitWidth).clip(viewWidth) + margin;
}

/**
 * セル高さ（マージンを含む）を計算
 * @param regulatingHeight   親からのサイズ指定（マージンを含む）
 */
- (CGFloat)calcCellHeight:(CGFloat)regulatingHeight {
    BCAccessor acc(BCAccessor::VERT);
    CGFloat margin = MICEdgeInsets(self.margin).dh();
    CGFloat viewHeight = [self calcCellSize:MAX(0,regulatingHeight-margin)
                                        acc:acc];
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
- (void) endRendering:(CGRect) finalCellRect {
    self.needsLayout = false;
    if(self.visibility==WPLVisibilityCOLLAPSED) {
        return;
    }
    // calcCellWidth/Heightを呼び出して、マージンを含むセルサイズを取得
    MICSize outerCellSize ([self calcCellWidth:0],
                           [self calcCellHeight:0]);

    // 上記のサイズのセルを alignment の指定に従って、finalCellRect 内に配置する。
    MICRect viewRect([self alignCellSize:outerCellSize-self.margin inRect:finalCellRect-self.margin]);
    WPLOG(@"endRendering:%@ -- viewRect=%@ / cellRect=%@", self.name, viewRect.toString(), MICRect(finalCellRect).toString() );
    if(viewRect!=self.view.frame) {
        CGFloat animDuration = self.animationDuration;
        if(animDuration>0) {
            [UIView animateWithDuration:animDuration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{self.view.frame=viewRect;} completion:nil];
        } else {
            self.view.frame = viewRect;
        }
    }
}

+ (void)log:(NSString *)fmt, ... {
    va_list args;
    va_start(args, fmt);
    [self log:fmt arguments:args];
    va_end(args);
}

+ (void)log:(NSString *)fmt arguments:(va_list)argList {
    NSLogv(fmt, argList);
}

@end

