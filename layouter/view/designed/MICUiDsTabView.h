//
//  MICUiDsTabView.h
//
//  タブビュー（タブ耳と切り替わるボディビューから構成されるビュー）クラス
//
//  Created by @toyota-m2k on 2014/12/15.
//  Copyright (c) 2014年 @toyota-m2k. All rights reserved.
//

#import "MICUiAccordionCellView.h"
#import "MICUiTabBarView.h"
#import "MICUiStatefulResource.h"
#import "MICUiDsTabButton.h"

@class MICUiDsTabView;

/**
 * MICUiDsTabViewのイベント用デリゲート
 */
@protocol MICUiDsTabViewDelegate<NSObject>
/**
 * タブが選択されたイベント
 */
- (void) onTabSelected:(MICUiDsTabView*)sender selectTab:(id)tabKey;
@end

/**
 * MICUiDsTabViewクラス
 */
@interface MICUiDsTabView : MICUiAccordionCellView<MICUiDsCustomButtonDelegate>

@property (nonatomic, readonly) MICUiTabBarView* tabBar;                            ///< タブバーインスタンス（内部で生成される）

@property (nonatomic, weak) id<MICUiDsTabViewDelegate> tabViewDelegate;             ///< イベントリスナー
@property (nonatomic, setter=selectTab:) NSString* selectedTab;                     ///< 選択中のタブ（のキー）

// タブのLook&Feel
// addTabする前に初期化しておくこと。
@property (nonatomic) CGFloat tabHeight;                                            ///< タブの高さ

@property (nonatomic) CGFloat tabWidth;                                             ///< タブの幅（ゼロを与えると自動可変サイズとして扱う）
@property (nonatomic) CGFloat tabMinWidth;                                          ///< タブの最小幅（tabWidth==0の場合のみ参照）
@property (nonatomic) CGFloat tabMaxWidth;                                          ///< タブの最大幅（tabWidth==0の場合のみ参照 / 0なら最大幅はチェックしない）

@property (nonatomic) CGFloat borderWidth;                                          ///< 枠線の幅
@property (nonatomic) CGFloat fontSize;                                             ///< フォントサイズ
@property (nonatomic) UIEdgeInsets contentMargin;                                   ///< ボタン矩形とコンテント（アイコン・キャプション）とのマージン
@property (nonatomic) CGFloat iconTextMargin;                                       ///< アイコンとキャプションの間のマージン
@property (nonatomic) CGFloat roundRadius;                                          ///< 角丸の半径（ゼロなら直角）
@property (nonatomic) bool attachBottom;                                            ///< true:下/右に付着する（上/左側のボーダーがオープン）
@property (nonatomic) bool turnOver;                                                ///< true:上下逆転

/**
 * 初期化
 */
- (instancetype) initWithFrame:(CGRect)frame;

/**
 * タブを追加する
 *
 * @param key       タブを識別する名前（tagは別の用途に使うことを想定して別のプロパティで管理）
 * @param label     タブに表示する文字列
 * @param colors    色・背景属性
 * @param icons     アイコン（不要ならnil）
 * @param updateView    true:内部でupdateViewを呼ぶ / false:呼ばない→あとで明示的にupdateViewを呼ぶこと。
 */
- (void) addTab:(NSString*)key label:(NSString*)label color:(id<MICUiStatefulResourceProtocol>)colors icon:(id<MICUiStatefulResourceProtocol>)icons updateView:(bool)updateView;

/**
 * タブを削除する
 */
- (void) removeTab:(NSString*)key;

/**
 * タブボタンを取得する
 */
- (MICUiDsTabButton*) getTabButton:(NSString*)key;

/**
 * D&Dによるタブ並び順のカスタマイズを開始
 */
- (void) beginCustomize;

/**
 * D&Dによるタブ並び順のカスタマイズを終了
 */
- (void) endCustomize;



@end
