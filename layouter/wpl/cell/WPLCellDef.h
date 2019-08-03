//
//  WPLCellDef.h
//  WP Layouter
//
//  Created by Mitsuki Toyota on 2019/08/02.
//  Copyright © 2019 Mitsuki Toyota. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 * セルの配置指定
 */
typedef enum _WPLCellAlignment {
    WPLCellAlignmentSTART,
    WPLCellAlignmentEND,
    WPLCellAlignmentCENTER,
    WPLCellAlignmentSTRETCH,    // requestViewWidth/Height は無視して、コンテナのサイズに合わせて伸縮する
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

    /** セルの最小サイズを計算 */
    - (CGSize) calcMinSizeForRegulatingWidth:(CGFloat) regulatingWidth andRegulatingHeight:(CGFloat) regulatingHeight;

    /** レイアウト確定 */
    - (void) layoutResolvedAt:(CGPoint)point inSize:(CGSize)size;

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

