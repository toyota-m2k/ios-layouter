//
//  MICResetableEvent.m
//  AnotherWorld
//
//  Created by @toyota-m2k on 2018/11/06.
//  Copyright  2018年 @toyota-m2k. All rights reserved.
//

#import "MICResetableEvent.h"

@implementation MICAutoResetEvent {
    dispatch_semaphore_t _semaphore;
}

+ (instancetype)create {
    return [[MICAutoResetEvent alloc] initSignaled:false];
}

+ (instancetype)create:(bool)initialSignaled {
    return [[MICAutoResetEvent alloc] initSignaled:initialSignaled];
}

- (instancetype) init {
    return [self initSignaled:false];
}

- (instancetype) initSignaled:(bool)signaled {
    self = [super init];
    if(nil!=self) {
        _semaphore = dispatch_semaphore_create(0);
        if(signaled) {
            dispatch_semaphore_signal(_semaphore);
        }
    }
    return self;
}

- (void) dispose {
    if(nil!=_semaphore) {
        _semaphore = nil;
    }
}

- (void) set {
    dispatch_semaphore_signal(_semaphore);
}

- (void) waitOne {
    if(0==dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER)) {
    }
}

- (bool) waitOneFor:(dispatch_time_t) ms {
    if( 0 == dispatch_semaphore_wait(_semaphore, dispatch_time(DISPATCH_TIME_NOW, ms*NSEC_PER_MSEC)) ) {
        return true;
    }
    return false;
}

@end


@implementation MICManualResetEvent {
    bool _signaled;
    MICAutoResetEvent* _event;
}

- (instancetype) init {
    return [self initSignaled:false];
}

- (instancetype) initSignaled:(bool)signaled {
    self = [super init];
    if(nil!=self) {
        _signaled = signaled;
        _event = [MICAutoResetEvent create:false];
    }
    return self;
}

+ (instancetype) create:(bool) initialSignaled {
    return [[self alloc] initSignaled:initialSignaled];
}


- (void) waitOne {
    @synchronized(self) {
        if(_signaled) {
            return;
        }
    }
    
    [_event waitOne];
    @synchronized (self) {
        _signaled = true;
    }
}

- (bool) waitOneFor:(dispatch_time_t) ms {
    @synchronized(self) {
        if(_signaled) {
        }
    }
    
    if([_event waitOneFor:ms]) {
        @synchronized (self) {
            _signaled = true;
        }
        return true;
    } else {
        return false;
    }
}

- (void) set {
    @synchronized (self) {
        if(_signaled) {
            return;
        } else if(_event!=nil) {
            [_event set];
        }
        _signaled = true;
    }
}

- (void) reset {
    @synchronized (self) {
        if(!_signaled) {
            return;
        }
        _signaled = false;
    }
}


@end
