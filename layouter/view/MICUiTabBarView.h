//
//  MICUiTabView.h
//
//  タブ（ボタンなど）を並べるタブバービュークラス
//
//  Created by @toyota-m2k on 2014/11/20.
//  Copyright (c) 2014年 @toyota-m2k. All rights reserved.
//

#import "MICUiStackView.h"

/**
 * タブバーの左右に配置するファンクションボタンの種別
 */
typedef enum _micUiTabBarFuncButton {
    MICUiTabBarFuncButtonSCROLL_PREV,       ///< 前へスクロール（スクロール可否によって表示/非表示、有効・無効が切り替わる）
    MICUiTabBarFuncButtonSCROLL_NEXT,       ///< 後へスクロール（スクロール可否によって表示/非表示、有効・無効が切り替わる）
    MICUiTabBarFuncButtonCUSTOMIZING,       ///< D&Dによるカスタマイズ開始
    MICUiTabBarFuncButtonFOLDING,           ///< 折りたたみ（TabViewとして使用時に有効）
    MICUiTabBarFuncButtonOTHER,             ///< クライアント定義
} MICUiTabBarFuncButton;

/**
 * コールバック用デリゲートi/fの定義
 */
@protocol MICUiTabViewDelegate <NSObject>

- (void) onFuncButtonStateChanged:(UIView*)button enabled:(BOOL)enabled;
- (void) onCustomizingStateChanged:(UIView*)button customizingNow:(bool)customizing;
- (void) onFoldingStateChanged:(UIView*)button folded:(bool)folded;

@end

/**
 * タブバークラス
 */
@interface MICUiTabBarView : UIView<MICUiLayoutDelegate, UIScrollViewDelegate>

@property (nonatomic,readonly) MICUiStackView* bar;                     ///< 直接操作することはやめてほしい。
@property (nonatomic,readonly) int tabCount;                            ///< 設定されているタブの総数
@property (nonatomic,weak) id<MICUiTabViewDelegate> tabViewDelegate;    ///< コールバック用デリゲート
@property (nonatomic) NSString* name;                                   ///< for debug

/**
 * タブ（UIView*）を追加する
 * @param   update  true:updateLayoutを呼び出す  /false:呼び出さない
 */
- (void) addTab:(UIView*)tab updateView:(bool)update;

/**
 * タブ（UIView*）を指定位置に挿入する。
 * @param   update  true:updateLayoutを呼び出す  /false:呼び出さない
 */
- (void) insertTab:(UIView*)tab beforeSibling:(UIView*)sibling updateView:(bool)update;

/**
 * タブ（UIView*）を削除する
 * @param   update  true:updateLayoutを呼び出す  /false:呼び出さない
 */
- (void) removeTab:(UIView*)tab updateView:(bool)update;

/**
 * 指定位置のタブを取得
 */
- (UIView*) tabAt:(int)index;

- (UIView*) findTab:(bool (^)(UIView *tab))isMatch;

/**
 * タブとファンクションボタンの再配置を実行する。
 */
- (void) updateLayout;

/**
 * タブバーの左側にファンクションボタンを追加する。
 */
- (void) addLeftFuncButton:(UIView*)button function:(MICUiTabBarFuncButton)func;

/**
 * タブバーの右側にファンクションボタンを追加する。
 */
- (void) addRightFuncButton:(UIView*)button function:(MICUiTabBarFuncButton)func;

/**
 * タブバーを左方向へスクロールする。
 */
- (void) scrollPrev;

/**
 * タブバーを右方向へスクロールする。
 */
- (void) scrollNext;


- (void) ensureTabVisible:(UIView*)tab animated:(bool)anim;

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

@end
