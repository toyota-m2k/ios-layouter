//
//  WPLValueBinding.h
//  WP Layouter
//
//  Created by Mitsuki Toyota on 2019/08/03.
//  Copyright © 2019 Mitsuki Toyota. All rights reserved.
//

#import "WPLGenericBinding.h"

/**
 * ValueBinding
 *
 * Viewの値(text/checked, ...) と Sourceの値とをバインドするクラス
 */
@interface WPLValueBinding : WPLGenericBinding

- (instancetype) initWithCell:(id<IWPLCell>) cell
                       source:(id<IWPLObservableData>) source
                  bindingMode:(WPLBindingMode)bindingMode
                 customAction:(WPLBindingCustomAction)customAction;

@end
