//
//  WPLCellDef.h
//  WP Layouter
//
//  Created by toyota-m2k on 2019/08/02.
//  Copyright © 2019 toyota-m2k. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "WPLRangedSize.h"
#import "WPLDef.h"

#define WPL_CELL_SIZING_AUTO 0           // Auto  中身に合わせてサイズを決定する
#define WPL_CELL_SIZING_STRETCH (-1.0)   // Stretch 親のサイズに合わせて決定する

/**
 * セルの配置指定
 */
typedef enum _WPLCellAlignment {
    WPLCellAlignmentSTART,
    WPLCellAlignmentEND,
    WPLCellAlignmentCENTER,
} WPLCellAlignment;

/**
 * 表示・非表示
 */
typedef enum _WPLVisibility {
    WPLVisibilityVISIBLE,
    WPLVisibilityCOLLAPSED,
    WPLVisibilityINVISIBLE,
} WPLVisibility;

@protocol IWPLCell;

/**
 * セルコンテナ（子セルのサイズ変更監視）i/f
 * ContainerCell が、子Cell の変更を検知して、再レイアウトできるようにするためのデリゲート
 */
@protocol IWPLContainerCellDelegate
    - (void) onChildCellModified:(id<IWPLCell>) cell;
    @property (nonatomic,readonly) CGFloat animationDuration;
@end

typedef enum _WPLRenderingMode {
    WPLRenderingNORMAL = 0,     // 通常のセルツリー構成変更などに起因するレンダリング
    WPLRenderingSIZING = 1,     // ルートのサイズ変更に追従するためのレンダリング
    WPLRenderingFORCE  = 2,     // 強制的な再レンダリング
} WPLRenderingMode;

@protocol IWPLCellWH   <NSObject>

/**
 * レンダリング開始を伝える。
 * beginRenderingとendRenderingInRectは必ずペアで呼ばれるが、calcCellWidth/calcCellHeight は
 * 必ずしも呼ばれない。従って、calcCell* の中で状態を保存し、endRenderingで利用するようなコードは不可。
 */
- (void) beginRendering:(WPLRenderingMode) mode;

/**
 * セル幅（マージンを含む）を計算
 * @param regulatingWidth   親からのサイズ指定（マージンを含む）
 */
- (CGFloat)calcCellWidth:(CGFloat)regulatingWidth;

/**
 * セル高さ（マージンを含む）を計算
 * @param regulatingHeight   親からのサイズ指定（マージンを含む）
 */
- (CGFloat)calcCellHeight:(CGFloat)regulatingHeight;

- (CGFloat)recalcCellWidth:(CGFloat)regulatingWidth;
- (CGFloat)recalcCellHeight:(CGFloat)regulatingHeight;

/**
 * セルの位置、サイズを確定し、ビューを再配置する。
 * @param   finalCellRect  セルを配置可能な矩形領域（親ビュー座標系）
 */
- (void) endRenderingInRect:(CGRect) finalCellRect;

@end

/**
 * セルの基底 i/f
 */
@protocol IWPLCell    <IWPLDisposable, IWPLCellWH>
    @property(nonatomic) NSString* name;                    // 名前（任意）
    @property(nonatomic,readonly) UIView* view;             // セルに配置するビュー
    - (void) dispose;                                       // 破棄

    // For rendering
    @property(nonatomic) bool needsLayout;                  // セルのサイズなどが変わったときにtrueになる
    @property(nonatomic) UIEdgeInsets margin;               // マージン
    @property(nonatomic) WPLCellAlignment hAlignment;       // 横方向配置指示
    @property(nonatomic) WPLCellAlignment vAlignment;       // 縦方向配置指示
    @property(nonatomic, readonly) CGSize actualViewSize;   // view.frame.size と同じ
    @property(nonatomic) CGSize requestViewSize;            // 要求サイズ
    @property(nonatomic) WPLMinMax limitWidth;              // 最大・最小幅
    @property(nonatomic) WPLMinMax limitHeight;             // 最大・最小高さ
    @property(nonatomic, weak) id<IWPLContainerCellDelegate> containerDelegate;  // 親コンテナにサイズ変更を通知するためのデリゲート
    @property(nonatomic) id extension;                      // 親コンテナが自由に利用するメンバー

    /**
     * レイアウト準備（仮配置）
     * セル内部の配置を計算し、セルサイズを返す。
     * このあと、親コンテナセルでレイアウトが確定すると、layoutCompleted: が呼び出されるので、そのときに、内部の配置を行う。
     * @param regulatingCellSize    stretch指定のセルサイズを決めるためのヒント
     *    セルサイズ決定の優先順位
     *      requestedViweSize       regulatingCellSize            内部コンテンツ(view/cell)サイズ
     *      ○ 正値(fixed)                無視                        requestedViewSizeにリサイズ
     *         ゼロ(auto)                 無視                     ○ 元のサイズのままリサイズしない
     *         負値(stretch)              ゼロ (auto)              ○ 元のサイズのままリサイズしない (regulatingCellSize の stretch 指定は無視する)
     *         負値(stretch)           ○ 正値 (fixed)                regulatingCellSize にリサイズ
     *
     * @return セルサイズ（マージンを含む
     */
    - (CGSize) layoutPrepare:(CGSize) regulatingCellSize;

    /**
     * レイアウトを確定する。
     * layoutPrepareが呼ばれた後に呼び出される。
     * @param finalCellRect     確定したセル領域（マージンを含む）
     *
     *  リサイズ＆配置ルール
     *      requestedViweSize       finalCellRect                 内部コンテンツ(view/cell)サイズ
     *      ○ 正値(fixed)                無視                        requestedViewSizeにリサイズし、alignmentに従ってfinalCellRect内に配置
     *         ゼロ(auto)                 無視                     ○ 元のサイズのままリサイズしないで、alignmentに従ってfinalCellRect内に配置
     *         負値(stretch)              ゼロ (auto)              ○ 元のサイズのままリサイズしない、alignmentに従ってfinalCellRect内に配置 (regulatingCellSize の stretch 指定は無視する)
     *         負値(stretch)           ○ 正値 (fixed)                finalCellSize にリサイズ（regulatingCellSize!=finalCellRect.sizeの場合は再計算）。alignmentは無視
     */
    - (void) layoutCompleted:(CGRect) finalCellRect;

    // For bindings
    @property(nonatomic) WPLVisibility visibility;         // 表示・非表示
    @property(nonatomic) bool enabled;                      // 有効/無効
@end


/**
 * ReadOnly 属性をサポートするセルの i/f
 */
@protocol IWPLCellSuportReadonly <IWPLCell>
    @property(nonatomic) bool readonly;
@end

/**
 * Value属性をサポートするセルの i/f
 */
@protocol IWPLCellSupportValue <IWPLCell>
    @property(nonatomic) id value;

    /**
     * Viewへの入力が更新されたときのリスナー登録
     * @param target        listener object
     * @param selector      (cell)->Unit
     * @return key  removeInputListenerに渡して解除する
     */
    - (id) addInputChangedListener:(id)target selector:(SEL)selector;

    /**
     * リスナーの登録を解除
     */
    - (void) removeInputListener:(id)key;
@end

@protocol IWPLCellSupportNamedValue <IWPLCell>
    - (id) valueForName:(NSString*)name;
    - (void) setValue:(id)value forName:(NSString*)name;

    /**
     * Viewへの入力が更新されたときのリスナー登録
     * @param target        listener object
     * @param selector      (cell,name)->Unit
     * @return key  removeNamedValueListenerに渡して解除する
     */
    - (id) addNamed:(NSString*)name valueListener:(id)target selector:(SEL)selector;

    /**
     * リスナーの登録を解除
     */
    - (void) removeNamed:(NSString*)name valueListener:(id)key;
@end


@protocol IWPLCellSupportCommand <IWPLCell>
    /**
     * タップ（ボタンactionなど）イベントのリスナー
     * @param target            listener object
     * @param selector          (cell)->Unit
     * @return key
     */
    - (id) addCommandListener:(id)target selector:(SEL)selector;
//    - (id) addTappedListener:(id)target selector:(SEL)selector  __attribute__((deprecated("use addCommandListener instead.")));

    /**
     * リスナーの登録を解除
     */
    - (void) removeCommandListener:(id)key;
//    - (void) removeTappedListener:(id)key  __attribute__((deprecated("use removeCommandListener instead.")));
@end

