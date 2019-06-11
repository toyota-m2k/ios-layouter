//
//  MICQueue.m
//  AnotherWorld
//
//  Created by @toyota-m2k on 2018/11/21.
//  Copyright  2018年 @toyota-m2k. All rights reserved.
//

#import "MICQueue.h"

@implementation MICQueue {
    NSMutableArray* _array;
}

- (instancetype) init {
    self = [super init];
    if(nil!=self) {
        _array = [NSMutableArray array];
    }
    return self;
}

- (void)enque:(id)v {
    @synchronized (self) {
        [_array addObject:v];
    }
}

- (id)deque {
    @synchronized (self) {
        if(_array.count==0) {
            return nil;
        }
        id v = _array[0];
        [_array removeObjectAtIndex:0];
        return v;
    }
}

- (NSInteger) count {
    @synchronized (self) {
        return _array.count;
    }
}

- (void) removeAll {
    @synchronized (self) {
        [_array removeAllObjects];
    }
}
@end
