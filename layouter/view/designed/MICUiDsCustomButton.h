﻿//
//  MICUiDsCustomButton.h
//
//  オーナードローなボタンビューの基底クラス
//
//  Created by 豊田 光樹 on 2014/12/15.
//  Copyright (c) 2014年 M.TOYOTA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MICUiStatefulResource.h"
#import "MICUiLayout.h"

@class MICUiDsCustomButton;

/**
 * カスタムボタンのイベント用デリゲート
 */
@protocol MICUiDsCustomButtonDelegate <NSObject>
/**
 * ボタンの状態(buttonStateプロパティ)が変更されたときの通知
 */
- (void) onCustomButtonStateChangedAt:(MICUiDsCustomButton*)view from:(MICUiViewState)before to:(MICUiViewState)after;
/**
 * ボタンがタップされたときの通知
 */
- (void) onCustomButtonTapped:(MICUiDsCustomButton*)view;
@end

/**
 * カスタムボタンクラス
 */
@interface MICUiDsCustomButton : UIView<MICUiDraggableCellProtocol>

@property (nonatomic) NSString* text;                                               ///< ボタンのキャプション
@property (nonatomic) id<MICUiStatefulResourceProtocol> colorResources;             ///< 色指定・背景画像指定用リソース
@property (nonatomic) id<MICUiStatefulResourceProtocol> iconResources;              ///< アイコン定義用リソース

@property (nonatomic) MICUiAlign    textHorzAlignment;                              ///< キャプションの横方向アラインメント
@property (nonatomic) CGFloat borderWidth;                                          ///< 枠線の幅
@property (nonatomic) CGFloat fontSize;                                             ///< フォントサイズ
@property (nonatomic) UIEdgeInsets contentMargin;                                   ///< ボタン矩形とコンテント（アイコン・キャプション）とのマージン
@property (nonatomic) CGFloat iconTextMargin;                                       ///< アイコンとキャプションの間のマージン
@property (nonatomic) CGFloat roundRadius;                                          ///< 角丸の半径（ゼロなら直角）
@property (nonatomic) bool turnOver;                                                ///< 上下逆転（１８０度回転）

@property (nonatomic,readonly) MICUiViewState buttonState;                          ///< ボタンの状態
@property (nonatomic) bool enabled;                                                 ///< 有効／無効状態
@property (nonatomic) bool selected;                                                ///< 選択状態
@property (nonatomic) bool activated;                                               ///< アクティブ化状態（タップされた状態）
@property (nonatomic) bool inert;                                                   ///< 不活性状態（主に内部利用のみ：D&D操作中のタップ動作を禁止する場合に使用）
@property (nonatomic) id<MICUiDsCustomButtonDelegate> customButtonDelegate;         ///< イベントリスナー
@property (nonatomic) NSString* key;

#pragma mark - PROTECTED methods

/**
 * 状態依存のアイコンを取得
 *   iconResourcesが指定されていれば、それから取得、指定されていなければ、colorResourcesから取得する。
 */
- (UIImage*) getIconForState:(MICUiViewState)state;


/**
 * ラベル描画用フォントを取得する
 *  デフォルトの実装では、boldSystemFont を使用。これを変更する場合はサブクラスでオーバーライドする。
 */
- (UIFont*) getFont;

/**
 * 描画領域を取得する。
 * テキスト、または、アイコンの描画位置を変更する場合は、サブクラスでオーバーライドする。デフォルトの実装は、
 * - 左端にアイコン、その右にiconTextMarginをあけてテキストを表示する。
 * - アイコンだけ、または、テキストだけのときは、それぞれセンタリングする。
 */
- (void) getContentRect:(UIImage*)icon iconRect:(CGRect*)prcIcon textRect:(CGRect*)prcText;

/**
 * テキストを描画する。
 *  通常はオーバーライド不要。drawContentをオーバーライドする場合に、テキスト出力のユーティリティとして利用する。
 */
- (void) drawText:(CGContextRef)rctx rect:(CGRect)rect halign:(NSTextAlignment)halign valign:(MICUiAlign)valign;

/**
 * 背景を描画する
 *  背景の描画方法を変更する場合は、サブクラスでオーバーライド
 *  デフォルトでは、
 *  - 画像を使用
 *  - 背景色、ボーダー色を指定した矩形または、角丸矩形で描画
 *  の２種類をサポート
 */
- (void) eraseBackground:(CGContextRef)ctx rect:(CGRect)rect;

/**
 * ボタンのコンテント（アイコンとテキスト）を描画する。
 * - 背景（塗りとボーダー）の描画方法を変更する場合はeraseBackgroundをオーバーライド
 * - アイコンとテキストの位置を変える→　getContentRect をオーバーライド
 * - テキストのフォントを変える→　getFontをオーバーライド
 * これ以外（例えば、アイコンを２つ使うとか、テキストを二段にするとか）のカスタマイズを行う場合には、このメソッドをオーバーライドする。
 */
- (void) drawContent:(CGContextRef)ctx rect:(CGRect)rect;


/**
 * コンテントを表示するための最小ボタンサイズを計算する。
 * @param  height   タブの高さ（0なら、高さも計算する）
 * @return ボタンサイズ（contentMarginを含む）
 */
- (CGSize) calcPlausibleButtonSizeFotHeight:(CGFloat)height forState:(MICUiViewState)state;

@end
