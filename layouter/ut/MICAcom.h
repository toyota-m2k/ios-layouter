//
//  MICAcom.h
//
//  JavaScript の Promise にインスパイアされた、非同期処理をチェーン化する仕掛け
//
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
/**
 * IMICAcomResolver
 * Promiseチェーン内のタスク間で、タスクの完了を報告するためのi/f
 */
@protocol IMICAcomResolver <NSObject>
- (void) complete:(bool)resolved withParam:(nullable id)param;
@property (nonatomic,nonnull,readonly) void (^resolve)  (_Nullable id result);
@property (nonatomic,nonnull,readonly) void (^reject)  (_Nullable id error);
@end
typedef id<IMICAcomResolver> MICAcomix;

/**
 * IMICAcom, MICPromise
 * 実行可能なタスクを表現するi/f
 */
@protocol IMICAcom <NSObject>
- (void) execute:(bool)resolving chainResult:(nullable id)result acomix:(nullable MICAcomix) acomix;
@end
typedef id<IMICAcom> MICPromise;

#define MIC_PROMISE(type) (MICPromise)

/**
 * IMICAcomFlammable
 * バックグラウンドで実行を開始できるタスクのi/f
 */
@protocol IMICAcomFlammable
- (void) executeBackground;
@end

/**
 * Promiseチェーンを構築するための　CライクなAPIをプロパティとして定義したi/f
 * MICAcomクラスだけが実装
 */
@protocol IMICAcomChain <IMICAcom, IMICAcomFlammable, IMICAwaitable>
@property (nonatomic,nonnull,readonly) id<IMICAcomChain> (^then)    (MICPromise     (^action)(_Nullable id chainedResult));
@property (nonatomic,nonnull,readonly) id<IMICAcomChain> (^ignore)  (MICPromise     (^action)(_Nullable id chainedResult));
@property (nonatomic,nonnull,readonly) id<IMICAcomChain> (^then_)   (void           (^action)(_Nullable id chainedResult, MICAcomix acomix));
@property (nonatomic,nonnull,readonly) id<IMICAcomChain> (^failed)  (void           (^action)(_Nullable id error));
@property (nonatomic,nonnull,readonly) id<IMICAcomChain> (^anyway)  (void           (^action)(_Nullable id param));
@property (nonatomic,nonnull,readonly) id<IMICAcomChain> (^all)     (NSArray<MICPromise>* tasks);
@property (nonatomic,nonnull,readonly) id<IMICAcomChain> (^race)    (NSArray<MICPromise>* tasks);
@property (nonatomic,nonnull,readonly) id<IMICAcomChain> (^seq)     (NSArray<MICPromise>* tasks);
@property (nonatomic,nonnull,readonly) void              (^ignite)  (void);
@end

/**
 * IMICAcomResolverの実装クラス
 */
@interface MICAcomResolverBase : NSObject<IMICAcomResolver>
- (void) dispose;
@end

/**
 * Promiseチェーン構築の親となるクラス
 *  チェーンのノード（タスク）は、IMICAcomChain i/f のメソッド（then,ignore,failed,...)の呼び出しによって生成する。
 *  チェーンを生成したのち、以下のメソッドで、実行を開始（着火）する必要がある。
 *
 *  ignite()
 *  - executeBackground
 *  + beginAsync
 *      サブスレッドを起こして、タスクを実行
 * - 
 *
 */
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

#define MPSV_INT(i) ((i)!=nil && [(i) isKindOfClass:NSNumber.class] ? [(NSNumber*)(i) integerValue] : 0)
#define MPSV_BOOL(i) ((i)!=nil && [(i) isKindOfClass:NSNumber.class] ? [(NSNumber*)(i) boolValue] : false)
#define MPSV_DOUBLE(i) ((i)!=nil && [(i) isKindOfClass:NSNumber.class] ? [(NSNumber*)(i) doubleValue] : 0)

#define MICAcomRESOLVE(v)  [MICAcom resolve:(v)]
#define MICAcomREJECT(v)   [MICAcom reject:(v)]
#define acom_resolve    MICAcom.resolve
#define acom_reject     MICAcom.reject


#define BEGIN_PROMISTIC_ASYNC [MICAcom beginAsync:
#define END_PROMISTIC_ASYNC ];

#if defined(__cplusplus)

@interface MICAcom (CPP)

/**
 * スレッドを考慮して、実行を開始する
 *  - 呼び出しスレッドがメインスレッドなら、サブスレッドを起こして、タスクを実行
 *  - 呼び出しスレッドがサブスレッドなら、
 *      - forceThread == true : サブスレッドを起こしてタスクを実行
 *      - forceThread == false: カレントスレッドでタスクを実行（同期的に実行される：タスク終了まで呼び出しスレッドを占有する）
 */
- (void) launch:(bool) forceThread;

@end

/**
 * MICAcomをC++で、少し綺麗に記述できるようにするラッパー
 * launch / async あたりは、少しだけ kotlin っぽいネーミングにしてみたりして。
 */
class MICAiful {
private:
    MICAcom* _acom;
public:
    /**
     * 空のAcomを作成（ルート用）
     */
    MICAiful() {
        _acom = MICAcom.promise;
    }
    /**
     * PromiseインスタンスからAcomを作成
     * (Promise --> Acom 変換）
     */
    MICAiful(MICPromise promise) {
        _acom = [MICAcom promise:promise];
    }
    /**
     * コピーコンストラクタ
     */
    MICAiful(MICAiful& src) {
        _acom = src._acom;
    }
    /**
     * AwaiterインスタンスからAcomを作成
     * AwaiterをAcomとして利用する場合に使用（たぶん、ほぼ使わないと思う）
     */
    MICAiful(MICAwaiter awaiter) {
        _acom = [MICAcom promise:[MICAcom promiseWithAwaiter:awaiter]];
    }
    /**
     * デストラクタ
     */
    ~MICAiful() {
        _acom = nil;
    }
    
    /**
     * 普通の then ノードを作成
     * Blockが返すMICPromiseが、チェインに挿入される
     */
    MICAiful& then(MICPromise (^action)(id _Nullable chainedResult)) {
        _acom.then(action);
        return *this;
    }
    /**
     * 処理待機用の then ノードを作成
     * Block内で、acomix.resolve()/reject()が呼ばれるまで待機する処理をチェインに挿入する。
     */
    MICAiful& then_(void (^action)(id _Nullable chainedResult, MICAcomix acomix)) {
        _acom.then_(action);
        return *this;
    }

    /**
     * エラーを無視するノードを作成
     * then()とほぼ同じだが、このBlockが返すPromiseがrejectされても、resolveとして処理を継続する点が異なる。
     */
    MICAiful& ignore(MICPromise (^action)(id _Nullable chainedResult)) {
        _acom.ignore(action);
        return *this;
    }
    
    /**
     * エラーを受け取るノードを作成
     * Promiseチェーン内のタスクがrejectされると、それ以降の、then/then_/ignore/all/race/seq はスキップされ、failedノードが実行される。
     */
    MICAiful& failed(void (^action)(id _Nullable error)) {
        _acom.failed(action);
        return *this;
    }
    
    /**
     * エラー/成功にかかわらず呼び出されるノードを作成
     */
    MICAiful& anyway(void (^action)(id _Nullable param)) {
        _acom.anyway(action);
        return *this;
    }
    
    /**
     * 並列実行タスクを登録
     *  全ての実行が成功するとresolveとして、次のノードに遷移する。１つでも失敗すれば reject となる
     */
    MICAiful& all(NSArray<MICPromise>* tasks) {
        _acom.all(tasks);
        return *this;
    }
    /**
     * 並列実行タスクを登録
     *  １つでもタスクが成功するとresolveとして、次のノードに遷移する。すべてのタスクが失敗すれば、reject となる
     */
    MICAiful& race(NSArray<MICPromise>* tasks) {
        _acom.race(tasks);
        return *this;
    }
    /**
     * 直列実行タスクを登録
     *  then で接続するのと同じ効果だが、チェーンを動的に作成する場合に利用する。
     */
    MICAiful& seq(NSArray<MICPromise>* tasks) {
        _acom.seq(tasks);
        return *this;
    }
    
    /**
     * Acom 変換
     */
    operator MICAcom* _Nonnull () const {
        return _acom;
    }
    
    /**
     * Acom を取得
     */
    MICAcom* acom() const {
        return _acom;
    }
    
    /**
     * 実行開始（終了を待たない）
     * 通常はサブスレッドを起動してタスクを実行するが、
     * forceBackThread == false で、カレントスレッドがMainThreadでなければ、カレントスレッドのままタスクを実行する。
     * つまり、この場合は、同期的にタスクが実行されることになる。
     */
    void launch(bool forceBackThread=false) const {
        [_acom launch:forceBackThread];
    }
    
    /**
     * 実行を開始し、終了まで待機可能なMICAwaiterオブジェクトを返す。
     * 通常はサブスレッドを起動してタスクを実行するが、
     * カレントスレッドがMainThreadでなければ、カレントスレッドのままタスクを実行する（同期的にタスクを実行）。
     * launchと異なり、強制的に別のスレッドで実行するオプションはないが、asyncを使うのは、Awaiterによる待ち合わせが目的のはずなので問題ないはず。
     */
    MICAwaiter async() {
        return _acom.awaiter;
    }
    
    /**
     * タスクを開始して、終わるまで待機し、結果を返す。
     * 呼び出しスレッドを待機するので、メインスレッドから呼び出してはいけない。
     */
    id<IMICAwaiterResult> await() {
        return _acom.awaiter.await;
    }
    
    /**
     * バックグラウンド呼び出しの起点を明確化するための、ちょっと回りくどいタスク開始メソッド
     * BEGIN_AIFUL_LAUNCH, BEGIN_AIFUL_LAUNCH__ で使用
     */
    static void launch(bool forceBackground, MICAcom* acom) {
        [acom launch:forceBackground];
    }
    
    /**
     * 同上
     * BEGIN_AIFUL_ASYNC で使用。
     */
    static MICAwaiter async(MICAcom* acom) {
        return acom.awaiter;
    }
};

// launch(forceBackground=false, acom)
#define BEGIN_AIFUL_LAUNCH      MICAiful::launch(false,
// launch(forceBackground=true, acom)
#define BEGIN_AIFUL_LAUNCH__    MICAiful::launch(true,
// async(acom)
#define BEGIN_AIFUL_ASYNC       MICAiful::async(
#define END_AIFUL               );
#define acom_await(promise)    MICAiful(promise).await()

#endif

NS_ASSUME_NONNULL_END

#endif // __MICACOM_H__
