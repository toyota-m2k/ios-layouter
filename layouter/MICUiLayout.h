//
//  MICUiLayout.h
//
//  レイアウター共通の定義
//
//  Created by @toyota-m2k on 2014/10/23.
//  Copyright (c) 2014年 @toyota-m2k. All rights reserved.
//
#include <UIKit/UIKit.h>

//-------------------------------------------------------------------------------------------
#pragma mark - 定数定義

/**
 * レイアウトの方向
 */
typedef enum _micUiOrientation {
    MICUiVertical = 1,   ///< 縦
    MICUiHorizontal = 2, ///< 横
} MICUiOrientation;
#define MICUiOrientationBOTH  (MICUiVertical|MICUiHorizontal)

/**
 * アラインメント
 */
typedef enum _micUiAlign {
    MICUiAlignTOP = 1,              // 左 or 上
    MICUiAlignCENTER = 2,           // 中央
    MICUiAlignBOTTOM = 3,           // 右 or 下
} MICUiAlign;

// 横向き用エイリアス
#define MICUiAlignLEFT      MICUiAlignTOP
#define MICUiAlignRIGHT     MICUiAlignBOTTOM
// 無効値
#define MICUiAlignINVALID   0

/**
 * アラインメント（FILL入り）
 */
typedef enum _micUiAlignEx {
    MICUiAlignExTOP = 1,              // 左 or 上
    MICUiAlignExCENTER = 2,           // 中央
    MICUiAlignExBOTTOM = 3,           // 右 or 下
    MICUiAlignExFILL = 4,             // 領域いっぱいに拡大/縮小
} MICUiAlignEx;
// 横向き用エイリアス
#define MICUiAlignExLEFT      MICUiAlignExTOP
#define MICUiAlignExRIGHT     MICUiAlignExBOTTOM

// 無効値
#define MICUiAlignExINVALID   0

/**
 * 位置指定
 */
typedef enum _micUiPos {
    MICUiPosLEFT    = 1,          // 左
    MICUiPosTOP     = 2,          // 左 or 上
    MICUiPosRIGHT   = 4,          // 右 or 下
    MICUiPosBOTTOM  = 8,          // 右 or 下
} MICUiPos;

/**
 * 頂点指定
 */
typedef enum _micUiEdge {
    MICUiEdgeLT,                    // 左上
    MICUiEdgeRT,
    MICUIEdgeLB,
    MICUIEdgeRB,
}MICUiEdge;

/**
 * 位置指定（拡張版）
 */
typedef enum _micUiPosEx {
    // １辺
    MICUiPosExLEFT = MICUiPosLEFT,
    MICUiPosExTOP  = MICUiPosTOP,
    MICUiPosExRIGHT = MICUiPosRIGHT,
    MICUiPosExBOTTOM = MICUiPosBOTTOM,
    
    // 2辺
    MICUiPosExVERT = MICUiPosLEFT|MICUiPosRIGHT,
    MICUiPosExHORZ = MICUiPosTOP|MICUiPosBOTTOM,
    
    MICUiPosExLT = MICUiPosLEFT|MICUiPosTOP,                    // 左上
    MICUiPosExRT = MICUiPosRIGHT|MICUiPosTOP,
    MICUIPosExLB = MICUiPosLEFT|MICUiPosBOTTOM,
    MICUIPosExRB = MICUiPosRIGHT|MICUiPosBOTTOM,

    // ３辺
    MICUiPosExUPPER = MICUiPosLEFT|MICUiPosTOP|MICUiPosRIGHT,
    MICUiPosExLOWER = MICUiPosLEFT|MICUiPosBOTTOM|MICUiPosRIGHT,
    MICUiPosExLEFTSIDE = MICUiPosTOP|MICUiPosLEFT|MICUiPosBOTTOM,
    MICUiPosExRIGHTSIDE = MICUiPosTOP|MICUiPosRIGHT|MICUiPosBOTTOM,
    
    // All
    MICUiPosExALL = MICUiPosLEFT|MICUiPosTOP|MICUiPosRIGHT|MICUiPosBOTTOM,
} MICUiPosEx;

/**
 * 充填方向
 */
typedef enum _mmyUiGravity {
    MICUiGravityTOP,                // 上/右右寄せ
    MICUiGravityCENTER,             // 中央寄せ
    MICUiGravityBOTTOM,             // 下/右寄せ
}MICUiGravity;
// 横向き用エイリアス
#define MICUiGravityLEFT      MICUiGravityTOP
#define MICUiGravityRIGHT     MICUiGravityBOTTOM

/**
 */

#define MICUI_DEFAULT_ANIM_DURATION     0.15

//-------------------------------------------------------------------------------------------
#pragma mark - レイアウタのイベント

/**
 * レイアウター共通のイベントハンドラ用プロトコル
 * デフォルトの動作は、MICUiGridCellDragSuportクラスに実装。
 */
@protocol MICUiLayoutDelegate

    /**
     * コンテントのサイズが変更になった。
     *  スクロール領域 (UIScrollView#contentSize)を更新する。
     *  @param  layout  レイアウター
     *  @param  size    マージンを含むコンテント領域のサイズ
     */
    - (void) onContentSizeChanged:(id) layout size:(CGSize)size;

    /**
     * 指定された矩形領域が画面内に入るようスクロールすることを要求
     *  @param  layout  要求元のレイアウター
     *  @param  rect    領域指定（コンテナ（＝セルの親）：通常はUIScrollView)の座標系での領域）
     */
    - (void) ensureRectVisible:(id) layout rect:(CGRect)rect;

@end

// 前方参照
@protocol MICUiDraggableLayoutProtocol;
@protocol MICUiDropAcceptorDelegate;


//-------------------------------------------------------------------------------------------
#pragma mark - D&Dイベント情報クラス

/**
 * イベント情報クラス
 */
@protocol MICUiDragEventArg

    /**
     * ドラッグ用オーバーレイビュー
     */
    @property (nonatomic, readonly) UIView* overlayView;

    /**
     * オーバーレイビュー上でのタップ位置
     */
    @property (nonatomic, readonly) CGPoint touchPosOnOverlay;

    /**
     * ドラッグ元レイアウター
     */
    @property (nonatomic, readonly) id<MICUiDraggableLayoutProtocol> dragSource;

    /**
     * ドラッグ先レイアウター
     */
    @property (nonatomic, readonly) id<MICUiDraggableLayoutProtocol> dragDestination;
    /**
     * ドラッグ中のビュー
     */
    @property (nonatomic,readonly) UIView* draggingView;

    /**
     * ドラッグ中のセル
     */
    @property (nonatomic) id draggingCell;

    /**
     * コンテナビュー（レイアウタが管理しているビュー）を取得
     */
    - (UIView*) containerViewOf:(id<MICUiDraggableLayoutProtocol>)layout;

    /**
     * ココンテナビュー上でのタップ位置を取得
     */
    - (CGPoint) touchPosOn:(id<MICUiDraggableLayoutProtocol>)layout;

    /**
     * 指定されたレイアウター上でのタップ開始位置を取得
     */
    - (CGPoint) firstTouchPosOn:(id<MICUiDraggableLayoutProtocol>)layout;

    /**
     * view引数で指定されたビュー上でのタップ位置を取得
     */
    - (CGPoint) touchPosOnView:(UIView*) view;

    /**
     * view引数で指定されたビュー上でのタップ位置を取得
     */
    - (CGPoint) firstTouchPosOnView:(UIView*) view;

    /**
     * コンテナ上のサブビューをオーバーレイビューに預ける。
     */
    - (BOOL) depositView: (UIView*) view;

    /**
     * 預けていたサブビューを取り戻す。
     * @param backToContainer   true:コンテナビューに戻す。/ false:オーバーレイビューからremoveするだけ。
     * @return 預けていたサブビュー
     */
    - (UIView*) bringBack: (BOOL)backToContainer ofLayout:(id<MICUiDraggableLayoutProtocol>)layout;

    /**
     * 預けているサブビューのコンテナ座標系でのフレーム矩形を取得
     */
    - (CGRect) getViewFrameOn:(id<MICUiDraggableLayoutProtocol>)layout;

//    /**
//     * 預けているサブビューのコンテナ座標系での中心座標を取得
//     */
//    - (CGPoint) getViewCenterOn:(id<MICUiDraggableLayoutProtocol>)layout;

    /**
     * 預けているサブビューのコンテナ座標系での矩形領域を指定して、オーバーレイ上での位置・サイズを変更
     */
    - (void) setViewFrame: (CGRect) rect onLayout:(id<MICUiDraggableLayoutProtocol>)layout;

//    /**
//     * 預けているサブビューのコンテナ座標系での中心座標を指定して、オーバーレイ上での位置を変更
//     */
//    - (void) setViewCenter: (CGPoint)point onLayout:(id<MICUiDraggableLayoutProtocol>)layout;

@end

//-------------------------------------------------------------------------------------------
#pragma mark - レイアウターのプロトタイプ
@protocol MICUiLayoutProtocol<NSObject>

    // マージン
    @property (nonatomic) UIEdgeInsets margin;                  ///< グリッドレイアウター全体のマージン
    @property (nonatomic) CGFloat marginLeft;                   ///< グリッドレイアウター全体のマージン（左）
    @property (nonatomic) CGFloat marginRight;                  ///< グリッドレイアウター全体のマージン（右）
    @property (nonatomic) CGFloat marginTop;                    ///< グリッドレイアウター全体のマージン（上）
    @property (nonatomic) CGFloat marginBottom;                 ///< グリッドレイアウター全体のマージン（下）

    // ヒント
    @property (nonatomic,weak) UIView* parentView;              ///< 親ビュー（nil可：nilなら、add/insert/removeChildのときに、親ビューとの接続関係を変更しない）
    //@property (nonatomic,readonly) NSArray* childViews;       ///< 子ビューの配列
    @property (nonatomic,readonly) int childCount;              ///< 子ビューの数
    @property (nonatomic) CGFloat animDuration;                 ///< セル移動アニメーションのduration

    /**
     * レイアウター の表示サイズを取得する。
     * @return マージンを含むレイアウター全体のサイズ（スクロール領域の計算に使用することを想定）
     */
    - (CGSize) getSize;

    /**
     * レイアウターのマージンを除く、正味のコンテント領域の領域を取得する。
     *
     * @return  コンテナビュー座標系（bounds内）での矩形領域（ヒットテストなどに利用されることを想定）。
     */
    - (CGRect) getContentRect;

    /**
     * セルを再配置して、ビューを更新する。
     */
    - (BOOL) updateLayout:(BOOL)animation onCompleted:(void (^)(BOOL)) onCompleted;


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

    /**
     * needsRecalcLayout フラグを立てる
     */
    - (void) requestRecalcLayout;

    /**
     * レイアウターにセル（ビュー）を追加する
     * このメソッドでは表示は更新されない。表示を更新する場合はupdateLayoutメソッドを呼ぶこと。
     *
     * @param view 追加するビュー
     */
    - (void) addChild:(UIView*)view;

    /**
     * レイアウターの指定位置にセルを挿入する。
     * このメソッドでは表示は更新されない。表示を更新する場合はupdateLayoutメソッドを呼ぶこと。
     *
     * @param view 追加（挿入）するビュー
     * @param siblingView 挿入位置のビュー（このビューの位置＝このビューの１つ前に挿入する）: nil なら末尾（＝＝addChild)
     */
    - (void) insertChild:(UIView*)view
                  before:(UIView*)siblingView;

    /**
     * セルを削除する。
     * このメソッドでは表示は更新されない。表示を更新する場合はupdateLayoutメソッドを呼ぶこと。
     */
    - (void) removeChild:(UIView*)child;

    /**
     * すべてのセルを削除する。
     * このメソッドでは表示は更新されない。表示を更新する場合はupdateLayoutメソッドを呼ぶこと。
     */
    - (void) removeAllChildren;

    /**
     * viewを子要素に持っているか？
     */
    - (bool) containsChild:(UIView*)view;

    /**
     * 子ビューのインデックスを取得
     * @return 子ビューのインデックス（子でなければ　−１）
     */
    - (int) indexOfChild:(UIView*)view;

    /**
     * 指定されたインデックスの子ビューを取得する。
     */
    - (UIView*) childAt:(int)index;

    /**
     * ビューを検索
     */
    - (UIView*) findView:(bool (^)(UIView* view))matcher;

@end

//-------------------------------------------------------------------------------------------
#pragma mark - セルのD&Dをサポートするレイアウターのプロトタイプ

@protocol MICUiDraggableLayoutProtocol <MICUiLayoutProtocol>

    // 状態・状態監視
    @property (nonatomic,readonly) BOOL dragging;                                               ///< ドラッグ中か？
    @property (nonatomic,weak) id<MICUiLayoutDelegate> layoutDelegate;                          ///< イベントリスナー
    @property (nonatomic,weak) id<MICUiDropAcceptorDelegate> dropAcceptorDelegate;          ///< D&D操作制限用デリゲート
    @property (nonatomic,readonly) int draggableOrientation;                                    ///< ドラッグ可能な方向      Vertical | Horizontal | Both

    /**
     * D&Dによるカスタマイズを開始するときに呼び出される。
     *  このタイミングで、このセルビューに対するタップやドラッグなどのユーザ操作を無効化する。
     */
    - (void) onBeginCustomizing;

    /**
     * D&Dによるカスタマイズを終了するときに呼び出される。
     *  onBeginCustomizingで行った変更を元に戻す。
     */
    - (void) onEndCustomizing;

    /**
     * ドラッグを開始する。
     *
     * @param eventArg  コンテナビュー座標でのタップ位置など
     * @return true:ドラッグを開始した　/ false:ドラッグは開始していない。
     */
    - (BOOL)beginDrag:(id<MICUiDragEventArg>) eventArg;

    /**
     * 指定位置へドラッグする。
     *
     * @param eventArg  コンテナビュー座標でのドラッグ位置など
     */
    - (void)dragTo:(id<MICUiDragEventArg>) eventArg;

    /**
     * ドラッグ終了（ドロップ）
     */
    - (void)endDrag:(id<MICUiDragEventArg>) eventArg;

    /**
     * ドラッグ操作をキャンセルして、ドラッグ開始時の状態に戻す。
     */
    - (void)cancelDrag:(id<MICUiDragEventArg>) eventArg;

    /**
     * レイアウターにドロップは可能か？
     */
    - (BOOL) canDrop:(id<MICUiDragEventArg>) eventArg;

    /**
     * canDropがfalseを返したあと、一定時間、ドラッグが止まるとhoverが呼ばれる。
     */
    - (void) dragHover:(id<MICUiDragEventArg>) eventArg;

    /**
     * アイテムがレイアウターからドラッグされてレイアウター外に持ちだされる
     */
    - (void) dragLeave:(id<MICUiDragEventArg>) eventArg;

    /**
     * アイテムがレイアウター外からドラッグされて、レイアウター内に持ち込まれる。
     */
    - (void) dragEnter:(id<MICUiDragEventArg>) eventArg;

@end

//-------------------------------------------------------------------------------------------
#pragma mark - ドラッグされるセルビューへの通知イベント

@protocol MICUiDraggableCellProtocol<NSObject>

    /**
     * D&Dによるカスタマイズを開始するときに呼び出される。
     *  このタイミングで、このセルビューに対するタップやドラッグなどのユーザ操作を無効化する。
     *
     * @param layout    呼び出し元レイアウター
     */
    - (void) onBeginCustomizing:(id<MICUiDraggableLayoutProtocol>)layout;

    /**
     * D&Dによるカスタマイズを終了するときに呼び出される。
     *  onBeginCustomizingで行った変更を元に戻す。
     *
     * @param layout    呼び出し元レイアウター
     */
    - (void) onEndCustomizing:(id<MICUiDraggableLayoutProtocol>)layout;

    /**
     * このセルビューのD&Dが開始されるタイミングで呼び出される。
     * onBeginCustomizing〜onEndCustomizingの間に、0回以上呼び出される。
     *
     *  必要に応じて、セルの表示更新・形状変更などを行う。
     *
     * @param layout    呼び出し元レイアウター
     * @return true: ドラッグ開始可　／ false:ドラッグ開始拒否
     */
    - (BOOL) onBeginDragging:(id<MICUiDraggableLayoutProtocol>)layout;


    /**
     * このセルビューに対するD&Dが完了したタイミングで呼び出される。
     *
     * @param layout    呼び出し元レイアウター
     * @param done      true:確定 / false:キャンセル
     */
    - (void) onEndDragging:(id<MICUiDraggableLayoutProtocol>)layout done:(BOOL)done;


@optional
    - (CGVector) getTrackingPointBasedOnCenter:(id<MICUiDraggableLayoutProtocol>)layout;

@end

//-------------------------------------------------------------------------------------------
#pragma mark - ビューの自動サイズ調整用プロトコル

/**
 * 自動的なサイズ変更を受け入れるコンテナ（レイアウター、ビュー）がサポートすべきプロトコル
 */
@protocol MICUiSizeDeterminableProtocol<NSObject>

    /**
     * コンテントを表示するために必要な最小サイズを計算する。
     */
    - (CGSize) calcMinSizeOfContents;

@end

//-------------------------------------------------------------------------------------------
#pragma mark - D&Dサポータープロトコル
/**
 * D&Dサポータークラス(MICUiCellDragSupport/MICUiCellDragSupportEx)が実装するプロトコル
 */
@protocol MICUiDragSupporter<NSObject>
    @property (nonatomic,weak) UIView* baseView;                                        ///< ドラッグ可能な領域をすべて含むビュー（このビューの子ビューとして、overlayViewを作成する。）
    @property (nonatomic,readonly) BOOL isCustomizing;                                  ///< true: カスタマイズ中（D&DモードON）
//    @property (nonatomic,weak) id<MICUiDropAcceptorDelegate> dropAcceptorDelegate;  ///< D&D操作制限用デリゲート
    @property (nonatomic) NSValue* baseRect;                    ///< オーバーレイビューの矩形領域（nilならcontainerViewと同じサイズで作成）
    @property (nonatomic) CGRect overlayRect;                   ///< baseRectがnilなら、containerView.frame、nilでなければ、その値を返す。


    /**
     * コンテナビューとしてUIScrollView派生クラスを使用する場合に、
     * レイアウターのサイズ変更に合わせてスクロール領域を調整したり、D&Dによる自動スクロールを有効にする。
     * 早い話、layouterのdelegateに、このサポーターを設定する。
     *
     *  @param  enable  true:有効化　/ false: 無効化
     */
    - (void) enableScrollSupport:(BOOL)enable;


    /**
     * 長押しによるカスタマイズ開始、タップによるカスタマイズ終了を有効化・無効化する。
     * 事前に、layouter(or strongLayouter)、containerViewプロパティに有効な値を設定しておく必要がある。
     *
     * @param longPress             true: 長押しで、カスタマイズ（D&D)モードへの移行を有効化
     * @param tap                   true: 画面タップで、カスタマイズモード終了を有効化
     */
    - (void) beginCustomizingWithLongPress:(BOOL)longPress
                                endWithTap:(BOOL)tap;


    /**
     * カスタマイズ（D&Dモード）を開始する。
     */
    - (void) beginCustomizing;

    /**
     * カスタマイズ（D&Dモード）を終了する。
     */
    - (void) endCustomizing;

    /**
     * (PRIVATE) ドラッグ処理（パンとロングプレスの共通処理）
     *  ※内部利用限定
     */
    - (void)doDrag:(UIGestureRecognizer*)sender;

@end

//-------------------------------------------------------------------------------------------
#pragma mark - セルのドロップ受容体（←なんかかっちょいい）用デリゲート

@protocol MICUiDropAcceptorDelegate <NSObject>

    /**
     * srcLayoutからドラッグされたビュー(draggingView)は、dstLayoutにドロップ可能か？
     *  @param  draggingView    ドラッグ中のビュー
     *  @param  srcLayout       ドラッグ中のビューの出処のレイアウト
     *  @param  dstLayout       ドロップされようとしているレイアウター
     *  @param  underlaidView   draggingViewの直下にあるdstLayer内のビュー
     *  @return true:ドロップ可能　/ false:ドロップ不可
     */
    - (BOOL) canDropView:(UIView*)draggingView
              fromLayout:(id<MICUiDraggableLayoutProtocol>)srcLayout
                toLayout:(id<MICUiDraggableLayoutProtocol>)dstLayout
                  onView:(UIView*)underlaidView;


    /**
     * canDropLayoutがfalseを返した場合で、かつ、その後、未練がましく、そのレイアウト上で止まっている場合に呼び出される。
     *  @param  draggingView    ドラッグ中のビュー
     *  @param  srcLayout       ドラッグ中のビューの出処のレイアウト
     *  @param  dstLayout       ホバーされているレイアウター
     *  @param  underlaidView   draggingViewの直下にあるdstLayer内のビュー
     */
    - (void) onHoverView:(UIView*)draggingView
              fromLayout:(id<MICUiDraggableLayoutProtocol>)srcLayout
                toLayout:(id<MICUiDraggableLayoutProtocol>)dstLayout
                  onView:(UIView*)underlaidView;

@end





