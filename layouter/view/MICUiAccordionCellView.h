//
//  MICUiAccordionCellView.h
//
//  ラベルタップで折りたたみ可能なビュー
//
//  Created by @toyota-m2k on 2014/10/29.
//  Copyright (c) 2014年 @toyota-m2k. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MICUiLayout.h"

#define MICUI_ACCORDIONCELLVIEW_ANIM_DURATION MICUI_DEFAULT_ANIM_DURATION

@class MICUiAccordionCellView;

/**
 * アコーディオンセルの開閉イベント通知用プロトコル
 */
@protocol MICUiAccordionCellDelegate<NSObject>

/**
 * アコーディオンの開閉操作が実行される前に呼び出される。
 *  @param sender   呼び出し元アコーディオン
 *  @param folded   true:折りたたまれる　/ false:展開される
 *  @param frame    操作完了後のフレーム矩形
 */
- (void) accordionCellFolding:(MICUiAccordionCellView*)sender fold:(BOOL)folded lastFrame:(CGRect)frame;
/**
 * アコーディオンの開閉操作が実行された後に呼び出される。
 *  @param sender   呼び出し元アコーディオン
 *  @param folded   true:折りたたまれた　/ false:展開された
 *  @param frame    操作完了後のフレーム矩形
 */
- (void) accordionCellFolded:(MICUiAccordionCellView*)sender fold:(BOOL)folded lastFrame:(CGRect)frame;

@end

/**
 * アコーディオンセルにレイアウターを内包するためのデリゲート
 */
@protocol MICUiAccordionCellLayoutDelegate<MICUiAccordionCellDelegate>

/**
 * レイアウターを内包している場合(setBodyLayoutを使用している場合）に、レイアウターのサイズが更新されたときに通知される。
 * 必要なら親側でアコーディオンセルのサイズ調整を行うこと。
 *  @param sender   呼び出し元アコーディオン
 *  @param size     変更後のアコーディオンセルサイズ（Labelも含む）
 */

- (void) accordionCellContentsSizeChanged:(MICUiAccordionCellView*)sender toSize:(CGSize)size;

/**
 * レイアウターを内包している場合(setBodyLayoutを使用している場合）に、指定された領域を画面内に表示するようスクロール要求する。
 *  @param sender   呼び出し元アコーディオンセル
 *  @param rect     表示する領域（アコーディオンセル（＝sender）クライアント座標系）
 */
- (void) ensureRectVisible:(MICUiAccordionCellView*)sender ofRect:(CGRect)rect;

@end

/**
 * アコーディオンセル
 */
@interface MICUiAccordionCellView : UIView <MICUiLayoutDelegate,MICUiSizeDeterminableProtocol,MICUiDraggableCellProtocol> {
    
}

@property (nonatomic) int labelPos;                             ///< ラベルビューの位置（上下左右:MICUiPosXXXXの組み合わせ）
@property (nonatomic) MICUiOrientation orientation;             ///< 伸び縮みの方向（ラベルビューの位置によって決まる：上下→Vertical ／ 左右→Horizontal）
@property (nonatomic) bool rotateRight;                         ///< orientation == Horizontalのとき、ラベルビューを　true:90度右回転 / false:左回転
@property (nonatomic,readonly) CGRect bodyBounds;               ///< ビュー内のラベルを除くボディ領域の領域（サブビューを貼るときは、この領域に貼れば良い）
@property (nonatomic,readonly) bool folding;                    ///< 折りたたみ状態（変更は、fold/unfold/toggleFoldingメソッドを使用）
@property (nonatomic,readonly,weak) UIView* labelView;          ///< ラベルビュー (setLabelView/removeLabelViewメソッドで設定）
@property (nonatomic,readonly,weak) UIView* bodyView;           ///< ボディビュー（setBodyView/removeBodyViewメソッドで設定）
@property (nonatomic) bool movableLabel;                        ///< false:ラベルを固定して、ボディ側が伸び縮みする　/ true:ラベルがボディ側へ移動することによって伸び縮みする
@property (nonatomic,weak) id<MICUiAccordionCellDelegate> accordionDelegate;
@property (nonatomic,strong,readonly) id<MICUiLayoutProtocol> layouter;

@property (nonatomic) MICUiAlignEx labelAlignment;              ///< ラベルの配置方法
@property (nonatomic) UIEdgeInsets labelMargin;                 ///< ラベル周辺のマージン
@property (nonatomic) UIEdgeInsets bodyMargin;                  ///< ボディ周辺のマージン
@property (nonatomic) bool needsCalcLayout;                     ///< レイアウト計算必要フラグ
@property (nonatomic) CGFloat animDuratin;                      ///< 開閉アニメーションのDuration

// for Debug
@property (nonatomic) NSString* name;

/**
 * ビューの初期化
 */
- (MICUiAccordionCellView*)initWithFrame:(CGRect)frame;          // default initializer

/**
 * ビューのレイアウトを計算する。
 *  labelPos,orientation,rotateRight,movableLabel,labelView,bodyViewのプロパティを変更したら、このメソッドを呼ぶ必要がある。
 *  ただし、このメソッド実行時点のビューのサイズ・位置を基準にレイアウトするので、unfoldされた状態で実行しないと例外を投げるので注意。
 */
- (void) updateLayout;

/**
 * 折りたたむ
 */
- (void) fold :(BOOL)animation onCompleted:(void (^)(BOOL)) onCompleted;

/**
 * 展開する
 */
- (void) unfold :(BOOL)animation  onCompleted:(void (^)(BOOL)) onCompleted;

/**
 * 折りたたみ/展開の状態をトグルする
 */
- (void) toggleFolding:(BOOL)animation onCompleted:(void (^)(BOOL)) onCompleted;

/**
 * ラベルビューを設定する。（必須）
 */
- (void) setLabelView:(UIView*)labelView;


/**
 * スクロールビューの自動リサイズモードを有効にする。
 */
- (void) enableAutoResizing:(BOOL)enable minBodySize:(CGFloat)min maxBodySize:(CGFloat)max;

/**
 * ラベルビューの設定を解除する。
 */
- (UIView*) removeLabelView;

/**
 * ボディビューを設定する。（任意）
 *  ラベルビュー領域を除いた部分に配置される。ボディビューを指定しないで、このビューのbodyBoundsに、直接サブビューを貼り付けて使っても可。
 * @param   bodyView    ボディ部にセットするビュー
 */
- (void) setBodyView:(UIView*)bodyView;
/**
 * ボディビューの設定を解除する。
 */
- (UIView*) removeBodyView;

/**
 * ボディビューの代わりにレイアウターを設定する。
 *  ラベルビュー領域を除いた部分にレイアウターを配置する。
 *  以後、addSubviewの代わりに、このレイアウターにaddChildする。当然のことながら、setBodyView()との併用は不可。
 *  @param  layouter    レイアウター
 */
- (void) setBodyLayouter:(id<MICUiLayoutProtocol>)layouter;

- (id<MICUiLayoutProtocol>) removeBodyLayouter;

@end
