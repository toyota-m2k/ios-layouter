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

@implementation WPLCell {
    bool _needsLayout;
    
    MICEdgeInsets _margin;
    WPLVisibility _visibility;
    MICSize _requestViewSize;
    WPLCellAlignment _hAlignment;
    WPLCellAlignment _vAlignment;
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
                   hAlignment:(WPLCellAlignment)hAlignment
                   vAlignment:(WPLCellAlignment)vAlignment
                   visibility:(WPLVisibility)visibility
            containerDelegate:(id<IWPLContainerCellDelegate>)containerDelegate {
    self = [super init];
    if(nil!=self) {
        _view = view;
        _name = name;
        _margin = margin;
        _hAlignment = hAlignment;
        _vAlignment = vAlignment;
        _requestViewSize = requestViewSize;
        _containerDelegate = containerDelegate;
        _extension = nil;
        _visibility = visibility;
        view.hidden = (_visibility != WPLVisibilityVISIBLE);
        _animationDuration = -1;
        [self updateViewSizeOnRequested];
        _needsLayout = true;
    }
    return self;
}

/**
 * インスタンス生成ヘルパー
 * 通常、containerDelegate は、ContainerCellへの addCell で設定されるため、ここでは nil にしておく。
 */
+ (instancetype) newCellWithView:(UIView*)view
                            name:(NSString*) name
                          margin:(UIEdgeInsets) margin
                 requestViewSize:(CGSize) requestViewSize
                      hAlignment:(WPLCellAlignment)hAlignment
                      vAlignment:(WPLCellAlignment)vAlignment
                      visibility:(WPLVisibility)visibility {
    
    return [[self alloc] initWithView:view name:name margin:margin requestViewSize:requestViewSize hAlignment:hAlignment vAlignment:vAlignment visibility:visibility containerDelegate:nil];
}

/**
 * C＋＋版　インスタンス生成ヘルパー
 */
+ (instancetype)newCellWithView:(UIView *)view
                           name:(NSString *)name
                         params:(const WPLCellParams&)params {
    return [[self alloc] initWithView:view name:name margin:params._margin requestViewSize:params._requestViewSize hAlignment:params._align.horz vAlignment:params._align.vert visibility:params._visibility containerDelegate:nil];
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
    return _view.userInteractionEnabled;
}

/**
 * 有効・無効 setter
 */
- (void) setEnabled:(bool)v {
    _view.userInteractionEnabled = v;
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
    }
    if(s.height>0) {
        s.height -= _margin.dh();
    }
    return s;
}

- (CGRect) rectWithMargin:(CGRect)rect {
    return MICRect(rect) + self.margin;
}
- (CGRect) rectWithoutMargin:(CGRect)rect {
    return MICRect(rect) - self.margin;
}


/**
 * レイアウト準備（仮配置）
 * セル内部の配置を計算し、セルサイズを返す。
 * このあと、親コンテナセルでレイアウトが確定すると、layoutCompleted: が呼び出されるので、そのときに、内部の配置を行う。
 * @param regulatingCellSize    stretch指定のセルサイズを決めるためのヒント(セルマージンを含む)
 *    セルサイズ決定の優先順位
 *      requestedViweSize       regulatingCellSize          内部コンテンツ(view/cell)サイズ
 *      ○ 正値(fixed)                無視                       requestedViewSizeにリサイズ
 *        ゼロ(auto)                 無視                     ○ 元のサイズのままリサイズしない
 *        負値(stretch)              ゼロ (auto)              ○ 元のサイズのままリサイズしない (regulatingCellSize の stretch 指定は無視する)
 *        負値(stretch)            ○ 正値 (fixed)               regulatingCellSize にリサイズ
 *        負値(stretch)              負値 (stretch)             ここではゼロを返し、layoutCompletedでの親コンテナによる指示に従う
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
    return [self sizeWithMargin:size];
}

/**
 * レイアウトを確定する。
 * layoutPrepareが呼ばれた後に呼び出される。
 * @param finalCellRect     確定したセル領域（マージンを含む）
 *
 *  リサイズ＆配置ルール
 *      requestedViweSize       finalCellRect                 内部コンテンツ(view/cell)サイズ
 *      ○ 正値(fixed)                無視                       requestedViewSizeにリサイズし、alignmentに従ってfinalCellRect内に配置
 *        ゼロ(auto)                 無視                     ○ 元のサイズのままリサイズしないで、alignmentに従ってfinalCellRect内に配置
 *        負値(stretch)              ゼロ (auto)              ○ 元のサイズのままリサイズしない、alignmentに従ってfinalCellRect内に配置 (regulatingCellSize の stretch 指定は無視する)
 *        負値(stretch)            ○ 正値 (fixed)               finalCellSize にリサイズ（regulatingCellSize!=finalCellRect.sizeの場合は再計算）。alignmentは無視
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

