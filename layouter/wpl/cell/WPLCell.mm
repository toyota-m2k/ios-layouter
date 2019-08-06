//
//  WPLCell.m
//  layouterSample
//
//  Created by Mitsuki Toyota on 2019/08/02.
//  Copyright © 2019 Mitsuki Toyota. All rights reserved.
//

#import "WPLCell.h"
#import "MICVar.h"
#import "MICUiRectUtil.h"

@implementation WPLCell {
    bool _needsLayout;
    
    UIEdgeInsets _margin;
    WPLVisibility _visibility;
    CGSize _requestViewSize;
    WPLCellAlignment _hAlignment;
    WPLCellAlignment _vAlignment;
}

@synthesize containerDelegate = _containerDelegate, name = _name, extension = _extension, view = _view;

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

/**
 * セルサイズを計算
 * 以下の優先順序でサイズを決定
 * １）requestViewSizeで指定されたサイズ
 * ２）親コンテナから指定されたサイズ(regulatingSize)
 * ３）ビューのサイズ
 *
 * @param regulatingWidth   親コンテナから指定された幅(0:Auto-->セルのコンテンツに合わせる)
 * @param regulatingHeight  親コンテナから指定された高さ(0:Auto-->セルのコンテンツに合わせる)
 * @return マージンを含むセルサイズ
 */
/** セルの最小サイズを計算 */
- (CGSize) calcMinSizeForRegulatingWidth:(CGFloat) regulatingWidth andRegulatingHeight:(CGFloat) regulatingHeight {
    // width
    MICSize size(self.requestViewSize);
    if(size.width<=0) {
        if(regulatingWidth>0) {
            size.width = regulatingWidth;
        } else {
            size.width = self.view.frame.size.width;
        }
    }
    if(size.height<=0) {
        if(regulatingHeight>0) {
            size.height = regulatingHeight;
        } else {
            size.height = self.view.frame.size.height;
        }
    }
    return size + _margin;
}

/**
 * セルの位置・サイズを確定してビューに反映する
 *
 * １）Alignment==STRETCHなら、与えられたサイズ(-margin)をViewにセット
 * ２）STRETCH以外なら、
 *    a) requestViewSize でサイズが指定されていれば、Viewのサイズを変更
 *    b) それ以外は、元のサイズのままにする
 * ３）マージンを考慮して、Viewの位置をセット
 *
 * @param point 位置
 * @param size サイズ
 */
- (void) layoutResolvedAt:(CGPoint)point inSize:(CGSize)size {
    self.needsLayout = false;
    if(self.visibility==WPLVisibilityCOLLAPSED) {
        return;
    }
    var rect = MICRect(MICRect(point, size) - _margin);
    var viewRect = MICRect(rect);
    if(self.hAlignment!=WPLCellAlignmentSTRETCH) {
        if(self.requestViewSize.width>0) {
            viewRect.size.width = self.requestViewSize.width;
        } else {
            viewRect.size.width = self.view.frame.size.width;
        }
        if(self.hAlignment==WPLCellAlignmentCENTER) {
            viewRect.moveToHCenterOfOuterRect(rect);
        } else if(self.hAlignment == WPLCellAlignmentEND){
            viewRect.move(rect.RB().x-viewRect.RB().x, 0);
        }
    }
    
    if(self.vAlignment!=WPLCellAlignmentSTRETCH) {
        if(self.requestViewSize.height>0) {
            viewRect.size.height = self.requestViewSize.height;
        } else {
            viewRect.size.height = self.view.frame.size.height;
        }
        if(self.vAlignment==WPLCellAlignmentCENTER) {
            viewRect.moveToVCenterOfOuterRect(rect);
        } else if(self.vAlignment == WPLCellAlignmentEND){
            viewRect.move(0, rect.RB().y-viewRect.RB().y);
        }
    }
    
    self.view.frame = viewRect;
}


@end

