//
//  MICUiBaseLayout.h
//
//  レイアウターの基底クラス
//
//  Created by 豊田 光樹 on 2014/11/10.
//  Copyright (c) 2014年 豊田 光樹. All rights reserved.
//

#import <UIKit/UiKit.h>
#import "MICUiLayout.h"

//---------------------------------------------------------------------------------------------------
#pragma mark - セル情報基底クラス

/**
 * セル情報基底クラス
 */
@interface MICUiLayoutCell : NSObject {
    __weak UIView*  _view;
    BOOL _dragging;
    CGSize _orgViewSize;
    CGRect _reservedLocation;
}

@property (nonatomic, weak, readonly) UIView* view;     ///< セルに配置するビュー
@property (nonatomic, readonly) BOOL draggable;         ///< ドラッグ操作の可否
@property (nonatomic, readonly) BOOL dragging;          ///< ドラッグ操作中か？
@property (nonatomic) CGSize orgViewSize;               ///< レイアウターが変更する前のサイズ（レイアウターから持ち出すときのサイズ）
@property (nonatomic, readonly) BOOL isLocationReserved;    ///< 位置／サイズは予約済み（レイアウターによる移動・リサイズ禁止）か？

/**
 * 初期化
 */
- (MICUiLayoutCell*)init;

/**
 * 初期化
 */
- (MICUiLayoutCell*)initWithView:(UIView*)view;

/**
 * セルをドラッグ中状態へ移行する。
 *  @return true:移行した　/ false:セルは移動禁止
 */
- (BOOL) beginDrag;

/**
 * ドラッグ状態のセルを通常状態に戻す。
 *  @return true:移行した　/ false:もともとセルはドラッグされていなかった。
 */
- (BOOL) endDrag;

- (void) reserveLocation:(CGRect)location;

- (void) cancelLocationReservation;


@end

//---------------------------------------------------------------------------------------------------
#pragma mark - ドラッグ情報基底クラス（MICUiCellDraggingInfo）
/**
 * ドラッグの状態
 */
typedef enum _InterLayoutDragState {
    DRAG_DOMESTIC,          ///< 同一レイアウト内のドラッグ
    DRAG_OUTGOING,          ///< レイアウトから持ちだされる（ソース側レイアウト）
    DRAG_INCOMING,          ///< レイアウトに持ち込まれる（ディスティネーション側レイアウト）
} InterLayoutDragState;


/**
 * ドラッグ情報基底クラス
 */
@interface MICUiCellDraggingInfo : NSObject {
@protected
    InterLayoutDragState _dragState;                                ///< ドラッグの状態
    MICUiLayoutCell* _draggingCell;
    __weak NSMutableArray* _masterChildren;                         ///< レイアウターが管理している子リスト（マスター）
    __weak id<MICUiDragEventArg> _eventArgs;
    int _orgIndex;
    int _currentIndex;
    CGRect _prevVisibleRect;
}

@property (nonatomic) MICUiLayoutCell* draggingCell;                ///< ドラッグ中のアイテム（外部からドラッグされたセルは、このフィールドにしか保持しない期間があるので、weakは不可）
@property (nonatomic,weak) id<MICUiDragEventArg> eventArgs;         ///< タッチイベントの情報
@property (nonatomic) int orgIndex;                                 ///< ドラッグ操作開始時点でのドラッグアイテムのインデックス
@property (nonatomic) int currentIndex;                             ///< ドラッグされているセルの挿入位置
@property (nonatomic) CGRect prevVisibleRect;                       ///< 前回ensureRectVisibleした矩形

@property (nonatomic,readonly) bool isIncoming;                     ///< 外部レイアウターから持ち込まれようとしているか？
@property (nonatomic,readonly) bool isOutgoing;                     ///< 外部レイアウターへ持ちだそうとしているか？
@property (nonatomic,readonly) bool isDomestic;                     ///< レイアウター内部でのD&Dか？

/**
 * オブジェクト生成
 */
- (MICUiCellDraggingInfo *)initWithCell:(MICUiLayoutCell*)cell
                          originalIndex:(int)index
                               children:(NSMutableArray*) children;

@end

//---------------------------------------------------------------------------------------------------
#pragma mark - レイアウターの基底クラス（MICUiBaseLayout）

/**
 * レイアウターの基底クラス
 */
@interface MICUiBaseLayout : NSObject<MICUiDraggableLayoutProtocol> {
@protected
    NSMutableArray* _children;                              ///< 子ビューの配列
    bool _needsRecalcLayout;                                ///< セル配置の再計算が必要ならtrue
    bool _contentSizeChanged;                               ///< calcLayoutでレイアウターのサイズが変化した時にセットされるダーティフラグ
    MICUiCellDraggingInfo* _draggingInfo;                   ///< ドラッグ情報
    NSTimer* _scrollingTimer;                               ///< ドラッグ中のスクロールを監視するためのタイマー
    __weak UIView* _parentView;                             ///< 親ビュー（nil可：nilなら、add/insert/removeChildのときに、親ビューとの接続関係を変更しない）
    
    CGFloat _marginLeft;
    CGFloat _marginTop;
    CGFloat _marginRight;
    CGFloat _marginBottom;
    CGFloat _animDuration;

    __weak id<MICUiLayoutDelegate> _layoutDelegate;         ///< イベントリスナー
    NSString* _name;                                        ///< for debug
}

@property (nonatomic) NSString* name;
@property (nonatomic,readonly) NSArray* children;

/**
 * レイアウターから持ち出すときのビューサイズを設定する。
 */
- (void)setOrgSize:(CGSize)size ofChild:(UIView*)child;

/**
 * （PROTECTED) セルを指定位置に挿入する
 */
- (void) insertCell:(MICUiLayoutCell*)cell atIndex:(int)idx;

/**
 * (PROTECTED) セルのインデクス
 */
- (int) indexOfCell : (MICUiLayoutCell*)cell;

/**
 * (PROTECTED) 指定インデックスのセルを取得
 */
- (MICUiLayoutCell*) cellAt:(int)idx;

/**
 * (PROTECTED) Viewを保持するセルを取得
 */
- (MICUiLayoutCell*) findCell:(UIView*)view;

/**
 * セルの位置・サイズを固定する
 */
- (void) reserveCell:(UIView *)view toLocation:(CGRect)frame;

/**
 * セルの位置・サイズ固定を解除する。
 */
- (void) cancelCellLocationReservation:(UIView *)view;

/**
 * １つのセルの位置・サイズを固定して、再配置を実行。
 *  AccordionCellViewのような、伸び縮みするビューで、それ自身がアニメーションするときに、レイアウターのアニメーションと同時に実行させるために使用する。
 *
 *  @param  view        固定するビュー
 *  @param  location    固定するビューの位置・サイズ
 *  @param  anim        アニメーションするかどうか
 *  @param  onCompleted アニメーション完了時のコールバック
 */
- (void)updateLayoutWithReservingCell:(UIView *)view atLocation:(CGRect)location animated:(BOOL)anim onCompleted:(void (^)(BOOL)) onCompleted;

//---------------------------------------------------------------------------------------------------
#pragma mark - サブクラスでオーバーライドが必要なメソッド

/**
 * (PROTECTED, ABSTRACT) レイアウターの表示サイズを取得する。
 * @return マージンを含むレイアウター全体のサイズ（スクロール領域の計算に使用することを想定）
 */
- (CGSize) getSize;

/**
 * (PROTECTED, ABSTRACT) レイアウターのマージンを除く、正味のコンテント領域の領域を取得する。
 *
 * @return  コンテナビュー座標系（bounds内）での矩形領域（ヒットテストなどに利用されることを想定）。
 */
- (CGRect) getContentRect;

/**
 * (PROTECTED, ABSTRACT) セル情報インスタンスを生成する。
 */
- (MICUiLayoutCell*)createCell:(UIView*)view;

/**
 * (PROTECTED, ABSTRACT) セル配置の再計算
 */
- (void) calcLayout;

/**
 * (PROTECTED, ABSTRACT) セルの位置・サイズの計算値を取得する
 */
- (CGRect) getCellRect:(MICUiLayoutCell*)cell;

/**
 * (PROTECTED, ABSTRACT) 指定された座標位置のセルを取得する。
 */
- (MICUiLayoutCell*) hitTestAtX:(CGFloat)x andY:(CGFloat)y;

/**
 * (PROTECTED, ABSTRACT) ドラッグ情報クラスのインスタンスを作成する。
 */
- (MICUiCellDraggingInfo*) createCellDraggingInfo:(MICUiLayoutCell*) cell  event:(id<MICUiDragEventArg>) eventArg;

/**
 * (PROTECTED, ABSTRACT) ドラッグ前の状態に戻す
 */
- (BOOL) resetDrag:(id<MICUiDragEventArg>) eventArg;

/**
 * (PROTECTED, ABSTRACT) ドラッグ操作の実行
 */
- (BOOL) doDrag:(id<MICUiDragEventArg>) eventArg;

/**
 * (PROTECTED) セルが画面内に入るようスクロールする。
 */
- (void) ensureCellVisible:(MICUiLayoutCell*)cell;
@end
