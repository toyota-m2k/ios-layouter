//
//  MICObservers.h
//  NSKeyValueObserverRegistration に対するオブザーバー登録／解除をいい具合にする
//
//  Created by @toyota-m2k on 2017/11/02.
//  Copyright  2017年 @toyota-m2k Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MICObservers : NSObject

/**
 * @param observer  observeValueForKeyPathメソッドを実装するオブジェクト
 */
- (instancetype) initWithObserver:(id)observer;

/**
 * オブザーバーを追加
 *
 * handlerの型
 *  - (void) handler:(id)target (NSDictionary*)change (void*)context
 */
- (void) add:(NSString*)key to:(id)target listener:(id)listener handler:(SEL)handler;
- (void) add:(NSString*)key to:(id)target listener:(id)listener handler:(SEL)handler options:(NSKeyValueObservingOptions)options context:(void*)context;

/**
 * オブザーバーを削除
 */
- (void) remove:(NSString*)key from:(id)target;
- (void) removeAll;
- (void) dispose;

/**
 * 実行
 */
- (void) observe:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void*)context;

@end
