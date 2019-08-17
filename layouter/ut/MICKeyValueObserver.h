//
//  MICKeyValueObserver.h
//  NSKeyValueObserverRegistration に対するオブザーバー登録／解除をいい具合にする
//
//  Created by @toyota-m2k on 2017/11/02.
//  Copyright  2017年 @toyota-m2k Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IMICKeyValueObserverItem <NSObject>
@property (nonatomic,readonly) NSString* key;
@property (nonatomic,readonly) NSDictionary* change;
@property (nonatomic,readonly) void* context;
@end


typedef void (^MICObserverActionProc)(id<IMICKeyValueObserverItem> info, id target);

@interface MICKeyValueObserver : NSObject

/**
 * @param actor     監視対象
 */
- (instancetype) initWithActor:(id)actor;

/**
 * オブザーバーを追加
 *
 * @param   key         監視対象のプロパティ名　(@"frame", @"contentSize"など）
 * @param   listener    リスナーオブジェクト(handlerの持ち主）
 * @param   handler     リスナーのセレクタ
 * @param   options     NSKeyValueObservingOptions
 * @param   context     handlerに渡す任意の値
 *
 * handlerの型
 *  - (void) handler:(id<IMICKeyValueObserverItem>) info target:(id)target;
 *
 */
- (void) add:(NSString*)key listener:(id)listener handler:(SEL)handler options:(NSKeyValueObservingOptions)options context:(void*)context;
/**
 * オブザーバーを追加
 *
 * @param   key         監視対象のプロパティ名　(@"frame", @"contentSize"など）
 * @param   listener    リスナーオブジェクト(handlerの持ち主）
 * @param   handler     リスナーのセレクタ
 */
- (void) add:(NSString*)key listener:(id)listener handler:(SEL)handler;

/**
 * オブザーバーを追加 (ブロック型リスナーを使用するバージョン）
 *
 * @param   key         監視対象のプロパティ名　(@"frame", @"contentSize"など）
 * @param   action      リスナー
 * @param   options     NSKeyValueObservingOptions
 * @param   context     handlerに渡す任意の値
 */
- (void) add:(NSString*)key action:(MICObserverActionProc) action options:(NSKeyValueObservingOptions)options context:(void*)context;

/**
 * オブザーバーを追加 (ブロック型リスナーを使用するバージョン）
 *
 * @param   key         監視対象のプロパティ名　(@"frame", @"contentSize"など）
 * @param   action      リスナー
 */
- (void) add:(NSString*)key action:(MICObserverActionProc) action;

/**
 * オブザーバーを削除
 */
- (void) remove:(NSString*)key;
- (void) removeAll;
- (void) dispose;

@end
