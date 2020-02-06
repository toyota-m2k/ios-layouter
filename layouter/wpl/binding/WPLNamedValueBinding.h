//
//  WPLNamedValueBinding.h
//
//  Created by @toyota-m2k on 2020/02/03.
//  Copyright @toyota-m2k. All rights reserved.
//

#import "WPLGenericBinding.h"

@interface WPLNamedValueBinding : WPLGenericBinding

- (instancetype) initWithCell:(id<IWPLCellSupportNamedValue>) cell
                    valueName:(NSString*) valueName
                       source:(id<IWPLObservableData>) source
                  bindingMode:(WPLBindingMode)bindingMode
                 customAction:(WPLBindingCustomAction)customAction;

@end
