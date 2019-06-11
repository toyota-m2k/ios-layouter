//
//  MICAcom.m
//  AnotherWorld
//
//  Created by @toyota-m2k on 2018/11/21.
//  Copyright  2018年 @toyota-m2k. All rights reserved.
//

#import "MICAcom.h"
#import "MICQueue.h"
#import "MICResetableEvent.h"
#import "MICVar.h"

#pragma mark - 内部クラスの前方参照

@interface MICAcomWithAction : MICAcomResolverBase<IMICAcom>
+ (instancetype) create:(id<IMICAcom>(^)(_Nullable id chainedResult)) action;
@end

@interface MICAcomWithIgnoreAction : MICAcomWithAction
+ (instancetype) create:(id<IMICAcom>(^)(_Nullable id chainedResult)) action;
@end

@interface MICAcomWithRawAction : NSObject<IMICAcom>
+ (instancetype) create:(void (^)(_Nullable id chainedResult, MICAcomix acomix)) action;
@end

@interface MICAcomWithErrorHandler : NSObject<IMICAcom>{
    void (^_handler)(id _Nullable);
}
+ (instancetype) create:(void (^)(_Nullable id error)) action;
@end

@interface MICAcomWithAnywayHandler : MICAcomWithErrorHandler
+ (instancetype) create:(void (^)(_Nullable id error)) action;
@end

@interface MICAcomParallel : MICAcomResolverBase<IMICAcom>
+ (instancetype) create:(NSArray*)tasks race:(bool)race sequential:(bool)seq;
@end

@interface MICAcomResolve : NSObject<IMICAcom> {
    id _param;
}
+ (instancetype) createWithResult:(nullable id)result;
@end

@interface MICAcomReject : MICAcomResolve
+ (instancetype) createWithError:(nullable id)error;
@end

@interface MICLittleResolver : MICAcomResolverBase<IMICAcomResolver>
- (instancetype) initWithPromise:(id<IMICAcom>)promise owner:(MICAcomParallel*)owner;
@end


#pragma mark - MICAcom クラス

@implementation MICAcom {
    MICQueue* _taskQueue;
    MICAutoResetEvent* _drivingSignal;
    bool _burning;
    bool _resolving;
    id _chainedParam;
    MICAcomix _ownerAcomix;
}

#if true
+ (MICBackgroundExecutor)executor {
    return MICAsync.executor;
}
#else
static NSOperationQueue* sExecutor = nil;
+ (NSOperationQueue *)executor {
    if(nil==sExecutor) {
        sExecutor = [[NSOperationQueue alloc] init];
    }
    return sExecutor;
}
#endif

@synthesize then_ = _then_;
@synthesize then = _then;
@synthesize anyway = _anyway;
@synthesize failed = _failed;
@synthesize ignore = _ignore;
@synthesize all = _all;
@synthesize race = _race;
@synthesize seq = _seq;
@synthesize ignite = _ignite;

- (instancetype)init {
    self = [super init];
    if(nil!=self) {
        _taskQueue = [MICQueue new];
        _burning = false;
        _drivingSignal = [MICAutoResetEvent create:false];
        _resolving = true;
        _chainedParam = nil;
        _ownerAcomix = nil;
        
        __weak let me = self;
        _then = ^id<IMICAcomChain> (id<IMICAcom>(^action)(_Nullable id chainedResult)) {
            return [me addThenNode:action];
        };
        _ignore = ^id<IMICAcomChain> (id<IMICAcom>(^action)(_Nullable id chainedResult)) {
            return [me addIgnoreNode:action];
        };
        _then_ = ^id<IMICAcomChain> (void (^action)(_Nullable id chainedResult, MICAcomix acomix)) {
            return [me addRawThenNode:action];
        };
        _failed = ^id<IMICAcomChain> (void (^action)(_Nullable id error)) {
            return [me addFailedNode:action];
        };
        _anyway = ^id<IMICAcomChain> (void (^action)(_Nullable id param)) {
            return [me addAnywayNode:action];
        };
        _all = ^id<IMICAcomChain> (NSArray* tasks) {
            return [me addParallelNode:tasks race:false sequential:false];
        };
        _race  = ^id<IMICAcomChain> (NSArray* tasks) {
            return [me addParallelNode:tasks race:true sequential:false];
        };
        _seq  = ^id<IMICAcomChain> (NSArray* tasks) {
            return [me addParallelNode:tasks race:true sequential:true];
        };

        _ignite = ^() {
            [me executeBackground];
        };
    }
    return self;
}

- (void) dispose {
    [super dispose];
    [_taskQueue removeAll];
    _then = nil;
    _then_ = nil;
    _failed = nil;
    _all = nil;
    _race = nil;
    _ownerAcomix = nil;
    _chainedParam = nil;
    _drivingSignal = nil;
}

- (MICAcom*) addThenNode:(id<IMICAcom>(^)(_Nullable id chainedResult)) action {
    [_taskQueue enque:[MICAcomWithAction create:action]];
    return self;
}

- (MICAcom*)addIgnoreNode:(id<IMICAcom>(^)(_Nullable id chainedResult)) action {
    [_taskQueue enque:[MICAcomWithIgnoreAction create:action]];
    return self;
}

- (MICAcom*) addRawThenNode:(void (^)(_Nullable id chainedResult, MICAcomix acomix)) action {
    [_taskQueue enque:[MICAcomWithRawAction create:action]];
    return self;
}
- (MICAcom*) addFailedNode:(void (^)(_Nullable id error)) action {
    [_taskQueue enque:[MICAcomWithErrorHandler create:action]];
    return self;
}
- (MICAcom*) addAnywayNode:(void (^)(_Nullable id param)) action {
    [_taskQueue enque:[MICAcomWithAnywayHandler create:action]];
    return self;
}
- (MICAcom*) addParallelNode:(NSArray*) tasks race:(bool)race sequential:(bool)seq{
    [_taskQueue enque:[MICAcomParallel create:tasks race:race sequential:seq]];
    return self;
}

- (void)executeBackground:(nullable id)chainedResult acomix:(nullable id<IMICAcomResolver>)acomix {
    if(_burning) {
        if(nil!=acomix) {
            acomix.reject(chainedResult);
        }
        return;
    }
    
    _burning = true;
    _ownerAcomix = acomix;
    _chainedParam = chainedResult;
    
    [MICAcom.executor execute:^{
        [self beginToDrive];
    }];
}

- (void)executeBackground {
    [self executeBackground:nil acomix:nil];
}

- (void)execute:(bool)resolving chainResult:(nullable id)result acomix:(nullable MICAcomix)acomix {
    [MICAsync assertSubThread];
    
    if(_burning||!resolving) {
        if(nil!=acomix) {
            acomix.reject(result);
        }
        return;
    }
    
    _burning = true;
    _ownerAcomix = acomix;
    _chainedParam = result;
    
    [self beginToDrive];
}

- (void) beginToDrive {
    while( _taskQueue.count > 0) {
        id<IMICAcom> task = [_taskQueue deque];
        if(nil!=task) {
            [task execute:_resolving chainResult:_chainedParam acomix:self];
            [_drivingSignal waitOne];
        }
    }
    [_ownerAcomix complete:_resolving withParam:_chainedParam];
    [self dispose];
}

- (void)complete:(bool)resolved withParam:(id)param {
    _chainedParam = param;
    if(!resolved) {
        _resolving = false;
    }
    [_drivingSignal set];
}

+ (instancetype)promise {
    return [[MICAcom alloc] init];
}

+ (instancetype)promise:(MICPromise) promise {
    if([promise isKindOfClass:MICAcom.class]) {
        return (MICAcom*)promise;
    } else {
        return (MICAcom*)[MICAcom new].then(^MICPromise _Nonnull(id  _Nullable chainedResult) {
            return promise;
        });
    }
}

+ (id<IMICAcom>)resolve {
    static MICAcomResolve* r = nil;
    if(nil==r) {
        r = [MICAcomResolve createWithResult:nil];
    }
    return r;
}

+ (id<IMICAcom>)resolve:(id)param {
    if(nil==param) {
        return self.resolve;
    }
    return [MICAcomResolve createWithResult:param];
}

+ (id<IMICAcom>)reject {
    static MICAcomReject* r = nil;
    if(nil==r) {
        r = [MICAcomReject createWithError:nil];
    }
    return r;
}

+ (id<IMICAcom>)reject:(id)param {
    if(nil==param) {
        return self.reject;
    }
    return [MICAcomReject createWithError:param];
}

+ (MICPromise)action:(void (^)(id _Nullable, MICAcomix _Nonnull))action {
    return [MICAcomWithRawAction create:action];
}

+ (void) beginAsync:(id<IMICAcomFlammable>) promise {
    [promise executeBackground];
}

- (nonnull id<IMICAwaiter>)awaiter {
    let task = [MICTaskAwaiter new];
    self
    .then(^id<IMICAcom> _Nonnull(id  _Nullable chainedResult) {
        [task setResult:chainedResult];
        return nil;
    })
    .failed(^(id error) {
        [task setError:(nil!=error)?error:@"something wrong"];
    });
    
    if(NSThread.isMainThread) {
        self.ignite();
    } else {
        [self execute:true chainResult:nil acomix:nil];
    }
    return task;
}

+ (id<IMICAcom>)promiseWithAwaiter:(MICAwaiter)awaiter {
    return [MICAsyncAwaiterAcom promise:awaiter];
}

@end

#pragma mark - IMICAcom：thenブロック用（アクション付き）

@implementation MICAcomWithAction {
    MICAcomix _ownerAcomix;
    id<IMICAcom>(^_action)(_Nullable id chainedResult);
}

- (instancetype) initWithAction:(id<IMICAcom>(^)(_Nullable id chainedResult)) action {
    self = [super init];
    if(nil!=self) {
        _ownerAcomix = nil; // lateinit
        _action = action;
    }
    return self;
}

+ (instancetype) create:(id<IMICAcom>(^)(_Nullable id chainedResult)) action {
    return [[MICAcomWithAction alloc] initWithAction:action];
}

- (void)execute:(bool)resolving chainResult:(id)result acomix:(MICAcomix)acomix {
    _ownerAcomix = acomix;
    if(resolving&&nil!=_action) {
        let p = _action(result);
        if(nil!=p) {
            [p execute:true chainResult:nil acomix:self];
            return;
        }
    }
    [self complete:resolving withParam:result];
}

- (void)complete:(bool)resolved withParam:(id)param {
    [_ownerAcomix complete:resolved withParam:param];
}

- (void) dispose {
    _action = nil;
    _ownerAcomix = nil;
}


@end

     
#pragma mark - IMICAcom：ignoreブロック用（アクション付き）
     
 @implementation MICAcomWithIgnoreAction {
 }
 
 + (instancetype) create:(id<IMICAcom>(^)(_Nullable id chainedResult)) action {
     return [[MICAcomWithIgnoreAction alloc] initWithAction:action];
 }
 
 - (void)complete:(bool)resolved withParam:(id)param {
     [super complete:true withParam:param];
 }
 
 @end

#pragma mark - IMICAcom：then_ブロック用（手動アクション付き）

@implementation MICAcomWithRawAction {
    void (^_action)(id _Nullable, MICAcomix);
}

- (instancetype) initWithAction:(void (^)(id _Nullable, MICAcomix)) action {
    self = [super init];
    if(nil!=self) {
        _action = action;
    }
    return self;
}

+ (instancetype)create:(void (^)(id _Nullable, MICAcomix))action {
    return [[MICAcomWithRawAction alloc] initWithAction:action];
}

- (void)execute:(bool)resolving chainResult:(id)result acomix:(MICAcomix)acomix {
    if(resolving && nil!=_action) {
        _action(result, acomix);
    } else {
        [acomix complete:resolving withParam:result];
    }
    [self dispose];
}

- (void) dispose {
    _action = nil;
}

@end

#pragma mark - IMICAcom：failedブロック用

@implementation MICAcomWithErrorHandler

- (instancetype)initWithHandler:(void (^)(id _Nullable))action {
    self = [super init];
    if(nil!=self) {
        _handler = action;
    }
    return self;
}

+ (instancetype)create:(void (^)(id _Nullable))action {
    return [[MICAcomWithErrorHandler alloc] initWithHandler:action];
}

- (void)execute:(bool)resolving chainResult:(id)result acomix:(MICAcomix)acomix {
    if(!resolving && nil!=_handler) {
        _handler(result);
    }
    [acomix complete:resolving withParam:result];
}

@end


#pragma mark - IMICAcom：anywayブロック用

@implementation MICAcomWithAnywayHandler

+ (instancetype)create:(void (^)(id _Nullable))action {
    return [[MICAcomWithAnywayHandler alloc] initWithHandler:action];
}

- (void)execute:(bool)resolving chainResult:(id)result acomix:(MICAcomix)acomix {
    if(nil!=_handler) {
        _handler(result);
    }
    [acomix complete:resolving withParam:result];
}

@end

#pragma mark - IMICAcom: resolve用

@implementation MICAcomResolve

+ (instancetype)createWithResult:(id)result {
    return [[MICAcomResolve alloc] initWithResult:result];
}

- (instancetype) initWithResult:(nullable id) result {
    self = [super init];
    if(nil!=self) {
        _param = result;
    }
    return self;
}

- (void)execute:(bool)resolving chainResult:(id)result acomix:(MICAcomix)acomix {
    acomix.resolve(_param);
}

@end

#pragma mark - IMICAcom: reject用

@implementation MICAcomReject

+ (instancetype)createWithError:(id)error {
    return [[MICAcomReject alloc] initWithResult:error];
}

- (void) execute:(bool)resolving chainResult:(id)result acomix:(MICAcomix)acomix {
    acomix.reject(_param);
}

@end


#pragma mark - IMICAcom: 並列処理用

@implementation MICAcomParallel {
    NSArray* _aryPromise;
    bool _race;
    bool _seq;
    MICAcomix _ownerAcomix;

    NSMutableArray* _aryResults;
    NSInteger _failed;
    NSInteger _succeeded;
}

- (bool) isCompleted {
    return _succeeded + _failed == _aryPromise.count;
}

- (instancetype)initWithTasks:(NSArray*)aryPromise race:(bool)race sequencial:(bool)seq {
    self = [super init];
    if(nil!=self) {
        _aryPromise = aryPromise;
        _race = race;
        _seq = seq;
        _ownerAcomix = nil;
        _aryResults = [NSMutableArray arrayWithCapacity:aryPromise.count];
        for(int i=0, ci=(int)aryPromise.count ; i<ci ; i++) {
            [_aryResults addObject:NSNull.null];
        }
        _failed = 0;
        _succeeded = 0;
    }
    return self;
}

+ (instancetype)create:(NSArray *)tasks race:(bool)race sequential:(bool)seq {
    return [[MICAcomParallel alloc] initWithTasks:tasks race:race sequencial:seq];
}

- (void)execute:(bool)resolving chainResult:(id)result acomix:(MICAcomix)acomix {
    _ownerAcomix = acomix;
    if(resolving && _aryPromise.count>0) {
        for(id p in _aryPromise) {
            var littleAcomix = [[MICLittleResolver alloc] initWithPromise:p owner:self];
            if(!_seq && [p conformsToProtocol:@protocol(IMICAcomFlammable)]) {
                [p executeBackground:result acomix:littleAcomix];
            } else {
                [p execute:resolving chainResult:result acomix:littleAcomix];
            }
        }
    } else {
        [acomix complete:resolving withParam:result];
    }
}

- (void)complete:(bool)resolved withParam:(id)param {
    [_ownerAcomix complete:resolved withParam:param];
}

- (bool) handleResult:(id<IMICAcom>)promise resolving:(bool)resolving result:(nullable id)result checkFinishing:(bool(^)(void)) checkFinishing {
    @synchronized (self) {
        if(resolving) {
            _succeeded++;
        } else {
            _failed++;
        }
        let index = [_aryPromise indexOfObject:promise];
        let count = _aryPromise.count;
        if(NSNotFound!=index && index<count) {
            _aryResults[index] = (result==nil) ? NSNull.null : result;
        }
        return checkFinishing();
    }
}

- (void) onSingleRaceTaskFinished:(id<IMICAcom>)promise resolving:(bool)resolving result:(nullable id)result {
    if([self handleResult:promise resolving:resolving result:result checkFinishing:^bool{
        return self->_succeeded==1 || self.isCompleted;
    }]) {
        [self complete:resolving withParam:result];
    }
}

- (void) onSingleTaskFinished:(id<IMICAcom>)promise resolving:(bool)resolving result:(nullable id)result {
    if(_race) {
        [self onSingleRaceTaskFinished:promise resolving:resolving result:result];
        return;
    }
    
    if([self handleResult:promise resolving:resolving result:result checkFinishing:^bool{
        return self.isCompleted;
    }]) {
        [self complete:_failed==0 withParam:_aryResults];
    }
}

@end

@implementation MICLittleResolver {
    id<IMICAcom> _promise;
    MICAcomParallel* _owner;
}

- (instancetype) initWithPromise:(id<IMICAcom>)promise owner:(MICAcomParallel*)owner{
    self = [super init];
    if(nil!=self) {
        _promise = promise;
        _owner = owner;
    }
    return self;
}

- (void)complete:(bool)resolved withParam:(nullable id)param {
    [_owner onSingleTaskFinished:_promise resolving:resolved result:param];
    [self dispose];
}

- (void) dispose {
    [super dispose];
    _owner = nil;
    _promise = nil;
}

@end

@implementation MICAcomResolverBase

@synthesize resolve = _resolve;
@synthesize reject = _reject;

- (instancetype) init {
    self = [super init];
    __weak let me = self;
    if(nil!=self) {
        _resolve = ^void (_Nullable id result) {
            [me complete:true withParam:result];
        };
        _reject = ^void (_Nullable id error) {
            [me complete:false withParam:error];
        };
    }
    return self;
}

- (void)complete:(bool)resolved withParam:(nullable id)param {
    NSAssert(false, @"must be overridden");
}

- (void) dispose {
    _resolve = nil;
    _reject = nil;
}

@end

@implementation MICAsyncAwaiterAcom {
    MICAwaiter _awaiter;
}


- (instancetype)initWithAwaiter:(MICAwaiter) awaiter {
    self = [super init];
    if(nil!=self) {
        _awaiter = awaiter;
    }
    return self;
}

+ (instancetype)promise:(MICAwaiter)awaiter {
    return [[self alloc] initWithAwaiter:awaiter];
}

- (void)execute:(bool)resolving chainResult:(nullable id)result acomix:(nullable MICAcomix)acomix {
    let r = _awaiter.await;
    [acomix complete:r.error==nil withParam:r.result];
}

@end
