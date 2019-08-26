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

- (instancetype) initWithCell:(id<IWPLCell>) cell
                       source:(id<IWPLObservableData>) source
//                  bindingMode:(WPLBindingMode)bindingMode                 SOURCE_TO_VIEW 一択
                 customAction:(WPLBindingCustomAction)customAction
                   actionType:(WPLBoolStateActionType) actionType
                     negation:(bool)negation;
@end
