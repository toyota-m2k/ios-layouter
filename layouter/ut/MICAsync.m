//
//  MICAsync.m
//  AnotherWorld
//
//  Created by @toyota-m2k on 2018/11/22.
//  Copyright  2018年 @toyota-m2k. All rights reserved.
//

#import "MICAsync.h"
#import "MICResetableEvent.h"
#import "MICAcom.h"
#import "MICVar.h"
#import "MICExecutor.h"

//----------------------------------------------------------------------------------------------------

@implementation MICTaskAwaiter {
    MICManualResetEvent* _event;
    bool _finished;
}

@synthesize error = _error;
@synthesize result = _result;
@synthesize completed = _completed;

- (instancetype)init {
    self = [super init];
    if(nil!=self) {
        _event = [MICManualResetEvent create:false];
        _error = _result = nil;
        _completed = nil;
        _finished = false;
    }
    return self;
}

- (void) finish:(id)result error:(id)error {
    MICAwaiterCompleteHandler callback = nil;
    @synchronized (self) {
        if(_finished) {
            return;
        }
        _finished = true;
        _result = result;
        _error = error;
        callback = _completed;
    }
    
    [_event set];
    
    if(nil!=callback) {
        [MICAsync mainThreadAsync:^{
            callback(self->_result, self->_error);
        }];
    }
}

- (void)setError:(nonnull id)error {
    [self finish:nil error:error];
}

- (void)setResult:(id)result {
    [self finish:result error:nil];
}

- (nonnull id<IMICAwaiterResult>)await {
    MIC_ASSERT_SUB_THREAD;
    [_event waitOne];
    return self;
}

- (id)getError {
    MIC_ASSERT_SUB_THREAD;
    [_event waitOne];
    return _error;
}

- (id)getResult {
    MIC_ASSERT_SUB_THREAD;
    [_event waitOne];
    return _result;
}

- (void)setCompleted:(MICAwaiterCompleteHandler)callback {
    bool call = false;
    @synchronized (self) {
        _completed = callback;
        call = _finished;
    }
    if(call) {
        // コールバック関数を設定しようとした時点で、すでにタスクが終了している場合は、ここでコールバックしてしまう。
        [MICAsync mainThreadAsync:^{
            callback(self->_result, self->_error);
        }];
    }
}

- (bool)isCompleted {
    @synchronized (self) {
        return _finished;
    }
}

- (id<IMICAwaiter>)awaiter {
    return self;
}
@end

//----------------------------------------------------------------------------------------------------

@implementation MICCompletedAwaiter

@synthesize error = _error;
@synthesize result = _result;
@synthesize completed = _completed;

- (instancetype)init {
    self = [super init];
    if(nil!=self) {
        _error = _result = nil;
        _completed = nil;
    }
    return self;
}

+ (instancetype) result:(id) result {
    let r = [MICCompletedAwaiter new];
    [r setResult:result];
    return r;
}

+ (instancetype) error:(nonnull id) error {
    let r = [MICCompletedAwaiter new];
    [r setError:error];
    return r;
}

- (void)setError:(nonnull id)error {
    _error = error;
}

- (void)setResult:(nullable id)result {
    _result = result;
}

- (nonnull id<IMICAwaiterResult>)await {
    return self;
}

- (id)getError {
    return _error;
}

- (id)getResult {
    return _result;
}

- (bool)isCompleted {
    return true;
}

- (id<IMICAwaiter>)awaiter {
    return self;
}

@end

//----------------------------------------------------------------------------------------------------

@interface MICAwaiterResultImpl : NSObject<IMICAwaiterResult>
@end
@implementation MICAwaiterResultImpl

@synthesize error = _error;
@synthesize result = _result;

- (instancetype) initWithResult:(id)result error:(id)error {
    self = [super init];
    if(nil!=self) {
        _error = error;
        _result = result;
    }
    return self;
}


+ (instancetype) error:(id)error {
    return [[MICAwaiterResultImpl alloc] initWithResult:nil error:error];
}

+ (instancetype) result:(id)result {
    return [[MICAwaiterResultImpl alloc] initWithResult:result error:nil];
}
@end

//----------------------------------------------------------------------------------------------------

@implementation MICAsync

+ (MICBackgroundExecutor)executor {
    static MICBackgroundExecutor sExecutor = nil;
    if(nil==sExecutor) {
        sExecutor = [MICExecutorFactory executor];
    }
    return sExecutor;
}

+ (id<IMICAwaiterResult>) await:(id) target {
    [self validate];
    if([target conformsToProtocol:@protocol(IMICAwaitable) ]) {
        return [(id<IMICAwaitable>)target awaiter].await;
    } else if ([target conformsToProtocol:@protocol(IMICAcom)]) {
        return [MICAcom promise:target].awaiter.await;
    } else {
        return [MICAwaiterResultImpl result:target];
    }
    
}

+ (bool) validate {
    if(NSThread.isMainThread) {
        NSAssert(false, @"must be called in sub-thread.");
        return false;
    }
    return true;
}

+ (MICAwaiter)async:(id<IMICAwaiterResult> _Nonnull (^)(MICAwaitProc await))blockableAction {
    let task = [MICTaskAwaiter new];
    MICAwaitProc await = ^id<IMICAwaiterResult> (id target) {
        return [MICAsync await:target];
    };
    
    [self.executor execute:^{
        id<IMICAwaiterResult> r = blockableAction(await);
        [task finish:r.result error:r.error];
    }];
    return task;
}

+ (void)assertSubThread {
    [self validate];
}

+ (void) mainThread:(void(^)(void)) action {
    if(NSThread.isMainThread) {
        action();
    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            action();
        });
    }
}

+ (id) mainThreadFunc:(id(^)(void)) func {
    if(NSThread.isMainThread) {
        return func();
    } else {
        __block id r = nil;
        dispatch_sync(dispatch_get_main_queue(), ^{
            r = func();
        });
        return r;
    }
}

+ (void) mainThreadAsync:(void(^)(void)) action {
    if(NSThread.isMainThread) {
        action();
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            action();
        });
    }
}

+ (id<IMICAwaiterResult>) resultError:(id)error {
    return [MICAwaiterResultImpl error:error];
}
+ (id<IMICAwaiterResult>) resultSuccess:(nullable id)result {
    return [MICAwaiterResultImpl result:result];
}

@end
