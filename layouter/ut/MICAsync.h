//
//  MICAsync.h
//  AnotherWorld
//
//  Created by @toyota-m2k on 2018/11/22.
//  Copyright  2018年 @toyota-m2k. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/**
 * IMICAwaiterResult
 * Awaiterが返す戻り値型
 */
@protocol IMICAwaiterResult <NSObject>
@property (nonatomic,readonly,nullable) id result;
@property (nonatomic,readonly,nullable) id error;
@end

/**
 * IMICAwaitable
 * Awaiterを返すことができるオブジェクトのプロトコル
 */
@protocol IMICAwaiter;
@protocol IMICAwaitable <NSObject>
- (id<IMICAwaiter>) awaiter;
@end

/**
 * Awaiterの待ち合わせ完了イベントのハンドラ型
 * 普通は、await/getResultなどで待ち合わせを行うが、コールバック型での待ち合わせもできるという贅沢設計。
 * しかも、このハンドラはmain threadから呼び出されることを保証する。
 */
typedef void(^MICAwaiterCompleteHandler)(id result, id error);

/**
 * IMICAwaiter
 * 待ち合わせ可能なオブジェクトのプロトコル
 */
@protocol IMICAwaiter <IMICAwaitable>
- (id<IMICAwaiterResult>) await;
- (nullable id) getResult;
- (nullable id) getError;
- (bool) isCompleted;
@property (nonatomic,nullable) MICAwaiterCompleteHandler completed;   // call in main thread
@end
typedef id<IMICAwaiter> MICAwaiter;

/**
 * IMICCompleter
 * Awaiterの待ち合わせを完結させるためのi/fをた定義したプロトコル
 */
@protocol IMICCompleter <NSObject>
- (void) setResult:(nullable id) result;
- (void) setError:(id) error;
@end
typedef id<IMICCompleter> MICCompleter;

/**
 * MICTaskAwaiter
 * Awaiter/Completerの基本的な待ち合わせを実装したコンクリートクラス
 */
@interface MICTaskAwaiter : NSObject<IMICCompleter, IMICAwaiter, IMICAwaiterResult>
@end

/**
 * MICCompletedAwaiter
 *  待ち合わせ不要なAwaiter.
 *  同期的な処理をIMICAwaiter互換のAPIで扱うための実装
 */
@interface MICCompletedAwaiter : NSObject<IMICAwaiter, IMICAwaiterResult>
+ (instancetype) error:(nonnull id) error;
+ (instancetype) result:(nullable id) result;
@end

/**
 *
 */
@protocol IMICBackgroundExecutor <NSObject>
- (void) execute:(void(^)(void)) runnable;
@end
typedef id<IMICBackgroundExecutor> MICBackgroundExecutor;

/**
 * MICAsync
 * Asyncユーティリティクラス
 */
typedef id<IMICAwaiterResult> _Nullable (^MICAwaitProc)(id awaitable);
@interface MICAsync : NSObject

/**
 * サブスレッドを起動するための共通OperationQueue
 */
+ (MICBackgroundExecutor) executor;

/**
 * 非同期処理を開始する
 * 非同期処理ブロック(blockableAction)内で、await 関数を使って待ち合わせを行う。
 * この処理全体が、再帰的にAwaiterを返すので、呼び出し元での完了監視などが可能。
 */
+ (MICAwaiter) async:(id<IMICAwaiterResult> (^)(MICAwaitProc await)) blockableAction;

/**
 * サブスレッドから呼び出されていなければNSAssert()を呼び出す。
 */
+ (void) assertSubThread;

/**
 * メインスレッドでactionを実行
 * actionの終了まで待機
 */
+ (void) mainThread:(void(^)(void)) action;
/**
 * メインスレッドでactionを実行
 * actionを待機することなく、すぐに制御を戻す。
 */
+ (void) mainThreadAsync:(void(^)(void)) action;
/**
 * メインスレッドでfuncを実行して、その戻り値を返す。
 * funcの終了まで待機
 */
+ (id) mainThreadFunc:(id(^)(void)) func;

/**
 * actionをメインスレッドのキューに積む
 * （現在のメインスレッドのコールスタックを抜けた後で実行する）
 */
+ (void) mainThreadEnqueue:(void(^)(void)) action;


/**
 * delayInSec後にメインスレッドで実行
 */
+ (void) mainThreadDelay:(double)delayInSec action:(void(^)(void)) action;

+ (id<IMICAwaiterResult>) resultError:(id)error;
+ (id<IMICAwaiterResult>) resultSuccess:(nullable id)result;

@end

#define MIC_ASSERT_SUB_THREAD    NSAssert(!NSThread.isMainThread, @"must be called in sub-thread.")
#define MIC_ASSERT_MAIN_THREAD   NSAssert(NSThread.isMainThread, @"must be called in main-thread.")

#ifdef __cplusplus
class MICMainThread {
public:
    MICMainThread() {}
    
    void run(void(^action)(void)) {
        [MICAsync mainThread:action];
    }
    
    void runAsync(void(^action)(void)) {
        [MICAsync mainThreadAsync:action];
    }
    
    id run(id(^func)(void)) {
        return [MICAsync mainThreadFunc:func];
    }
    
    void enqueue(void(^action)(void)) {
        [MICAsync mainThreadEnqueue:action];
    }
    
    void delay(double sec, void(^action)(void)) {
        [MICAsync mainThreadDelay:sec action:action];
    }
};
#endif

NS_ASSUME_NONNULL_END
