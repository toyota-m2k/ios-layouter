//
//  WPLBindingBase.h
//  layouterSample
//
//  Created by Mitsuki Toyota on 2019/08/05.
//  Copyright © 2019 Mitsuki Toyota. All rights reserved.
//

#import "WPLBindingDef.h"

@interface WPLBindingBase : NSObject<IWPLBinding>

- (instancetype) initWithCell:(id<IWPLCell>)cell
                       source:(id<IWPLObservableData>)source
                  bindingMode:(WPLBindingMode)bindingMode
                 customAction:(WPLBindingCustomAction) customAction;

/**
 * カスタムアクションを呼び出す
 */
- (void) invokeCustomActionFromView:(bool) fromView;

@end
