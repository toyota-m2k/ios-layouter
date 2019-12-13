//
//  WPLBoolStateBinding.h
//  WP Layouter
//
//  Created by toyota-m2k on 2019/08/03.
//  Copyright © 2019 toyota-m2k. All rights reserved.
//

#import "WPLGenericBinding.h"

/**
 * Bool型ソースとViewの状態（visibility, enabled, readonly)のBindingクラス
 */
@interface WPLBoolStateBinding : WPLGenericBinding

@property (nonatomic,readonly) WPLBoolStateActionType actionType;

/**
 * bool値をBoolStateにバインドする
 *
 * @param cell          バインドするセル
 * @param source        データソース
 * @param customAction  カスタムアクション
 * @param actionType    WPLBoolStateActionType
 * @param negation      false (true->visible...) / true (true->collapsed...)
 */
- (instancetype) initWithCell:(id<IWPLCell>) cell
                       source:(id<IWPLObservableData>) source
//                  bindingMode:(WPLBindingMode)bindingMode                 SOURCE_TO_VIEW 一択
                 customAction:(WPLBindingCustomAction)customAction
                   actionType:(WPLBoolStateActionType) actionType
                     negation:(bool)negation;

/**
 * 任意の型の値（intやstringなど）との比較結果をBoolStateにバインドする
 *
 * @param cell              バインドするセル
 * @param source            データソース
 * @param customAction      カスタムアクション
 * @param actionType        WPLBoolStateActionType
 * @param referenceValue    比較対象の値
 * @param equals            true (==) / false (!=)
 * @param compareAsBoolean  NSNumber#boolValue に変換して比較するか（trueにすると、@(2) も trueとして扱われる）
 */
- (instancetype)initWithCell:(id<IWPLCell>)cell
                    source:(id<IWPLObservableData>)source
              customAction:(WPLBindingCustomAction)customAction
                actionType:(WPLBoolStateActionType)actionType
            referenceValue:(id)referenceValue
                    equals:(bool)equals
          compareAsBoolean:(bool) compareAsBoolean;

@end
