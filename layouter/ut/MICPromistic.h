//
//  MICPromisetic.h
//  Promise風ユーティリティクラス
//  非同期処理が目的ならMICAcomの利用を推奨。
// Kohibariのtmで使ってしまったから残すことにした。UI制御などUIスレッドでチェーンする必要があるときは、MICAcomより使いやすいのだ。
//
//  Created by toyota-m2k on 2018/10/05.
//  Copyright © 2018年 toyota-m2k. All rights reserved.
//
#ifndef __MICPROMISTIC_H__
#define __MICPROMISTIC_H__

#ifdef __MICACOM_H__
#error Danger!! Don't mix acom with promistic!
#endif

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class MICPromistic;

#pragma mark プロトコル定義

/**
 * id<MICPromisticCallback>
 * エイリアス：MICPromix
 *
 * then
 * このオブジェクトの resolve / reject を呼び出すことにより次のthen/failedブロックに制御が移る。
 */
@protocol MICPromisticCallback
@property (nonatomic, readonly) void (^resolve)(_Nullable id result);
@property (nonatomic, readonly) void (^reject)(_Nullable id error);
@end
typedef id<MICPromisticCallback> MICPromix;

#pragma mark -

///**
// * failedブロックに渡されるPromiseオブジェクト
// */
//@protocol MICPromisticIdentifier
//@end
//typedef id<MICPromisticIdentifier> MICPromiy;
//
//#pragma mark -

/**
 * Promisticで待ち合わせ可能なインターフェース定義
 */
@protocol MICPromisticAwaitable <MICPromisticCallback>
@property (nonatomic, readonly) MICPromistic* await;
@end
typedef id<MICPromisticAwaitable> MICAwaitabee;

#pragma mark - ブロック関数型定義

/**
 * then_ブロック型
 * 単独でthenノードになる関数型
 *
 * @param chainedResult １つ前のthenブロックがresolveした値
 * @param promix resolve/rejectするためのハンドラ
 *
 * thenブロックの処理が完了するまで、このpromixハンドラをretainしておかないと、Promisticノードが解放されてエラーになることがあるので注意
 * うっかり、非同期APIに、promix.resolve/reject の値だけを渡して処理するコードを書いたら、resolve/rejectを呼び出すタイミングで、
 * Promisticノードが解放されていて、次のノードに制御が移らない現象が発生してハマった。
 *
 * また、promix.resolveまたは、rejectを呼び出さないと、Promisticノードがリークする恐れがあるので、ここも注意。
 * これらの観点から、（効率は若干悪いが、）次の thenブロック＋MICPromisticChainAction型ハンドラを使う方が多少安全かもしれない。
 */
typedef void (^MICPromisticAction)(_Nullable id chainedResult, MICPromix promix);

/**
 * thenブロック型
 *
 * @param chainedResult １つ前のthenブロックがresolveした値
 * @return  thenブロックのサブタスクとして接続するMICPromisticチェーン
 *          nilを返すと、resolve(chainResult)として扱う。(return [MICPromistic promiseticResolve]; と等価）
 */
typedef  MICPromistic* _Nonnull  (^MICPromisticChainAction)(_Nullable id chainedResult);

/**
 * failedブロック型
 *
 * @param error     １つ前のthenブロックがrejectした値
 */
typedef void (^MICPromisticErrorHandler)(_Nullable id error);

/**
 * anywayブロック型
 */
typedef void (^MICPromisticAnywayHandler)(_Nullable id param);


#pragma mark -
/**
 * MICPromistic : Promise的なもの。
 *
 *  非同期処理を直列に並べることだけを目的としており、本当のPromiseやco と完全に同じ動作を期待されては困る。
 *  また、このクラスそのものは、スレッドは起こさないし、意識もしない。
 *  thenブロック内で、適切にスレッド操作が行われているものとし、一つ前のthenブロックのスレッドで、次のthenブロックが呼び出される。
 *  適宜、UIスレッドやサブスレッドへのスイッチを行うこと。
 */

@interface MICPromistic : NSObject<MICPromisticCallback>

#pragma mark Promisticメソッド（C関数型プロパティ）

/**
 * thenブロック設定メソッド（というか実装上は関数型のプロパティ）
 * MICPromisticActionのコメントを参照
 */
@property (nonatomic, readonly) MICPromistic* (^then_)(_Nonnull MICPromisticAction action);

/**
 * then_ブロック設定メソッド（というか実装上は関数型のプロパティ）
 * MICPromisticChainActionのコメントを参照
 */
@property (nonatomic, readonly) MICPromistic* (^then)(_Nonnull MICPromisticChainAction promistic);

/**
 * 引数のpromisticが失敗(reject)しても無視して、resolve()として次に進める thenの亜種
 */
@property (nonatomic, readonly) MICPromistic* (^ignore)(_Nonnull MICPromisticChainAction promistic);

/**
 * Promiseチェーンそのものを追加するメソッド
 * then と比較すると、呼び出した時点でPromisticリストが構築・追加される（inject）か、ノードに着火した時点でPromisticリストが構築される（then）か、という違いがある。
 */
@property (nonatomic, readonly) MICPromistic* (^inject)(MICPromistic* action);

/**
 * failedブロック設定
 * (javascriptでは、catchブロックだが、ObjC予約語のため、failed とした）
 */
@property (nonatomic, readonly) MICPromistic* (^failed)(_Nonnull MICPromisticErrorHandler errorHandler);

/**
 * anywayブロック設定
 * (javascriptではfinallyだが、予約語回避のため anywayとした）
 *
 * 処理フローとしては、(thenブロックではなく）failedブロックに準ずる。つまり、anywayブロックにPromiseブロックを内包することはできない。
 * また、anyway().then()のように繋いだ時、thenブロックが実行されるとは限らない（anyway以前のresolve/reject状態に依存する。）
 * reject/resolve状態に関わらず、プロミスチェーンを続けたい場合は、ignore()ブロックを使う。
 */
@property (nonatomic, readonly) MICPromistic* (^anyway)(_Nonnull MICPromisticAnywayHandler anywayHandler);

/**
 * 並列実行
 * - すべて実行。
 * - すべて成功したらresolve、１つでもエラーが起きたらrejectとして扱う
 * - 各タスクの結果は NSArrayに格納して、resolveのchainedResult、または、rejectのerrorパラメータとして返す。
 */
@property (nonatomic, readonly) MICPromistic* (^all)(NSArray* promistics);
/**
 * 並列実行
 * javascriptでは、一番早く完了した返した結果を返すやつだが、本物の非同期処理ではないので、そうもいかず、
 * allとほぼ同様の動作とし、「１つでも成功したらresolve / すべて失敗した場合だけrejectとして扱う」点だけ区別した。
 */
@property (nonatomic, readonly) MICPromistic* (^race)(NSArray* promistics);
/**
 * Promisticチェーンの実行開始
 */
@property (nonatomic, readonly) MICPromistic* (^ignite)(void);

#pragma mark - Promisticインスタンス生成

/**
 * 空のPromiseを作成
 * igniteメソッドが呼ばれない限り、自動的には実行されない。
 */
+ (instancetype) promistic;

/**
 * アクションを指定して Promiseを作成
 * igniteメソッドが呼ばれない限り、自動的には実行されない。
 */
+ (instancetype) promisticAction:(MICPromisticAction) action;

/**
 * 着火するとすぐにrejectするPromisticインスタンスを生成
 */
+ (instancetype) promisticReject;
+ (instancetype) promisticRejectWithError:(_Nullable id) error;

/**
 * 着火するとすぐにresolveするPromisticインスタンスを生成
 */
+ (instancetype) promisticResolve;
+ (instancetype) promisticResolveWithParam:(_Nullable id) param;

#pragma mark -
/**
 * Promisticによる非同期処理を開始する。
 * @param promise   ignite するpromisticなやつ
 * @param queue     スレッドを開始するためのOperationQueue。nil なら、メソッド内で勝手に作って使う。
 */
+ (void) beginAsync:(MICPromistic*) promise onOperationQueue:( NSOperationQueue* _Nullable )queue;
+ (void) beginAsync:(MICPromistic*) promise;

@end

#define BEGIN_PROMISTIC_ASYNC [MICPromistic beginAsync:
#define END_PROMISTIC_ASYNC ];

#define MICPROMISTIC_ENABLE_DEBUGGER (1)
#if MICPROMISTIC_ENABLE_DEBUGGER
@interface MICPromistic (Debug)
- (void) dump:(NSString*) prefix;
- (int) tag;
@end

@interface MICPromisticDebugger : NSObject
+ (MICPromisticDebugger*) instance;
- (void) clear;
- (void) dump:(NSString*) prefix;
- (NSInteger) leakedCount;
#define MICPROMISTIC_DEV_DUMP(m) [MICPromisticDebugger.instance dump:m];
#define MICPROMISTIC_DEV_CLEAR [MICPromisticDebugger.instance clear];
#define MICPROMISTIC_DEV_LEAKED [MICPromisticDebugger.instance leakedCount]
@end
#else
#define MICPROMISTIC_DEV_DUMP(m)
#define MICPROMISTIC_DEV_CLEAR
#define MICPROMISTIC_DEV_LEAKED 0
#endif


NS_ASSUME_NONNULL_END

#define MPSO_INT(v) [NSNumber numberWithInteger:v]
#define MPSO_BOOL(v) [NSNumber numberWithBool:v]
#define MPSV_INT(i) ((i)!=nil && [(i) isKindOfClass:NSNumber.class] ? [(NSNumber*)(i) integerValue] : 0)
#define MPSV_BOOL(i) ((i)!=nil && [(i) isKindOfClass:NSNumber.class] ? [(NSNumber*)(i) boolValue] : false)

#endif // __MICPROMISTIC_H__
