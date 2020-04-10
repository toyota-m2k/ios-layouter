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

/**
 * セルの基底 i/f
 */
@protocol IWPLCell    <IWPLDisposable>
    // 基本情報
    @property(nonatomic) NSString* name;                    // 名前（任意）
    @property(nonatomic,readonly) UIView* view;             // セルに配置するビュー

    /**
     * リソース解放
     */
    - (void) dispose;

    // レンダリング情報
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

    // For bindings

    @property(nonatomic) WPLVisibility visibility;         // 表示・非表示
    @property(nonatomic) bool enabled;                      // 有効/無効

    // Rendering i/f

    /**
     * レンダリング開始。
     * 必要に応じてレンダリングキャッシュのクリアなどを行う。
     * beginRenderingとendRenderingは必ずペアで呼ばれる。
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

    /**
     * レンダリングキャッシュを破棄してセル幅を再計算
     */
    - (CGFloat)recalcCellWidth:(CGFloat)regulatingWidth;

    /**
     * レンダリングキャッシュを破棄してセルの高さを再計算
     */
    - (CGFloat)recalcCellHeight:(CGFloat)regulatingHeight;

    /**
     * セルの位置、サイズを確定し、ビューを再配置する。
     * @param   finalCellRect  セルを配置可能な矩形領域（親ビュー座標系）
     */
    - (void) endRendering:(CGRect) finalCellRect;

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

