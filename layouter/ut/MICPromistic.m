//
//  MICPromistic.m
//  Promise風ユーティリティクラス
//
//  Created by toyota-m2k on 2018/10/05.
//  Copyright © 2018年 toyota-m2k. All rights reserved.
//

#import "MICPromistic.h"
#import "MICVar.h"

static int TAG_GENERATOR = 0;


#pragma - mark デバッグ用

#if MICPROMISTIC_ENABLE_DEBUGGER

#define DEALLOC_TEST    false   // trueにすると、deallocされたかどうかも記録する

#define DEV_REG(p)  [MICPromisticDebugger.instance regist:p];
#define DEV_UNREG(p)  [MICPromisticDebugger.instance unregist:p];
#define DEV_FIN(p)  [MICPromisticDebugger.instance removed:p];

//#define DEV_DUMP(m) MICPromisticDebugger.instance.dump(m)

@implementation MICPromisticDebugger {
    NSMutableDictionary* _mapPromise;
}

+ (MICPromisticDebugger*) instance {
    static MICPromisticDebugger* _instance = nil;
    if(nil==_instance) {
        _instance = [[MICPromisticDebugger alloc] init];
    }
    return _instance;
    
}

- (instancetype) init {
    self = [super init];
    if(nil!=self) {
        _mapPromise = [NSMutableDictionary dictionary];
    }
    return self;
}
- (void) regist:(MICPromistic*) promise {
    [promise dump:@"++"];
    [_mapPromise setObject:promise forKey:[NSNumber numberWithInt:promise.tag]];
}
- (void) unregist:(MICPromistic*) promise {
    [promise dump:@"--"];
    if(DEALLOC_TEST) {
        [_mapPromise setObject:NSNull.null forKey:[NSNumber numberWithInt:promise.tag]];
    } else {
        [_mapPromise removeObjectForKey:[NSNumber numberWithInt:promise.tag]];
    }
}

- (void) removed:(MICPromistic*) promise {
    [promise dump:@"~~"];
    if(DEALLOC_TEST) {
        [_mapPromise removeObjectForKey:[NSNumber numberWithInt:promise.tag]];
    }
}

- (void) dump:(NSString*) prefix {
    if(_mapPromise.count==0) {
        NSLog(@"%@:no promistic.", prefix);
    } else {
        NSLog(@"%@:dump promistics.", prefix);
        for(NSNumber* key in _mapPromise.allKeys) {
            id p = _mapPromise[key];
            if(p == NSNull.null) {
                NSLog(@"  disposed but not dealloced: %d", key.intValue);
            } else {
                [p dump: @"  not disposed"];
            }
        }
    }
}

- (NSInteger) leakedCount {
    return _mapPromise.count;
}

- (void)clear {
    [_mapPromise removeAllObjects];
}

@end
#else

#define DEV_REG(p)
#define DEV_UNREG(p)
#define DEV_FIN(p)

#endif


#pragma - mark 内部クラスの宣言

/**
 * 並列実行(all/race)ようPromistic派生クラス
 */
@interface MICParallelPromistic : MICPromistic
- (instancetype) initWithPromistics:(NSArray*)promistics forRace:(bool)race;
@end

/**
 * Promisticチェーンの燃焼状態に関係なく、任意のタイミング(＝ノードのexecute前)にresolve/reject可能なPromistic派生クラス
 * 通常のPromisticは、Promiseチェーンが順次実行される過程で、thenノード内から、resolve/rejectされることにより、状態遷移するが、
 * .NETのTaskCompletionSourceなどのように（待ち方はぜんぜん違うが）、Promisticな仕掛けで、スレッド間の待ち合わせになどに利用する。
 */
@interface MICAsyncPromistic : MICPromistic<MICPromisticAwaitable>
@end

#pragma mark -

/**
 * 基本のPromisticクラス実装
 */
@implementation MICPromistic {
    MICPromisticAction _action;
    MICPromisticErrorHandler _errorHandler;
    MICPromisticAnywayHandler _anywayHandler;
    
    MICPromistic* _next;
    MICPromistic* _head;
    bool _burnt; // for debug
    int _tag;   // for debug
//    NSString* _label;
}

@synthesize reject = _reject;
@synthesize resolve = _resolve;

#pragma mark - 状態

/**
 * ノードは燃えているか
 */
- (bool) burnt {
    return self.first->_burnt;
}

/**
 * タグ（デバッグ情報）
 */
- (int) tag {
    return _tag;
}

- (void) dump:(NSString*) prefix {
    NSLog(@"%@:Promistic-%d", prefix, _tag);
}


//- (void) log:(NSString*) msg {
//    if(nil!=_label) {
//        NSLog(@"Promistic: %d (%@): %@", _tag, _label, msg);
//    } else {
//        NSLog(@"Promistic: %d : %@", _tag, msg);
//    }
//}

#pragma mark - 実行・動作制御メソッド

/**
 * Promiseチェーンに着火する。
 */
- (void) execute:(id)chainedResult {
    if(_burnt) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"MICPromistic: the task to be executed is already burning or has been burnt."
                                     userInfo:nil];
    }
    _burnt = true;
    if(nil!=_action) {
        @try {
            _action(chainedResult, self);
        } @catch (NSException* e) {
            NSLog(@"MICPromistic.execute: actionHandler caught exception: %@",e.reason);
            [self setError:e];
        }
    } else {
        if(nil!=_anywayHandler) {
            @try {
                _anywayHandler(chainedResult);
            } @catch(NSException* e) {
                // anyway のエラーは無視
                NSLog(@"MICPromistic.execute: anywayHandler caught exception: %@",e.reason);
            }
        }
        if( nil!=_next) {
            [_next execute:chainedResult];
        }
        [self dispose];
    }
}

/**
 *  errorHandlerを呼び出しながら、残りのPromiseを蹴散らす。
 */
- (void) abort:(id) error {
    if(_burnt) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"MICPromistic: the task to be aborted is already burning or has been burnt."
                                     userInfo:nil];
    }
    _burnt = true;
    if(nil!=_errorHandler) {
        @try {
            _errorHandler(error);
        } @catch (NSException* e) {
            NSLog(@"MICPromistic.abort: errorHandler caught exception: %@",e.reason);
        }
    }
    if(nil!=_anywayHandler) {
        @try {
            _anywayHandler(error);
        } @catch (NSException* e) {
            NSLog(@"MICPromistic.abort: anywayHandler caught exception: %@",e.reason);
        }
    }
    if( nil!=_next) {
        [_next abort:error];
    }
    [self dispose];
}

/**
 * resolve()の処理の中身。
 * 次のPromiseをキックする
 */
- (void) setResult:(id)result {
    if(_next!=nil) {
        [_next execute:result];
    }
    NSLog(@"setResult: promistic chain resolved.");
    [self dispose];
}

/**
 *  reject()の中身
 *  自分自身の_errorHandlerを呼んでから、残りのノードを abort する
 */
- (void) setError:(id)error {
    NSAssert(_errorHandler==nil, @"a promise node has both errorHandler and actionHandler");
//    if(nil!=_errorHandler) {
//        @try {
//        _errorHandler(error, self);
//        } @catch(NSException* e) {
//            NSLog(@"MICPromistic.setError: _errorHandler caught exception: %@",e.reason);
//        }
//    }
    NSLog(@"setError: promistic chain rejected.");
    if(nil!=_next) {
        [_next abort:error];
    }
    [self dispose];
}

#pragma mark - 非同期処理としてPromiseを開始する

/**
 * Promisticによる非同期処理を開始する。
 * @param promise   ignite するpromisticなやつ
 * @param queue     スレッドを開始するためのOperationQueue。nil なら、メソッド内で勝手に作って使う。
 */
+ (void)beginAsync:(MICPromistic *)promise onOperationQueue:(NSOperationQueue *)queue {
    if(nil==queue) {
        queue = [[NSOperationQueue alloc] init];
    }
    [queue addOperationWithBlock:^{
        promise.ignite();
    }];
}

+ (void)beginAsync:(MICPromistic *)promise {
    return [self beginAsync:promise onOperationQueue:nil];
}

#pragma mark - Promiseチェーン操作メソッド

/**
 * Promiseチェーン点火後は、ノードの追加NGなので、チェックして例外を投げる。
 */
- (void) validateBeforeAddingNode {
    if(self.burnt) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"cannot add promistic nodes after the chain being ignited"
                                     userInfo:nil];
    }
}

/**
 * parentTaskのサブタスクとしてsubTask（未着火）を追加して、着火する。
 *  親タスクのthenハンドラ内で実行する。
 *  subTaskが成功(then)、失敗(failed)したタイミングで、parentTask.resolve/rejectが呼び出される。
 *
 * then()ブロックに return文を書き忘れると、このメソッドで　EXC_BAD_ACCESSが出ることがある。（return文がないのは、文法エラーでコンパイルできないはずなのだが、xcodeがとてつもなくクソなのだ。）
 */
+ (void) chainTaskFrom:(MICPromix)parentTask to:(MICPromistic*)subTask {
    subTask
    .then_(^(id  _Nullable chainedResult, MICPromix  _Nonnull promix) {
        parentTask.resolve(chainedResult);
        promix.resolve(nil);
    })
    .failed(^(id _Nullable error) {
        parentTask.reject(error);
    })
    .ignite();
}

/**
 * parentTaskのサブタスクとしてsubTask（未着火）を追加して、着火する。
 * chainTaskFrom:to: とほぼ同じだが、failedのときも、成功として resolveするところだけ異なる。
 */
+ (void) chainTaskFrom:(MICPromix)parentTask toIgnoringTask:(MICPromistic*)subTask {
    subTask
    .then_(^(id  _Nonnull chainedResult, MICPromix  _Nonnull promix) {
        parentTask.resolve(chainedResult);
        promix.resolve(nil);
    })
    .failed(^(id  _Nonnull error) {
        parentTask.resolve(error);
    })
    .ignite();
}

- (MICPromistic*) addNextNode:(MICPromistic*) promistic {
    [self validateBeforeAddingNode];
    self.last->_next = promistic.first;
    promistic->_head = self.first;
    return promistic.last;
}

/**
 * then_ の中の人
 * 与えられたActionを持ったPromisticインスタンスを生成して、Promiseチェーンに追加する。
 */
- (MICPromistic*) addNextAction:(_Nullable MICPromisticAction) action {
    [self validateBeforeAddingNode];
    let node = [[MICPromistic alloc] initWithAction:action];
    return [self addNextNode:node];
}

/**
 * injectの中の人
 * 与えられた外部Promiseチェーンを、Promiseチェーンの末尾に追加する。
 */
//- (MICPromistic*) addNextPromise:(MICPromistic*) action {
//    [self validateBeforeAddingNode];
//    MICPromistic* head = self.first;
//    MICPromistic* p = action.first;
//    MICPromistic* last = nil;
//    self.last->_next = p;
//    // 追加されるPromisticチェーンのheadを付け替える
//    for(;p!=nil;p=p->_next) {
//        p->_head = head;
//        last = p;
//    }
//    return last;
//}

/**
 * then の中の人
 * 与えられたactionブロックによってチェーン燃焼中に動的に生成されるPromiseチェーンを内包可能なPromisticノードを生成し、Promiseチェーンの末尾に追加する。
 */
- (MICPromistic*) addNextChain:(MICPromisticChainAction) action {
    [self validateBeforeAddingNode];
    let node = [[MICPromistic alloc] initWithAction:^(id prev, MICPromix promix){
        MICPromistic* chain = action(prev);
        if(nil!=chain) {
            [MICPromistic chainTaskFrom:promix to:chain];
        } else {
            promix.resolve(prev);
        }
    }];
    return [self addNextNode:node];
}

/**
 * ignoreの中の人
 * actionが返すpromisticがrejectされても、resolveされたものとして扱う以外は、addNextChain
 */
- (MICPromistic*) addNextIgnoringChain:(MICPromisticChainAction) action {
    [self validateBeforeAddingNode];
    let node = [[MICPromistic alloc] initWithAction:^(id prev, MICPromix promix){
        MICPromistic* chain = action(prev);
        if(nil!=chain) {
            [MICPromistic chainTaskFrom:promix toIgnoringTask:chain];
        } else {
            promix.resolve(prev);
        }
    }];
    return [self addNextNode:node];
}

/**
 * failedの中の人
 * エラーハンドラノードをPromiseチェーンに追加する。
 */
- (MICPromistic*) addErrorHandler:(_Nullable MICPromisticErrorHandler) handler {
    let node = [[MICPromistic alloc] initWithErrorHandler:handler];
    return [self addNextNode:node];
}

/**
 * anywayの中の人
 * AnywayハンドラノードをPromiseチェーンに追加する。
 */
- (MICPromistic*) addAnywayHandler:(_Nullable MICPromisticAnywayHandler) handler {
    let node = [[MICPromistic alloc] initWithAnywayHandler:handler];
    return [self addNextNode:node];
}

/**
 * Promiseチェーンの先頭のノードを取得
 */
- (MICPromistic*) first {
    return (nil!=_head) ? _head : self;
}

/**
 * Promiseチェーンの末尾のノードを取得
 */
- (MICPromistic*) last {
    MICPromistic* p = self;
    while(nil!=p->_next) {
        p = p->_next;
    }
    return p;
}

/**
 * all/raceの中の人
 * 並列実行用Promisticノード（MICParallelPromistic）を生成して、Promiseチェーンの末尾に追加
 */
- (MICPromistic*) addNextParalells:(NSArray*) promistics race:(bool)race {
    let node = [[MICParallelPromistic alloc] initWithPromistics:promistics forRace:race];
    return [self addNextNode:node];
}


#pragma mark - 初期化・解放

/**
 * 参照を破棄する。
 *  ブロックを多用するので、なんやようしらんやつらがぶらさがってリークするのを回避。
 */
- (void) dispose {
//    NSLog(@"Promistic(%d):disposed", _tag);
    
    _action = nil;
    _errorHandler = nil;
    _anywayHandler = nil;
    _next = nil;
    _head = nil;
    
    _resolve = nil;
    _reject = nil;
    
    _then = nil;
    _then_ = nil;
    _failed = nil;

    _ignore = nil;
    _inject = nil;

    _all = nil;
    _race = nil;
    
    DEV_UNREG(self)
}

- (instancetype) initWithAction:(_Nullable MICPromisticAction)handler {
    return [self initWithAction:handler orErrorHandler:nil orAnywayHandler:nil];
}

- (instancetype) initWithErrorHandler:(_Nullable MICPromisticErrorHandler)handler {
    return [self initWithAction:nil orErrorHandler:handler orAnywayHandler:nil];
}

- (instancetype) initWithAnywayHandler:(_Nullable MICPromisticAnywayHandler)handler {
    return [self initWithAction:nil orErrorHandler:nil orAnywayHandler:handler];
}

/**
 * アクション or エラーハンドラを与えてPromiseチェーンのノードを作成
 * @private
 */
- (instancetype) initWithAction:(_Nullable MICPromisticAction)action orErrorHandler:(_Nullable MICPromisticErrorHandler)errorHandler orAnywayHandler:(_Nullable MICPromisticAnywayHandler) anywayHandler {
    self = [super init];
    if(nil!=self) {
        __weak MICPromistic* me = self;
        _head = nil;
        _tag = TAG_GENERATOR++;
        _burnt = false;
        _action = action;
        _errorHandler = errorHandler;
        _anywayHandler = anywayHandler;
        
        _resolve = ^(id result) {
            [me setResult:result];
        };
        _reject = ^(id error) {
            [me setError:error];
        };
        _then_ = ^MICPromistic* (MICPromisticAction nextAction) {
            return [me addNextAction:nextAction];
        };
//        _inject = ^MICPromistic* (MICPromistic* nextAction) {
//            return [me addNextPromise:nextAction];
//        };
        _then = ^MICPromistic* (MICPromisticChainAction nextAction) {
            return [me addNextChain:nextAction];
        };
        _ignore = ^MICPromistic* (MICPromisticChainAction nextAction) {
            return [me addNextIgnoringChain:nextAction];
        };
        _failed = ^MICPromistic* (MICPromisticErrorHandler handler) {
            return [me addErrorHandler:handler];
        };
        _anyway = ^MICPromistic* (MICPromisticAnywayHandler handler) {
            return [me addAnywayHandler:handler];
        };
        _all = ^MICPromistic* (NSArray* promistics) {
            return [me addNextParalells:promistics race:false];
        };
        _race = ^MICPromistic* (NSArray* promistics) {
            return [me addNextParalells:promistics race:true];
        };
        _ignite = ^() {
            [me.first execute:nil];
            return me.first;
        };
        //NSLog(@"Promistic(%d):allocated", _tag);
        DEV_REG(self)
    }
    return self;
}


/**
 * メモリリーク監視用にオーバーライド
 */
- (void)dealloc {
    DEV_FIN(self);
    // NSLog(@"Promistic(%d):dealloced", _tag);
}

#pragma mark - Promisticインスタンス生成

/**
 * 空のPromiseを作成
 * igniteメソッドが呼ばれない限り、自動的には実行されない。
 */
+ (instancetype) promistic {
    return [[MICPromistic alloc] initWithAction:nil];
}

/**
 * アクションを指定して Promiseを作成
 * igniteメソッドが呼ばれない限り、自動的には実行されない。
 */
+ (instancetype) promisticAction:(MICPromisticAction) action {
    return [[MICPromistic alloc] initWithAction:action];
}

/**
 * 着火するとすぐにresolveするPromisticインスタンスを生成
 */
+ (instancetype) promisticResolve {
    return MICPromistic.promistic;
}

/**
 * 着火するとすぐにresolveするPromisticインスタンスを生成
 * @param param    次のthenブロックに渡す値
 */
+ (instancetype) promisticResolveWithParam:(id) param {
    return [MICPromistic promisticAction:^(id  _Nullable chainedResult, MICPromix  _Nonnull promix) {
        promix.resolve(param);
    }];
}

/**
 * 着火するとすぐにrejectするPromisticインスタンスを生成
 */
+ (instancetype) promisticReject {
    return [MICPromistic promisticRejectWithError:nil];
}

/**
 * 着火するとすぐにrejectするPromisticインスタンスを生成
 * @param error エラー情報
 */
+ (instancetype) promisticRejectWithError:(id) error {
    return [MICPromistic promisticAction:^(id  _Nullable chainedResult, MICPromix  _Nonnull promix) {
        promix.reject(error);
    }];
}

@end

#pragma mark -

/**
 * 並列実行（all/race条件）をサポートするためのクラス
 * （内部クラス：利用者がこれを直接操作することはない）
 */
@implementation MICParallelPromistic {
    NSMutableArray* _aryPromistics;
    NSMutableArray* _aryResults;
    NSInteger _failed;
    NSInteger _succeeded;
    bool _race;
}

- (NSInteger) finished {
    return _succeeded + _failed;
}

- (bool) isCompleted {
    return self.finished == _aryPromistics.count;
}

/**
 * 初期化
 */
- (instancetype) initWithPromistics:(NSArray*)promistics forRace:(bool)race{
    self = [super initWithAction:nil];
    if(nil!=self) {
        _race = race;
        _succeeded = 0;
        _failed = 0;

        NSInteger count = _aryPromistics.count;
        _aryPromistics = [NSMutableArray arrayWithCapacity:count];  // 配列をコピーしていて、一見無駄に見えるが、promistics内のオブジェクトがリストの先頭を指しているとは限らないので、
                                                                    // あとから indexOfで探せるよう firstに正規化しておく。
        _aryResults = [NSMutableArray arrayWithCapacity:count];
        for(MICPromistic* px in promistics) {
            [_aryResults addObject:[NSNull null]];
            [_aryPromistics addObject:px.first];
        }
    }
    return self;
}

- (void) executeSingle:(MICPromistic*) po {
    po
    .then_(^(id  _Nullable chainedResult, MICPromix  _Nonnull promix) {
        [self onSingleTaskSucceeded:po withResult:chainedResult];
        promix.resolve(nil);
    })
    .failed(^(id  _Nullable error) {
        [self onSingleTaskFailed:po withError:error];
    })
    .ignite();
}

- (void) execute:(id)chainedResult {
    for(MICPromistic* po in _aryPromistics) {
        [self executeSingle:po];
    }
}

/**
 * タスクの実行が成功した時の処理
 */
- (void) onSingleTaskSucceeded:(MICPromistic*)promise withResult:(id)chainedResult {
    [self onSingleTaskCompleted:promise withResult:chainedResult resolved:true];
}

/**
 * タスクの実行が失敗した時の処理
 */
- (void) onSingleTaskFailed:(MICPromistic*)promise withError:(id) error {
    [self onSingleTaskCompleted:promise withResult:error resolved:false];
}

/**
 * 並列実行中の１つのタスク（＝Promiseチェーン）が終了したときの処理
 */
- (void) onSingleTaskCompleted:(MICPromistic*)promise withResult:(id)result resolved:(bool)resolved {
    bool completed = false;
    @synchronized (self) {
        if(resolved) {
            _succeeded++;
        } else {
            _failed++;
        }
        
        let index = [_aryPromistics indexOfObject:promise.first];
        let count = _aryPromistics.count;
        if(NSNotFound!=index&&index<count) {
            _aryResults[index] = (result!=nil) ? result : NSNull.null;
        }
        completed = self.isCompleted;
        // NSLog(@"count=%ld, isCompleted=%d", _aryPromistics.count, _aryPromistics.count == (_failed+_succeeded));
    }
    if(completed) {
        if((_race && _succeeded>0) || (!_race && _failed==0)) {
            [self setResult:_aryResults];
        } else {
            [self setError:_aryResults];
        }
        [_aryPromistics removeAllObjects];
    }
    // promise.resolve(nil);   // 結果は使われないはずだが、これをやっておかないと disposeされない。
}

/**
 * 並列処理開始用にオーバーライド
 */
//- (void)execute:(id)chainedResult {
//    for(MICPromistic* p in _aryPromistics) {
//        // thenブロックを指定して実行
//        p.last.then_(^(id chainedResult, MICPromix promix) {
//            [self onSingleTaskCompleted:(MICPromistic *)promix withResult:chainedResult];
//        }).failed(^(id error, MICPromiy promiy) {
//            [self onSingleTaskFailed:(MICPromistic *)promiy withError:chainedResult];
//        });
//        p.ignite();
//    }
//}

/**
 * 参照を破棄する。
 *  ブロックを多用するので、なんやようしらんやつらがぶらさがってリークするのを回避。
 */
- (void) dispose {
    [super dispose];
    _aryResults = nil;
    _aryPromistics = nil;
}

@end

#pragma mark -

/**
 * 非同期ノードの状態
 */
typedef enum _MICAsyncPromisticState {
    MICAsyncPromisticStateINIT,             // 初期化されたままの状態
    MICAsyncPromisticStateWAITING,          // ノードは executeされ、まだ、resolve/rejectされていない。
    MICAsyncPromisticStateRESOLVED,         // ノードは executeされる前に　resolveされている
    MICAsyncPromisticStateREJECTED,         // ノードは executeされる前に rejectされている
    MICAsyncPromisticStateFINISHING,        // ノードは executeされ、かつ、resolve/rejectされており、いままさに、setResult/setErrorを呼び出そうとしている。
    MICAsyncPromisticStateBURNT,            // ノードは すべての処理を終えて燃え尽きた。
} MICAsyncPromisticState;

@implementation MICAsyncPromistic {
    id _resultParam;
    MICAsyncPromisticState _asyncState;
}

/**
 * Promisticによる待ち合わせオブジェクトを取得
 * .NETのTaskCompletionSourceなどのように（待ち方はぜんぜん違うが）、Promisticな仕掛けで、スレッド間の待ち合わせになどに利用する。
 */
+ (MICAwaitabee) awaitable {
    return [[MICAsyncPromistic alloc] init];
}


/**
 * Promisticインスタンスを返す。
 * 待ち合わせ方は、主に３通り
 *  - 直接、then().ignit()で待つ
 *  - Promiseチェーンに inject
 *  - thenブロック内で、return awaitable.await; とする
 * 非同期処理側で、awaitable.resolve/rejectすることにより、上記Promisticチェーン内で処理が遷移する。
 */
- (MICPromistic *)await {
    return self;
}

/**
 * 初期化
 */
- (instancetype) init {
    self = [super initWithAction:^(id  _Nullable chainedResult, MICPromix  _Nonnull promix) {
        // empty
    }];
    if(nil!=self) {
        _resultParam = nil;
        _asyncState = MICAsyncPromisticStateINIT;
    }
    return self;
}

/**
 * Promiseチェーンに着火する。
 */
- (void) execute:(id)chainedResult {
    bool resolved = false;
    @synchronized (self) {
        switch(_asyncState) {
            case MICAsyncPromisticStateINIT:
                _asyncState = MICAsyncPromisticStateWAITING;   // reject/resolve待ち
                return;
            case MICAsyncPromisticStateRESOLVED:                // executeより前にresolveされている
                resolved = true;
                // fall through ...
            case MICAsyncPromisticStateREJECTED:                // executeより前にrejectされている
                _asyncState = MICAsyncPromisticStateFINISHING;
                break;
            case MICAsyncPromisticStateFINISHING:               // 多重呼び出しなど、やってはいけないことをやった。
            case MICAsyncPromisticStateWAITING:
            default:
                @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                               reason:[NSString stringWithFormat:@"MICAsyncPromistic: unexpected state on beginning task (%d).", self.tag]
                                             userInfo:nil];
        }
    }
    
    if(resolved) {
        [self setResult:_resultParam];
    } else {
        [self setError:_resultParam];
    }
}

/**
 * resolve()の処理の中身。
 * 次のPromiseをキックする
 */
- (void) setResult:(id)result {
    @synchronized (self) {
        switch(_asyncState) {
            case MICAsyncPromisticStateINIT:                    // execute前にresolveされた --> 保留
                _asyncState = MICAsyncPromisticStateRESOLVED;
                _resultParam = result;
                return;
            case MICAsyncPromisticStateWAITING:                 // execute後にresolveされた
            case MICAsyncPromisticStateFINISHING:               // execute経由で保留中の結果反映が要求された
                _asyncState = MICAsyncPromisticStateBURNT;
                break;
            case MICAsyncPromisticStateRESOLVED:
            case MICAsyncPromisticStateREJECTED:
            default:
                @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                               reason:[NSString stringWithFormat:@"MICAsyncPromistic: unexpected state on resolving task (%d).", self.tag]
                                             userInfo:nil];
        }
    }
    [super setResult:result];
}

/**
 *  reject()の中身
 *  errorHandlerを呼び出しながら、残りのPromiseを蹴散らす。
 */
- (void) setError:(id)error {
    @synchronized (self) {
        switch(_asyncState) {
            case MICAsyncPromisticStateINIT:                    // execute前にresolveされた --> 保留
                _asyncState = MICAsyncPromisticStateREJECTED;
                _resultParam = error;
                return;
            case MICAsyncPromisticStateWAITING:                 // execute後にresolveされた
            case MICAsyncPromisticStateFINISHING:               // execute経由で保留中の結果反映が要求された
                _asyncState = MICAsyncPromisticStateBURNT;
                break;
            case MICAsyncPromisticStateRESOLVED:
            case MICAsyncPromisticStateREJECTED:
            default:
                @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                               reason:[NSString stringWithFormat:@"MICAsyncPromistic: unexpected state on resolving task (%d).", self.tag]
                                             userInfo:nil];
        }
    }
    [super setError:error];
}

@end

