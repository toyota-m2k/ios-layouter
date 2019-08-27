//
//  WPLCellDef.h
//  WP Layouter
//
//  Created by toyota-m2k on 2019/08/02.
//  Copyright © 2019 toyota-m2k. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

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

/**
 * セルの基底 i/f
 */
@protocol IWPLCell    <NSObject>
    @property(nonatomic) NSString* name;                        // 名前（任意）
    @property(nonatomic,readonly) UIView* view;               // セルに配置するビュー
    - (void) dispose;                                       // 破棄

    // For rendering
    @property(nonatomic) bool needsLayout;                  // セルのサイズなどが変わったときにtrueになる
    @property(nonatomic) UIEdgeInsets margin;               // マージン
    @property(nonatomic) WPLCellAlignment hAlignment;       // 横方向配置指示
    @property(nonatomic) WPLCellAlignment vAlignment;       // 縦方向配置指示
    @property(nonatomic, readonly) CGSize actualViewSize;     // view.frame.size と同じ
    @property(nonatomic) CGSize requestViewSize;              // 要求サイズ
    @property(nonatomic, weak) id<IWPLContainerCellDelegate> containerDelegate;  // 親コンテナにサイズ変更を通知するためのデリゲート
    @property(nonatomic) id extension;                      // 親コンテナが自由に利用するメンバー

    /**
     * レイアウト準備（仮配置）
     * セル内部の配置を計算し、セルサイズを返す。
     * このあと、親コンテナセルでレイアウトが確定すると、layoutCompleted: が呼び出されるので、そのときに、内部の配置を行う。
     * @param regulatingCellSize    stretch指定のセルサイズを決めるためのヒント
     *    セルサイズ決定の優先順位
     *      requestedViweSize       regulatingCellSize          内部コンテンツ(view/cell)サイズ
     *      ○ 正値(fixed)                無視                       requestedViewSizeにリサイズ
     *        ゼロ(auto)                 無視                     ○ 元のサイズのままリサイズしない
     *        負値(stretch)              ゼロ (auto)              ○ 元のサイズのままリサイズしない (regulatingCellSize の stretch 指定は無視する)
     *        負値(stretch)            ○ 正値 (fixed)               regulatingCellSize にリサイズ
     * @return  セルサイズ（マージンを含む
     */
    - (CGSize) layoutPrepare:(CGSize) regulatingCellSize;

    /**
     * レイアウトを確定する。
     * layoutPrepareが呼ばれた後に呼び出される。
     * @param finalCellRect     確定したセル領域（マージンを含む）
     *
     *  リサイズ＆配置ルール
     *      requestedViweSize       finalCellRect                 内部コンテンツ(view/cell)サイズ
     *      ○ 正値(fixed)                無視                       requestedViewSizeにリサイズし、alignmentに従ってfinalCellRect内に配置
     *        ゼロ(auto)                 無視                     ○ 元のサイズのままリサイズしないで、alignmentに従ってfinalCellRect内に配置
     *        負値(stretch)              ゼロ (auto)              ○ 元のサイズのままリサイズしない、alignmentに従ってfinalCellRect内に配置 (regulatingCellSize の stretch 指定は無視する)
     *        負値(stretch)            ○ 正値 (fixed)               finalCellSize にリサイズ（regulatingCellSize!=finalCellRect.sizeの場合は再計算）。alignmentは無視
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

