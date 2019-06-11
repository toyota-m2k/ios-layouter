//
//  MICUiCellDragSupport.m
//
//  １つのビューの中だけでD&Dするドラッグサポータークラス
//
//  Created by @toyota-m2k on 2014/10/23.
//  Copyright (c) 2014年 @toyota-m2k. All rights reserved.
//

#import "MICUiCellDragSupport.h"
#import "MICUiRectUtil.h"
#import "MICUiDragView.h"

//--------------------------------------------------------------------------------------
#pragma mark - グリッドレイアウターD&Dによるカスタマイズ機能のサポートクラス

#define SCROLLINGTIMER_INTERVAL (0.25)

@interface MICUiCellDragSupport () {
    NSTimer* _scrollingTimer;
}

@end


/**
 * グリッドレイアウト上でのセルのD&Dによる移動をサポートのためのイベント処理を実装するクラス
 * 特にコンテナになるビューが　UIScrollView の場合は、ドラッグ中のスクロールや、
 * レイアウト実行時のスクロール領域（ContentSize）の調整などもサポートする。
 */
@implementation MICUiCellDragSupport {
}

//--------------------------------------------------------------------------------------
#pragma mark - プロパティ

// implements MICUiDragSupporter
@synthesize isCustomizing = _isCustomizing;
//@synthesize dropAcceptorDelegate = _dropAcceptorDelegate;
@synthesize baseView = _baseView;
@synthesize baseRect = _baseRect;

// implements MICUiDragEventArg
@synthesize draggingCell = _draggingCell;
@synthesize overlayView = _overlayView;
@synthesize touchPosOnOverlay = _touchPosOnOverlay;
@synthesize containerView = _containerView;

- (UIView *)containerView {
    return (_containerView!=nil) ? _containerView : _baseView;
}

/**
 * レイアウターを強参照で設定する。
 */
- (void)setStrongLayouter:(id<MICUiDraggableLayoutProtocol>)layouter {
    _strongLayouter = layouter;
    _layouter = layouter;
}

/**
 * overlayRect プロパティの設定
 *  実態は、baseRectプロパティに保持しており、このメソッドはヘルパー的位置づけ。
 */
- (void)setOverlayRect:(CGRect)overlayRect {
    _baseRect = [NSValue valueWithCGRect:overlayRect];
}

/**
 * overlayRect プロパティの取得
 *  baseRectがnilなら、baseView.frame、nilでなければ、その値を返す。
 */
- (CGRect)overlayRect {
    if(nil!=_baseRect) {
        return [_baseRect CGRectValue];
    } else {
        return self.baseView.frame;
    }
}

//--------------------------------------------------------------------------------------
#pragma mark - 初期化
/**
 * 初期化
 */
- (MICUiCellDragSupport*) init {
        self = [super init];
        if( nil!=self){
            _handlers = [[MICUiCellDragHandler alloc] initWithOwner:self];
            _containerView = nil;
            _baseView = nil;
            _layouter = nil;
            _isCustomizing = false;
            _overlayView = nil;
            _baseRect = nil;
            _scrollAcceleration = 50;
            _scrollSpeed = 1;
        }
        return self;
}

#pragma mark - MICUiDragSupporterプロトコル

/**
 * コンテナビューとしてUIScrollView派生クラスを使用する場合に、レイアウターのサイズ変更に合わせてスクロール領域を調整したり、D&Dによる自動スクロールを有効にする。
 *
 *  @param  enable  true:有効化　/ false: 無効化
 */
- (void) enableScrollSupport:(BOOL)enable {
    if(nil==_layouter || nil==self.containerView) {
        [NSException raise:@"MICUiCellDragSupport.enableScrollSupport" format:@"set layouter and containerView previously."];
    }
    
    if(enable ) {
        if([self.containerView isKindOfClass:[UIScrollView class]]) {
            _layouter.layoutDelegate = self;
        }
    } else {
        if(_layouter.layoutDelegate == self) {
            _layouter.layoutDelegate = nil;
        }
    }
    return;
}


/**
 * 長押しによるカスタマイズ開始、タップによるカスタマイズ終了を有効化・無効化する。
 * 事前に、layouter(or strongLayouter)、containerViewプロパティに有効な値を設定しておく必要がある。
 *
 * @param longPress             true: 長押しで、カスタマイズ（D&D)モードへの移行を有効化
 * @param tap                   true: 画面タップで、カスタマイズモード終了を有効化
 */
- (void) beginCustomizingWithLongPress:(BOOL)longPress
                            endWithTap:(BOOL)tap {

    if( nil==_baseView ) { // || nil==_layouter) {
        [NSException raise:@"MICUiGridCellDragSupport.enableDragAndDrop" format:@"set layouter and containerView previously."];
    }

    // 一旦リコグナイザの登録を解除
    [_handlers setLongPressGesture:false onView:_baseView];
    [_handlers setTapGesture:false onView:_overlayView];

    // 与えられたフラグに応じてリコグナイザを設定
    [_handlers enableLongPressRecognizer:longPress andTapRecognizer:tap];
    
    // リコグナイザを再登録
    [_handlers setLongPressGesture:true onView:_baseView];
    [_handlers setTapGesture:true onView:_overlayView];
}

- (void)fireBeginCustomizingEvent {
    [_layouter onBeginCustomizing];
}

- (void)fireEndCustomizingEvent {
    [_layouter onEndCustomizing];
}

/**
 * カスタマイズ（D&Dモード）を開始する。
 */
- (void) beginCustomizing {
    if( !_isCustomizing) {
        [self fireBeginCustomizingEvent];
        
        _isCustomizing = true;

        // オーバーレイビューを作成
        _overlayView = [[MICUiDragView alloc] initWithFrame:[self overlayRect]];
        [_baseView.superview addSubview:_overlayView];
        // ドラッグアイテムが裏に回らないよう、オーバーレイビューを最前面に持ち上げておく。
        [_baseView.superview bringSubviewToFront:_overlayView];
        

        // Panジェスチャーと（もしあれば）タップジェスチャーリコグナイザをoverlayビューに設定
        [_handlers setPanGesture:true onView:_overlayView];
        [_handlers setTapGesture:true onView:_overlayView];
    }
}

/**
 * カスタマイズ（D&Dモード）を終了する。
 */
- (void) endCustomizing {
    if( _isCustomizing) {
        [self fireEndCustomizingEvent];
        
        _isCustomizing = false;

        // ジェスチャーリコグナイザを削除
        [_handlers setPanGesture:false onView:_overlayView];
        [_handlers setTapGesture:false onView:_overlayView];

        // オーバーレイを削除
        [_overlayView removeFromSuperview];
        _overlayView = nil;
    }
}

//--------------------------------------------------------------------------------------
#pragma mark - タッチイベントのハンドル

/**
 * ドラッグしているビューの位置を更新する
 */
- (void) updateDepositedViewPos {
    id<MICUiDraggableLayoutProtocol> layouter = [self layouter];
    CGPoint pos = _touchPosOnOverlay;
    if([_depositedView conformsToProtocol:@protocol(MICUiDraggableCellProtocol)] &&
       [_depositedView respondsToSelector:@selector(getTrackingPointBasedOnCenter:)]) {
        CGVector d = [(id<MICUiDraggableCellProtocol>)_depositedView getTrackingPointBasedOnCenter:layouter];
        pos = pos - d;
    }
    int dragOri = layouter.draggableOrientation;
    if( !(dragOri&MICUiVertical)) {
        pos.y = _depositedView.center.y;        // 横方向にしかドラッグさせない
    }
    if(!(dragOri&MICUiHorizontal)) {
        pos.x = _depositedView.center.x;        // 縦方向にしかドラッグさせない
    }
    _depositedView.center = pos;
}


/**
 * (PRIVATE) ドラッグ開始
 */
- (void) beginDrag:(UIGestureRecognizer*)sender {
    [self updateTouchPos:sender];
    [self setFirstTouchPosOnOverlay];
//    if(((MICUiDragView*)_overlayView).firstTouch) {
//        _firstTouchPosOnOverlay = ((MICUiDragView*)_overlayView).touchBeginningPos;
//        ((MICUiDragView*)_overlayView).firstTouch = false;
//    } else {
//        _firstTouchPosOnOverlay = _touchPosOnOverlay;
//    }
    [_layouter beginDrag:self];
}

/**
 * (PRIVATE) 指定位置へドラッグ
 */
- (void) dragTo:(UIGestureRecognizer*)sender {
    if(nil!=sender) {
        [self updateTouchPos:sender];
        [self updateDepositedViewPos];
    }
    [_layouter dragTo:self];
}

/**
 * (PRIVATE) ドラッグ終了（ドロップ）
 */
- (void) endDrag:(UIGestureRecognizer*) sender {
    [_layouter endDrag:self];
}

/**
 * (PRIVATE) ドラッグキャンセル（ドラッグ開始前の状態に戻す）
 */
- (void) cancelDrag:(UIGestureRecognizer*) sender {
    [_layouter cancelDrag:self];
}

/**
 * (PRIVATE) ドラッグ処理（パンとロングプレスの共通処理）
 */
- (void)doDrag:(UIGestureRecognizer*)sender {
    if( !_isCustomizing){
        return;
    }
    switch(sender.state) {
        case UIGestureRecognizerStateBegan:
            //            NSLog(@"drag: begin");
            [self beginDrag:sender];
            [self startScrollingTimer];
            break;
        case UIGestureRecognizerStateChanged:
            //            NSLog(@"drag: changed");
            [self dragTo:sender];
            break;
        case UIGestureRecognizerStateEnded:
            //            NSLog(@"drag: end");
            [self stopScrollingTimer];
            [self endDrag:sender];
            break;
        case UIGestureRecognizerStateCancelled:
            //            NSLog(@"drag: cancel");
            [self stopScrollingTimer];
            [self cancelDrag:sender];
            break;
        default:
            break;
    }
}

//--------------------------------------------------------------------------------------
#pragma mark - スクロール監視タイマー


/**
 * スクロール監視タイマーを起動する。
 */
- (void)startScrollingTimer {
    if( nil ==_scrollingTimer || ![_scrollingTimer isValid]) {
//        NSLog(@"Timer: start");
        _scrollingTimer = [NSTimer scheduledTimerWithTimeInterval:SCROLLINGTIMER_INTERVAL
                                                           target:self
                                                         selector:@selector(watchScroll:)
                                                         userInfo:nil repeats:YES];
    }
}

/**
 * スクロール監視タイマーを停止する。
 */
- (void)stopScrollingTimer {
    if( nil != _scrollingTimer && [_scrollingTimer isValid]){
//        NSLog(@"Timer: stop");
        [_scrollingTimer invalidate];
        _scrollingTimer = nil;
    }
}

/**
 * ドラッグ位置に合わせて、コンテナビューをスクロールする。
 * （サブクラスと共通の処理）
 */
- (void) doAutoScroll:(UIScrollView*)sv {
    MICPoint cellCenter = [sv convertPoint:_touchPosOnOverlay fromView:_overlayView];
    //        MICRect cellRect = [sv convertRect:_depositedView.frame fromView:_overlayView];
    MICRect scrollRect(sv.contentOffset, sv.frame.size);
    MICSize contentSize = sv.contentSize;
    MICRect threshold(scrollRect);
    CGFloat w = scrollRect.width()*_scrollSpeed/100;
    CGFloat h = scrollRect.height()*_scrollSpeed/100;
    CGFloat sensingRange = MIN(scrollRect.width(), scrollRect.height());
    sensingRange*=0.4;
    if(sensingRange>100) {
        sensingRange = 100;
    }
    CGFloat accel = 1;
    
    bool needsScroll = false;
    threshold.deflate(sensingRange);
    sensingRange/=2;
    if( cellCenter.x < threshold.left() && scrollRect.left()>0) {
        // scroll to left
        accel = (threshold.left()-cellCenter.x)/sensingRange;
        scrollRect.origin.x -= w*(1+accel*_scrollAcceleration);
        needsScroll = true;
    } else if( cellCenter.x > threshold.right() && scrollRect.right()<contentSize.width) {
        // scroll to right
        accel = (cellCenter.x - threshold.right())/sensingRange;
        scrollRect.origin.x += w*(1+accel*_scrollAcceleration);
        needsScroll = true;
    }
    if( cellCenter.y < threshold.top() && scrollRect.top()>0) {
        // scroll above
        accel = (threshold.top()-cellCenter.y)/sensingRange;
        scrollRect.origin.y -= h*(1+accel*_scrollAcceleration);
        needsScroll = true;
    } else if( cellCenter.y > threshold.bottom() && scrollRect.bottom()<contentSize.height) {
        // scroll bellow
        accel = (cellCenter.y - threshold.bottom())/sensingRange;
        scrollRect.origin.y += h*(1+accel*_scrollAcceleration);
        needsScroll = true;
    }
//    NSLog(@"accel = %f", accel);
    if(needsScroll) {
        [sv scrollRectToVisible:scrollRect animated:true];
    }
}

/**
 * 自動スクロール（サブクラスでオーバーライド）
 */
- (void) autoScroll {
    if([self.containerView isKindOfClass:[UIScrollView class]] ) {
        [self doAutoScroll:(UIScrollView*)self.containerView];
    }
}

/**
 * スクロールを監視して、ドラッグ中のアイテムの位置を補正する。
 */
- (void)watchScroll:(NSTimer*)timer {
    [self dragTo:nil];
    [self autoScroll];
}



//--------------------------------------------------------------------------------------
#pragma mark - GridLayoutイベントハンドラ　（MICUiGridLayoutDelegate）

/**
 * グリッドサイズが変更になった。（implements MICUiGridLayoutDelegate）
 *  スクロール領域 (contentSize)を更新する。
 *
 * @param layout    呼び出し元のレイアウターインスタンス
 * @param size      変更後のサイズ
 */
- (void) onContentSizeChanged:(id) layout size:(CGSize)size {
    if( !CGSizeEqualToSize(((UIScrollView*)self.containerView).contentSize, size)) {
        ((UIScrollView*)self.containerView).contentSize = size;
    }
}

/**
 * 現在のスクロール位置（UIScrollView#contentOffset）を取得する
 */
- (CGPoint)getScrollPosition:(id)layout {
    return ((UIScrollView*)self.containerView).contentOffset;
}

/**
 * スクロール領域内の表示範囲を取得
 */
- (CGRect) getVisibleRect:(id) layout {
    CGRect rc;
    rc.origin =((UIScrollView*)self.containerView).contentOffset;
    rc.size = ((UIScrollView*)self.containerView).frame.size;
    return rc;
}

/**
 * 指定された矩形領域が画面内に入るようスクロールすることを要求（implements MICUiGridLayoutDelegate）
 *
 * @param layout    呼び出し元のレイアウターインスタンス
 * @param rect      セルの矩形
 */
- (void) ensureRectVisible:(id) layout rect:(CGRect)rect {
//    MICRect r(rect);
//    NSLog(@"EnsureRectVisible.(%f,%f)-(%f,%f)", r.left(),r.top(), r.right(),r.bottom());
    [(UIScrollView*)self.containerView scrollRectToVisible:rect animated:true];
}

//--------------------------------------------------------------------------------------
#pragma mark - MICUiDragEventArg の実装

/**
 * ドラッグ元
 */
- (id<MICUiDraggableLayoutProtocol>)dragSource {
    return _layouter;
    
}
/**
 * ドラッグ先
 */
- (id<MICUiDraggableLayoutProtocol>)dragDestination {
    return _layouter;
}

/**
 * ドラッグ中のビュー
 */
//@property (nonatomic,readonly) UIView* draggingView;
- (UIView*) draggingView {
    return _depositedView;
}

/**
 * 指定されたビュー座標上でのタップ位置を取得
 */
- (CGPoint) touchPosOnView:(UIView*) view {
    return [_overlayView convertPoint:_touchPosOnOverlay toView:view];
}

- (CGPoint) firstTouchPosOnView:(UIView*) view {
    return [_overlayView convertPoint:_firstTouchPosOnOverlay toView:view];
}

/**
 * layoutに対応付けられたコンテナビューを取得する。
 */
- (UIView*) containerViewOf:(id<MICUiDraggableLayoutProtocol>)layout {
    return self.containerView;
}


/**
 * eventArgに保持するタッチ位置を更新する。
 */
- (void) updateTouchPos:(UIGestureRecognizer*) sender {
    _touchPosOnOverlay = [sender locationInView:_overlayView];
}

/**
 * オーバーレイビュー上で最初にタップされた位置を取り出してフィールドに設定する。
 */
- (void) setFirstTouchPosOnOverlay {
    if(((MICUiDragView*)_overlayView).firstTouch) {
        _firstTouchPosOnOverlay = ((MICUiDragView*)_overlayView).touchBeginningPos;
        ((MICUiDragView*)_overlayView).firstTouch = false;
    } else {
        _firstTouchPosOnOverlay = _touchPosOnOverlay;
    }
}

/**
 * 指定されたレイアウター上でのタップ位置を取得
 */
- (CGPoint) touchPosOn:(id<MICUiDraggableLayoutProtocol>)layout {
    return [self touchPosOnView:self.containerView];
}

/**
 * 指定されたレイアウター上でのタップ開始位置を取得
 */
- (CGPoint) firstTouchPosOn:(id<MICUiDraggableLayoutProtocol>)layout {
    return [self firstTouchPosOnView:self.containerView];
}

/**
 * コンテナ上のサブビューをオーバーレイビューに預ける。
 */
- (BOOL) depositView: (UIView*) view {
    if(nil!=_overlayView) {
        _depositedView = view;
        CGRect frame = [_overlayView convertRect:view.frame fromView:self.containerView];
        [view removeFromSuperview];
        view.frame = frame;
        [self updateDepositedViewPos];
        _depositedView.alpha = 0.5f;
        [_overlayView addSubview:view];
        return true;
    }
    return false;
}

/**
 * 預けていたサブビューを取り戻す。
 * @param backToContainer   true:コンテナビューに戻す。/ false:オーバーレイビューからremoveするだけ。
 * @return 預けていたサブビュー
 */
- (UIView *)bringBack:(BOOL)backToContainer ofLayout:(id<MICUiDraggableLayoutProtocol>)layout {
    if( nil!=_overlayView && _depositedView) {
        UIView* view = _depositedView;
        _depositedView.alpha = 1.0f;
        _depositedView = nil;
        if( backToContainer ) {
            UIView* containerView = [self containerViewOf:layout];
            CGRect frame = [_overlayView convertRect:view.frame toView:containerView];
            [view removeFromSuperview];
            view.frame = frame;
            [containerView addSubview:view];
            // ドラッグアイテムが裏に回らないよう、オーバーレイビューを最前面に持ち上げておく。
            [_baseView.superview bringSubviewToFront:_overlayView];
        }
        return view;
    }
    return nil;
    
}

/**
 * 預けているサブビューのコンテナ座標系でのフレーム矩形を取得
 */
- (CGRect) getViewFrameOn:(id<MICUiDraggableLayoutProtocol>)layout {
    return [self.containerView convertRect:_depositedView.frame fromView:_overlayView];
}

/**
 * 預けているサブビューのコンテナ座標系での矩形領域を指定して、オーバーレイ上での位置・サイズを変更
 */
- (void) setViewFrame: (CGRect) rect onLayout:(id<MICUiDraggableLayoutProtocol>)layout {
    _depositedView.frame = [self.containerView convertRect:rect toView:_overlayView];
    
}

@end