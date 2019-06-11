//
//  MICUiSwitchingViewMediator.h
//
//  予め設定しておいたルールにしたがって、複数のビュー（ペイン）の表示非表示を自動的に切り替える仲介者クラス
//
//  Created by @toyota-m2k on 2014/12/24.
//  Copyright (c) 2014年 @toyota-m2k. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - MICUiViewVisibilityDelegate

@class MICUiSwitchingViewMediator;

/**
 * ビューの表示・非表示（開閉）を切り替えるためのコールバック用プロトコル
 */
@protocol MICUiViewVisibilityDelegate <NSObject>

/**
 * Switcherが管理するViewの表示・非表示状態を変更する。
 */
- (void) setViewVisibility:(UIView*) view visible:(bool)show onCompleted:(void (^)(BOOL)) onCompleted;

/**
 * Viewの表示状態を取得
 * @return true:表示　/ false:非表示
 */
- (bool) isViewVisible:(UIView*) view;

@end

/**
 * Switcherによるビューの表示・非表示動作の開始・完了を通知するコールバック
 */
@protocol MICUiSwitchingViewDelegate <NSObject>

/**
 * Switcherが管理するビューの表示状態の変更処理が開始される直前に１回コールされる。
 * 表示状態の変更は、０個以上のビューに対して行われる可能性がある。
 */
- (void) willSwitchViewVisibility:(MICUiSwitchingViewMediator*)sender;

/**
 * Switcherが管理するビューの表示状態の変更処理が完了した時に１回コールされる。
 * @param changed   true:１個以上のビューの表示状態が変化した / false:１つも変化しなかった。
 */
- (void) didSwitchViewVisibility:(MICUiSwitchingViewMediator*)sender changed:(bool)changed;

@end

#pragma mark - MICUiSwitchingViewMediator

/**
 * ビューの表示・非表示（開閉）を調停するためのメディエーター
 */
@interface MICUiSwitchingViewMediator : NSObject

#pragma mark - 初期化

@property (nonatomic,weak) id<MICUiSwitchingViewDelegate> delegate;

/**
 * 初期化
 */
- (instancetype) init;

#pragma mark - ルールの編集

/**
 * このリスト内のビューが１つ表示されたら、残りは非表示にする。
 */
- (void) setExclusiveViewGroup:(NSArray*)namelist;

/**
 * このリスト内のビューが１つ表示されたら、残りも表示する。
 */
- (void) setCompanionViewGroup:(NSArray*)namelist;

/**
 * このリスト内の片方のビューが表示されたら、もう片方を非表示にする。
 * 逆に、片方が非表示になったら、もう片方を表示する。
 */
- (void) setAlternativeViewGroup:(NSArray*) namelistA andAnotherGroup:(NSArray*) namelistB;

/**
 * 現在設定中のルールをクリアする。
 */
- (void) clearRule;

/**
 * 現在設定中のルールに名前をつける。この名前を使って、activateRuleメソッドが使用可能になる。
 */
- (void) stockRuleAs:(NSString*)rulename;

/**
 * 現在設定中のルールをクリアして、対比されているルールのなかから名前で指定されたルールを有効化する。
 */
- (void) activateRule:(NSString*)rulename;


#pragma mark - Colleagueの登録・登録解除

/**
 * 管理対象ビューを登録する
 *
 *  @param  view        ビュー
 *  @param  name        ビューの名前
 *  @param  callback    ビュー開閉操作用デリゲート（nilなら、Viewの hidden 属性を操作する）
 */
- (void) registerView:(UIView*)view ofName:(NSString*)name callback:(id<MICUiViewVisibilityDelegate>)callback;

/**
 * 管理対象ビューの登録を解除する
 *
 * @param name  解除するビューの名前
 */
- (void) unregisterView:(NSString*)name;

/**
 * ビューの名前を返す（NSDictionaryの逆引きのため、数が増えると効率が悪いので注意）
 */
- (NSString*) getViewName:(UIView*)view;

#pragma mark - ビューの表示・非表示

/**
 * showView/hideViewの中の人
 */
- (void)setViewVisibility:(NSString *)name visible:(bool)visible updateView:(bool)update;

/**
 * ビューを表示する（事後連絡でも可）
 *
 *  @param name    表示するビューの名前
 *  @param update   true:ビューの表示状態を更新する / false:内部情報を設定するだけ（あとから明示的に applyVisibilitiesを呼ぶこと）
 */
- (void) showView:(NSString*)name updateView:(bool)update;

/**
 * ビューを非表示する（事後連絡でも可）
 *
 *  @param name    非表示にするビューの名前
 *  @param update   true:ビューの表示状態を更新する / false:内部情報を設定するだけ（あとから明示的に applyVisibilitiesを呼ぶこと）
 */
- (void) hideView:(NSString*)name updateView:(bool)update;

/**
 * ビューの表示/非表示状態を適用する。
 */
- (void) applyVisibilities;

@end
