//
//  MICUiCellDragSupport.h
//
//  １つのビューの中だけでD&Dするドラッグサポータークラス
//
//  Created by 豊田 光樹 on 2014/10/23.
//  Copyright (c) 2014年 豊田 光樹. All rights reserved.
//

#import "MICUiLayout.h"
#import "MICUiCellDragHandler.h"

/**
 * MICUiCellDragSupport.h クラス
 *
 * レイアウター上でのセルのD&Dによる移動をサポートのためのイベント処理を実装するクラス。
 * 特にコンテナになるビューが　UIScrollView の場合は、ドラッグ中のスクロールや、
 * レイアウト実行時のスクロール領域（ContentSize）の調整などもサポートする。
 */
@interface MICUiCellDragSupport : NSObject <MICUiDragSupporter, MICUiLayoutDelegate, MICUiDragEventArg> {
    // プロトコルで宣言されている公開プロパティの中の人
    BOOL _isCustomizing;
    UIView* _overlayView;
    UIView* _depositedView;
    CGPoint _touchPosOnOverlay;
    CGPoint _firstTouchPosOnOverlay;
    id _draggingCell;
//    __weak id<MICUiDropAcceptorDelegate> _dropAcceptorDelegate;
    __weak UIView* _baseView;
    NSValue* _baseRect;

    // @protected:
    MICUiCellDragHandler*   _handlers;
}

// 公開プロパティ
@property (nonatomic,weak) UIView* containerView;           ///< セルのコンテナ（Exではドラッグ中のみ有効）
@property (nonatomic,weak) id<MICUiDraggableLayoutProtocol> layouter;
@property (nonatomic, strong) id<MICUiDraggableLayoutProtocol> strongLayouter;      // このクラスにレイアウターを保持させる場合はこちらのプロパティを使用。
@property (nonatomic) CGFloat scrollAcceleration;           ///< スクロールの加速       0:加速なし　〜　大きいほど加速大（デフォルト30）
@property (nonatomic) CGFloat scrollSpeed;                  ///< スクロールの基準速度   1〜    大きいほど速い（デフォルト2）

/**
 * 初期化
 */
- (MICUiCellDragSupport*) init;

/**
 * @protected   メンバに保持しているタッチ位置を更新する。
 */
- (void) updateTouchPos:(UIGestureRecognizer*) sender;

/**
 * オーバーレイビュー上で最初にタップされた位置を取り出してフィールドに設定する。
 */
- (void) setFirstTouchPosOnOverlay;

/**
 * @protected ドラッグしているビューの位置を更新する
 */
- (void) updateDepositedViewPos;

/**
 * ドラッグ中の自動スクロール
 */
- (void) doAutoScroll:(UIScrollView*)sv;

- (void) fireBeginCustomizingEvent;
- (void) fireEndCustomizingEvent;

@end

