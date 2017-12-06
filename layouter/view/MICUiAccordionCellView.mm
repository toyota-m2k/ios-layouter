//
//  MICUiAccordionCellView.m
//
//  ラベルタップで折りたたみ可能なビュー
//
//  レンダリングルール：
//  このビューのサイズ（bounds)を基準として、ラベル領域を切り出し、残った領域をボディ領域とする。
//
//  Created by 豊田 光樹 on 2014/10/29.
//  Copyright (c) 2014年 豊田 光樹. All rights reserved.
//

#import "MICUiAccordionCellView.h"
#import "MICUiRectUtil.h"
#import "MICUiLayoutView.h"

/**
 * アコーディオンセル
 */
@implementation MICUiAccordionCellView {
    bool _rotated;                      ///< ラベル回転中フラグ
    MICSize _viewSize;                  ///< レイアウト計算のベースとしたビューサイズ
    MICRect _labelBounds;               ///< マージン（_labelMargin）を含むラベル領域
    MICRect _bodyBounds;                ///< マージン（_bodyMargin）を含むラベル領域
    MICEdgeInsets _labelMargin;         ///< ラベル周りのマージン
    MICEdgeInsets _bodyMargin;          ///< ボディ周りのマージン
    MICSize _labelOrgSize;              ///< 回転前のラベルビューサイズ
    MICSize _viewOrgSize;                  ///< 折りたたみ前の高さ（Label,Body,マージンを含む）
    bool _foldedBeforeDrag;

    bool _autoResizingEnabled;          ///< スクロールビューの自動リサイズモード有効フラグ
    CGFloat _minBodySize;               ///< 自動リサイズ時の最小ボディサイズ
    CGFloat _maxBodySize;               ///< 自動リサイズ時の最大ボディサイズ
    
    bool _frameObserverEnabled;         ///< サイズ変更イベントリスナー登録済みフラグ
    bool _foldingStateChanging;
}

#pragma mark - 初期化

/**
 * ビューの初期化
 */
- (MICUiAccordionCellView*)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
   	 if(nil!=self) {
         _needsCalcLayout = false;
         _labelPos = MICUiPosTOP|MICUiPosLEFT;
         _rotateRight = false;
         _folding = false;
         _bodyBounds = CGRectZero;
         _labelBounds = CGRectZero;
         _rotated = false;
         _movableLabel = false;
         _accordionDelegate = nil;
         _labelAlignment = MICUiAlignExFILL;
         _labelMargin = UIEdgeInsetsZero;
         _bodyMargin = UIEdgeInsetsZero;
         _minBodySize = _maxBodySize = 0;
         _autoResizingEnabled = false;
         _frameObserverEnabled = _foldingStateChanging = false;
         _animDuratin = MICUI_ACCORDIONCELLVIEW_ANIM_DURATION;
         self.clipsToBounds = true;
    }
    return self;
}

#pragma mark - プロパティ(getter/setter)

/**
 * ラベルの表示位置設定
 */
- (void)setLabelPos:(int)labelPos {
    if(_labelPos!=labelPos) {
        _labelPos = labelPos;
        _needsCalcLayout = true;
    }
}

/**
 * 伸縮方向の設定
 */
- (void)setOrientation:(MICUiOrientation)orientation {
    if( _orientation!=orientation) {
        _orientation = orientation;
        _needsCalcLayout = true;
    }
}

/**
 * 縦置きラベルの回転方向を指定
 */
- (void)setRotateRight:(bool)rotateRight {
    if( _rotateRight!=rotateRight) {
        _rotateRight = rotateRight;
        if(_orientation==MICUiHorizontal) {
            _needsCalcLayout = true;
        }
    }
}

/**
 * ボディ領域を取得
 */
- (CGRect) bodyBounds {
    [self calcLayout];
    return _bodyBounds;
}

/**
 * ラベルマージン取得
 */
- (UIEdgeInsets) labelMargin {
    return _labelMargin;
}

/**
 * ラベルマージン設定
 */
- (void) setLabelMargin :(UIEdgeInsets)margin{
    if( _labelMargin != margin) {
        _labelMargin = margin;
        _needsCalcLayout = true;
    }
}

/**
 * ボディマージン取得
 */
- (UIEdgeInsets) bodyMargin {
    return _bodyMargin;
}

/**
 * ボディマージン設定
 */
- (void) setBodyMargin :(UIEdgeInsets)margin{
    if( _bodyMargin != margin) {
        _bodyMargin = margin;
        _needsCalcLayout = true;
    }
}

//------------------------------------------------------------------------------------------
#pragma mark - レイアウト
/**
 * 縦伸縮型のときに、ラベルは上か？
 */
static bool isPositionTop(int flags) {
    return (flags&MICUiPosBOTTOM)!=MICUiPosBOTTOM;
}

/**
 * 横伸縮型のときに、ラベルは左か？
 */
static bool isPositionLeft(int flags) {
    return (flags&MICUiPosRIGHT)!=MICUiPosRIGHT;
}

/**
 * コンテント（ラベル＋ボディ）のサイズを変更しないで表示する場合に必要な最小矩形を取得する。
 *  縦型の場合、
 *      height: ラベルビューの高さ＋ボディビューの高さ（または、レイアウターのgetSizeで取得される高さ）＋マージン高さ（ラベルマージン上下、ボディマージン上下）の合計
 *      width:  ラベルビューの幅＋ラベルマージン左右合計とボディビューの幅（または、レイアウターのgetSizeで取得される幅）＋ボディマージン左右合計の大きい方
 */
- (CGSize) calcMinSizeOfContents {
    if(!_rotated && nil!=_labelView) {
        _labelOrgSize = _labelView.frame.size;
    }
    MICSize size;
    if(nil!=_bodyView) {
        if([_bodyView conformsToProtocol:@protocol(MICUiSizeDeterminableProtocol)]) {
            size = [(id)_bodyView calcMinSizeOfContents];
        } else {
            size = _bodyView.frame.size;
        }
    } else if(_layouter) {
        size = [_layouter getSize];
        // 位置決め用にlayouterに設定しているマージン分のサイズを差し引く
        MICEdgeInsets mgn = _layouter.margin;
        size.height -= mgn.dh();
        size.width -= mgn.dw();
    }

    if( _orientation == MICUiVertical){
        size.height += (_labelOrgSize.height + _bodyMargin.dh() + _labelMargin.dh());
        size.width = MAX(_labelOrgSize.width+_labelMargin.dw(), size.width+_bodyMargin.dw());
    } else {
        size.width += (_labelOrgSize.height + _bodyMargin.dw() + _labelMargin.dw());
        size.height = MAX(_labelOrgSize.width +_labelMargin.dh(), size.height+_bodyMargin.dh());
    }
    return size;
}

/**
 * レイアウトを計算
 * （必ず、unfoldした状態で呼び出すこと）
 */
- (void) calcLayout {
    if(!_needsCalcLayout) {
        return;
    }

    // 折りたたみ中以外の場合だけ、再計算フラグをリセットする。
    // 折りたたみ中は、ラベルビューだけ配置計算する。この場合は完全な再計算ではないので、再計算フラグはリセットしない。
    if(!_folding) {
        _needsCalcLayout = false;
    }

    _labelBounds = CGRectZero;
    MICRect viewRect(CGPointZero, self.bounds.size);         // ビュー全体の領域から、ラベル、ボディ領域を切り出していく。
    _viewSize = viewRect.size;
    
    if( _labelView==nil) {
        return;
    }
    if(!_rotated&&_labelOrgSize.isEmpty()) {
        _labelOrgSize = _labelView.frame.size;
    }
    if(!_folding) {
        _viewOrgSize = viewRect.size;
    } else {
        if(_orientation==MICUiVertical) {
            viewRect.setHeight(_viewOrgSize.height);
        } else {
            viewRect.setWidth(_viewOrgSize.width);
        }
    }
    
    if(_orientation==MICUiVertical) {
        if(isPositionTop(_labelPos)) {
            _labelBounds = viewRect.partialTopRect(_labelOrgSize.height+_labelMargin.dh());
            viewRect.setTop(_labelBounds.bottom());
        } else {
            _labelBounds = viewRect.partialBottomRect(_labelOrgSize.height+_labelMargin.dh());
            viewRect.setBottom(_labelBounds.top());
        }
    } else {
        if(isPositionLeft(_labelPos)) {
            _labelBounds = viewRect.partialLeftRect(_labelOrgSize.height+_labelMargin.dw());
            viewRect.setLeft(_labelBounds.right());
            
        } else {
            _labelBounds = viewRect.partialRightRect(_labelOrgSize.height+_labelMargin.dw());
            viewRect.setRight(_labelBounds.left());
        }
    }
    
    _labelBounds.norimalize();
    _bodyBounds = viewRect;
    _bodyBounds.norimalize();
}

/**
 * ビューの配置を更新
 */
- (void) updateLayout {
    [self calcLayout];
    
    if(nil!=_labelView) {
        CGSize labelSize = _labelView.frame.size;
        MICRect labelRect = _labelBounds;
        labelRect.deflate(_labelMargin);
        if(_orientation==MICUiVertical) {
            CGFloat labelWidth = (_rotated)?labelSize.height:labelSize.width;
            _labelView.transform = CGAffineTransformIdentity;
            _rotated = false;
            if(_labelAlignment!=MICUiAlignExFILL) {
                if(labelRect.width()>labelSize.width) {
                    switch(_labelAlignment) {
                        default:
                        case MICUiAlignExLEFT:
                            labelRect = labelRect.partialLeftRect(labelWidth);
                            break;
                        case MICUiAlignExCENTER:
                            labelRect = labelRect.partialHorzCenterRect(labelWidth);
                            break;
                        case MICUiAlignExRIGHT:
                            labelRect = labelRect.partialRightRect(labelWidth);
                            break;
                    }
                } else {
                    labelRect.setWidth(labelSize.width);
                }
            }
        } else {
            CGFloat r = (_rotateRight)? -M_PI/2 : M_PI/2;
            CGFloat labelHeight = (_rotated)?labelSize.height:labelSize.width;
            _labelView.transform = CGAffineTransformMakeRotation(r);
            _rotated = true;
            if(_labelAlignment!=MICUiAlignExFILL) {
                if(labelRect.height()>labelSize.width) {
                    switch(_labelAlignment) {
                        default:
                        case MICUiAlignExTOP:
                            labelRect = labelRect.partialTopRect(labelHeight);
                            break;
                        case MICUiAlignExCENTER:
                            labelRect = labelRect.partialVertCenterRect(labelHeight);
                            break;
                        case MICUiAlignExBOTTOM:
                            labelRect = labelRect.partialBottomRect(labelHeight);
                            break;
                    }
                } else {
                    labelRect.setHeight(labelSize.width);
                }
            }
        }
        _labelView.frame = labelRect;
    }
    if(nil!=_bodyView) {
        MICRect bodyRect;
        if(!_folding) {
            bodyRect = _bodyBounds;
        }
        MICRect bodyBounds = bodyRect - _bodyMargin;
        _bodyView.frame = bodyBounds;
    } else if(nil!=_layouter) {
        MICEdgeInsets insets(MICRect::unionRect(_bodyBounds,_labelBounds), _bodyBounds);
        insets += _bodyMargin;
        _layouter.margin = insets;
        [_layouter updateLayout:false onCompleted:nil];
    }
}

//------------------------------------------------------------------------------------------
#pragma mark - 折りたたみ/展開

/**
 * 折りたたんだ時のフレーム矩形を計算
 */
- (CGRect) getFrameRectOnFolded {
    if (!_movableLabel) {
        return _labelBounds;    //ラベル位置を移動しない
    } else {
        MICRect rc = _labelBounds;
        if(_orientation==MICUiVertical) {
            if(isPositionTop(_labelPos)) {
                rc.setY(_bodyBounds.bottom()-_labelBounds.size.height);
            } else {
                rc.setY(0);
            }
        } else {
            if(isPositionLeft(_labelPos)) {
                rc.setX(_bodyBounds.right()-_labelBounds.size.width);
            } else {
                rc.setX(0);
            }
        }
        return rc;
    }
}

/**
 * 展開したときのフレーム矩形を計算
 */
- (CGRect) getFrameRectOnUnfolded {
    if (!_movableLabel) {
        return MICRect::unionRect(_labelBounds,_bodyBounds);
    } else {
        MICRect rc = MICRect::unionRect(_labelBounds,_bodyBounds);
        if(_orientation==MICUiVertical) {
            if(isPositionTop(_labelPos)) {
                rc.setY(-(_bodyBounds.bottom()-_labelBounds.size.height));
            } else {
                rc.setY(_labelBounds.origin.y);
            }
        } else {
            if(isPositionLeft(_labelPos)) {
                rc.setX(-(_bodyBounds.right()-_labelBounds.size.width));
            } else {
                rc.setX(_labelBounds.origin.x);
            }
        }
        return rc;
    }
}

/**
 * 折りたたむ
 */
- (void) fold : (BOOL) animation onCompleted:(void (^)(BOOL)) onCompleted{
    if(_folding){
        return;
    }
    [self updateLayout];
    _foldingStateChanging = true;
    _folding = true;
    
    // Note:
    // boundsとframeのサイズは一致させておかないと、きれいにアニメーションしない。
    // 考えてみれば当然のことなのだが、boundsとframeのサイズが異なること自体がありえない（異なるサイズを指定すると後勝ちで設定される）ので、
    // 別々の値を設定してアニメーションすると、最終形態は同じでも、遷移状態が見えてしまって、アニメーションがグダグダになる。
    
    CGRect lastFrame = [self.superview convertRect:[self getFrameRectOnFolded] fromView:self];
    MICRect lastBounds(_labelBounds.origin, lastFrame.size); //self.bounds.size);

    if(nil!=_accordionDelegate) {
        [_accordionDelegate accordionCellFolding:self fold:true lastFrame:lastFrame];
    }
    if(animation) {
        [UIView animateWithDuration:_animDuratin
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.bounds = lastBounds;
                             self.frame = lastFrame;
                         } completion:^(BOOL result){
                             _foldingStateChanging = false;
                             if(nil!=_accordionDelegate) {
                                 [_accordionDelegate accordionCellFolded:self fold:true lastFrame:lastFrame];
                             }
                             if(nil!=onCompleted) {
                                 onCompleted(result);
                             }
                         }];
    } else {
        self.bounds = lastBounds;
        self.frame = lastFrame;
        if(nil!=_accordionDelegate) {
            [_accordionDelegate accordionCellFolded:self fold:true lastFrame:lastFrame];
        }
        if(nil!=onCompleted) {
            onCompleted(true);
        }
    }
    
}

/**
 * 展開する
 */
- (void) unfold : (BOOL) animation onCompleted:(void (^)(BOOL)) onCompleted{
    if(!_folding){
        return;
    }
//    [self updateLayout];  これをよぶと、Unfold時にラベルビューの位置が不正になる。
    _folding = false;
    _foldingStateChanging = true;
    
    CGRect lastFrame = [self.superview convertRect:[self getFrameRectOnUnfolded] fromView:self];
    MICRect lastBounds(CGPointZero, lastFrame.size); // self.bounds.size);

    if(nil!=_accordionDelegate) {
        [_accordionDelegate accordionCellFolding:self fold:false lastFrame:lastFrame];
    }
    
    if(animation){
        [UIView animateWithDuration:_animDuratin
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.bounds = lastBounds;
                             self.frame = lastFrame;
                         } completion:^(BOOL result){
                             _foldingStateChanging = false;
                             if(nil!=_accordionDelegate) {
                                 [_accordionDelegate accordionCellFolded:self fold:false lastFrame:lastFrame];
                             }
                             if(nil!=onCompleted) {
                                 onCompleted(result);
                             }
                         }];
    }else{
        self.bounds = lastBounds;
        self.frame = lastFrame;
        if(nil!=_accordionDelegate) {
            [_accordionDelegate accordionCellFolded:self fold:false lastFrame:lastFrame];
        }
        if(nil!=onCompleted) {
            onCompleted(true);
        }
    }
}

/**
 * 折りたたみ/展開の状態をトグルする
 */
- (void) toggleFolding : (BOOL)animation  onCompleted:(void (^)(BOOL)) onCompleted{
    if(_folding) {
        [self unfold:animation onCompleted:onCompleted];
    } else {
        [self fold:animation onCompleted:onCompleted];
    }
}

//------------------------------------------------------------------------------------------
#pragma mark - ラベル

/**
 * ラベルビューを設定する。（必須）
 */
- (void) setLabelView:(UIView*)labelView {
    if(nil!=_labelView) {
        [NSException raise:@"MICUiAccordionCellView.setLabelView" format:@"labelView has been already set."];
    }
    
    _labelView = labelView;
    [self addSubview:labelView];
    _needsCalcLayout = true;
}

/**
 * ラベルビューの設定を解除する。
 */
- (UIView*) removeLabelView {
    UIView* v = _labelView;
    if(nil!=v){
        [v removeFromSuperview];
        if(_rotated){
            _rotated = false;
            v.transform = CGAffineTransformIdentity;
        }

        _labelOrgSize = CGSizeZero;
        _labelView = nil;
        _needsCalcLayout = true;
    }
    return v;
}

//------------------------------------------------------------------------------------------
#pragma mark - ボディ

/**
 * ボディビューを設定する。（任意）
 *  ラベルビュー領域を除いた部分に配置される。ボディビューを指定しないで、このビューのbodyBoundsに、直接サブビューを貼り付けて使っても可。
 */
- (void) setBodyView:(UIView*)bodyView {
    if(nil!=_bodyView) {
        [NSException raise:@"MICUiAccordionCellView.setBodyView" format:@"bodyView has been already set."];
    }
    if(_autoResizingEnabled && ![bodyView isKindOfClass:UIScrollView.class]) {
        [NSException raise:@"setBodyView" format:@"autoResizing mode requires UIScrollView in body."];
    }
    
    _bodyView = bodyView;
    [self addSubview:bodyView];
    _needsCalcLayout = true;
    
    if(_autoResizingEnabled && [self notifyContentSizeOfScrollView]) {
        _needsCalcLayout = true;
    }
}

/**
 * ボディビューの設定を解除する。
 */
- (UIView*) removeBodyView {
    UIView* v = _bodyView;
    if(nil!=v){
        [v removeFromSuperview];
        _bodyView = nil;
        _needsCalcLayout = true;
    }
    return v;
}

/**
 * レイアウターをボディとしてセットする。
 */
- (void) setBodyLayouter:(id<MICUiLayoutProtocol>)layouter {
    _layouter = layouter;
    _layouter.parentView = self;
    if([_layouter conformsToProtocol:@protocol(MICUiDraggableLayoutProtocol)]) {
        ((id<MICUiDraggableLayoutProtocol>)_layouter).layoutDelegate = self;
    }
    _needsCalcLayout = true;
}

/**
 * レイアウターを切り離す。
 * レイアウターやビューに登録された子ビューはremoveされないので、あらかじめ削除しておくこと。
 */
- (id<MICUiLayoutProtocol>)removeBodyLayouter {
    id<MICUiLayoutProtocol> r = _layouter;
    if(nil!=r) {
        _layouter = nil;
        r.parentView = nil;
        if([r conformsToProtocol:@protocol(MICUiDraggableLayoutProtocol)]) {
            ((id<MICUiDraggableLayoutProtocol>)r).layoutDelegate = nil;
        }
        _needsCalcLayout = true;
    }
    return r;
}

/**
 * 自動リサイズモードを有効化する。
 */
- (void)enableAutoResizing:(BOOL)enable minBodySize:(CGFloat)min maxBodySize:(CGFloat)max {
    if(nil!=_bodyView && ![_bodyView isKindOfClass:UIScrollView.class] ) {
        [NSException raise:@"MICUiAccordionCellView.enableAutoResizing" format:@"autoResizing mode requires UIScrollView in body."];
    }
    
    if(max<=0 || min<0 || max<min) {
        [NSException raise:@"MICUiAccordionCellView.enableAutoResizing" format:@"invalid arguments."];
    }
    
    _autoResizingEnabled = enable;
    _minBodySize = min;
    _maxBodySize = max;
    if(_autoResizingEnabled && [self notifyContentSizeOfScrollView]) {
        _needsCalcLayout = true;
    }
}


/**
 * 自動リサイズモード時のサイズ変更要求を発行する。
 *  自動とはいっても、勝手にサイズ変更するわけではなく、accordionDelegate に accordionCellContentsSizeChanged メッセージを投げて、
 *  親側でビューサイズの変更と、全体のレイアウトの再計算を行ってもらう。
 */
- (bool)notifyContentSizeOfScrollView {
    if(nil==_accordionDelegate || [_accordionDelegate conformsToProtocol:@protocol(MICUiAccordionCellLayoutDelegate)]) {
        return false;
    }
    [self calcLayout];

    CGSize size;
    if([_bodyView isKindOfClass:MICUiLayoutView.class]) {
        size = [((MICUiLayoutView*)_bodyView).layouter getSize];
    } else {
        size = ((UIScrollView*)_bodyView).contentSize;
    }
    
    MICRect bodyRect = _bodyBounds - _bodyMargin;
    CGFloat d = 0;
    if(self.orientation==MICUiVertical) {
        if(size.height < _minBodySize ) {
            size.height = _minBodySize;
        } else if( size.height > _maxBodySize) {
            size.height = _maxBodySize;
        }
        d = size.height - bodyRect.height();
    } else {
        if(size.width < _minBodySize ) {
            size.width = _minBodySize;
        } else if( size.width > _maxBodySize) {
            size.width = _maxBodySize;
        }
        d = size.width - bodyRect.width();
    }
    if(0!=d) {
        CGSize cellSize = MICRect::unionRect(_bodyBounds, _labelBounds).size;
        if(self.orientation==MICUiVertical) {
            cellSize.height += d;
        } else {
            cellSize.width += d;
        }
        NSLog(@"... new size=(%f,%f)", cellSize.width, cellSize.height);
        [(id<MICUiAccordionCellLayoutDelegate>)_accordionDelegate accordionCellContentsSizeChanged:self toSize:cellSize];
        return true;
    }
    return false;
}


/**
 * 親ビューにアタッチされる/デタッチされる→ビューサイズ監視の開始・終了
 */
- (void)didMoveToSuperview {
    if(nil!=self.superview) {
        // アタッチされる
        if(!_frameObserverEnabled) {
            _frameObserverEnabled = true;
            [self addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
        }
    } else {
        // デタッチされる
        if(_frameObserverEnabled) {
            _frameObserverEnabled = false;
            [self removeObserver:self forKeyPath:@"frame"];
        }
    }
    //NSLog(@"did move to superview: %@", [self.superview description]);
}

/**
 * ボディビューが設定されたタイミングで、contentSize変更イベントハンドラを登録する。
 */
- (void)didAddSubview:(UIView *)subview {
    if([subview isKindOfClass:UIScrollView.class] && _bodyView == subview ) {
        [subview addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionPrior context:NULL];
    }
}

/**
 * ボディビューが削除されるタイミングで、contentSize変更イベントハンドラを登録解除する。
 */
- (void)willRemoveSubview:(UIView *)subview {
    if([subview isKindOfClass:UIScrollView.class] && _bodyView == subview) {
        [subview removeObserver:self forKeyPath:@"contentSize" context:NULL];
    }
}
/**
 * contentSizeの変更イベント監視ハンドラ
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if( [keyPath isEqualToString:@"contentSize"] ) {
//        NSLog(@"ContentSize changed. (%@)", self.name);
        if(nil!=_accordionDelegate && _autoResizingEnabled && [_accordionDelegate conformsToProtocol:@protocol(MICUiAccordionCellLayoutDelegate)]) {
            if([self notifyContentSizeOfScrollView]) {
                _needsCalcLayout = true;
                [self updateLayout];
            }
        }
    } else if( [keyPath isEqualToString:@"frame"]) {
        if(!_foldingStateChanging && _viewSize != self.frame.size ) {
            _needsCalcLayout = true;
            [self updateLayout];
        }
        
    }
}

//------------------------------------------------------------------------------------------
#pragma mark - MICUiLayoutDelegateプロトコルの実装

/**
 * コンテントのサイズが変更になった。
 *  スクロール領域 (UIScrollView#contentSize)を更新する。
 */
- (void) onContentSizeChanged:(id) layout size:(CGSize)size {
    if(!_folding) {
        [self calcLayout];
    }
         
    if(_accordionDelegate!=nil && [_accordionDelegate conformsToProtocol:@protocol(MICUiAccordionCellLayoutDelegate)]) {
//        CGSize viewSize = size;
//         if(_orientation==MICUiVertical) {
//             viewSize.height += _labelBounds.height();
//         } else {
//             viewSize.width += _labelBounds.width();
//         }
        // size引数には、layouterのマージン込のサイズが渡ってくる。
        // ボディにレイアウターをセットしている場合は、ビュー全体（ラベルを含む）に対するマージンがセットされており、
        // このsizeがそのまま、必要なビューのサイズということになる。
        [(id<MICUiAccordionCellLayoutDelegate>)_accordionDelegate accordionCellContentsSizeChanged:self toSize:size];
    }
}

/**
 * 指定された矩形領域が画面内に入るようスクロールすることを要求
 *  @param  layout  要求元のレイアウター
 *  @param  rect    領域指定
 */
- (void) ensureRectVisible:(id) layout rect:(CGRect)rect {
    if(nil!=_accordionDelegate && [_accordionDelegate conformsToProtocol:@protocol(MICUiAccordionCellLayoutDelegate)]) {
        [(id<MICUiAccordionCellLayoutDelegate>)_accordionDelegate ensureRectVisible:self ofRect:rect];
    }
    
}


///**
// * ドラッグ中の自動スクロール量のコールバックを設定する。
// */
//- (void) setScrollAmountCallback:(void (^)(CGPoint amount)) scrolled;
//

/**
 * 現在のスクロール位置（UIScrollView#contentOffset）を取得する
 */
- (CGPoint) getScrollPosition:(id) layout {
    return CGPointZero;
}

/**
 * スクロール領域内の表示範囲を取得
 */
- (CGRect) getVisibleRect:(id) layout {
    return self.bounds;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"AccCell[name=%@",self.name];
}

#pragma mark - MICUiDraggableCellProtocol の実装

/**
 * D&Dによるカスタマイズを開始するときに呼び出される。
 *  このタイミングで、このセルビューに対するタップやドラッグなどのユーザ操作を無効化する。
 *
 * @param layout    呼び出し元レイアウター
 */
- (void) onBeginCustomizing:(id<MICUiDraggableLayoutProtocol>)layout {
    
}

/**
 * D&Dによるカスタマイズを終了するときに呼び出される。
 *  onBeginCustomizingで行った変更を元に戻す。
 *
 * @param layout    呼び出し元レイアウター
 */
- (void) onEndCustomizing:(id<MICUiDraggableLayoutProtocol>)layout {
    
}

/**
 * このセルビューのD&Dが開始されるタイミングで呼び出される。
 * onBeginCustomizing〜onEndCustomizingの間に、0回以上呼び出される。
 *
 *  必要に応じて、セルの表示更新・形状変更などを行う。
 *
 * @param layout    呼び出し元レイアウター
 * @return true: ドラッグ開始可　／ false:ドラッグ開始拒否
 */
- (BOOL) onBeginDragging:(id<MICUiDraggableLayoutProtocol>)layout {
    _foldedBeforeDrag = _folding;
    [self fold:false onCompleted:nil];
    return true;
}

/**
 * このセルビューに対するD&Dが完了したタイミングで呼び出される。
 *
 * @param layout    呼び出し元レイアウター
 * @param done      true:確定 / false:キャンセル
 */
- (void) onEndDragging:(id<MICUiDraggableLayoutProtocol>)layout done:(BOOL)done {
    if(!_foldedBeforeDrag) {
        [self unfold:false onCompleted:nil];
    }
}

- (CGVector)getTrackingPointBasedOnCenter:(id<MICUiDraggableLayoutProtocol>)layout {
    if( _folding) {
        return MICVector();
    }
    MICRect labelFrame = [self convertRect:_labelView.frame toView:self.superview];
    MICPoint labelCenter = labelFrame.center();
    return labelCenter - self.center;
}

@end
