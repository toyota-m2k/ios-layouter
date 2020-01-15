//
//  WPLCommandBinding.h
//  ボタンなどのタップイベントをValueChangedイベントとして発行するバインディングクラス
//
//  Created by Mitsuki Toyota on 2019/12/17.
//  Copyright © 2019 MichaelSoft. All rights reserved.
//

#import "WPLGenericBinding.h"

@interface WPLCommandBinding : WPLGenericBinding

/**
 * タップイベントとバインドするクラス
 */
- (instancetype) initWithCell:(id<IWPLCell>) cell
                       source:(id<IWPLObservableData>) source   // 通常は WPLSubject を使用する
//                  bindingMode:(WPLBindingMode)bindingMode     // VIEW_TO_SOURCE 一択
                 customAction:(WPLBindingCustomAction)customAction;

@end

