//
//  WPLValueBinding.h
//  layouterSample
//
//  Created by Mitsuki Toyota on 2019/08/03.
//  Copyright © 2019 Mitsuki Toyota. All rights reserved.
//

#import "WPLBindingDef.h"

/**
 * ValueBinding
 *
 * Viewの値(text/checked, ...) と Sourceの値とをバインドするクラス
 */
@interface WPLValueBinding : NSObject<IWPLBinding>

- (instancetype) initWithCell:(id<IWPLCell>) cell
                       source:(id<IWPLObservableData>) source
                  bindingMode:(WPLBindingMode)bindingMode
                 customAction:(WPLBindingCustomAction)customAction;

/**
 * カスタムアクションを呼び出す (protected)
 */
- (void) invokeCustomActionFromView:(bool) fromView;

@end
