//
//  MICUiGridLayout.h
//
//  ビューを格子状（タイル状）に並べるGrid型レイアウター
//  （Metroのスタート画面からインスパイヤ）
//
//  Created by 豊田 光樹 on 2014/10/15.
//  Copyright (c) 2014年 豊田 光樹. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MICUiBaseLayout.h"

@class MICUiGridLayout;

//--------------------------------------------------------------------------------------
#pragma mark - 定数定義

/**
 * グリッドセルのスタイル
 */
typedef enum _micUiGridCellStyle {
    MICUiGlStyleNORMAL,     ///< 普通のセル
    MICUiGlStyleSEPARATOR,  ///< セパレーター（固定幅方向いっぱいに配置＆ドラッグ禁止）
} MICUiGridCellStyle;


//--------------------------------------------------------------------------------------
#pragma mark - グリッドレイアウト内のセル情報クラス

/**
 * グリッドレイアウト内のセル情報クラス
 */
@interface MICUiGridCell : MICUiLayoutCell {
}
@property (nonatomic) int width;                        ///< セルの幅（ユニット数）
@property (nonatomic) int height;                       ///< セルの高さ（ユニット数）
@property (nonatomic) int x;                            ///< セルのｘ座標（ユニット座標）
@property (nonatomic) int y;                            ///< セルのｙ座標（ユニット座標）
@property (nonatomic) MICUiGridCellStyle cellStyle;     ///< セルスタイル

/**
 * 空のセルを作成
 */
- (id) init;

/**
 * セル情報を与えて初期化
 */
- (id) initWithView:(UIView*)v unitX:(int)w unitY:(int)h cellStyle:(MICUiGridCellStyle)style;

@end

//--------------------------------------------------------------------------------------
#pragma mark - グリッド型レイアウター本丸

/**
 * グリッド型レイアウター
 */
@interface MICUiGridLayout : MICUiBaseLayout {
}

//--------------------------------------------------------------------------------------
#pragma mark - プロパティ

// グリッドの方向
@property (nonatomic) MICUiOrientation growingOrientation;    ///< 伸張方向
@property (nonatomic) MICUiOrientation fixedOrientation;      ///< 固定方向

// セルサイズ、マージン指定
@property (nonatomic) CGSize cellSize;                      ///< １セルユニットのサイズ
@property (nonatomic) CGFloat cellSpacingHorz;              ///< セル間隔（横方向）
@property (nonatomic) CGFloat cellSpacingVert;              ///< セル間隔（縦方向）

// グリッドのサイズ（セル数）
@property (nonatomic) int fixedSideCount;                   ///< 固定幅方向のセルユニット数
@property (nonatomic,readonly) int growingSideCount;        ///< 伸張方向のセルユニット数（セル追加や並べ替えによって変化する）
@property (nonatomic) int megaUnitX;                        ///< 複数のユニットを１つのｶﾀﾏﾘとして扱う場合のユニット数（横）
@property (nonatomic) int megaUnitY;                        ///< 同上（縦）

//--------------------------------------------------------------------------------------
#pragma mark - 初期化

/**
 * レイアウターの初期化
 */
- (id) init;

/**
 * レイアウターの初期化
 */
- (id) initWithCellSize:(CGSize)cellSize
     growingOrientation:(MICUiOrientation)growingOrientation
             fixedCount:(int)count;

//--------------------------------------------------------------------------------------
#pragma mark - グリッド型レイアウター　セル操作

/**
 * レイアウターにセル（ビュー）を追加する
 * このメソッドでは表示は更新されない。表示を更新する場合はupdateLayoutメソッドを呼ぶこと。
 *
 * @param view 追加するビュー
 * @param x セルの横方向サイズ（ユニット数）
 * @param y セルの縦方向サイズ（ユニット数）
 */
- (void) addChild:(UIView*)view
            unitX:(int)x
            unitY:(int)y;

/**
 * レイアウターにセル（ビュー）を追加する
 * このメソッドでは表示は更新されない。表示を更新する場合はupdateLayoutメソッドを呼ぶこと。
 *
 * @param view 追加するビュー
 * @param x セルの横方向サイズ（ユニット数）
 * @param y セルの縦方向サイズ（ユニット数）
 * @param style セルスタイル
 */
- (void) addChild:(UIView*)view
            unitX:(int)x
            unitY:(int)y
        cellStyle:(MICUiGridCellStyle) style;


/**
 * レイアウターの指定位置にセルを挿入する。
 * このメソッドでは表示は更新されない。表示を更新する場合はupdateLayoutメソッドを呼ぶこと。
 *
 * @param view 追加（挿入）するビュー
 * @param x セルの横方向サイズ（ユニット数）
 * @param y セルの縦方向サイズ（ユニット数）
 * @param siblingView 挿入位置のビュー（このビューの位置＝このビューの１つ前に挿入する）: nil なら末尾（＝＝addChild)
 */
- (void) insertChild:(UIView*)view
               unitX:(int)x
               unitY:(int)y
              before:(UIView*)siblingView;

/**
 * レイアウターの指定位置にセルを挿入する。
 * このメソッドでは表示は更新されない。表示を更新する場合はupdateLayoutメソッドを呼ぶこと。
 *
 * @param view 追加（挿入）するビュー
 * @param x セルの横方向ユニット数
 * @param y セルの縦方向ユニット数
 * @param style セルスタイル
 * @param siblingView 挿入位置のビュー（このビューの位置＝このビューの１つ前に挿入する）: nil なら末尾（＝＝addChild)
 */
- (void) insertChild:(UIView *)view
               unitX:(int)x
               unitY:(int)y
           cellStyle:(MICUiGridCellStyle) style
              before:(UIView *)siblingView;


////--------------------------------------------------------------------------------------
//#pragma mark - グリッド型レイアウター　ドラッグ＆ドロップ
//
///**
// * ドラッグを開始する。
// *
// * @param touchPos  コンテナビュー座標でのタップ位置
// * @return true:ドラッグを開始した　/ false:ドラッグは開始していない。
// */
//- (BOOL)beginDrag:(id<MICUiDragEventArg>)touchPos;
//
///**
// * 指定位置へドラッグする。
// *
// * @param touchPos  コンテナビュー座標でのドラッグ位置
// */
//- (void)dragTo:(id<MICUiDragEventArg>)touchPos;
//
///**
// * ドラッグ終了（ドロップ）
// */
//- (void)endDrag;
//
///**
// * ドラッグ操作をキャンセルして、ドラッグ開始時の状態に戻す。
// */
//- (void)cancelDrag;

//--------------------------------------------------------------------------------------
#pragma mark - グリッドレイアウター グループの折りたたみ

/**
 * セパレータで指定されたグループ（そのセパレータから次のセパレータまで）を折りたたむ。
 */
- (void)foldGroup:(UIView*)cellView;

/**
 * 折りたたまれたグループを開く
 */
- (void)unfoldGroup:(UIView*)cellView;

/**
 * グループの折りたたみ状態をトグルする
 */
- (void)toggleGroupFolding:(UIView*)cellView;

/**
 * 折りたたまれたグループをすべて開く
 */
- (void) unfoldAllGroups;


@end

