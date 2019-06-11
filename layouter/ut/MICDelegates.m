//
//  MICDelegates.m
//  LayoutDemo
//
//  Created by @toyota-m2k on 2014/12/22.
//  Copyright (c) 2014年 @toyota-m2k. All rights reserved.
//

#import "MICDelegates.h"

@implementation MICDelegateObject

- (instancetype)initWithObject:(id)delegate {
    self = [super init];
    if(nil!=self) {
        _delegate = delegate;
    }
    return self;
}

@end

@implementation MICDelegates {
    NSMutableArray* _ary;
}

- (instancetype)init{
    self = [super init];
    if(nil!=self) {
        _ary = [[NSMutableArray alloc] init];
    }
    return self;
}

- (int)count {
    return (int)_ary.count;
}

- (int)indexOfDelegate:(id)delegate {
    int i = 0;
    for(MICDelegateObject* obj in _ary) {
        if(obj.delegate == delegate) {
            return i;
        }
        i++;
    }
    return -1;
}

- (void)add:(id)delegate {
    if([self indexOfDelegate:delegate]>=0) {
        return;
    }
    
    id obj = [[MICDelegateObject alloc] initWithObject:delegate];
    if(nil!=obj) {
        [_ary addObject:obj];
    }
}

- (void)remove:(id)delegate {
    int i = [self indexOfDelegate:delegate];
    if(i>=0) {
        [_ary removeObjectAtIndex:i];
    }
}

- (void)clean {
    for(int i=((int)_ary.count)-1 ; i>=0 ; i--) {
        if(nil==((MICDelegateObject*)_ary[i]).delegate) {
            [_ary removeObjectAtIndex:i];
        }
    }
}

- (void)invoke:(void (^)(id))func {
    for(MICDelegateObject* d in _ary) {
        if(nil!=d.delegate) {
            func(d.delegate);
        }
    }
}

@end
