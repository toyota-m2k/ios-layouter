//
//  WPLSubject.h
//
//  Created by Mitsuki Toyota on 2019/12/11.
//  Copyright © 2019 Mitsuki Toyota. All rights reserved.
//

#import "WPLObservableMutableData.h"

@interface WPLSubject : WPLObservableMutableData

/**
 * next() 的なやつ
 * ... valueChanged のエイリアス
 */
- (void) trigger;

/**
 * 値をセットして（値が変化していなくても）valueChangedイベントを発行する。
 * ... WPLSubject.setValue のエイリアス
 */
- (void) trigger:(id)value;

/**
 * リスナー(OnNext的なやつ）を登録
 * ... addValueChangedListener のエイリアス
 *
 * @param target 通知先
 * @param selector メソッドのセレクタ
 * @return 登録されたリスナーを識別するキー --> removeListener に渡して登録解除する
 */
- (id) addListener:(id)target selector:(SEL)selector;

/**
 * リスナーを登録解除する
 * ... removeValueChangedListener のエイリアス
 *
 * @param key addListener の戻り値
 */
- (void) removeListener:(id)key;

@end

