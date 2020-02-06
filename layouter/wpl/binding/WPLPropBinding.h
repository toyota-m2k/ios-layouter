//
//  WPLPropBinding.h
//  WP Layouter
//
//  Created by toyota-m2k on 2019/08/26.
//  Copyright © 2019 toyota-m2k. All rights reserved.
//

#import "WPLGenericBinding.h"

@interface WPLPropBinding : WPLGenericBinding

@property (nonatomic,readonly) WPLPropType propType;

/**
 * Viewのプロパティと直接バインドするクラス
 */
- (instancetype) initWithCell:(id<IWPLCell>) cell
                       source:(id<IWPLObservableData>) source
//                  bindingMode:(WPLBindingMode)bindingMode     // SOURCE_TO_VIEW 一択
                     propType:(WPLPropType) propType
                 customAction:(WPLBindingCustomAction)customAction;

@end

