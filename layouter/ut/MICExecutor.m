//
//  MICExecutor.m
//  Anytime
//
//  Created by @toyota-m2k on 2018/12/01.
//  Copyright  2018年 @toyota-m2k Corporation. All rights reserved.
//

#import "MICExecutor.h"

@interface MICOperationQueueExecutor : NSObject<IMICBackgroundExecutor>

@end

@implementation MICOperationQueueExecutor {
    NSOperationQueue* _operationQueue;
}

- (void)execute:(nonnull void (^)(void))runnable {
    [_operationQueue addOperationWithBlock:runnable];
}

- (instancetype) init {
    self = [super init];
    if(self!=nil) {
        _operationQueue = [[NSOperationQueue alloc] init];
        _operationQueue.name = @"MICOperationQueueExecutor";
    }
    return self;
}

@end

@interface MICGCDExecutor : NSObject<IMICBackgroundExecutor>

@end

@implementation MICGCDExecutor {
    dispatch_queue_t _queue;
}

- (void)execute:(void (^)(void))runnable {
    dispatch_async(_queue, runnable);
}

- (instancetype) initUsingGlobal:(bool)useGlobal {
    self = [super init];
    if(self!=nil) {
        if(useGlobal){
            _queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        } else {
            _queue = dispatch_queue_create("com.@toyota-m2k.MICGCDExecutor", DISPATCH_QUEUE_CONCURRENT);
        }
    }
    return self;
}


@end

@interface MICRawThread : NSThread
@property (nonatomic) void(^runnable)(void);
@end
@implementation MICRawThread

- (void)main {
    if(nil!=_runnable) {
        _runnable();
        _runnable = nil;
    }
}

- (instancetype)initWithRunnable:(void(^)(void)) runnable {
    self = [super init];
    if(nil!=self) {
        _runnable = runnable;
        self.name = @"com.@toyota-m2k.MICRawThread";
    }
    return self;
}

@end

@interface MICRawThreadExecutor : NSObject<IMICBackgroundExecutor>

@end

@implementation MICRawThreadExecutor

- (void)execute:(nonnull void (^)(void))runnable {
    MICRawThread* th = [[MICRawThread alloc] initWithRunnable:runnable];
    [th start];
}

@end

@implementation MICExecutorFactory

+ (MICBackgroundExecutor)executor:(MICExecutorType)type {
    switch(type) {
        case MICExecutorOPRATION_QUEUE:
            return [[MICOperationQueueExecutor alloc] init];
        case MICExecutorGCD_GLOBAL:
            return [[MICGCDExecutor alloc] initUsingGlobal:true];
        case MICExecutorGCD_PRIVATE:
            return [[MICGCDExecutor alloc] initUsingGlobal:false];
        case MICExecutorRAW:
            return [[MICRawThreadExecutor alloc] init];
    }
}

+ (MICBackgroundExecutor) executor {
    return [self executor:MICExecutorGCD_PRIVATE];
}
@end

