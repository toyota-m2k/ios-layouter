//
//  WPLBoolStateBinding.h
//  WP Layouter
//
//  Created by Mitsuki Toyota on 2019/08/03.
//  Copyright © 2019 Mitsuki Toyota. All rights reserved.
//

#import "WPLGenericBinding.h"

/**
 * Bool型ソースとViewの状態（visibility, enabled, readonly)のBindingクラス
 */
@interface WPLBoolStateBinding : WPLGenericBinding
- (instancetype) initWithCell:(id<IWPLCell>) cell
                       source:(id<IWPLObservableData>) source
//                  bindingMode:(WPLBindingMode)bindingMode                 SOURCE_TO_VIEW 一択
                 customAction:(WPLBindingCustomAction)customAction
                   actionType:(WPLBoolStateActionType) actionType
                     negation:(bool)negation;
@end
