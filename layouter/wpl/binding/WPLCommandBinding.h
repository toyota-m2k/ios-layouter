//
//  WPLCommandBinding.h
//  ボタンなどのタップイベントをValueChangedイベントとして発行するバインディングクラス
//
//  Created by toyota-m2k on 2019/12/17.
//  Copyright © 2019 toyota-m2k. All rights reserved.
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

