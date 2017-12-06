//
//  MICUiAccordionView.m
//
//  複数のAccordionCellViewを縦または横方向に並べて配置するアコーディオンビュー
//
//  Created by 豊田 光樹 on 2014/10/31.
//  Copyright (c) 2014年 豊田 光樹. All rights reserved.
//

#import "MICUiAccordionView.h"
#import "MICUiRectUtil.h"
#import "MICUiCellDragSupportEx.h"

/**
 * アコーディオンビュークラスの実装
 */
@implementation MICUiAccordionView {
    UIView* _foldingView;                   ///< 折り畳み状態が変化するビュー（遷移状態管理用）
    CGSize _foldingFrameSize;               ///< 折りたたみ状態変化後のビューサイズ（遷移状態管理用）
    id _rootNode;                           ///< レイアウターツリーのルートノード（StackLayout）
}

/**
 * 保持しているアコーディオンセルの数（＝StackViewの子の数）
 */
- (int)cellCount {
    return _stackLayout.childCount;
}

/**
 * 初期化
 */
- (MICUiAccordionView*) init {
    return [self initWithFrame:CGRectZero];
}

/**
 * ビューのフレームを指定して初期化
 */
- (MICUiAccordionView*) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(nil!=self){
        // AccordionCellView以外のビューのドロップを禁止するため
        _stackLayout.dropAcceptorDelegate = self;
    }
    return self;
}
/**
 * 子ビュー（MICUiAccordionCellView限定）を追加
 */
- (id)addChild:(UIView *)view {
    return [self addChild:view updateLayout:false withAnimation:false];
}

/**
 * @private
 */
- (id) addViewToDragSupporter:(UIView*)view {
    if(nil==_dragSupport) {
        //D&Dがまだ有効化されていない。
        return nil;
    }

    id<MICUiDraggableLayoutProtocol> layouter = nil;
    UIView* containerView = view;
    if( nil != ((MICUiAccordionCellView*)view).layouter ) {
         if([((MICUiAccordionCellView*)view).layouter conformsToProtocol:@protocol(MICUiDraggableLayoutProtocol)]) {
             layouter = (id<MICUiDraggableLayoutProtocol>)((MICUiAccordionCellView*)view).layouter;
         }
    } else if (nil!=((MICUiAccordionCellView*)view).bodyView) {
        if([((MICUiAccordionCellView*)view).bodyView isKindOfClass:MICUiLayoutView.class]) {
            containerView = ((MICUiAccordionCellView*)view).bodyView;
            layouter = (id<MICUiDraggableLayoutProtocol>)((MICUiLayoutView*)((MICUiAccordionCellView*)view).bodyView).layouter;
        }
    }
    if(nil!=layouter) {
        return [(MICUiCellDragSupportEx*)_dragSupport addSubLayouter:layouter
                                                    andContainerView:containerView
                                                        toParentNode:_rootNode];
    }
    return nil;
}


- (id)addChild:(UIView *)view updateLayout:(bool)update withAnimation:(bool)animation{
    if(![view isKindOfClass:MICUiAccordionCellView.class]) {
        [NSException raise:@"MICUiAccordionView.addChild" format:@"view must be an instance of MICUiAccordionCellView"];
    }

    id r = [self addViewToDragSupporter:view];
    ((MICUiAccordionCellView*)view).accordionDelegate = self;
    [super addChild:view updateLayout:update withAnimation:animation];
    return r;
}


- (id)insertChild:(UIView*)view beforeSibling:(UIView*)sibling {
    return [self insertChild:view beforeSibling:sibling updateLayout:false withAnimation:false];
}

- (id)insertChild:(UIView*)view beforeSibling:(UIView*)sibling updateLayout:(bool)update withAnimation:(bool)animation {
    if(![view isKindOfClass:MICUiAccordionCellView.class]) {
        [NSException raise:@"MICUiAccordionView.addChild" format:@"view must be an instance of MICUiAccordionCellView"];
    }

    id r = [self addViewToDragSupporter:view];
    ((MICUiAccordionCellView*)view).accordionDelegate = self;
    [super insertChild:view beforeSibling:sibling updateLayout:update withAnimation:animation];
    return r;
}

- (MICUiAccordionCellView*) cellAt:(int)index {
    return (MICUiAccordionCellView*)[_stackLayout childAt:index];
}


#pragma mark - MICUiAccordionCellDelegate の実装

/**
 * アコーディオンの開閉操作が実行される前に呼び出される。
 *  @param sender   呼び出し元アコーディオン
 *  @param folded   true:折りたたまれる　/ false:展開される
 *  @param frame    操作完了後のフレーム矩形
 */
- (void) accordionCellFolding:(MICUiAccordionCellView*)sender fold:(BOOL)folded lastFrame:(CGRect)frame {
    // StackLayoutのレンダリングは、updateLayout(さらにその内部で実行されるcalcLayout)時点でのビューサイズを基準に計算される。
    // したがって、閉じる／開く動作を行うには、セル（AccordionCellのボディ）サイズを変更してから、StackLayout#updateLayoutしなければならないが、
    // そうすると、StackLayoutによるレイアウト変更アニメーションが始まる前に、セルのサイズが確定してしまい、アニメーションが不自然になる。
    // アニメーションを正しく行わせるには、セルサイズの変更をStackViewに任せる必要があり、レンダリング中にセルサイズを外部から指定するために、
    // 一時的に、getCellSizeDelegateを設定し、折りたたみ動作が終わったら解除することにした。
    _foldingView = sender;
    _foldingFrameSize = frame.size;
    _stackLayout.getCellSizeDelegate = self;
    [_stackLayout requestRecalcLayout];
    [_stackLayout updateLayout:true onCompleted:nil];
}
/**
 * アコーディオンの開閉操作が実行された後に呼び出される。
 *  @param sender   呼び出し元アコーディオン
 *  @param folded   true:折りたたまれた　/ false:展開された
 *  @param frame    操作完了後のフレーム矩形
 */
- (void) accordionCellFolded:(MICUiAccordionCellView*)sender fold:(BOOL)folded lastFrame:(CGRect)frame {
    _stackLayout.getCellSizeDelegate = nil;
    MICRect rc = sender.bounds;
    if(rc.height()>self.frame.size.height) {
        rc = rc.partialTopRect(self.frame.size.height);
    }
    [self ensureRectVisible:sender ofRect:rc];       // ensureRectVisibleの第２引数の矩形領域は、第１引数のビューの座標系で渡す点に注意。
}

#pragma mark - MICUiAccordionCellLayoutDelegate の実装

/**
 * レイアウターを内包している場合に、レイアウターのサイズが更新されたときに通知される。
 * 必要なら親側でアコーディオンセルのサイズ調整を行うこと。
 *  @param sender   呼び出し元アコーディオン
 *  @param size     変更後のアコーディオンセルサイズ（Labelも含む）
 */
- (void) accordionCellContentsSizeChanged:(MICUiAccordionCellView*)sender toSize:(CGSize)size {
//    _foldingView = sender;
//    _foldingFrameSize = size;
//    _stackLayout.getCellSizeDelegate = self;
//    [_stackLayout requestRecalcLayout];
//    [_stackLayout updateLayout:true onCompleted:nil];
    CGRect frame = sender.frame;
    frame.size = size;
    sender.frame = frame;
    [_stackLayout requestRecalcLayout];
    [_stackLayout updateLayout:false onCompleted:nil];
}

/**
 * レイアウターを内包している場合(setBodyLayoutを使用している場合）に、指定された領域を画面内に表示するようスクロール要求する。
 *  @param sender   呼び出し元アコーディオンセル
 *  @param rect     表示する領域（アコーディオンセル（＝sender）クライアント座標系）
 */
- (void) ensureRectVisible:(MICUiAccordionCellView *)sender ofRect:(CGRect)rect {
    if( [_dragSupport conformsToProtocol:@protocol(MICUiLayoutDelegate)]) {
        MICViewRect vrc(sender, rect);
        [(id<MICUiLayoutDelegate>)_dragSupport ensureRectVisible:_stackLayout rect:vrc.getRectOnView(self)];
    }
}

//--------------------------------------------------------------------------------------
#pragma mark - MICUiSizeDeterminableProtocolの実装

/**
 * コンテントの表示に必要な最小矩形を取得する。
 */
- (CGSize) calcMinSizeOfContents {
    MICSize total;
    for(int i=0,ci=_layouter.childCount ; i<ci ; i++) {
//    for(MICUiAccordionCellView* view in _layouter.childViews) {
        MICUiAccordionCellView* view = (MICUiAccordionCellView*)[_layouter childAt:i];
        MICSize size = [view calcMinSizeOfContents];
        if(_stackLayout.orientation == MICUiHorizontal) {
            size.transpose();
        }
        total.height += size.height;
        total.width = fmax(size.width, total.width);
    }
    int count = _stackLayout.childCount-1;
    if(count>0) {
        total.height += ( _stackLayout.cellSpacing * count );
    }
    if(_stackLayout.orientation == MICUiHorizontal) {
        total.transpose();
    }
    MICEdgeInsets margin = _stackLayout.margin;
    total.width += margin.dw();
    total.height += margin.dh();
    return total;
}

/**
 * すべてのセルと、自身のレウアウトを更新する
 */
- (void)updateLayout:(bool)animation {
    if(nil!=_layouter) {
        for(int i=0,ci=_layouter.childCount ; i<ci ; i++) {
            MICUiAccordionCellView* view = (MICUiAccordionCellView*)[_layouter childAt:i];
            [view updateLayout];
        }
        [_layouter updateLayout:animation onCompleted:nil];
    }
}

/**
 * DragSupportインスタンスを作成
 */
- (void) prepareDragSupporter {
    _dragSupport = [[MICUiCellDragSupportEx alloc] init];
    UIView* baseview = [self dragOverlayBaseView];
    if(nil==baseview) {
        baseview = self;
    }
    ((MICUiCellDragSupportEx*)_dragSupport).baseView = baseview;
    _rootNode = [(MICUiCellDragSupportEx*)_dragSupport addRootLayouter:_stackLayout andContainerView:self];
    return;
}

#pragma mark - MICUiStackLayoutGetCellSizeDelegateの実装

/**
 * 折りたたみ動作中に最終サイズを返す。
 *  accordionCellFoldingメソッド内のコメント参照
 */
- (CGSize)getCellSizeForLayout:(UIView*)view {
    if(view == _foldingView) {
        return _foldingFrameSize;
    } else {
        return view.frame.size;
    }
}


#pragma mark - MICUiDropRestrictorDelegateの実装

/**
 * ビューはドロップ可能か？
 * AccordionCellView以外のビューのドロップを禁止する。
 */
- (BOOL)canDropView:(UIView *)draggingView
         fromLayout:(id<MICUiDraggableLayoutProtocol>)srcLayout
           toLayout:(id<MICUiDraggableLayoutProtocol>)dstLayout
             onView:(UIView *)underlaidView {

    if(dstLayout==_layouter) {
        if([draggingView isKindOfClass:MICUiAccordionCellView.class]) {
            return true;
        } else {
            return false;
        }
    }
    // 他のレイアウターのことは知らん
    return true;
}

/**
 * ビューが一定時間ホバーしている。
 */
- (void)onHoverView:(UIView *)draggingView
         fromLayout:(id<MICUiDraggableLayoutProtocol>)srcLayout
           toLayout:(id<MICUiDraggableLayoutProtocol>)dstLayout
             onView:(UIView *)underlaidView {

    if(dstLayout==_layouter && [underlaidView isKindOfClass:MICUiAccordionCellView.class]) {
        if(((MICUiAccordionCellView*)underlaidView).folding) {
            // 折り畳まれているセルを開く
            [(MICUiAccordionCellView*)underlaidView unfold:false onCompleted:nil];
        }
    }
}

@end
