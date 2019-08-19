//
//  WPLGenericBinding.h
//  WP Layouter
//
//  Created by toyota-m2k on 2019/08/05.
//  Copyright © 2019 toyota-m2k. All rights reserved.
//

#import "WPLBindingDef.h"

/**
 * バインディングの基底クラス
 *  一般的なバインディングには、WPLValueBinding, WPLBoolStateBinding を使用する。
 *  一方、ViewのbackgroundColor や alpha などにバインドするような特殊なケースには、このクラスを直接使用して、customActionに処理を記述するか、
 *  あるいは、サブクラスを作成して、onSourceChanged: をオーバーライドする。
 */
@interface WPLGenericBinding : NSObject<IWPLBinding>

/**
 * 標準の初期化
 */
- (instancetype) initWithCell:(id<IWPLCell>)cell
                       source:(id<IWPLObservableData>)source
                  bindingMode:(WPLBindingMode)bindingMode
                 customAction:(WPLBindingCustomAction) customAction;

/**
 * サブクラスから実行される用の初期化
 * sourceに対する変更監視リスナーの登録遅延が可能。
 */
- (instancetype) initInternalWithCell:(id<IWPLCell>)cell
                               source:(id<IWPLObservableData>)source
                          bindingMode:(WPLBindingMode)bindingMode
                         customAction:(WPLBindingCustomAction) customAction
                 enableSourceListener:(bool) enableSourceListener;

/**
 * カスタムアクションを呼び出す
 */
- (void) invokeCustomActionFromView:(bool) fromView;

/**
 * ソースの変更監視を開始する。
 * initInternalWithCell を enableSourceListener=false で呼び出した場合に、ソース監視を開始するために実行する。
 */
- (void) startSourceChangeListener;

/**
 * ソースが変更されたときのイベントハンドラ
 */
- (void) onSourceValueChanged:(id<IWPLObservableData>) source;

@end
