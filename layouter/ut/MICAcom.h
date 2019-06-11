//
//  MICAcom.h
//  MICPromisticの改良版
//  MICPromisticは、着火したスレッド（たとえばメインスレッド）で実行を開始するのに対し、MICAcomは、サブスレッドで実行する。
//  つまり、MICPromisticを使う場合、呼び出し元で意識して非同期化する必要があったが、MICAcomは最初から非同期化することが保証される。
//  また、MICPromisticはタスクチェーンがそのままコールスタックになるため、チェーンが長いと、その分、スタックが深くなるという構造的欠陥を持っているので、
//  今後は、できるだけMICAcomの方を使うようにしたい。
//
//  Created by @toyota-m2k on 2018/11/21.
//  Copyright  2018年 @toyota-m2k. All rights reserved.
//
#ifndef __MICACOM_H__
#define __MICACOM_H__

#ifdef __MICPROMISTIC_H__
#error Danger!! Don't mix acom with promisetic!
#endif

#import <Foundation/Foundation.h>
#import "MICAsync.h"


NS_ASSUME_NONNULL_BEGIN

//--------------------------------------------------------------------------------------------------------------
// Interfaces
//--------------------------------------------------------------------------------------------------------------
@protocol IMICAcomResolver <NSObject>
- (void) complete:(bool)resolved withParam:(nullable id)param;
@property (nonatomic,nonnull,readonly) void (^resolve)  (_Nullable id result);
@property (nonatomic,nonnull,readonly) void (^reject)  (_Nullable id error);
@end
typedef id<IMICAcomResolver> MICAcomix;

@protocol IMICAcom <NSObject>
- (void) execute:(bool)resolving chainResult:(nullable id)result acomix:(nullable MICAcomix) acomix;
@end
typedef id<IMICAcom> MICPromise;

@protocol IMICAcomFlammable
- (void) executeBackground;
@end

@protocol IMICAcomChain <IMICAcom, IMICAcomFlammable, IMICAwaitable>
@property (nonatomic,nonnull,readonly) id<IMICAcomChain> (^then)    (MICPromise     (^action)(_Nullable id chainedResult));
@property (nonatomic,nonnull,readonly) id<IMICAcomChain> (^ignore)  (MICPromise     (^action)(_Nullable id chainedResult));
@property (nonatomic,nonnull,readonly) id<IMICAcomChain> (^then_)   (void           (^action)(_Nullable id chainedResult, MICAcomix acomix));
@property (nonatomic,nonnull,readonly) id<IMICAcomChain> (^failed)  (void           (^action)(_Nullable id error));
@property (nonatomic,nonnull,readonly) id<IMICAcomChain> (^anyway)  (void           (^action)(_Nullable id param));
@property (nonatomic,nonnull,readonly) id<IMICAcomChain> (^all)     (NSArray* tasks);
@property (nonatomic,nonnull,readonly) id<IMICAcomChain> (^race)    (NSArray* tasks);
@property (nonatomic,nonnull,readonly) id<IMICAcomChain> (^seq)     (NSArray* tasks);
@property (nonatomic,nonnull,readonly) void              (^ignite)  (void);
@end

@interface MICAcomResolverBase : NSObject<IMICAcomResolver>
- (void) dispose;
@end

@interface MICAcom : MICAcomResolverBase<IMICAcomChain,IMICAcom, IMICAwaitable>

+ (instancetype) promise;
+ (instancetype) promise:(MICPromise) sub;

+ (MICPromise) resolve:(nullable id) param;
+ (MICPromise) resolve;
+ (MICPromise) reject:(nullable id) param;
+ (MICPromise) reject;
+ (MICPromise) action:(void (^)(_Nullable id chainedResult, MICAcomix acomix)) action;

+ (MICBackgroundExecutor) executor;

+ (void) beginAsync:(id<IMICAcomFlammable>) promise;
+ (MICPromise) promiseWithAwaiter:(MICAwaiter) awaiter;

@end

@interface MICAsyncAwaiterAcom : NSObject<IMICAcom>

+ (instancetype) promise:(MICAwaiter) awaiter;
- (instancetype) initWithAwaiter:(MICAwaiter) awaiter;

@end

NS_ASSUME_NONNULL_END

#define MPSV_INT(i) ((i)!=nil && [(i) isKindOfClass:NSNumber.class] ? [(NSNumber*)(i) integerValue] : 0)
#define MPSV_BOOL(i) ((i)!=nil && [(i) isKindOfClass:NSNumber.class] ? [(NSNumber*)(i) boolValue] : false)

#define MICAcomRESOLVE(v)  [MICAcom resolve:(v)]
#define MICAcomREJECT(v)   [MICAcom reject:(v)]

#define BEGIN_PROMISTIC_ASYNC [MICAcom beginAsync:
#define END_PROMISTIC_ASYNC ];

#endif // __MICACOM_H__
