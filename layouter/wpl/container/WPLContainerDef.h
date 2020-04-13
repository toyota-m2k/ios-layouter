//
//  WPLContainerDef.h
//  WP Layouter
//
//  Created by toyota-m2k on 2019/08/02.
//  Copyright © 2019 toyota-m2k. All rights reserved.
//
#import "WPLCellDef.h"

/**
 * スクロール方向
 * WPLScrollCell, WPL*ScrollView で使用する
 */
typedef enum _WPLScrollOrientation {
    WPLScrollNone = 0,
    WPLScrollOrientationHORZ = 1,
    WPLScrollOrientationVERT = 2,
    WPLScrollOrientationBOTH = 3,
} WPLScrollOrientation;

/**
 * コンテナセルのi/f定義
 *
 * レイアウト更新のデータフロー
 * ・あるセルでサイズなどが変更される
 *   --> needsLayout = true --> 親コンテナの　onChildCellModified を呼び出す
 * ・rootContainer を保持しているビューの onChildCellModified から、rootContainer.layout() を呼び出す
 *   --> 各セルの calcMinSize() を呼び出して、レンダリングを実行
 *          各セルのcalcMinSize() は、自身のサイズを計算して返す
 *          そのセルがコンテナの場合は、子セルのレイアウトを実行（または準備）
 *   --> すべてのサイズから配置を計算して、各セルの layoutResolved()を呼び出して配置を確定。
 *          各セルは与えられた位置/サイズに従って、ビューを再配置する
 *          そのセルがコンテナの場合は、必要に応じて、与えられたサイズで、子セルの配置を再計算して、配置を確定する。
 */
@protocol IWPLContainerCell <IWPLCell, IWPLContainerCellDelegate>
    /**
     * 子セルの再配置が必要フラグ
     */
    @property (nonatomic, readonly) bool needsLayoutChildren;

    /**
     * セルを追加
     */
    - (void) addCell:(id<IWPLCell>) cell;

    /**
     * セルを削除(CellはDisposeされる)
     */
    - (void) removeCell:(id<IWPLCell>) cell;

    /**
     * セルをコンテナから切り離す (見た目はremoveCellと同じだが、Disposeされない）
     */
    - (id<IWPLCell>) detachCell:(id<IWPLCell>) cell;

    /**
     * セルの名前で検索
     */
    - (id<IWPLCell>) findByName:(NSString*) name;

    /**
     * ビューでセルを検索
     */
    - (id<IWPLCell>) findByView:(UIView*) view;

//    /**
//     * レイアウトやり直すために、すべてのコンテナのレイアウトを無効化する。
//     */
//    - (void) invalidateAllLayout;
//    /**
//     * キャッシュ済みレイアウト情報（サイズ）をクリアする
//     */
//    - (void) invalidateLayout;

@end


