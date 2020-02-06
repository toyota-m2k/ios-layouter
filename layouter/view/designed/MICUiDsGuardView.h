//
//  MICUiDsGuardView.h
//
//  Created by @toyota-m2k on 2020/02/04.
//  Copyright (c) 2020 @toyota-m2k. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MICUiDsGuardView : UIView

/**
 * タップイベントのリスナー
 * - (void) onGuardViewTapped;
 */
- (void) setTouchListener:(id) target action:(SEL) action;
/**
 * GuardViewを表示（hidden=falseと同じ）
 */
- (void) show;
/**
 * GuardViewを非表示にする（hidden=trueと同じ）
 */
- (void) hide;

/**
 * GuardViewをせ作成＆タップリスナーをセットして、rootViewにaddSubviewする。
 * 作成されたGuardViewは初期状態で非表示。
 */
+ (instancetype) guardViewOnRootView:(UIView*) rootView
                              target:(id) target
                              action:(SEL) action
                             bgColor:(UIColor*) bgColor;

/**
* GuardViewをせ作成＆タップリスナーをセットして、rootViewにaddSubviewする。
* 作成されたGuardViewは初期状態で非表示。
*/
+ (instancetype) guardViewOnRootView:(UIView*) rootView
                              target:(id) target
                              action:(SEL) action;

@end

