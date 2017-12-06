//
//  MICUiCellDragSupportEx.m
//
//  異なるビューの間をD&Dできるドラッグサポータークラス
//
//  Created by 豊田 光樹 on 2014/11/05.
//  Copyright (c) 2014年 豊田 光樹. All rights reserved.
//

#import "MICUiCellDragSupportEx.h"
#import "MICUiRectUtil.h"
#import "MICTree.h"
#import "MICUiDragView.h"
#import "MICUiCellDragHandler.h"
#import "MICStringUtil.h"

//------------------------------------------------------------------------------------------
#pragma mark - MICUiLayoutRec（レイアウターツリーノード情報）
/**
 * 管理対象のレイアウターに関する情報を保持するクラス。
 *  レイアウターツリーのノード情報として管理される。
 */
@interface MICUiLayoutRec : NSObject
@property (nonatomic,weak)  id<MICUiDraggableLayoutProtocol> layouter;
@property (nonatomic,weak)  UIView* containerView;
- (MICUiLayoutRec*) initWithLayouter:(id<MICUiDraggableLayoutProtocol>)layouter andContainerView:(UIView*)view;
@end

static inline UIView* VIEW(MICTreeNode* node) {
    return (nil!=node && nil!=node.value) ? ((MICUiLayoutRec*)node.value).containerView : nil;
}

static inline id<MICUiDraggableLayoutProtocol> LAYOUT(MICTreeNode* node) {
    return (nil!=node.value) ? ((MICUiLayoutRec*)node.value).layouter : nil;
}

@implementation MICUiLayoutRec

- (MICUiLayoutRec*) initWithLayouter:(id<MICUiDraggableLayoutProtocol>)layouter andContainerView:(UIView*)view {
    self = [self init];
    if(nil!=self) {
        _layouter = layouter;
        _containerView = view;
    }
    return self;
}

@end

//------------------------------------------------------------------------------------------
#pragma mark - MICUiCellDragSupportEx

@interface MICUiCellDragSupportEx () {
}

@end

#define HOVER_THRESHOLD_TIME 0.5
#define HOVER_THRESHOLD_POINT 5

class HoverChecker {
private:
    MICRect _rcCheck;
    double _hoverStartTime;
    __weak id _hoveringOn;
    bool _done;

private:
    void reset(const CGPoint& touchPos) {
        _hoverStartTime = CFAbsoluteTimeGetCurrent();
        _rcCheck.setRect(touchPos.x-HOVER_THRESHOLD_POINT, touchPos.y-HOVER_THRESHOLD_POINT,
                         touchPos.x+HOVER_THRESHOLD_POINT, touchPos.y+HOVER_THRESHOLD_POINT);
        _done = false;
    }
    

public:
    HoverChecker() {
        clear();
    }
    
    void clear() {
        _hoveringOn = nil;
        _hoverStartTime = 0;
        _done = false;
    }
    
    bool hover(id hoveringOn, const CGPoint& touchPos) {
        if(hoveringOn != _hoveringOn) {
            // 新しいアイテムの上をホバー：reset
            _hoveringOn = hoveringOn;
            reset(touchPos);
        } else {
            if(!_rcCheck.ptInRect(touchPos)) {
                // 一定以上移動＝ドラッグして移動中
                reset(touchPos);
            } else if(!_done && CFAbsoluteTimeGetCurrent() - _hoverStartTime > HOVER_THRESHOLD_TIME ) {
                // hover!!
                _done = true;
                return true;
            } else {
                // nothing to do.
            }
        }
        return false;
    }
};

@implementation MICUiCellDragSupportEx {
    __weak MICTreeNode* _dragSrc;
    __weak MICTreeNode* _dragDst;
    MICTree* _layoutTree;
    HoverChecker _hoverChecker;
}

//------------------------------------------------------------------------------------------
#pragma mark - プロパティ

/**
 * ドラッグ先レイアウター
 */
- (id<MICUiDraggableLayoutProtocol>)dragDestination {
    return LAYOUT(_dragDst);
}

/**
 * ドラッグ元レイアウター
 */
- (id<MICUiDraggableLayoutProtocol>)dragSource {
    return LAYOUT(_dragSrc);
}

//
// このクラスでは使用しない親クラスのプロパティを潰す
//
//@property (nonatomic, weak) id<MICUiDraggableLayoutProtocol> layouter;
- (id<MICUiDraggableLayoutProtocol>)layouter {
    //[NSException raise:@"MICUiCellDragSupporetEx.layouter" format:@"forbidden property (getter)."];
    return LAYOUT(_dragDst);
}
- (void)setLayouter:(id<MICUiDraggableLayoutProtocol>)layouter {
    [NSException raise:@"MICUiCellDragSupporetEx.layouter" format:@"forbidden property (setter)."];
}
- (id<MICUiDraggableLayoutProtocol>)strongLayouter {
    [NSException raise:@"MICUiCellDragSupporetEx.strongLayouter" format:@"forbidden property (getter)."];
    return nil;
}
- (void)setStrongLayouter:(id<MICUiDraggableLayoutProtocol>)strongLayouter {
    [NSException raise:@"MICUiCellDragSupporetEx.strongLayouter" format:@"forbidden property (setter)."];
}
- (UIView *)containerView {
    return VIEW(_dragDst);
}
- (void)setContainerView:(UIView *)containerView {
    [NSException raise:@"MICUiCellDragSupporetEx.containerView" format:@"forbidden property (setter)."];
}

/**
 * レイアウターツリーのダンプを出力する。(for debug)
 */
- (void)dumpLayoutTree{
    [_layoutTree forEach:^bool(MICTreeNode *node) {
        MICStringBuffer sb;
        for(int depth = node.depth ; depth>0; depth--) {
            sb += @" - ";
        }
        NSLog(@"LayoutTree:%@%@",(NSString*)sb, [LAYOUT(node) description]);
        return false;
    }];
}


//------------------------------------------------------------------------------------------
#pragma mark - 初期化

/**
 * 初期化
 */
- (MICUiCellDragSupportEx*) init {
    self = [super init];
    if(nil!=self) {
        _layoutTree = [[MICTree alloc] init];
        _layoutTree.root = [[MICTreeNode alloc] init];
    }
    return self;
}

//------------------------------------------------------------------------------------------
#pragma mark - レイアウターノードの操作

/**
 * レイアウターが入れ子になっていて、すべてのレイアウターの共通のルートレイアウターが唯一つ存在する場合（例：MICUiAccordionViewのレイアウターなど）に、
 * そのルートレイアウターを登録する。
 */
- (id) addRootLayouter:(id<MICUiDraggableLayoutProtocol>)layouter andContainerView:(UIView*)view {
    if([view isKindOfClass:[UIScrollView class]]) {
        layouter.layoutDelegate = self;
    }
    _layoutTree.root.value = [[MICUiLayoutRec alloc] initWithLayouter:layouter andContainerView:view];
    return _layoutTree.root;
}

/**
 * 構成上の親を持つレイアウターを登録する。
 * また、ルートに複数のレイアウターを並列に並べる場合（例：カスタマイズのために、２つのビューを並べる）には、addRootLayouterメソッドは呼ばないで、
 * このメソッドの　parentNodeにnilを渡す。
 */
- (id) addSubLayouter:(id<MICUiDraggableLayoutProtocol>)layouter andContainerView:(UIView*)view toParentNode:(id)parentNode {
    if([view isKindOfClass:[UIScrollView class]]) {
        layouter.layoutDelegate = self;
    }

    id value = [[MICUiLayoutRec alloc] initWithLayouter:layouter andContainerView:view];
    if(nil==parentNode) {
        [_layoutTree.root addChild:[[MICTreeNode alloc] initWithValue:value]];
    } else {
        [(MICTreeNode*)parentNode addChild:[[MICTreeNode alloc] initWithValue:value]];
    }
    return value;
}

/**
 * layouterをキーに登録されているレウアウターツリーノードを探す。
 *  layouterとノードは１：１対応が前提。
 */
- (MICTreeNode*) findNode:(id<MICUiDraggableLayoutProtocol>)layouter {
    return [_layoutTree forEach:^bool(MICTreeNode *node) {
        if(nil!=node.value) {
            return LAYOUT(node) == layouter;
        }
        return false;
    }];
}

/**
 * childLayoutは、parentLayoutの子孫か？
 */
- (bool) isLayout:(id<MICUiDraggableLayoutProtocol>)childLayout descendantOf:(id<MICUiDraggableLayoutProtocol>)parentLayout {
    MICTreeNode* childNode = [self findNode:childLayout];
    MICTreeNode* parentNode = [self findNode:parentLayout];
    return [childNode isDescendantOf:parentNode];
}


//------------------------------------------------------------------------------------------
#pragma mark - D&Dによるカスタマイズ

/**
 * 保持するレイアウターのサイズ変更に合わせてスクロール領域を調整したり、D&Dによる自動スクロールを有効にする。
 */
- (void)enableScrollSupport:(BOOL)enable {
    [_layoutTree forEach:^bool(MICTreeNode *node) {
        if(nil!=node.value) {
            id<MICUiDraggableLayoutProtocol> layout = LAYOUT(node);
            if(enable) {
                layout.layoutDelegate = self;
            } else if(layout.layoutDelegate == self) {
                layout.layoutDelegate = nil;
            }
        }
        return false;
    }];
}

//--------------------------------------------------------------------------------------
#pragma mark - D&D操作

- (void)fireBeginCustomizingEvent {
    [_layoutTree forEachPostorder:^bool(MICTreeNode *node) {
        if(nil!=node.value) {
            id layout = LAYOUT(node);
            if([layout conformsToProtocol:@protocol(MICUiDraggableLayoutProtocol)]) {
                [layout onBeginCustomizing];
            }
        }
        return false;
    }];
}

- (void)fireEndCustomizingEvent {
    [_layoutTree forEachPostorder:^bool(MICTreeNode *node) {
        if(nil!=node.value) {
            id layout = LAYOUT(node);
            if([layout conformsToProtocol:@protocol(MICUiDraggableLayoutProtocol)]) {
                [layout onEndCustomizing];
            }
        }
        return false;
    }];
}

- (MICTreeNode*) findLayouterAtPoint:(CGPoint) point onFound:(bool(^)(MICTreeNode* found))onFound {
    MICViewRect vrc(_overlayView, point);
    return [_layoutTree forEachPostorder:^bool(MICTreeNode *node) {
        if(nil!=node.value) {
            id<MICUiLayoutProtocol> layout = LAYOUT(node);
            UIView* container = VIEW(node);
            CGPoint pos = vrc.getRectOnView(container);
            if(MICRect::containsPoint(container.bounds, pos)) {
                MICRect rcLayout = [layout getContentRect];
                if(rcLayout.containsPoint(pos)) {
                    if(nil!=onFound) {
                        return onFound(node);
                    }
                    return true;
                }
            }
        }
        return false;
    }];
}

/**
 * (PRIVATE) ドラッグ開始
 */
- (void) beginDrag:(UIGestureRecognizer*)sender {
    // ドラッグアイテムが裏に回らないよう、オーバーレイビューを最前面に持ち上げておく。
    [_overlayView.superview bringSubviewToFront:_overlayView];
    
    [self updateTouchPos:sender];
    [self setFirstTouchPosOnOverlay];

    [self findLayouterAtPoint:_touchPosOnOverlay onFound:^bool(MICTreeNode *found) {
        _dragSrc = _dragDst = found;
        [LAYOUT(found) beginDrag:self];
        return true;
//        if([LAYOUT(found) beginDrag:self]) {
//            return true;
//        }
//        _dragSrc = _dragDst = nil;
//        return false;
    }];
}

///**
// * レイアウターへのドロップが可能かどうか問い合わせる。
// */
//- (bool) queryDropTo:(id<MICUiDraggableLayoutProtocol>)layouter {
//    if(nil!=_dropAcceptorDelegate) {
//        return [_dropAcceptorDelegate canDropView:[self draggingView] toLayout:layouter fromLayout:[self dragSource]];
//    } else {
//        return [layouter canDrop:self];
//    }
//}
//
//- (void) notifyDragHover:(id<MICUiDraggableLayoutProtocol>)layouter {
//    if(nil!=_dropAcceptorDelegate) {
//        [_dropAcceptorDelegate onHoverView:[self draggingView] toLayout:layouter fromLayout:[self dragSource]];
//    } else {
//        [layouter dragHover:self];
//    }
//}

/**
 * (PRIVATE) 指定位置へドラッグ
 */
- (void) dragTo:(UIGestureRecognizer*)sender {
    if(nil!=sender) {
        [self updateTouchPos:sender];
        [self updateDepositedViewPos];
    }
    
    [self findLayouterAtPoint:_touchPosOnOverlay onFound:^bool(MICTreeNode *found) {
        if(found == _dragDst) {
            // 同一レイアウター内の移動なら、レイアウター内だけで判断できるはず。
            [LAYOUT(found) dragTo:self];
        } else if( [found isDescendantOf:_dragSrc] ) {
            // 親階層から子階層へのドロップは禁止
            //
            // ここで　false を返すことで、このレイアウターを含む親階層のレイアウターにドロップ処理が流す。
            // そうしないと、親階層のアイテムをドラッグするとき、子アイテム上でイベントが拾えなくなってしまう。
             return false;
        } else if( [LAYOUT(found) canDrop:self] ) {
            // レイアウター間の移動
            [LAYOUT(_dragDst) dragLeave:self];
            _dragDst = found;
            [LAYOUT(found) dragEnter:self];
            [LAYOUT(found) dragTo:self];
        } else {
            if(_hoverChecker.hover(found, _touchPosOnOverlay)) {
                [LAYOUT(found) dragHover:self];
            }
        }
        return true;
    }];
}

/**
 * (PRIVATE) ドラッグ終了（ドロップ）
 */
- (void) endDrag:(UIGestureRecognizer*) sender {

    [_layoutTree forEachPostorder:^bool(MICTreeNode *node) {
        if(nil!=node.value) {
            [LAYOUT(node) endDrag:self];
        }
        return false;
    }];
    _dragSrc = _dragDst = nil;
    _hoverChecker.clear();
}

/**
 * (PRIVATE) ドラッグキャンセル（ドラッグ開始前の状態に戻す）
 */
- (void) cancelDrag:(UIGestureRecognizer*) sender {
    [_layoutTree forEachPostorder:^bool(MICTreeNode *node) {
        if(nil!=node.value) {
            [LAYOUT(node) cancelDrag:self];
        }
        return false;
    }];
    _dragSrc = _dragDst = nil;
}

//--------------------------------------------------------------------------------------------
#pragma mark - MICUiLayoutDelegate プロトコル

/**
 * コンテントのサイズが変更になった。
 *  スクロール領域 (UIScrollView#contentSize)を更新する。
 */
- (void) onContentSizeChanged:(id) layout size:(CGSize)size {
    MICTreeNode* node = [self findNode:layout];
    if(nil==node) {
        [NSException raise:@"MICUiCellDragSupportEx:" format:@"node not exists."];
        return;
    }
    
    UIScrollView* sview = (UIScrollView*)VIEW(node);
    if( !CGSizeEqualToSize(sview.contentSize, size)) {
        CGSize currentSize = sview.frame.size;
        if(size.width < currentSize.width || size.height<currentSize.height) {
            // contentSizeがframeサイズより小さくなる時（スクロールが不要になり、contentOffsetがゼロに戻る時）だけ、アニメーション内で実行。
            // 常にそうしてもよいかもしれないが。
            [UIView animateWithDuration:0.3
                                  delay:0.1
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 sview.contentSize = size;
                             }
                             completion:nil];
        } else {
            sview.contentSize = size;
        }
        
    }
}

/**
 * 自動スクロール
 * 上位のコンテナすべてについて自動スクロールさせるために、オーバーライド
 */
- (void) autoScroll {
    for(MICTreeNode* node = _dragDst ; nil!=node ; node = node.parent) {
        UIView* v = VIEW(node);
        if([v isKindOfClass:UIScrollView.class]) {
            [self doAutoScroll:(UIScrollView*)v];
        }
    }
}

/**
 * 指定された矩形領域が画面内に入るようスクロールすることを要求
 */
- (void) ensureRectVisible:(id) layout rect:(CGRect)rect {
    MICRect r(rect);
    // NSLog(@"EnsureRectVisible.(%f,%f)-(%f,%f)", r.left(),r.top(), r.right(),r.bottom());

    MICTreeNode* child = [self findNode:layout];
    if(nil==child) {
        [NSException raise:@"MICUiCellDragSupportEx:" format:@"node not exists."];
        return;
    }
    
    UIScrollView* sview = (UIScrollView*)VIEW(child);
    [sview scrollRectToVisible:rect animated:true];

    MICTreeNode* ancestor = child.parent;
    while(nil!=ancestor && nil!=ancestor.value ) {
        UIView* aview = VIEW(ancestor);
        UIView* cview = VIEW(child);
        
        if(nil!=aview && [aview isKindOfClass:[UIScrollView class]]) {
            CGRect rc = [aview convertRect:cview.frame fromView:cview.superview];
            [(UIScrollView*)aview scrollRectToVisible:rc animated:true];
        }

        child = ancestor;
        ancestor = ancestor.parent;
    }
    
}

//--------------------------------------------------------------------------------------------
#pragma mark - MICUiDragEventArg プロトコル
/**
 * コンテナビュー（レイアウタが管理しているビュー）を取得
 */
- (UIView*) containerViewOf:(id<MICUiDraggableLayoutProtocol>)layout {
    MICTreeNode* node = [self findNode:layout];
    return VIEW(node);
}

/**
 * ココンテナビュー上でのタップ位置を取得
 */
- (CGPoint) touchPosOn:(id<MICUiDraggableLayoutProtocol>)layout {
    return [self touchPosOnView:[self containerViewOf:layout]];
}

/**
 * 指定されたレイアウター上でのタップ開始位置を取得
 */
- (CGPoint) firstTouchPosOn:(id<MICUiDraggableLayoutProtocol>)layout {
    return [self firstTouchPosOnView:[self containerViewOf:layout]];
}

/**
 * 預けているサブビューのコンテナ座標系でのフレーム矩形を取得
 */
- (CGRect) getViewFrameOn:(id<MICUiDraggableLayoutProtocol>)layout {
    UIView* container = [self containerViewOf:layout];
    return [container convertRect:_depositedView.frame fromView:_overlayView];
}

/**
 * 預けているサブビューのコンテナ座標系での矩形領域を指定して、オーバーレイ上での位置・サイズを変更
 */
- (void) setViewFrame: (CGRect) rect onLayout:(id<MICUiDraggableLayoutProtocol>)layout {
    UIView* container = [self containerViewOf:layout];
    _depositedView.frame = [container convertRect:rect toView:_overlayView];
}

@end
